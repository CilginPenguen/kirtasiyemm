import 'package:flutter/material.dart';
import 'package:Kirtasiyem/views/EkSayfalar/GecmisDetay.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Class/gecmisSiparis.dart';
import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';
import 'package:intl/intl.dart';


class Gecmissayfa extends StatefulWidget {
  const Gecmissayfa({Key? key});

  @override
  State<Gecmissayfa> createState() => _GecmissayfaState();
}

class _GecmissayfaState extends State<Gecmissayfa> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime anlikTarih = DateTime.now();
  DateFormat tarihFormati = DateFormat('yyyy-MM-dd');

  Future<List<gunduzRenkler>> ayarlariGoster() async {
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }

  Future<List<gecmisSiparis>> seciliGecmisGoster(String tarih) async {
    var gecmisListesi = await kirtasiyeDao().gecmisListe(aranacakTarih: tarih);
    return gecmisListesi;
  }

  Future<double> gecmisToplam() async {
    var gecmisListesi = await seciliGecmisGoster(tarihFormati.format(anlikTarih));
    double toplamCiro = 0;
    for (var gecmisSiparis in gecmisListesi) {
      toplamCiro += gecmisSiparis.toplam_tutar;
    }
    return toplamCiro;
  }
  Future<void> silinenEkle({required int urun_id,required int gecmis_adet}) async{
    await kirtasiyeDao().stokGuncelle(urun_id: urun_id, stokAdet: gecmis_adet);
  }
  Future<void> sil({required int urun_id}) async{
   await kirtasiyeDao().gecmisSil(urun_id: urun_id);
  }

  Future<void>snackCikti ({required String cikti,required int urun_id,required int adet}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: Colors.black87,
        content: Row(
          children: [
            Expanded(
              child: Text(
                cikti,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            TextButton(
              child: const Text(
                "Evet",
                style: TextStyle(color: Colors.red,fontSize: 20),
              ),
              onPressed: () async {
                await silinenEkle(urun_id: urun_id, gecmis_adet: adet);
                await sil(urun_id: urun_id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() {

                });
              },
            ),
            TextButton(
              child: const Text(
                "Hayır",
                style: TextStyle(color: Colors.green,fontSize: 20),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<gunduzRenkler>>(
      future: ayarlariGoster(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ayarListesi = snapshot.data!;
          int? yaziRenk = ayarListesi[0].renk_kod;
          int? butonBg = ayarListesi[1].renk_kod;
          int? BarBg = ayarListesi[2].renk_kod;
          int? mainBg = ayarListesi[3].renk_kod;
          int? icon = ayarListesi[4].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg),
            appBar: AppBar(
              backgroundColor: Color(BarBg),
              title: Text(
                "Geçmiş Takvim",
                style: TextStyle(color: Color(yaziRenk)),
              ),
              actions: [
                FutureBuilder<double>(
                  future: gecmisToplam(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      double? ciro = snapshot.data;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          "Ciro: ${ciro ?? 0} \u{20BA}",
                          style: TextStyle(color: Color(yaziRenk)),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Hata: ${snapshot.error}');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2022, 1, 1),
                  lastDay: DateTime.utc(2400, 12, 31),
                  focusedDay: anlikTarih,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(anlikTarih, day);
                  },
                  onDaySelected: (date, focusedDay) {
                    setState(() {
                      anlikTarih = date;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<gecmisSiparis>>(
                    future: seciliGecmisGoster(tarihFormati.format(anlikTarih)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var gecmisSiparisler = snapshot.data!;
                        return ListView.builder(
                          itemCount: gecmisSiparisler.length,
                          itemBuilder: (context, index) {
                            var gecmisListe = gecmisSiparisler[index];
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>gecmisDetay(gecmisler: gecmisListe)));
                              },
                              child: Card(
                                color: Color(butonBg),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              gecmisListe.urun_ad,
                                              style: TextStyle(fontSize: 14, color: Color(yaziRenk)),
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Birim Fiyatı: ${gecmisListe.urun_fiyat} \u{20BA}',
                                                  style: TextStyle(fontSize: 14, color: Color(yaziRenk)),
                                                ),
                                                Text(
                                                  "Fiyat : ${gecmisListe.toplam_tutar} \u{20BA}",
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
                                            const SizedBox(width: 8),
                                            Text(
                                              "Adet: ${gecmisListe.sepet_birim}",
                                              style: TextStyle(color: Color(yaziRenk)),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                snackCikti(cikti: "${gecmisListe.urun_ad} geçmişten silmek istiyor musun?", urun_id: gecmisListe.urun_id, adet: gecmisListe.sepet_birim);
                                              });
                                            },
                                            icon: Icon(Icons.delete, color: Color(icon)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

