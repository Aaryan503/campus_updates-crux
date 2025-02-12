import 'package:campus_updates/Models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_updates/Models/club.dart';

class NewEvent extends StatefulWidget {
  const NewEvent({super.key,required this.userRole});
  final String userRole;

  @override
  State<NewEvent> createState() {
    return _NewEventState();
  }
}

class _NewEventState extends State<NewEvent> {
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;
  var enteredTitle = '';
  var enteredClub = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Filters selectedCategory = Filters.technical;
  var enteredDescription = '';


  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _presentTimePicker() async {
    var pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;
    setState(() {
      _selectedTime = pickedTime;
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
    Filters? _selectedFilter = Filters.technical;
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

void _saveItem() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    if (_selectedDate == null || _selectedTime == null ||
        mergeDateAndTime(_selectedDate!, _selectedTime!).isBefore(DateTime.now())) {
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
          orElse: () => Filters.technical, 
        );
      } else {
        if (widget.userRole == 'admin') {
          selectedCategory = Filters.technical;
        } else {
          Filters? userSelectedCategory = await _selectCategoryPopup();
          if (userSelectedCategory != null) {
            selectedCategory = userSelectedCategory;
          } else {
            print("User did not select a category. Defaulting to Technical.");
            selectedCategory = Filters.technical;
          }
        }
        await _addClub(enteredClub, selectedCategory);
      }
      final eventRef = FirebaseFirestore.instance.collection('events');

      final newEvent = await eventRef.add({
        'title': enteredTitle,
        'clubname': enteredClub,
        'datetime': Timestamp.fromDate(mergedDateTime), 
        'description': enteredDescription,
        'registeredUsers':  [],
      });

      if (!context.mounted) return;

      Navigator.of(context).pop(
        Event(
          id: newEvent.id, 
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

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Event"),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 4,
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
                      counterText: "",
                    ),
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
                              counterText: "",
                            ),
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
                                ? 'Select Date'
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
                                ? 'Select Time'
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
                                _formKey.currentState!.reset();
                              },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
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
                            : const Text('Add Item'),
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