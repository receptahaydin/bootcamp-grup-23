import 'package:flutter/material.dart';

class ActivitySelectionPage extends StatefulWidget {
  final String city;
  final String startDate;
  final String endDate;
  final String tripType;
  final List<String> activities;

  const ActivitySelectionPage({
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    required this.activities,
  });

  @override
  _ActivitySelectionPageState createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  List<String> _selectedActivities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktiviteleri Seç"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widget.activities.map((activity) {
            return CheckboxListTile(
              title: Text(activity),
              value: _selectedActivities.contains(activity),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedActivities.add(activity);
                  } else {
                    _selectedActivities.remove(activity);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'city': widget.city,
              'startDate': widget.startDate,
              'endDate': widget.endDate,
              'tripType': widget.tripType,
              'days': DateTime.parse(widget.endDate)
                      .difference(DateTime.parse(widget.startDate))
                      .inDays +
                  1,
              'activities': _selectedActivities,
            });
          },
          child: const Text("Gezi Oluştur"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
