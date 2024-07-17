import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bootcamprojeai/pages/activity_selection_page.dart';

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
      ''; // API anahtarını buraya ekleyin

  final Map<String, List<Map<String, String>>> _cityImages = {
    'Adana': [
      {
        'url':
            'https:https://img.memurlar.net/galeri/4400/6c283fe2-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Adana: Sabancı Merkez Camii. Fotoğraf, Ali Başarır'
      }
    ],
    'Adıyaman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2b9d58e8-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Adıyaman: Nemrut Dağı. Fotoğraf, Coolbiere. A'
      }
    ],
    'Afyon': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/23ed7aee-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Afyon: Frig Vadisi. (Yıldız Pozlama) Fotoğraf, Hümeyra Çelik'
      }
    ],
    'Ağrı': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2ded7aee-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Ağrı: İshak Paşa Sarayı ve Ağrı Dağı manzarası. Fotoğraf, Nuro Aksoy'
      }
    ],
    'Amasya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d402a7f4-bb68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Amasya: Kral mezarları ve Amasya\'nın gece görünüşü. Fotoğraf, Can Eser'
      }
    ],
    'Ankara': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/39e50110-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Ankara: Gece Işıklandırmasıyla Anıtkabir'
      }
    ],
    'Antalya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b4577816-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Antalya: Side Apollon Tapınağı. Fotoğraf, Necat Çetin'
      }
    ],
    'Artvin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/efe1c31c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Artvin: Kara Göl. Fotoğraf, Özcan Malkoçer'
      }
    ],
    'Aydın': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4116e022-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Aydın: Apollon Tapınağı. Fotoğraf, Veli Toluay'
      }
    ],
    'Balıkesir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b6ab6a36-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Balıkesir: Manyas Kuş Cenneti. Fotoğraf, Zafer Çankırı'
      }
    ],
    'Bilecik': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/0dd3973c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bilecik: Orhan Gazi Camii'
      }
    ],
    'Bingöl': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/546aaa56-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bingöl: Yüzen Ada'
      }
    ],
    'Bitlis': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d7833a5d-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bitlis: Ahlat Selçuklu Mezarları. Fotoğraf, Erkam Uğur'
      }
    ],
    'Bolu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f1833a5d-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bolu: Göynük Evleri. Fotoğraf, Erdal Irgat'
      }
    ],
    'Burdur': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/96304163-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Burdur: Kibyra Antik Kenti. Fotoğraf, Recep Çirik'
      }
    ],
    'Bursa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/0ecc4769-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bursa: Cumalıkızık Köyü. Fotoğraf, Gökhan Güzeltepe'
      }
    ],
    'Çanakkale': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/20cc4769-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Çanakkale: Çanakkale Şehitleri Anıtı'
      }
    ],
    'Çankırı': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/eba9dc7c-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Çankırı: Tuz Mağaraları. Fotoğraf Melih Sular'
      }
    ],
    'Çorum': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8f0e9291-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Çorum: Osmancık Köprüsü. Fotoğraf, Can Eser'
      }
    ],
    'Denizli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3d0abb97-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Denizli: Pamukkale. Fotoğraf, Ahmet Şahin'
      }
    ],
    'Diyarbakır': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4b0abb97-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Diyarbakır: Ulu Camii. Fotoğraf, Kadir Kömür'
      }
    ],
    'Edirne': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/c14a129e-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Edirne: Selimiye Camii ve şehir silüeti. Fotoğraf, Ömer Şahin'
      }
    ],
    'Elazığ': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d44a129e-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Elazığ: Harput Kalesi. Fotoğraf, Hıdır Yıldırım'
      }
    ],
    'Erzincan': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d84639a4-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Erzincan: Girlevik Şelalesi. Fotoğraf, Çağrı Çırak'
      }
    ],
    'Erzurum': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e04639a4-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Erzurum: Üç Kümbetler. Fotoğraf, Barış Yorulmaz'
      }
    ],
    'Eskişehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/9d6868aa-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Eskişehir: Odun Pazarı. Fotoğraf, Murat Fındık'
      }
    ],
    'Gaziantep': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/71798ab0-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Gaziantep: Tarihi Bedesten içindeki bakırıcılar çarşısı. Fotoğraf, Hakkı Arıcan'
      }
    ],
    'Giresun': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7f798ab0-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Giresun: Kümbet Yaylası. Fotoğraf, Ahmet Yapan'
      }
    ],
    'Gümüşhane': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/5647d1b6-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Gümüşhane: Kürtün Vadisi. Fotoğraf, Mustafa Olgun'
      }
    ],
    'Hakkari': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6d47d1b6-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Hakkari: Mergan Yaylası. Fotoğraf, Mahmut Peynirci'
      }
    ],
    'Hatay': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/15d48fbd-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Hatay: M.Ö. 1. yüzyılda yapılmış Vespasianus ve Titus Tüneli. Fotoğraf, Soner Pehlivan'
      }
    ],
    'Isparta': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/20d48fbd-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Isparta: Eğirdir gece silüeti ve Eğirdir Gölü. Fotoğraf, Mehmet Altınay'
      }
    ],
    'Mersin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f7ce2ac5-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Mersin: Kız Kalesi. Fotoğraf, Erdal Suat'
      }
    ],
    'İstanbul': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/00cf2ac5-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'İstanbul: Galata Kulesi. Fotoğraf, Gökhan Girgine'
      }
    ],
    'İzmir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7a5841cb-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'İzmir: Efes Antik Kenti. Fotoğraf, Tingy Wu'
      }
    ],
    'Kars': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/865841cb-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kars: Ani Harabeleri. Fotoğraf, Salih Borbozan'
      }
    ],
    'Kastamonu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/ea7584d1-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kastamonu: Kastamonu Kalesi. Fotoğraf, Sertaç Ünal'
      }
    ],
    'Kayseri': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f47584d1-bc68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Kayseri: Kapuzbaşı Şelalesi. Fotoğraf, Ramazan Yücel Öner'
      }
    ],
    'Kırklareli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a2aa283e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Kırklareli: Bizans döneminde İmparator II. Teodosius\'un bu bölgedeki önemli şövalyelerinden biri olan Kozmos Dimitriyadis tarafından yaptırıldığı varsayılan Pınarhisar Kalesi.'
      }
    ],
    'Kırşehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/33ac5544-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kırşehir: Mucur Yeraltı Şehri'
      }
    ],
    'Kocaeli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/45ac5544-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kocaeli: Maşukiye Yaylası. Fotoğraf, Gökhan Alpdoğan'
      }
    ],
    'Konya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/f76f504a-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Konya: Mevlana Türbesi. Fotoğraf, İlknur Akpınar'
      }
    ],
    'Kütahya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6152d056-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kütahya: Aizanoi Antik Kenti. Fotoğraf, Zafer Çankırı'
      }
    ],
    'Malatya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/6952d056-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Malatya: Günpınar Şelalesi. Fotoğraf, Sefa Özdemir'
      }
    ],
    'Manisa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7ccad35c-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Manisa: Sardes Antik Kenti. Fotoğraf, Ali Başarır'
      }
    ],
    'Kahramanmaraş': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/c1f07363-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kahramanmaraş: Taş Köprü. Fotoğraf, Ümit Bor'
      }
    ],
    'Mardin': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/caf07363-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Mardin: Bir bütün olarak, Mardin şehrinin gece silüeti. Fotoğraf, Erkam Uğur'
      }
    ],
    'Muğla': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8b0b7f69-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Muğla: Ölü Deniz. Fotoğraf, Nejdet Düzen'
      }
    ],
    'Muş': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/920b7f69-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Muş: Murat Köprüsü. Fotoğraf, Hidayet Kara'
      }
    ],
    'Nevşehir': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/665bea6f-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Nevşehir: Kapadokya/Peri Bacaları. Fotoğraf, Reynaldi Herdinanto'
      }
    ],
    'Niğde': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3c29ea75-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Niğde: Alaaddin Camii. Fotoğraf, Serdar Güner'
      }
    ],
    'Ordu': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4b29ea75-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Ordu: Boztepe\'den gece Ordu görünüşü. Fotoğraf, Kerim Gültaş'
      }
    ],
    'Rize': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/9a4bf17b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Rize: Pokut Yaylası. Fotoğraf, Ferzan Uğurdağ'
      }
    ],
    'Sakarya': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/43050682-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Sakarya: Sapanca Gölü. Fotoğraf, Selçuk Gülen'
      }
    ],
    'Samsun': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/cc143688-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Samsun: Atatürk Heykeli'
      }
    ],
    'Siirt': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/dd8c588e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Siirt: Siirt\'in Aydınlar ilçesinde ekinoks zamanlarında güneş ışınlarının belli bir vakitte belli bir noktaya düşeceğinin 17-18. yüzyıllarda hesap edilmesine dayalı olarak inşa edilen türbe. Fotoğraf, Tarık Oran.'
      }
    ],
    'Sinop': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e68c588e-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Sinop: Sinop Kalesi ve fotoğrafta görüldüğü gibi surları. Fotoğraf, Caucas Blue'
      }
    ],
    'Sivas': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8abe1195-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Sivas: Divriği Ulu Camii ve Darüşşifası. Fotoğraf, Ahmet Özbaş'
      }
    ],
    'Tekirdağ': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/99be1195-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Tekirdağ: Ayçiçeği/Günebakan Bahçeleri. Fotoğraf, Ramis Akar'
      }
    ],
    'Tokat': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d3f8209b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Tokat: Ballıca Mağarası. Fotoğraf, Tuna Ozata'
      }
    ],
    'Trabzon': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/dcf8209b-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Trabzon: Sümela Manastırı. Fotoğraf, Mustafa Tayar'
      }
    ],
    'Tunceli': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e0831aa1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Tunceli: Pertek Kalesi. Fotoğraf, Engin Asil'
      }
    ],
    'Şanlıurfa': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/e9831aa1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Şanlıurfa: Büyük kısmı Birecik Barajı nedeniyle sular altında kalmış Halfeti İlçesi. Fotoğraf, Aylin Erözcan'
      }
    ],
    'Uşak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/65dc19a7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Uşak: Ulubey Kanyonları'
      }
    ],
    'Van': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/21d108bb-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Van: Akdamar Adası ve Kilisesi. Fotoğraf, Coolbiere. A.'
      }
    ],
    'Yozgat': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2cd108bb-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Yozgat: Kazankaya Kanyonu. Fotoğraf, Adem Yağız'
      }
    ],
    'Zonguldak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/1c513ec2-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Zonguldak: Mitolojik karakter Herakles\'in ölüler ülkesinin kapısını bekleyen üç başlı köpek cerberus\'u yakaladığı yer olduğu rivayet edilen Cehennemağzı Mağaraları.'
      }
    ],
    'Aksaray': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/2e513ec2-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Aksaray: Ihlara Vadisi. Fotoğraf, Erol Şahin'
      }
    ],
    'Bayburt': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/aac638c8-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Bayburt: Bayburt Kalesi ve şehir silüeti. Fotoğraf, Can Savcı'
      }
    ],
    'Karaman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/b1c638c8-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Karaman: Hatuniye Medresesi'
      }
    ],
    'Kırıkkale': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a2b46fce-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Kırıkkale: Celal Bayar Parkı'
      }
    ],
    'Batman': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/a7b46fce-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Batman: Hasankeyf. Fotoğraf, Mehmet Çay'
      }
    ],
    'Şırnak': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/8ddf76d4-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Şırnak: Kırmızı Medrese'
      }
    ],
    'Bartın': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/97df76d4-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Bartın: İnkum Plajı. Fotoğraf, Murat Güler'
      }
    ],
    'Ardahan': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/3934eada-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Ardahan: Kış sezonunda Çıldır Gölü. Fotoğraf, Ahmet Hrmnc'
      }
    ],
    'Iğdır': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/4a34eada-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Iğdır: Halıkışla. Fotoğraf, Özkan Soylu'
      }
    ],
    'Yalova': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/d22a17e1-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Yalova: Erikli Şelalesi. Fotoğraf, Hüseyin Atakuru'
      }
    ],
    'Karabük': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/ce5e3de7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Karabük: Bulak Mağarası. Fotoğraf, Emrah Balaban'
      }
    ],
    'Kilis': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/db5e3de7-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description':
            'Kilis: Ravanda Kalesi, içinden görünüm. Fotoğraf, Hannan Aslan'
      }
    ],
    'Osmaniye': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/731b67ed-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Osmaniye: Ceyhan Nehri. Fotoğraf, Murat Beşbudak'
      }
    ],
    'Düzce': [
      {
        'url':
            'https://img.memurlar.net/galeri/4400/7d1b67ed-bd68-e311-8b97-14feb5cc1801.jpg?width=500',
        'description': 'Düzce: Kardüz Yaylası'
      }
    ],
  };
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

  Future<List<String>> _generateActivities() async {
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final prompt =
        '$_selectedCity şehrine $_tripType amaçlı seyahat için ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} ile ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)} tarihleri arasında yapılacak aktivite türleri öner. Kategorilere göre listele: Konaklama, Taşımacılık, Etkinlikler / Öğeler. Örnek:\n\n```\n{\n  "Konaklama": [\n    "Otel",\n    "Kiralık",\n    "Arkadaşlar/Aile",\n    "İkinci ev",\n    "Kamp yapmak",\n    "Seyir"\n  ],\n  "Ulaşım": [\n    "Uçak",\n    "Araba",\n    "Tren",\n    "Motosiklet",\n    "Tekne",\n    "Otobüs"\n  ],\n  "Etkinlikler / Öğeler": [\n    "Gerekli",\n    "Giyisi",\n    "Tuvalet kiti",\n    "Çalışma",\n    "Golf",\n    "Koşu",\n    "Resmi akşam yemeği",\n    "Yüzme havuzu",\n    "Uluslararası",\n    "Fotoğrafçılık",\n    "Kış sporları",\n    "Plaj",\n    "Yürüyüş"\n  ]\n}\n```';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text?.split(',') ?? [];
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
            tripType: _tripType,
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

  Widget _buildCityImages() {
    if (_cityImages.containsKey(_selectedCity)) {
      return Column(
        children: _cityImages[_selectedCity]!.map((imageData) {
          return Column(
            children: [
              Image.network(imageData['url']!),
              Text(imageData['description']!)
            ],
          );
        }).toList(),
      );
    } else {
      return Container();
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
                  const SizedBox(height: 24),
                  _buildCityImages(), // Şehir resimlerini gösteren widget
                ],
              ),
      ),
    );
  }
}
