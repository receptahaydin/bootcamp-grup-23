import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String phoneNumber = '';
  String profilePictureUrl = '';
  String address = '';
  String bio = '';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdditionalUserInfo();
  }

  Future<void> _fetchAdditionalUserInfo() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          phoneNumber = userDoc['phoneNumber'] ?? '';
          profilePictureUrl = userDoc['profilePictureUrl'] ?? '';
          address = userDoc['address'] ?? '';
          bio = userDoc['bio'] ?? '';

          _phoneController.text = phoneNumber;
          _addressController.text = address;
          _bioController.text = bio;
        });
      }
    }
  }

  Future<void> _saveAdditionalUserInfo() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).set({
        'displayName': user!.displayName ?? 'Belirtilmemiş',
        'email': user!.email ?? 'Belirtilmemiş',
        'phoneNumber': _phoneController.text,
        'profilePictureUrl': profilePictureUrl,
        'address': _addressController.text,
        'bio': _bioController.text,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgileri'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user != null
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profilePictureUrl.isNotEmpty)
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profilePictureUrl),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                        'Kullanıcı Adı', user!.displayName ?? 'Belirtilmemiş'),
                    const SizedBox(height: 16),
                    _buildInfoCard('Email', user!.email ?? 'Belirtilmemiş'),
                    const SizedBox(height: 16),
                    _buildInfoCard('Kullanıcı ID', user!.uid),
                    const SizedBox(height: 16),
                    _buildEditableInfoCard(
                        'Telefon Numarası', _phoneController),
                    const SizedBox(height: 16),
                    _buildEditableInfoCard('Adres', _addressController),
                    const SizedBox(height: 16),
                    _buildEditableInfoCard('Biyografi', _bioController,
                        maxLines: 3),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveAdditionalUserInfo();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bilgiler kaydedildi')),
                        );
                      },
                      child: const Text('Bilgileri Kaydet'),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Text('Kullanıcı bilgileri bulunamadı.'),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard(String title, TextEditingController controller,
      {int maxLines = 1}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
