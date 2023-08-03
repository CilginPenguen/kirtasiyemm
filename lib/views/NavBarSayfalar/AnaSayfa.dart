import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:Kirtasiyem/Class/urunlerListe.dart';
import 'package:Kirtasiyem/main.dart';
import 'package:Kirtasiyem/views/EkSayfalar/StokAlarm.dart';
import 'package:Kirtasiyem/views/EkSayfalar/gecmisSayfa.dart';

import '../../Class/gecmisSiparis.dart';
import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';
import '../../dberisim/VeritabaniErisim.dart';
import '../EkSayfalar/sepet.dart';
import '../EkSayfalar/urun_ekle.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});


  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {

  DateTime anlikTarih = DateTime.now();
  DateFormat tarihFormati = DateFormat('yyyy-MM-dd');


  double ciro=0;
  int kritik = 0;
  late Timer _timer;
  late DateTime _currentTime;

  int lazimlikSayi = 0;

  String barkodSonuc = '';
  Future<List<gecmisSiparis>> seciliGecmisGoster(String tarih) async {
    var gecmisListesi = await kirtasiyeDao().gecmisListe(aranacakTarih: tarih);
    return gecmisListesi;
  }

  Future<void> stokLimitiniGetir() async {
    int stokLimiti = await kirtasiyeDao().stokLimitiniGetir();
    lazimlikSayi = stokLimiti;
  }

  Future<double> ciroToplam() async {
    var gecmisListesi = await seciliGecmisGoster(tarihFormati.format(anlikTarih));
    double toplamCiro = 0;
    for (var gecmisSiparis in gecmisListesi) {
      setState(() {
        toplamCiro += gecmisSiparis.toplam_tutar;
      });
    }
    setState(() {
      ciro = toplamCiro;
    });
    return ciro;
  }
  Future<void> stokKritik() async {
    int stokLimiti = lazimlikSayi;
    List<urunlerListe> urunler = await kirtasiyeDao().stokKritik(stokLimiti);
    int kritikSayi = urunler.length;
    setState(() {
      kritik = kritikSayi;
    });
  }

  Future<void> barkodTara() async {
    String barcodeResult;
    try {
      barcodeResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', // Okuyucu rengi
        'İptal', // İptal düğmesi metni
        true, // Geçiş efekti aktif mi?
        ScanMode.BARCODE, // Sadece barkodları okuyun
      );
    } catch (e) {
      barcodeResult = 'Bir hata oluştu: $e';
    }
    barkodSonuc = barcodeResult;
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var varKontrol = await db.query("urunlerListe",where: "urun_barkod=?",whereArgs: [barkodSonuc]);
    setState(()  {
      if(barkodSonuc =="-1"){
        barkodSonuc = "";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const botNavbar()));
      }
      else if (varKontrol.isNotEmpty){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const botNavbar()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bu barkodlu ürün zaten kayıtlı"),
          ),
        );
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context)=>urunEkle(barkod: barkodSonuc)));
      }
    });
  }

  void refreshData() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshData();
  }

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    stokLimitiniGetir().then((_) {
      stokKritik();
    });
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    String hourText = _currentTime.hour<10 ?"0${_currentTime.hour}": "${_currentTime.hour}" ;
    String minuteText = _currentTime.minute < 10 ? '0${_currentTime.minute}' : '${_currentTime.minute}';
    String secondText = _currentTime.second < 10 ? '0${_currentTime.second}' : '${_currentTime.second}';


    Future<List<gunduzRenkler>> ayarlariGoster() async{
      var ayarListesi = await kirtasiyeDao().ayarlar();
      return ayarListesi;
    }
    void refreshData() {
      setState(() {});
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      refreshData();
    }



    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarListesi = snapshot.data;
          int? yaziRenk =ayarListesi?[0].renk_kod;
          int? butonBg = ayarListesi?[1].renk_kod;
          int? barBg = ayarListesi?[2].renk_kod;
          int? mainBg = ayarListesi?[3].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(
              backgroundColor: Color(barBg!),
              title: Text("Yeşil Kırtasiye",style: TextStyle(color: Color(yaziRenk!)),),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('$hourText:$minuteText:$secondText',
                    style: TextStyle(fontSize: 24,color: Color(yaziRenk)),),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder(
                    future: ciroToplam(),
                    builder: (context,snapshot){
                      if(snapshot.hasData){
                        var cirocuk = snapshot.data;
                        return Text("Günlük Ciro : ${cirocuk?.toStringAsFixed(2)}", style: TextStyle(fontSize: 33, color: Color(yaziRenk)),);
                      }else{
                        return Text("Günlük Ciro : 0 ve 0", style: TextStyle(fontSize: 40, color: Color(yaziRenk)),);
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(butonBg!),
                            ),
                            onPressed: (){
                              barkodTara();
                            },
                            label: Text("Ürün Ekle",style: TextStyle(color: Color(yaziRenk),fontSize: 19),),
                          icon: Icon(Icons.add_circle_outline,color: Color(yaziRenk),),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(butonBg)),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const sepet()));
                          },
                          icon: Icon(Icons.shopping_cart,color: Color(yaziRenk),),
                          label: Text("Alışveriş",style: TextStyle(color: Color(yaziRenk),fontSize: 19),),

                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(butonBg)),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const StokKritik()));
                        },
                        label:  Text("Stok Az: $kritik",style: TextStyle(color: Color(yaziRenk),fontSize: 19),),
                        icon: Icon(Icons.warning,color: Color(yaziRenk),),
                      ),
                    ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(butonBg)),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const Gecmissayfa()));
                          },
                          label:  Text("Geçmiş ",style: TextStyle(color: Color(yaziRenk),fontSize: 19),),
                          icon: Icon(Icons.restore_outlined,color: Color(yaziRenk),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        else{
          return const Center(child: Text("Gelmedi"),);
        }
      },
    );
  }
}
