import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:Bavul/pages/activity_selection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gif/gif.dart'; // gif paketi eklendi

class AddTripPage extends StatefulWidget {
  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin eklendi
  List<String> _cities = [];
  String _selectedCity = '';
  DateTimeRange? _selectedDateRange;
  String _tripType = 'Tatil';
  int _days = 0;
  bool _isLoading = false;
  late GifController _gifController; // GifController eklendi
  OverlayEntry? _loadingOverlayEntry;
  String _weatherInfo = "";
  IconData _weatherIcon = Icons.wb_sunny;
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String apiKey =
      ''; // API anahtarını buraya ekleyin

  final Map<String, List<Map<String, String>>> _cityImages = {
    'Adana': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6c283fe2-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Adıyaman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2b9d58e8-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Afyon': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/23ed7aee-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Ağrı': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2ded7aee-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Amasya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d402a7f4-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Ankara': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/39e50110-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Antalya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b4577816-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Artvin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/efe1c31c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Aydın': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4116e022-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Balıkesir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b6ab6a36-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bilecik': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/0dd3973c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bingöl': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/546aaa56-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bitlis': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d7833a5d-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bolu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f1833a5d-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Burdur': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/96304163-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bursa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/0ecc4769-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Çanakkale': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/20cc4769-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Çankırı': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/eba9dc7c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Çorum': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8f0e9291-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Denizli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3d0abb97-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Diyarbakır': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4b0abb97-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Edirne': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/c14a129e-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Elazığ': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d44a129e-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Erzincan': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d84639a4-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Erzurum': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e04639a4-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Eskişehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/9d6868aa-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Gaziantep': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/71798ab0-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Giresun': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7f798ab0-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Gümüşhane': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/5647d1b6-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Hakkari': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6d47d1b6-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Hatay': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/15d48fbd-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Isparta': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/20d48fbd-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Mersin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f7ce2ac5-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'İstanbul': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/00cf2ac5-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'İzmir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7a5841cb-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kars': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/865841cb-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kastamonu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/ea7584d1-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kayseri': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f47584d1-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kırklareli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a2aa283e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kırşehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/33ac5544-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kocaeli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/45ac5544-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Konya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f76f504a-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kütahya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6152d056-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Malatya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6952d056-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Manisa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7ccad35c-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kahramanmaraş': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/c1f07363-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Mardin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/caf07363-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Muğla': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8b0b7f69-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Muş': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/920b7f69-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Nevşehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/665bea6f-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Niğde': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3c29ea75-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Ordu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4b29ea75-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Rize': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/9a4bf17b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Sakarya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/43050682-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Samsun': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/cc143688-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Siirt': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/dd8c588e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Sinop': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e68c588e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Sivas': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8abe1195-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Tekirdağ': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/99be1195-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Tokat': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d3f8209b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Trabzon': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/dcf8209b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Tunceli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e0831aa1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Şanlıurfa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e9831aa1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Uşak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/65dc19a7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Van': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/21d108bb-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Yozgat': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2cd108bb-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Zonguldak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/1c513ec2-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Aksaray': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2e513ec2-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bayburt': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/aac638c8-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Karaman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b1c638c8-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kırıkkale': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a2b46fce-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Batman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a7b46fce-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Şırnak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8ddf76d4-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Bartın': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/97df76d4-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Ardahan': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3934eada-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Iğdır': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4a34eada-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Yalova': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d22a17e1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Karabük': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/ce5e3de7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Kilis': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/db5e3de7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Osmaniye': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/731b67ed-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
    'Düzce': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7d1b67ed-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
      }
    ],
  };
  @override
  void initState() {
    super.initState();
    _fetchCities();
    _gifController = GifController(vsync: this); // GifController başlatıldı
  }

  @override
  void dispose() {
    _gifController.dispose(); // GifController dispose edildi
    super.dispose();
  }

  void _showLoadingOverlay() {
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState != null) {
      _loadingOverlayEntry = OverlayEntry(
        builder: (context) => Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Gif(
                image: AssetImage("assets/animations/loading.gif"),
                controller: _gifController,
                autostart: Autostart.loop,
                onFetchCompleted: () {
                  _gifController.reset();
                  _gifController.forward();
                },
              ),
            ),
          ),
        ),
      );

      overlayState.insert(_loadingOverlayEntry!);
      print("Overlay inserted");
    } else {
      print("OverlayState not found");
    }
  }

  void _removeLoadingOverlay() {
    if (_loadingOverlayEntry != null) {
      print("Attempting to remove overlay");
      _loadingOverlayEntry?.remove();
      _loadingOverlayEntry = null;
      print("Overlay removed");
    } else {
      print("Overlay entry was null when trying to remove");
    }
  }

  Future<void> _fetchCities() async {
    final response =
        await http.get(Uri.parse('https://turkiyeapi.dev/api/v1/provinces'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cities = List<String>.from(data['data'].map((city) => city['name']));
        _selectedCity = _cities.first;
        _fetchWeatherData(_selectedCity);
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

  Future<Map<String, List<String>>> _generatePackingList() async {
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

    final prompt =
        '$_selectedCity şehrine yapacağım $_tripType amaçlı ${DateFormat('dd MMMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMMM yyyy').format(_selectedDateRange!.end)} tarihleri arasında '
        '${_days} günlük bir seyahat için hazırlamam gereken bir valiz listesi ve önemli bilgilendirmeler oluşturun. \n\n'
        '**Bavul:**\n\n'
        'Lütfen aşağıdaki kategorilere göre detaylı bir valiz listesi hazırlayın: \n\n'
        '**👚Giysiler:** \n'
        '- Seyahat tarihlerimdeki hava durumunu göz önünde bulundurarak (günlük ortalama sıcaklık, yağış olasılığı vb.) yeterli miktarda ve çeşitte giysi önerin. \n'
        '- Gündüz ve gece aktiviteleri için farklı giysi seçenekleri sunun. \n'
        '- Örneğin, tişört, pantolon, şort, elbise, ceket, iç çamaşırı, çorap vb. belirtebilirsiniz. \n\n'
        '**👟Ayakkabılar:** \n'
        '- Yapacağım aktivitelere uygun (yürüyüş, gezi, spor vb.) farklı ayakkabı türleri önerin. \n'
        '- Örneğin, spor ayakkabı, yürüyüş ayakkabısı, sandalet, terlik vb. belirtebilirsiniz. \n\n'
        '**💻Elektronik:** \n'
        '- Seyahatim sırasında ihtiyaç duyabileceğim elektronik eşyaları listeleyin. \n'
        '- Örneğin, telefon, şarj aleti, powerbank, kulaklık, fotoğraf makinesi vb. belirtebilirsiniz. \n\n'
        '**🪥Kişisel Bakım:** \n'
        '- Seyahatim boyunca kullanacağım kişisel bakım ürünlerini listeleyin. \n'
        '- Örneğin, diş fırçası, diş macunu, şampuan, saç kremi, duş jeli, güneş kremi, deodorant vb. belirtebilirsiniz. \n\n'
        '**Diğer:** \n'
        '- Yukarıdaki kategorilere girmeyen, seyahatim için gerekli olabilecek diğer eşyaları listeleyin. \n'
        '- Örneğin, pasaport, kimlik kartı, seyahat sigortası, ilaçlar, kitap, atıştırmalık, su şişesi vb. belirtebilirsiniz. \n\n'
        'Lütfen her kategori için miktar ve çeşit önerilerinde bulunurken, seyahatimin amacını, süresini ve seyahat tarihlerimdeki hava durumunu göz önünde bulundurun. '
        'Ayrıca, yapmayı planladığım aktivitelere göre özel önerilerde bulunabilirsiniz.\n\n'
        '**Önemli Bilgilendirmeler:**\n\n'
        '$_selectedCity şehrine ve ${DateFormat('dd MMMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMMM yyyy').format(_selectedDateRange!.end)} tarihleri arasındaki seyahatimle ilgili '
        'unutmamam gereken önemli bilgileri listeleyin. Örneğin, hava durumu, ulaşım, yerel gelenekler, önemli festivaller, güvenlik, sağlık vb. konularda bilgi verebilirsiniz.';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    print("Yapay Zeka Yanıtı:");
    print(response.text);

    final responseText = response.text ?? "";
    final lines = responseText.split('\n');
    Map<String, List<String>> result = {};
    String currentCategory = "";

    for (var line in lines) {
      line = line.trim();

      if (line.startsWith("**") && line.endsWith("**")) {
        currentCategory = line.replaceAll("*", "").trim();
        result[currentCategory] = [];
      } else if (line.startsWith("*")) {
        final item = line.replaceAll("*", "").trim();
        if (item.isNotEmpty) {
          result[currentCategory]?.add(item);
        }
      }
    }

    return result;
  }

  void _navigateToActivitySelection() async {
    if (_selectedCity.isNotEmpty && _selectedDateRange != null) {
      _showLoadingOverlay(); // Show the loading GIF overlay

      setState(() {
        _isLoading = true;
      });

      try {
        // Generate the packing list using the AI model
        final packingList = await _generatePackingList();

        // Immediately remove the overlay after the AI response is generated
        _removeLoadingOverlay();

        setState(() {
          _isLoading = false;
        });

        String? cityImageUrl = _cityImages[_selectedCity]?[0]['url'];

        // Proceed to navigate to the ActivitySelectionPage with the results
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivitySelectionPage(
              city: _selectedCity,
              startDate:
                  DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
              endDate: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
              tripType: _tripType,
              activitiesAndPacking: packingList,
              cityImage: cityImageUrl,
            ),
          ),
        );

        // Optionally handle the result after returning from the ActivitySelectionPage
        if (result != null) {
          await _saveTripToFirestore(result);
          Navigator.pop(context, result);
        }
      } catch (e) {
        print("Error during navigation or AI response generation: $e");
        _removeLoadingOverlay(); // Ensure overlay is removed even if an error occurs
      }
    }
  }

  Future<void> _saveTripToFirestore(Map<String, dynamic> tripData) async {
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('trips')
          .add({
        'city': tripData['city'],
        'startDate': tripData['startDate'],
        'endDate': tripData['endDate'],
        'tripType': tripData['tripType'],
        'days': tripData['days'],
        'selectedActivities': tripData['selectedActivities'],
        'cityImage': tripData['cityImage'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _fetchWeatherData(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$weatherApiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String weatherDescription = data['weather'][0]['description'];
      String weatherMain = data['weather'][0]['main'].toLowerCase();

      Map<String, String> weatherTranslations = {
        'clear sky': 'Açık hava',
        'few clouds': 'Az bulutlu',
        'scattered clouds': 'Dağınık bulutlar',
        'broken clouds': 'Parçalı bulutlu',
        'shower rain': 'Sağanak yağış',
        'rain': 'Yağmurlu',
        'thunderstorm': 'Gök gürültülü sağanak yağış',
        'snow': 'Karlı',
        'mist': 'Sisli',
      };
      weatherDescription =
          weatherTranslations[weatherDescription] ?? weatherDescription;

      setState(() {
        _weatherInfo =
            '$weatherDescription, Sıcaklık: ${data['main']['temp']}°C';

        if (weatherMain.contains('clear')) {
          _weatherIcon = WeatherIcons.day_sunny;
        } else if (weatherMain.contains('clouds')) {
          _weatherIcon = WeatherIcons.cloudy;
        } else if (weatherMain.contains('rain')) {
          _weatherIcon = WeatherIcons.rain;
        } else if (weatherMain.contains('snow')) {
          _weatherIcon = WeatherIcons.snow;
        } else if (weatherMain.contains('thunderstorm')) {
          _weatherIcon = WeatherIcons.thunderstorm;
        } else {
          _weatherIcon = WeatherIcons.na;
        }
      });
    } else {
      throw Exception('Hava durumu verileri alınamadı.');
    }
  }

  Widget _buildCityImages() {
    if (_cityImages.containsKey(_selectedCity)) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ..._cityImages[_selectedCity]!.map((imageData) {
            return Image.network(imageData['url']!);
          }).toList(),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  BoxedIcon(_weatherIcon, size: 32, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text(
                    '$_weatherInfo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Haydi Bir Gezi Planlayalım!")),
        backgroundColor: Color(0xff4285f4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cities.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    _buildCityImages(),
                    SizedBox(height: 20),
                    _buildDropdownButtonFormField(),
                    SizedBox(height: 20),
                    _buildDateRangePicker(),
                    SizedBox(height: 20),
                    Text(
                      "$_days gün",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff34a853),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTripTypeChip("İş", Icons.business),
                        _buildTripTypeChip("Tatil", Icons.beach_access),
                      ],
                    ),
                    SizedBox(height: 30),
                    _buildElevatedButton(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      onChanged: (newValue) {
        setState(() {
          _selectedCity = newValue!;
          _fetchWeatherData(_selectedCity);
        });
      },
      items: _cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: "Nereye Gidiyorsun?",
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xffea4335),
        ),
      ),
      selected: isSelected,
      selectedColor: Color(0xffea4335),
      onSelected: (_) {},
    );
  }

  Widget _buildDateRangePicker() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: _selectedDateRange == null
            ? "Ne Zaman Gidiyorsun?"
            : "${DateFormat('dd.MM.yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_selectedDateRange!.end)}",
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: () async {
        DateTimeRange? pickedDateRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          initialDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(Duration(days: 7)),
          ),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light().copyWith(
                  primary: Color(0xffea4335),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDateRange != null) {
          setState(() {
            _selectedDateRange = pickedDateRange;
            _calculateDays();
          });
        }
      },
    );
  }

  Widget _buildTripTypeChip(String label, IconData icon) {
    bool isSelected = _tripType == label;
    return ChoiceChip(
      label: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.white : Color(0xff4285f4),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: Color(0xff4285f4),
      onSelected: (bool selected) {
        setState(() {
          _tripType = label;
        });
      },
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _navigateToActivitySelection,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Bavul Hazırla!", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffea4335),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
