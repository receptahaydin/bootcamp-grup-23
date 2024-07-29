import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripDetailsPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  bool _isEditing = false;
  Map<String, List<String>> _selectedActivities = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    widget.trip['selectedActivities'].forEach((category, items) {
      _selectedActivities[category] = List<String>.from(items);
    });
  }

  Future<void> _updateTripInFirestore() async {
    if (user != null) {
      await _firestore.collection('trips').doc(widget.trip['tripId']).update({
        'selectedActivities': _selectedActivities,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip['city']),
        backgroundColor: const Color(0xffea4335),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              setState(() {
                if (_isEditing) {
                  _updateTripInFirestore();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.trip['cityImage'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.trip['cityImage'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                "${widget.trip['startDate']} - ${widget.trip['endDate']} (${widget.trip['days']} gün, ${widget.trip['tripType']})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4285f4),
                ),
              ),
              const SizedBox(height: 24),
              _buildPackingList(widget.trip['selectedActivities']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackingList(Map<String, List<String>> packingList) {
    return Column(
      children: packingList.entries.map((entry) {
        final category = entry.key;
        final items = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff34a853),
                ),
              ),
            ),
            Column(
              children: items.map((item) {
                final isSelected =
                    _selectedActivities[category]?.contains(item) ?? false;
                return _isEditing
                    ? CheckboxListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            decoration: isSelected
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedActivities[category]!.add(item);
                            } else {
                              _selectedActivities[category]!.remove(item);
                            }
                          });
                        },
                        secondary: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : null,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                        child: Text(
                          '- $item',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}
