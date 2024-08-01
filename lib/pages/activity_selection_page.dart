import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivitySelectionPage extends StatefulWidget {
  final String city;
  final String startDate;
  final String endDate;
  final String tripType;
  final String? cityImage;
  final Map<String, List<String>> activitiesAndPacking;

  const ActivitySelectionPage({
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    this.cityImage,
    required this.activitiesAndPacking,
  });

  @override
  _ActivitySelectionPageState createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage>
    with SingleTickerProviderStateMixin {
  Map<String, List<String>> _selectedActivities = {};
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _selectedActivities = Map.from(widget.activitiesAndPacking);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveTripToFirestore() async {
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('trips')
          .add({
        'city': widget.city,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'tripType': widget.tripType,
        'days': DateTime.parse(widget.endDate)
                .difference(DateTime.parse(widget.startDate))
                .inDays +
            1,
        'selectedActivities': _selectedActivities,
        'cityImage': widget.cityImage,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gezi Planı"),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          tabs: [
            Tab(text: "Valiz"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPackingList(widget.activitiesAndPacking),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            await _saveTripToFirestore();
            Navigator.pop(context, {
              'city': widget.city,
              'startDate': widget.startDate,
              'endDate': widget.endDate,
              'tripType': widget.tripType,
              'days': DateTime.parse(widget.endDate)
                      .difference(DateTime.parse(widget.startDate))
                      .inDays +
                  1,
              'selectedActivities': _selectedActivities,
              'cityImage': widget.cityImage,
            });
          },
          child: const Text(
            "Gezi Oluştur",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackingList(Map<String, List<String>> packingList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: packingList.entries.map((entry) {
          final category = entry.key;
          final items =
              entry.value.where((item) => item.trim().isNotEmpty).toList();

          if (items.isEmpty) {
            return SizedBox.shrink();
          }

          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ExpansionTile(
              title: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              children: items.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: _selectedActivities[category]?.contains(item) ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedActivities[category] ??= [];
                        _selectedActivities[category]!.add(item);
                      } else {
                        _selectedActivities[category]?.remove(item);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
