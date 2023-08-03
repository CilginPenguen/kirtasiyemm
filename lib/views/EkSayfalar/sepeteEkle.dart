import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Kirtasiyem/views/EkSayfalar/sepet.dart';
import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';
import '../../Class/urunlerListe.dart';
import '../../dberisim/VeritabaniErisim.dart';
import 'dart:math';

import '../../main.dart';

class SepeteEklemeSayfasi extends StatefulWidget {
  const SepeteEklemeSayfasi({Key? key}) : super(key: key);

  @override
  State<SepeteEklemeSayfasi> createState() => _SepeteEklemeSayfasiState();
}

class _SepeteEklemeSayfasiState extends State<SepeteEklemeSayfasi> with SingleTickerProviderStateMixin{

  late AnimationController animasyonKontrol;

  late Animation<double> scaleAnimasyonDegerleri;
  late Animation<double> rotateAnimasyonDegerleri;
  bool fabDurum = false;
  String barkodSonuc = '';
  bool arama = false;
  String kelime = "";

  Future<List<gunduzRenkler>> ayarlariGoster() async {
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }

  Future<List<urunlerListe>> urunleriGoster() async {
    var urunListesi = await kirtasiyeDao().urunListe();
    return urunListesi;
  }
  Future<List<urunlerListe>> aramaSonucListesi({required String kelime}) async{
    var aramaSonucListesi = kirtasiyeDao().urunArama(kelime: kelime);
    return aramaSonucListesi;
  }

  Future<void> sepeteKontrol({
    required int urun_id,
    required int urun_barkod,
    required String urun_ad,
    required int urun_adet,
    required double urun_fiyat,
    required int sepet_birim,
    required double ilkToplam,
  }) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var varKontrol = await db.query(
      'sepetList',
      where: 'urun_id = ?',
      whereArgs: [urun_id],
      limit: 1,
    );

    if (varKontrol.isEmpty) {
      await kirtasiyeDao().sepeteEkle(
        urun_id: urun_id,
        urun_barkod: urun_barkod,
        urun_ad: urun_ad,
        urun_adet: urun_adet,
        urun_fiyat: urun_fiyat,
        sepet_birim: sepet_birim,
        ilkToplam: ilkToplam,
      );
      snackCikti(cikti: "$urun_ad sepete eklendi");
    } else {
      var kayitVarMi = varKontrol.first;
      var varOlanUrun = kayitVarMi['urun_ad'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$varOlanUrun zaten sepete eklenmiş'),
        ),
      );
    }
  }

  Future<void> barkodIleTara() async {
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

    setState(() {
      barkodSonuc = barcodeResult;
      if(barkodSonuc =="-1"){
        barkodSonuc = "";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const botNavbar()));
      }else{
        kirtasiyeDao().barkodSorgulaVeAktar(barkodSonuc);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const sepet()));
      }
    });
  }

  Future<void>snackCikti ({required String cikti}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cikti),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animasyonKontrol = AnimationController(duration: const Duration(milliseconds: 200),vsync:this);

    scaleAnimasyonDegerleri = Tween(begin:0.0,end:1.0).animate(animasyonKontrol)..addListener(() {
      setState(() {});
    });

    rotateAnimasyonDegerleri = Tween(begin:0.0,end:pi/4).animate(animasyonKontrol)..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    animasyonKontrol.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ayarListesi = snapshot.data;
          int? yaziRenk = ayarListesi?[0].renk_kod;
          int? butonBg = ayarListesi?[1].renk_kod;
          int? BarBg = ayarListesi?[2].renk_kod;
          int? mainBg = ayarListesi?[3].renk_kod;
          int? faButon = ayarListesi?[4].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(
              backgroundColor: Color(BarBg!),
              title: arama? TextField(
                decoration: const InputDecoration(hintText: "Arama İçin Birşeyler Yazın"),
                onChanged: (aranan){
                  setState(() {
                    kelime = aranan;
                  });
                },
              )
                  :Text(
                "Yeşil Kırtasiye",
                style: TextStyle(color: Color(yaziRenk!)),
              ),
              actions: [arama ? IconButton(
                onPressed: (){
                  setState(() {
                    arama = false;
                    kelime = "";
                  });
                },
                icon: Icon(Icons.cancel,color: Color(yaziRenk!),) ,
              ):
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const sepet()),
                    );
                  },
                  child: Text(
                    "Sepete Dön",
                    style: TextStyle(color: Color(yaziRenk!)),
                  ),
                )
              ],
            ),
            body: FutureBuilder(
              future: arama? aramaSonucListesi(kelime: kelime) :urunleriGoster(),
              builder: (context, snap) {
                if (snap.hasData) {
                  var urunListesi = snap.data;
                  return ListView.builder(
                    itemCount: urunListesi!.length,
                    itemBuilder: (context, indeks) {
                      var Liste = urunListesi[indeks];
                      return Card(
                        color: Color(butonBg!),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Liste.urun_ad,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(yaziRenk),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Fiyat: ${Liste.urun_fiyat} \u{20BA}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(yaziRenk),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Adet : ${Liste.urun_adet}",
                                      style: TextStyle(color: Color(yaziRenk)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 58.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          sepeteKontrol(
                                            urun_id: Liste.urun_id,
                                            urun_barkod: int.parse(Liste.urun_barkod),
                                            urun_ad: Liste.urun_ad,
                                            urun_adet: Liste.urun_adet,
                                            urun_fiyat: Liste.urun_fiyat,
                                            sepet_birim: 1,
                                            ilkToplam: Liste.urun_fiyat,
                                          );
                                        });
                                      },
                                      icon: const Icon(Icons.shopping_cart_checkout_outlined, color: Colors.yellow),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("Boş 2"));
                }
              },
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Transform.scale(
                  scale: scaleAnimasyonDegerleri.value,
                  child: FloatingActionButton(
                    heroTag: "kelime ile arama",
                    onPressed: (){
                      setState(() {
                        arama=true;
                      });
                    },
                    tooltip: 'Kelime ile Ara',
                    backgroundColor: Color(faButon!),
                    child: const Icon(Icons.search),
                  ),
                ),
                Transform.scale(
                  scale: scaleAnimasyonDegerleri.value,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: "barkod Tarama",
                      onPressed: (){
                        barkodIleTara();
                      },
                      tooltip: 'Barkod İle Tara',
                      backgroundColor: Color(faButon),
                      child: Icon(Icons.camera,color: Color(yaziRenk),),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: rotateAnimasyonDegerleri.value,
                  child: FloatingActionButton(
                    onPressed: (){
                      if(fabDurum){
                        animasyonKontrol.reverse();
                        fabDurum=false;
                      }else{
                        animasyonKontrol.forward();
                        fabDurum=true;
                      }
                    },
                    tooltip: 'Fab Main',
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          );
        } else {
          return const Center(child: Text("Boş 1 "));
        }
      },
    );
  }
}