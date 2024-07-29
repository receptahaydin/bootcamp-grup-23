import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bootcamprojeai/pages/add_trip_page.dart';
import 'package:bootcamprojeai/pages/login_page.dart';
import 'package:bootcamprojeai/pages/trip_details_page.dart';
import 'package:bootcamprojeai/pages/profile_page.dart'; // Profil sayfası import
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> trips = [];
  List<Map<String, dynamic>> lists = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadLists();
  }

  Future<void> _loadTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('trips')) {
      setState(() {
        trips = (json.decode(prefs.getString('trips')!) as List)
            .map((trip) => trip as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _loadLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('lists')) {
      setState(() {
        lists = (json.decode(prefs.getString('lists')!) as List)
            .map((list) => list as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _saveTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('trips', json.encode(trips));
  }

  Future<void> _saveLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lists', json.encode(lists));
  }

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
    _saveTrips();
  }

  Future<void> _createNewList(String listName) async {
    setState(() {
      lists.add({'name': listName, 'items': []});
    });
    _saveLists();
  }

  Future<void> _deleteTrip(int index) async {
    setState(() {
      trips.removeAt(index);
    });
    _saveTrips();
  }

  void _showCreateListDialog() {
    final TextEditingController _listNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Liste Oluştur"),
          content: TextField(
            controller: _listNameController,
            decoration: const InputDecoration(
              labelText: "Liste Adı",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                final listName = _listNameController.text;
                if (listName.isNotEmpty) {
                  _createNewList(listName);
                  Navigator.pop(context);
                }
              },
              child: const Text("Oluştur"),
            ),
          ],
        );
      },
    );
  }

  void _showListDetails(Map<String, dynamic> list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailsPage(list: list),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gezilerim"),
        backgroundColor: const Color(0xffea4335),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: _buildAddTripButton(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: trips.isEmpty
                  ? _buildEmptyTripMessage()
                  : Column(
                      children: [
                        Expanded(child: _buildTripList()),
                        const SizedBox(height: 16),
                        const Text(
                          'Listelerim',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _buildListSection(),
                        ),
                      ],
                    ),
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

        if (result != null && mounted) {
          _addTrip(result);
        }
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label:
          const Text("Yeni Gezi Ekle", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff34a853),
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
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.list, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // Sağa kaydırma, yeni liste oluştur
              _showCreateListDialog();
            } else if (direction == DismissDirection.endToStart) {
              // Sola kaydırma, geziyi sil
              _deleteTrip(index);
            }
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(trip: trip),
                ),
              ).then((value) {
                if (value != null && value is Map<String, dynamic>) {
                  // TripDetailsPage'den gelen güncellenmiş veriyi al
                  setState(() {
                    trips[index] = value;
                  });
                  _saveTrips(); // Güncellenmiş gezileri kaydet
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      trip['cityImage'] ?? 'https://via.placeholder.com/150',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip['city'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${trip['startDate']} - ${trip['endDate']}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(
                      trip['tripType'] == 'İş'
                          ? Icons.work
                          : Icons.beach_access,
                      color: const Color(0xfffbbc04),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListSection() {
    return lists.isEmpty
        ? const Center(
            child: Text('Henüz bir liste oluşturulmadı.'),
          )
        : ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return ListTile(
                title: Text(list['name']),
                onTap: () => _showListDetails(list),
              );
            },
          );
  }
}

class ListDetailsPage extends StatelessWidget {
  final Map<String, dynamic> list;

  const ListDetailsPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list['name']),
      ),
      body: Center(
        child: Text("Liste Detayları"),
      ),
    );
  }
}
