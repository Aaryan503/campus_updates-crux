import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventName;
  final String clubName;
  final DateTime datetime;
  final String description;

  const EventDetailsScreen({
    super.key,
    required this.eventName,
    required this.clubName,
    required this.datetime,
    required this.description,

  });


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMd().format(datetime).toString();
    String formattedTime = DateFormat.Hm().format(datetime).toString();
    Duration difference = datetime.difference(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Details",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium!.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              clubName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 30,
              thickness: 1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
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
              description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10,),
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
          ],
        ),
      ),
    );
  }
}
