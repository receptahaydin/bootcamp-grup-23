import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bootcamprojeai/pages/activity_selection_page.dart'; // Gerekli import

class AddTripPage extends StatefulWidget {
  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  List<String> _cities = [];
  String _selectedCity = '';
  DateTimeRange? _selectedDateRange;
  String _tripType = 'Tatil';
  int _days = 0;
  bool _isLoading = false;

  final String apiKey =
      'secretkey'; // API anahtarını buraya ekleyin

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    final response =
        await http.get(Uri.parse('https://turkiyeapi.dev/api/v1/provinces'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cities = List<String>.from(data['data'].map((city) => city['name']));
        _selectedCity = _cities.first;
      });
    } else {
      throw Exception('Şehirler yüklenirken bir hata oluştu.');
    }
  }

  void _calculateDays() {
    if (_selectedDateRange != null) {
      setState(() {
        _days = _selectedDateRange!.end
                .difference(_selectedDateRange!.start)
                .inDays +
            1;
      });
    }
  }

  Future<Map<String, List<String>>> _generateActivities() async {
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final prompt =
        '$_selectedCity şehrine $_tripType amaçlı seyahat için ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} ile ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)} tarihleri arasında yapılacak aktivite türleri öner. Kategorilere göre listele: Konaklama, Taşımacılık, Etkinlikler / Öğeler. Örnek:\n\n```\n{\n  "Konaklama": [\n    "Otel",\n    "Kiralık",\n    "Arkadaşlar/Aile",\n    "İkinci ev",\n    "Kamp yapmak",\n    "Seyir"\n  ],\n  "Taşımacılık": [\n    "Uçak",\n    "Araba",\n    "Tren",\n    "Motosiklet",\n    "Tekne",\n    "Otobüs"\n  ],\n  "Etkinlikler / Öğeler": [\n    "Gerekli",\n    "Giyisi",\n    "Tuvalet kiti",\n    "Çalışma",\n    "Golf",\n    "Koşu",\n    "Resmi akşam yemeği",\n    "Yüzme havuzu",\n    "Uluslararası",\n    "Fotoğrafçılık",\n    "Kış sporları",\n    "Plaj",\n    "Yürüyüş"\n  ]\n}\n```';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    // String'i JSON'a parse etme
    final Map<String, dynamic> jsonResponse =
        json.decode(response.text ?? '{}');

    // Map<String, List<String>> türüne dönüştürme
    final Map<String, List<String>> activities = jsonResponse.map((key, value) {
      return MapEntry(key, List<String>.from(value));
    });

    return activities;
  }

  void _navigateToActivitySelection() async {
    if (_selectedCity.isNotEmpty && _selectedDateRange != null) {
      setState(() {
        _isLoading = true;
      });
      final activities = await _generateActivities();
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivitySelectionPage(
            city: _selectedCity,
            startDate:
                DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
            endDate: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
            tripType: _tripType ?? '',
            activities: activities,
          ),
        ),
      ).then((result) {
        if (result != null) {
          Navigator.pop(context, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Gezi"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cities.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text("Tek Destinasyon"),
                        selected: true,
                        onSelected: (_) {},
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: Text("Birden Fazla Varış Yeri"),
                        selected: false,
                        onSelected: (_) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCity = newValue!;
                      });
                    },
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: "Varış yeri",
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _selectedDateRange == null
                          ? "Tarih Aralığı Seçin"
                          : "${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}",
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      DateTimeRange? pickedDateRange =
                          await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        initialDateRange: DateTimeRange(
                          start: DateTime.now(),
                          end: DateTime.now().add(Duration(days: 7)),
                        ),
                      );
                      if (pickedDateRange != null) {
                        setState(() {
                          _selectedDateRange = pickedDateRange;
                          _calculateDays();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$_days gün",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: Column(
                          children: [
                            Icon(Icons.business, size: 24),
                            Text("İş"),
                          ],
                        ),
                        selected: _tripType == 'İş',
                        onSelected: (bool selected) {
                          setState(() {
                            _tripType = 'İş';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Column(
                          children: [
                            Icon(Icons.beach_access, size: 24),
                            Text("Tatil"),
                          ],
                        ),
                        selected: _tripType == 'Tatil',
                        onSelected: (bool selected) {
                          setState(() {
                            _tripType = 'Tatil';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _navigateToActivitySelection,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Aktiviteleri Seç"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
