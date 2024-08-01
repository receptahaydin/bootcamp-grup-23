import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String phoneNumber = '';
  String profilePictureUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png'; // Default profile picture URL
  String gender = 'Belirtilmemiş'; // Default gender value
  bool _isEditing = false;
  List<String> trips = [];
  String selectedTrip = '';
  List<String> memories = [];

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _memoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdditionalUserInfo();
  }

  Future<void> _fetchAdditionalUserInfo() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            phoneNumber = userDoc['phoneNumber'] ?? '';
            profilePictureUrl =
                userDoc['profilePictureUrl'] ?? profilePictureUrl;
            gender = userDoc['gender'] ?? 'Belirtilmemiş';
            trips = List<String>.from(userDoc['trips'] ?? []);
            selectedTrip = trips.isNotEmpty ? trips.first : '';
            memories = List<String>.from(userDoc['memories'] ?? []);

            _phoneController.text = phoneNumber;
          });
        }
      } catch (e) {
        print("Error fetching user info: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Kullanıcı bilgileri alınırken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _saveAdditionalUserInfo() async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user!.uid).set({
          'displayName': user!.displayName ?? 'Belirtilmemiş',
          'email': user!.email ?? 'Belirtilmemiş',
          'phoneNumber': _phoneController.text,
          'profilePictureUrl': profilePictureUrl,
          'gender': gender,
          'trips': trips,
          'memories': memories,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil bilgileri başarıyla güncellendi')),
        );
      } catch (e) {
        print("Error saving user info: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Profil bilgileri güncellenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String fileName = 'profile_pictures/${user!.uid}.png';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          profilePictureUrl = downloadUrl;
        });

        await _firestore.collection('users').doc(user!.uid).update({
          'profilePictureUrl': profilePictureUrl,
        });

        await _saveAdditionalUserInfo();
      } catch (e) {
        print("Image upload error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  void _addMemory() {
    if (selectedTrip.isNotEmpty && _memoryController.text.isNotEmpty) {
      setState(() {
        memories.add('Trip: $selectedTrip, Memory: ${_memoryController.text}');
        _memoryController.clear();
      });
      _saveAdditionalUserInfo();
    }
  }

  void _addTrip() {
    TextEditingController tripController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Gezi Ekle'),
          content: TextField(
            controller: tripController,
            decoration: const InputDecoration(labelText: 'Gezi Adı'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (tripController.text.isNotEmpty) {
                  setState(() {
                    trips.add(tripController.text);
                    if (selectedTrip.isEmpty) {
                      selectedTrip = tripController.text;
                    }
                  });
                  Navigator.of(context).pop();
                  _saveAdditionalUserInfo();
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgileri'),
        backgroundColor: const Color(0xffea4335),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _saveAdditionalUserInfo();
                }
              });
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: user != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(profilePictureUrl),
                      ),
                      if (_isEditing)
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepPurple,
                          child: IconButton(
                            onPressed: _pickAndUploadImage,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // User Info
                  _buildInfoCard(
                      'Kullanıcı Adı', user!.displayName ?? 'Belirtilmemiş'),
                  const SizedBox(height: 16),
                  _buildInfoCard('Email', user!.email ?? 'Belirtilmemiş'),
                  const SizedBox(height: 16),
                  _buildEditableInfoCard(
                      'Telefon Numarası', _phoneController, _isEditing),
                  const SizedBox(height: 16),
                  _buildGenderCard('Cinsiyet', _isEditing),
                  const SizedBox(height: 24),

                  // Trip and Memory Section
                  _buildTripsSection(),
                  const SizedBox(height: 24),
                  _buildMemorySection(),

                  const SizedBox(height: 32),
                ],
              )
            : const Center(
                child: Text('Kullanıcı bilgileri bulunamadı.'),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoCard(
      String title, TextEditingController controller, bool isEditing,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: isEditing,
          decoration: InputDecoration(
            fillColor: isEditing ? Colors.white : Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            if (title == 'Telefon Numarası') {
              phoneNumber = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenderCard(String title, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (isEditing)
          DropdownButton<String>(
            value: gender,
            items: <String>['Belirtilmemiş', 'Erkek', 'Kız']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                gender = newValue!;
              });
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              gender,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geziler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedTrip,
                items: trips.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTrip = newValue!;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTrip,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Anı Defteri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _memoryController,
          decoration: const InputDecoration(
            labelText: 'Anı Ekle',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _addMemory,
          child: const Text('Anı Ekle'),
        ),
        const SizedBox(height: 16),
        ...memories.map((memory) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(memory),
            )),
      ],
    );
  }
}
