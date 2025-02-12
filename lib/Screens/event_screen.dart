import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Future<void> _eventFuture;
  late bool isRegistered;
  int registeredNumber = 0;
  List<String> eventRegisteredUsers = [];
  String eventTitle = '', eventDescription = '', eventClubName = '';
  DateTime? eventDate;

  @override
  void initState() {
    super.initState();
    _eventFuture = loadEvent();
  }

  Future<void> loadEvent() async {
    try {
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.eventId);
      final eventDoc = await eventRef.get();

      if (eventDoc.exists) {
        setState(() {
          eventDate = (eventDoc['datetime'] as Timestamp).toDate();
          eventTitle = eventDoc['title'];
          eventDescription = eventDoc['description'];
          eventClubName = eventDoc['clubname'];
          eventRegisteredUsers = List<String>.from(eventDoc['registeredUsers']);
          isRegistered = eventRegisteredUsers.contains(FirebaseAuth.instance.currentUser?.uid);
          registeredNumber = eventRegisteredUsers.length;
        });
      }
    } catch (error) {
      print("Error fetching event details: $error");
    }
  }

  Future<void> registerForEvent(String userId) async {
    final eventRef =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);

    await eventRef.update({
      'registeredUsers': FieldValue.arrayUnion([userId]),
    });

    setState(() {
      isRegistered = true;
      registeredNumber += 1;
    });
  }

  Future<void> unregisterFromEvent(String userId) async {
    final eventRef =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId);

    await eventRef.update({
      'registeredUsers': FieldValue.arrayRemove([userId]),
    });

    setState(() {
      isRegistered = false;
      registeredNumber -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading event details",
                    style: GoogleFonts.poppins(fontSize: 18)));
          }
          if (eventDate == null) {
            return Center(
                child: Text("Event not found",
                    style: GoogleFonts.poppins(fontSize: 18)));
          }

          String formattedDate = DateFormat.yMd().format(eventDate!);
          String formattedTime = DateFormat.Hm().format(eventDate!);
          Duration difference = eventDate!.difference(DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium!.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  eventClubName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                const Divider(color: Colors.grey, height: 30, thickness: 1),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Starts: $formattedDate at $formattedTime",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  eventDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 8),
                Text(
                  difference.inHours > 24
                      ? "The event starts in ${difference.inDays} day(s)"
                      : difference.inHours > 1
                          ? "The event starts in ${difference.inHours} hour(s)"
                          : difference.inMinutes > 0
                              ? "The event starts in ${difference.inMinutes} minute(s)"
                              : "The event expired",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          if (isRegistered) {
                            await unregisterFromEvent(user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Unregistered from $eventTitle')),
                            );
                          } else {
                            await registerForEvent(user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Registered for $eventTitle')),
                            );
                          }
                        }
                      },
                      child: Text(isRegistered ? 'Unregister' : 'Register'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Registered: $registeredNumber people",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
