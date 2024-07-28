import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bootcamprojeai/pages/add_trip_page.dart';
import 'package:bootcamprojeai/pages/login_page.dart';
import 'package:bootcamprojeai/pages/trip_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> trips = [];

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _addTrip(Map<String, dynamic> trip) async {
    setState(() {
      trips.add(trip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gezilerim"),
        backgroundColor: Color(0xffea4335), // Google Kırmızısı
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Hizalamayı başlangıca alın
          children: [
            SizedBox(height: 20),
            Center(
              // Butonu ortalamak için Center widget'ı kullanın
              child: _buildAddTripButton(),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  trips.isEmpty ? _buildEmptyTripMessage() : _buildTripList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTripButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTripPage(),
          ),
        );

        if (result != null) {
          _addTrip(result);
        }
      },
      icon: Icon(Icons.add, color: Colors.white),
      label: Text("Yeni Gezi Ekle", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff34a853), // Google Yeşili
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyTripMessage() {
    return Center(
      child: Text(
        "Henüz gezi eklenmedi.",
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: Icon(
              trip['tripType'] == 'İş' ? Icons.business : Icons.beach_access,
              color: Color(0xfffbbc04), // Google Sarısı
              size: 32,
            ),
            title: Text(
              trip['city'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "${trip['startDate']} - ${trip['endDate']} (${trip['days']} gün)",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(trip: trip),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
