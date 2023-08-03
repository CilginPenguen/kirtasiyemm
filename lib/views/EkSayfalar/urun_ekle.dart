import 'package:flutter/material.dart';
import 'package:Kirtasiyem/main.dart';

import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';

class urunEkle extends StatefulWidget {
  final String barkod;

  const urunEkle({super.key, required this.barkod});

  @override
  State<urunEkle> createState() => _urunEkleState();
}

class _urunEkleState extends State<urunEkle> {

  var tfBarkod = TextEditingController();
  var tfUrunAd = TextEditingController();
  var tfUrunAdet = TextEditingController();
  var tfUrunFiyat = TextEditingController();

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }
  Future<void> kayit(String urun_barkod,String urun_ad,int urun_adet,double urun_fiyat)async {
    await kirtasiyeDao().barkodSorgulaVeEkle(urun_barkod, urun_ad, urun_adet, urun_fiyat);
  }


  @override
  void initState() {
    super.initState();
    tfBarkod.text = widget.barkod;
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
              title:  Text("Ürün Ekle",style: TextStyle(color: Color(yaziRenk!)),),
              actions: [
                TextButton(onPressed: (){
                  kayit(tfBarkod.text, tfUrunAd.text, int.parse(tfUrunAdet.text), double.parse(tfUrunFiyat.text));
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const botNavbar()));
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
