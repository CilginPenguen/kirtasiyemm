import 'package:flutter/material.dart';
import 'package:Kirtasiyem/Class/urunlerListe.dart';
import 'package:Kirtasiyem/dao/kirtasiyeDao.dart';
import 'package:Kirtasiyem/main.dart';

import '../../Class/gunduzRenkler.dart';

class urunDetay extends StatefulWidget {
  final urunlerListe urunler;

  const urunDetay({super.key, required this.urunler});


  @override
  State<urunDetay> createState() => _urunDetayState();
}

class _urunDetayState extends State<urunDetay> {


  var tfBarkod = TextEditingController();
  var tfUrunAd = TextEditingController();
  var tfUrunAdet = TextEditingController();
  var tfUrunFiyat = TextEditingController();

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }

  Future<void> urunGuncelle(
      {required int urun_id,
      required String urun_barkod,
      required String urun_ad,
      required int urun_adet,
      required double urun_fiyat})async {
    await kirtasiyeDao().urunGuncelle(urun_id: urun_id, urun_barkod: urun_barkod, urun_ad: urun_ad, urun_adet: urun_adet, urun_fiyat: urun_fiyat);
  }

  @override
  void initState() {
    super.initState();

    var uruns=widget.urunler;
    tfBarkod.text=uruns.urun_barkod;
    tfUrunAd.text=uruns.urun_ad;
    tfUrunAdet.text=uruns.urun_adet.toString();
    tfUrunFiyat.text=uruns.urun_fiyat.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarlistesi = snapshot.data;
          int? yaziRenk = ayarlistesi?[0].renk_kod;
          int? barBg = ayarlistesi?[2].renk_kod;
          int? mainBg = ayarlistesi?[3].renk_kod;

          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(backgroundColor: Color(barBg!),
              title:  Text("Ürünü Güncelle",style: TextStyle(color: Color(yaziRenk!)),),
              actions: [
                TextButton(onPressed: (){
                  urunGuncelle(urun_id: widget.urunler.urun_id, urun_barkod: tfBarkod.text, urun_ad: tfUrunAd.text, urun_adet: int.parse(tfUrunAdet.text), urun_fiyat: double.parse(tfUrunFiyat.text));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>botNavbar()),(route)=>false);
                },
                    child: Text("KAYDET",style: TextStyle(fontSize: 15,color: Color(yaziRenk)),))
              ],
            ),
            body:  Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 50,right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextField(
                      controller: tfBarkod,
                      decoration: const InputDecoration(hintText: "Barkod Alanı",),
                    ),
                    TextField(
                      controller: tfUrunAd,
                      decoration: const InputDecoration(hintText: "Ürün Adını Gir",),
                    ),
                    TextField(
                      controller: tfUrunAdet,
                      decoration: const InputDecoration(hintText: "Ürün Adetini Gir",),
                    ),
                    TextField(
                      controller: tfUrunFiyat,
                      decoration: const InputDecoration(hintText: "Ürün Fiyatını Gir",),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        else{
          return const Center();
        }
      },
    );
  }
}

