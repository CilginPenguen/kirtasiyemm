import 'package:flutter/material.dart';
import 'package:Kirtasiyem/Class/sepetListe.dart';
import 'package:Kirtasiyem/dao/kirtasiyeDao.dart';
import 'package:Kirtasiyem/main.dart';
import 'package:Kirtasiyem/views/EkSayfalar/sepeteEkle.dart';
import 'package:intl/intl.dart';

import '../../Class/gunduzRenkler.dart';



class sepet extends StatefulWidget {
  const sepet({Key? key}) : super(key: key);

  @override
  State<sepet> createState() => _sepetState();
}

class _sepetState extends State<sepet> {

  double toplamFiyat = 0;
  DateTime anlikTarih = DateTime.now();
  DateFormat tarihFormati = DateFormat("yyyy-MM-dd");
  List<sepetList>? sepetUrun;

  void gecmiseEkle() async{
    sepetUrun = await kirtasiyeDao().sepetListe();
    for(int a=0;a<sepetUrun!.length;a++){
      double toplamTutar = (sepetUrun![a].urun_fiyat * sepetUrun![a].sepet_birim);
      String toplamTutarS = toplamTutar.toStringAsFixed(2);
      await kirtasiyeDao().gecmisEkle(urun_id: sepetUrun![a].urun_id,
          urun_ad: sepetUrun![a].urun_ad,
          urun_adet: sepetUrun![a].urun_adet,
          urun_fiyat: sepetUrun![a].urun_fiyat,
          sepet_birim: sepetUrun![a].sepet_birim,
          toplamTutar: double.parse(toplamTutarS),
          tarih: tarihFormati.format(anlikTarih));
      await kirtasiyeDao().alisverisStokGuncelleme(sepetUrun![a].urun_id, sepetUrun![a].urun_adet-sepetUrun![a].sepet_birim);
    }
    await kirtasiyeDao().sepetSil();
  }


  Future<List<gunduzRenkler>> ayarlariGoster() async {
    var ayarListesi = kirtasiyeDao().ayarlar();
    return ayarListesi;
  }

  Future<List<sepetList>> sepet() async {
    var sepetListesi = kirtasiyeDao().sepetListe();
    return sepetListesi;
  }

  Future<void> sepetSil(int urun_id) async {
    await kirtasiyeDao().sepetUrunSil(urun_id);
    setState(() {});
  }

  Future<void> birimArttir(int urun_id) async {
    await kirtasiyeDao().sepetBirimArttir(urun_id);
  }

  Future<void> birimAzalt(int urun_id) async {
    await kirtasiyeDao().sepetBirimAzalt(urun_id);
  }

  Future<void> toplamiGuncelle(int urun_id, double ilkToplam) async {
    await kirtasiyeDao().updateIlkToplam(urun_id, ilkToplam);
  }

  Future<void> _updateToplamFiyat() async {
    double ilkToplam = await kirtasiyeDao().getIlkToplam();
      toplamFiyat = ilkToplam;
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
    _updateToplamFiyat();
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
          int? icon = ayarListesi?[4].renk_kod;
          return FutureBuilder(
            future: sepet(),
            builder: (context, snap) {
              if (snap.hasData) {
                var sepetUrun = snap.data;

                  _updateToplamFiyat();
                  return Scaffold(
                    backgroundColor: Color(mainBg!),
                    appBar: AppBar(
                      backgroundColor: Color(BarBg!),
                      title: Text(
                        "Sepet",
                        style: TextStyle(color: Color(yaziRenk!)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SepeteEklemeSayfasi(),
                              ),
                            );
                          },
                          child: Text(
                            "Ürün Ekle",
                            style: TextStyle(color: Color(yaziRenk), fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    body: ListView.builder(
                      itemCount: sepetUrun!.length,
                      itemBuilder: (context, indeks) {
                        var sepet = sepetUrun[indeks];
                        String kusurengel= (sepet.urun_fiyat * sepet.sepet_birim).toStringAsFixed(2);
                        double urunToplamFiyat = double.parse(kusurengel);

                        void adetArttir() async {
                          await birimArttir(sepet.urun_id); // Sepet Birimini Arttır
                          if (sepet.sepet_birim<=sepet.urun_adet) {
                            setState(() {
                              sepet.sepet_birim += 1;
                              urunToplamFiyat += sepet.urun_fiyat;
                              toplamiGuncelle(sepet.urun_id, urunToplamFiyat);

                            });
                          }
                        }
                        void adetAzalt() async {
                          if (sepet.sepet_birim > 0) {
                            await birimAzalt(sepet.urun_id); // Sepet birimini azalt
                            setState(() {
                              sepet.sepet_birim -= 1;
                              urunToplamFiyat -= sepet.urun_fiyat;
                              toplamiGuncelle(sepet.urun_id, urunToplamFiyat);
                            });
                          }
                        }

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
                                        sepet.urun_ad,
                                        style: TextStyle(fontSize: 14, color: Color(yaziRenk)),
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Birim Fiyatı: ${sepet.urun_fiyat} \u{20BA}',
                                            style: TextStyle(fontSize: 14, color: Color(yaziRenk)),
                                          ),
                                          Text(
                                            "Fiyat : $urunToplamFiyat \u{20BA}",
                                            style: TextStyle(fontSize: 14, color: Color(yaziRenk)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: sepet.sepet_birim != 1 ? adetAzalt : null,
                                        icon: const Icon(Icons.remove),
                                        color: Color(icon!),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Adet: ${sepet.sepet_birim}",
                                        style: TextStyle(color: Color(yaziRenk)),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: (sepet.sepet_birim<sepet.urun_adet)? adetArttir:null,
                                        icon: const Icon(Icons.add),
                                        color: Color(icon),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sepetSil(sepet.urun_id);
                                          toplamiGuncelle(sepet.urun_id, urunToplamFiyat);
                                        });
                                      },
                                      icon: Icon(Icons.delete, color: Color(icon)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    bottomSheet: SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: -3, // Negatif değer kullanarak gölge efektini içeri doğru ekliyoruz
                                    blurRadius: 5,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Tutar: ${toplamFiyat.toStringAsFixed(2)}\u{20BA}",
                                  style: TextStyle(color: Color(yaziRenk),fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Container(
                              color: Color(BarBg),
                              child:ElevatedButton.icon(
                                  onPressed: (){gecmiseEkle();Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>botNavbar()),(route)=>false);snackCikti(cikti: "İşlem tamamlandı");}, icon: Icon(Icons.catching_pokemon,color: Color(yaziRenk),),
                                  style: ElevatedButton.styleFrom(backgroundColor: Color(BarBg)),
                                  label: Text("Alışverişi Tamamla",style: TextStyle(color: Color(yaziRenk),fontSize: 16),)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

              } else {
                return Scaffold(
                  backgroundColor: Color(mainBg!),
                  appBar: AppBar(
                    backgroundColor: Color(BarBg!),
                    title: Text(
                      "Sepet",
                      style: TextStyle(color: Color(yaziRenk!)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => const SepeteEklemeSayfasi(),),);},
                        child: Text(
                          "Ürün Ekle",
                          style: TextStyle(color: Color(yaziRenk), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  body: Center(
                    child: Text(
                      "Sepet Boş",
                      style: TextStyle(color: Color(yaziRenk), fontSize: 20),
                    ),
                  ),
                  bottomSheet: SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: -3, // Negatif değer kullanarak gölge efektini içeri doğru ekliyoruz
                                  blurRadius: 5,
                                  offset: const Offset(0, -3), // Negatif değer kullanarak gölge efektini yukarı doğru ekliyoruz
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Tutar: $toplamFiyat\u{20BA}",
                                style: TextStyle(color: Color(yaziRenk),fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            color: Color(BarBg),
                            child: ElevatedButton.icon(
                                onPressed: (){},
                                icon: Icon(Icons.catching_pokemon,color: Color(yaziRenk),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(BarBg),
                                ),
                                label: Text("Alışverişi Tamamla",style: TextStyle(color: Color(yaziRenk),fontSize: 16),
                                )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        } else {
          return const Center(
            child: Text("Ayarlar Gelmedi"),
          );
        }
      },
    );
  }
}
