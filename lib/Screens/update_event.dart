import 'package:campus_updates/Models/club.dart';
import 'package:campus_updates/Models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateEvent extends StatefulWidget {
  const UpdateEvent({super.key, required this.event, required this.userRole});
  final Event event;
  final String userRole;

  @override
  State<UpdateEvent> createState() {
    return _UpdateEventState();
  }
}

class _UpdateEventState extends State<UpdateEvent> {

  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  var enteredTitle;
  var enteredDescription;
  var enteredClub = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final initialDt = widget.event.date;
    final initialDate = DateTime(initialDt.year, initialDt.month, initialDt.day);
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    var pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _presentTimePicker() async {
    final initialDt = widget.event.date;
    var pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: initialDt.hour, minute: initialDt.minute),
    );

    setState(() {
      _selectedTime = pickedTime;
      _selectedTime ??= TimeOfDay(hour: initialDt.hour, minute: initialDt.minute);
    });
  }

  DateTime mergeDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
  
  Future<Filters?> _selectCategoryPopup() async {
    Filters? _selectedFilter = widget.event.club.type;
    return showDialog<Filters>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Club category not defined"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text("Technical"),
                    leading: Radio<Filters>(
                      value: Filters.technical,
                      groupValue: _selectedFilter,
                      onChanged: (Filters? value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Cultural"),
                    leading: Radio<Filters>(
                      value: Filters.cultural,
                      groupValue: _selectedFilter,
                      onChanged: (Filters? value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Sports"),
                    leading: Radio<Filters>(
                      value: Filters.sports,
                      groupValue: _selectedFilter,
                      onChanged: (Filters? value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedFilter);
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

    _addClub(String clubName, Filters category) async {
    try {
      final clubsCollection = FirebaseFirestore.instance.collection('clubs');
      final querySnapshot = await clubsCollection
          .where('clubname', isEqualTo: clubName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await clubsCollection.add({
          'clubname': clubName,
          'category': category.toString().split('.').last, 
        });
      }
    } catch (error) {
      print('Error adding club: $error');
      rethrow;
    }
  }

  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      
      final initialDt = widget.event.date;
      final initialDate = DateTime(initialDt.year, initialDt.month, initialDt.day);
      _selectedDate ??= initialDate;
      _selectedTime ??= TimeOfDay(hour: initialDt.hour, minute: initialDt.minute);

      if (mergeDateAndTime(_selectedDate!, _selectedTime!).isBefore(DateTime.now())) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Invalid input'),
            content: const Text('Please make sure a valid Date and Time were entered'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isSending = true;
      });

      final DateTime mergedDateTime = mergeDateAndTime(_selectedDate!, _selectedTime!);
      Filters selectedCategory = widget.event.club.type; 

      try {
        final clubsCollection = FirebaseFirestore.instance.collection('clubs');

        if (widget.userRole == 'admin') {
          enteredClub = enteredClub.toLowerCase();
        } else {
          enteredClub = widget.userRole.toLowerCase();
        }

        final clubsSnapshot = await clubsCollection
            .where('clubname', isEqualTo: enteredClub)
            .limit(1)
            .get();

        if (clubsSnapshot.docs.isNotEmpty) {
          final String stringCategory = clubsSnapshot.docs.first['category'];
          selectedCategory = Filters.values.firstWhere(
            (filter) => filter.toString().split('.').last == stringCategory,
            orElse: () => widget.event.club.type, 
          );
        } else {
          if (widget.userRole == 'admin') {
            selectedCategory = widget.event.club.type;
          } else {
            Filters? userSelectedCategory = await _selectCategoryPopup();
            if (userSelectedCategory != null) {
              selectedCategory = userSelectedCategory;
            } else {
              print("User did not select a category. Defaulting to previous type.");
              selectedCategory = widget.event.club.type;
            }
          }
          await _addClub(enteredClub, selectedCategory);
        }
        final eventRef = FirebaseFirestore.instance.collection('events').doc(widget.event.id);

        await eventRef.update({
          'title': enteredTitle,
          'clubname': enteredClub,
          'datetime': Timestamp.fromDate(mergedDateTime), 
          'description': enteredDescription,
          'registeredUsers':  [],
        });

        if (!context.mounted) return;

        Navigator.of(context).pop(
          Event(
            id: widget.event.id, 
            title: enteredTitle,
            date: mergedDateTime,
            club: Club(name: enteredClub, type: selectedCategory),
            description: enteredDescription,
            registeredUsers: [],
          ),
        );
      } catch (error) {
        print('Error saving event: $error');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save event. Please try again.\n\n$error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _deleteEvent(Event event) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);
    try {
      await eventRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $error')),
      );
    }
  }


  @override
    Widget build(BuildContext context) {
    Filters selectedCategory = widget.event.club.type;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Event"),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 4,
        actions: [
          if (widget.userRole != 'guest')
            IconButton(
              onPressed:
                () async {
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
                  _deleteEvent(widget.event);
                  if (mounted){
                    Navigator.of(context).pop();
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 225, 142, 136)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: "Event Name",
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      counterText: '',
                    ),
                    initialValue: widget.event.title,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 2 ||
                          value.trim().length > 60) {
                        return 'Must be between 2 and 60 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredTitle = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (widget.userRole == 'admin')
                        Expanded(
                          child: TextFormField(
                            maxLength: 20,
                            decoration: InputDecoration(
                              labelText: "Club Name",
                              labelStyle: Theme.of(context).textTheme.bodyMedium,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                              counterText: '',
                            ),
                              initialValue: widget.event.club.name,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 2 ||
                                  value.trim().length > 20) {
                                return 'Must be between 2 and 20 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredClub = value!.toLowerCase();
                            },
                          ),
                        ),
                      if (widget.userRole == 'admin')
                        const SizedBox(width: 10),
                      if (widget.userRole == 'admin')
                        Expanded(
                          child: DropdownButtonFormField(
                            value: selectedCategory,
                            items: const [
                              DropdownMenuItem(
                                value: Filters.technical,
                                child: Text("Technical"),
                              ),
                              DropdownMenuItem(
                                value: Filters.cultural,
                                child: Text("Cultural"),
                              ),
                              DropdownMenuItem(
                                value: Filters.sports,
                                child: Text("Sports"),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Category",
                              labelStyle: Theme.of(context).textTheme.bodyMedium,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                          ),
                        ],
                      ),
                  if (widget.userRole == 'admin')
                    const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _presentDatePicker,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? DateFormat.yMMMd().format(DateTime(widget.event.date.year, widget.event.date.month, widget.event.date.day))
                                : DateFormat.yMMMd().format(_selectedDate!),
                             style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _presentTimePicker,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? TimeOfDay(hour: widget.event.date.hour, minute: widget.event.date.minute).format(context)
                                : _selectedTime!.format(context),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 5,
                    maxLength: 300,
                    decoration: InputDecoration(
                      labelText: "Event Description",
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      counterText: "",
                    ),
                    initialValue: widget.event.description,
                    onSaved: (value) {
                      enteredDescription = value ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSending ? null : _updateItem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Update Item'),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

}