import 'package:flutter/material.dart';

import '../../Class/gunduzRenkler.dart';
import '../../Class/urunlerListe.dart';
import '../../dao/kirtasiyeDao.dart';
import '../../main.dart';

class StokKritik extends StatefulWidget {
  const StokKritik({super.key});

  @override
  State<StokKritik> createState() => _StokKritikState();
}

class _StokKritikState extends State<StokKritik> {

  var tfLimit = TextEditingController();

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }
  Future<List<urunlerListe>> stokKritikke() async {
    int stokLimiti = int.tryParse(tfLimit.text) ?? 0;

    var stokKritikListesi = await kirtasiyeDao().stokKritik(stokLimiti);
    return stokKritikListesi;
  }


  @override
  void initState() {
    super.initState();
    stokLimitiniGetir();
  }

  Future<void> stokLimitiniGetir() async {
    int stokLimiti = await kirtasiyeDao().stokLimitiniGetir();
    tfLimit.text = stokLimiti.toString();
  }
  Future<void>limitiGuncelle({required int filtre})async{
    await kirtasiyeDao().stokLimitGuncelle(filtre: filtre);
  }
  Future<void>geriDon()async {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const botNavbar()),(route)=>false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarListesi = snapshot.data;
          int? yaziRenk =ayarListesi?[0].renk_kod;
          int? butonBg = ayarListesi?[1].renk_kod;
          int? BarBg = ayarListesi?[2].renk_kod;
          int? mainBg = ayarListesi?[3].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(
              backgroundColor: Color(BarBg!),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  geriDon();
                },
              ),
              title: Text("Stok Az",style: TextStyle(color: Color(yaziRenk!)),),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: SizedBox(
                    height: 40,
                    width: 75,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(butonBg!),width: 5)
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Color(yaziRenk)),
                        controller: tfLimit,
                        onChanged: (value) {
                          setState(() {
                            limitiGuncelle(filtre: int.parse(value));
                          });
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: FutureBuilder(
              future: stokKritikke(),
              builder: (context,snap){
                if(snap.hasData){
                  var stokKritikList = snap.data;
                  return ListView.builder(
                    itemCount: stokKritikList!.length,
                    itemBuilder: (context,indeks){
                      var Liste = stokKritikList[indeks];
                      return Card(
                        color: Color(butonBg),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(Liste.urun_ad, style: TextStyle(fontSize: 16,color: Color(yaziRenk))),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    Text("Stok : ${Liste.urun_adet}",style: TextStyle(color: Color(yaziRenk),fontSize: 18),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }else{
                  return const Center(child: Text("Boş 2"),);
                }
              },
            ),
          );
        }
        else{
          return const Center(child: Text("Boş 1 "),);
        }
      },

    );
  }
}
