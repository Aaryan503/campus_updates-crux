
import 'package:flutter/material.dart';
import 'package:campus_updates/Screens/event_screen.dart';
import 'package:campus_updates/Screens/filters.dart';
import 'package:campus_updates/Widgets/drawer.dart';
import 'package:campus_updates/Screens/add_event.dart';
import 'package:campus_updates/Models/club.dart';
import 'package:campus_updates/Models/event.dart';
import 'package:campus_updates/providers/filters_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Filter;
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, filteredevents});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _error;
  bool _isLoading = false;
  String userRole = '';
  List<Event> eventsList = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _getUserRole();
  }

  void _loadItems() async {
    _isLoading = true;
    final eventsCollection = FirebaseFirestore.instance.collection('events');
    final clubsCollection = FirebaseFirestore.instance.collection('clubs');

    try {
      final eventsSnapshot = await eventsCollection.get();
      final clubsSnapshot = await clubsCollection.get();

      if (!mounted) return;
      if (eventsSnapshot.docs.isEmpty || clubsSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<Event> loadedItems = [];
      final Map<String, Club> clubsmap = {};
      for (final clubDoc in clubsSnapshot.docs) {
        final clubData = clubDoc.data();
        final String clubName = clubData['clubname'].toLowerCase();

        final String categoryStr = clubData['category'];
        final Filters category = Filters.values.firstWhere(
          (filter) => filter.toString().split('.').last == categoryStr,
          orElse: () => Filters.technical, 
        );

        clubsmap[clubName] = Club(name: clubName, type: category);
      }
      List<String> pastEventIds = [];
      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final clubName = eventData['clubname'].toLowerCase();
        final associatedClub = clubsmap[clubName];

        final Timestamp eventTimestamp = eventData['datetime']; 
        final DateTime eventDate = eventTimestamp.toDate();

        if (DateTime.now().isBefore(eventDate) && associatedClub != null) {
          loadedItems.add(
            Event(
              id: eventDoc.id,
              title: eventData['title'],
              club: associatedClub,
              date: eventDate,
              description: eventData['description'],
            ),
          );
        } else {
          pastEventIds.add(eventDoc.id);
        }
      }
      for (String id in pastEventIds) {
        await eventsCollection.doc(id).delete();
      }

      loadedItems.sort((a,b) => a.date.compareTo(b.date));

      if (loadedItems.isNotEmpty) {
        loadedItems.removeLast();
      }

      if (!mounted) return;
      setState(() {
        eventsList = loadedItems;
        _isLoading = false;
      });

    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }


  void _addItem() async {
    _isLoading = true;
    final newItem = await Navigator.of(context).push<Event>(
      MaterialPageRoute(
        builder: (ctx) => NewEvent(userRole: userRole,),
      ),
    );

    if (newItem == null || !mounted) {
      return;
    }

    setState(() {
      eventsList.add(newItem);
      _isLoading = false;
    });
  }

  void _openDetails(String eventName, String clubName, DateTime datetime,
      String description) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EventDetailsScreen(
          eventName: eventName,
          clubName: clubName,
          datetime: datetime,
          description: description,
        ),
      ),
    );
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => const FiltersScreen(),
        ),
      );
    }
  }

   _getUserRole() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        if(mounted){
          setState(() {
          userRole = userDoc['role'];
          _isLoading = false; 
          
        });
        }
      } else {
        if(mounted) {
          setState(() {
          userRole = 'guest';
          _isLoading = false;
        });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
        _isLoading = false;
      });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user role: $error')),
      );
    }
  }

  void _deleteEvent(Event event) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);

    final index = eventsList.indexOf(event);
    setState(() {
      eventsList.removeAt(index);
    });

    try {
      await eventRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (error) {
      setState(() {
        eventsList.insert(index, event);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = ref.watch(filtersProvider);
    final filteredEvents = eventsList.where((Event event) {
      if (activeFilters[Filter.technical]! &&
          event.club.type == Filters.technical) {
        return true;
      }
      if (activeFilters[Filter.cultural]! &&
          event.club.type == Filters.cultural) {
        return true;
      }
      if (activeFilters[Filter.sports]! && 
      event.club.type == Filters.sports) {
        return true;
      }
      return false;
    }).toList();
    filteredEvents.sort((a,b) => a.date.compareTo(b.date));

    Widget content = Center(
        child: Text(
      'No events to display.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    ));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      content = Center(
          child: Text(
        _error!,
        style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: Colors.red, fontSize: 16),
      ));
    }

    if (filteredEvents.isNotEmpty) {
      content = ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (ctx, index) => Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Theme.of(context).cardColor,
          child: ListTile(
            title: Text(
              filteredEvents[index].title,
              style: GoogleFonts.roboto(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodySmall?.color,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _openDetails(
                filteredEvents[index].title,
                filteredEvents[index].club.name,
                filteredEvents[index].date,
                filteredEvents[index].description,
              );
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Text(
                filteredEvents[index].club.name[0].toUpperCase(),
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            subtitle: Text(
              "${filteredEvents[index].club.name[0].toUpperCase()}${filteredEvents[index].club.name.substring(1).toLowerCase()}",
              style: GoogleFonts.roboto(fontSize: 14, color:Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.2)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.yMd().format(filteredEvents[index].date),
                      style: GoogleFonts.roboto(fontSize: 14, color: Theme.of(context).textTheme.bodySmall!.color,),
                    ),
                    Text(
                      DateFormat.Hm().format(filteredEvents[index].date),
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),),
                    ),
                  ],
                ),
                if (userRole.toUpperCase() == filteredEvents[index].club.name.toUpperCase() || userRole == 'admin')
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text('Are you sure you want to delete this event?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        _deleteEvent(filteredEvents[index]);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Color.fromARGB(255, 225, 142, 136)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Campus Updates")),
        actions: [
          if (userRole != 'guest')
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      drawer: FilterDrawer(onSelectScreen: _setScreen),
      body: content,
    );
  }
}
