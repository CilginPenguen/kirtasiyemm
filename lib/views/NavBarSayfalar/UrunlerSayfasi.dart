import 'package:flutter/material.dart';
import 'package:Kirtasiyem/views/EkSayfalar/UrunDetay.dart';

import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';
import '../../Class/urunlerListe.dart';

class UrunlerSayfasi extends StatefulWidget {
  const UrunlerSayfasi({Key? key}) : super(key: key);

  @override
  State<UrunlerSayfasi> createState() => _UrunlerSayfasiState();
}


class _UrunlerSayfasiState extends State<UrunlerSayfasi> {

  bool arama = false;
  String kelime = "";

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }
  Future<List<urunlerListe>> urunleriGoster() async{
    var urunListesi = await kirtasiyeDao().urunListe();
    return urunListesi;
  }
  Future<void> sil(int urunId) async{
    await kirtasiyeDao().urunSil(urunId);
    setState(() {});
  }
  Future<List<urunlerListe>> aramaSonucListesi({required String kelime}) async{
    var aramaSonucListesi = kirtasiyeDao().urunArama(kelime: kelime);
    return aramaSonucListesi;
  }
  Future<void>snackCikti ({required String cikti,required int urun_id,}) async {
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
                onPressed: (){
                  sil(urun_id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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


  void refreshData() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshData();
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
          int? icon = ayarListesi?[4].renk_kod;
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
                  :Text("Ürünler",style: TextStyle(color: Color(yaziRenk!)),),
              actions: [
                arama ? IconButton(
                  onPressed: (){
                    setState(() {
                      arama = false;
                      kelime = "";
                    });
                  },
                  icon: Icon(Icons.cancel,color: Color(yaziRenk!),) ,
                ):
                IconButton(
                  onPressed: (){
                    setState(() {
                      arama = true;
                    });
                  },
                  icon: Icon(Icons.search,color: Color(yaziRenk!),) ,
                ),
              ],
            ),
            body: FutureBuilder(
              future: arama? aramaSonucListesi(kelime: kelime):urunleriGoster(),
              builder: (context,snap){
                if(snap.hasData){
                  var urunListesi = snap.data;
                  return ListView.builder(
                    itemCount: urunListesi!.length,
                    itemBuilder: (context,indeks){
                      var list = urunListesi[indeks];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>urunDetay(urunler: list)));
                        },
                        child: Card(
                          color: Color(butonBg!),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(list.urun_ad, style: TextStyle(fontSize: 18,color: Color(yaziRenk))),
                                      const SizedBox(height: 8),
                                      Text('Fiyat: ${list.urun_fiyat} \u{20BA}', style: TextStyle(fontSize: 16,color: Color(yaziRenk))),
                                      const SizedBox(height: 8,),
                                      Text("Stok : ${list.urun_adet}",style: TextStyle(color: Color(yaziRenk)),),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: (){
                                        snackCikti(cikti: "${list.urun_ad} silmek istiyor musunuz?", urun_id: list.urun_id);
                                      },
                                      icon: Icon(Icons.delete,color: Color(icon!)),
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
                }else{
                  return const Center(child: Text("Boş 2"),);
                }
              },
            ),
          );
        }
        else{
          return  Center(child: Text("Boş 1 "),);
        }
      },

    );
  }
}
