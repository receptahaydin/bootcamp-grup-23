import 'package:flutter/material.dart';

class TripDetailsPage extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip['city']),
        backgroundColor: Color(0xffea4335), // Google Kırmızısı
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trip['cityImage'] != null)
                ClipRRect(
                  // Yuvarlatılmış köşeler için
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(trip['cityImage']!),
                ),
              SizedBox(height: 20),
              Text(
                "${trip['startDate']} - ${trip['endDate']} (${trip['days']} gün, ${trip['tripType']})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4285f4), // Google Mavisi
                ),
              ),
              SizedBox(height: 24),
              ..._buildPackingList(trip['selectedActivities']),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPackingList(Map<String, List<String>> packingList) {
    List<Widget> widgets = [];

    packingList.forEach((category, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff34a853), // Google Yeşili
            ),
          ),
        ),
      );
      widgets.addAll(
        items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Text(
                '- $item',
                style: TextStyle(fontSize: 16),
              ),
            )),
      );
    });

    return widgets;
  }
}
