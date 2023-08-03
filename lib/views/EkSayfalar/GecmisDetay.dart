import 'package:flutter/material.dart';
import 'package:Kirtasiyem/Class/gecmisSiparis.dart';
import 'package:Kirtasiyem/dao/kirtasiyeDao.dart';
import 'package:Kirtasiyem/main.dart';

import '../../Class/gunduzRenkler.dart';

class gecmisDetay extends StatefulWidget {
  final gecmisSiparis gecmisler;


  gecmisDetay({required this.gecmisler});

  @override
  State<gecmisDetay> createState() => _gecmisDetayState();
}

class _gecmisDetayState extends State<gecmisDetay> {


  var tfUrunAdet = TextEditingController();
  double eskitoplam = 0;
  int eskiAdet =0;
  double urunFiyat =0;

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }

  Future<void> gecmisGuncelle({required int urun_id, required int urun_adet, required double toplam_tutar})async {
    await kirtasiyeDao().gecmisGuncelle(urun_id: urun_id, sepet_birim: urun_adet, toplam_tutar: toplam_tutar);
  }

  Future<void> stokGuncelle ({required int urun_id, required int eskiAdet, required int yeniAdet}) async{
    await kirtasiyeDao().stokGuncelle(urun_id: urun_id, stokAdet: eskiAdet-yeniAdet);
  }

  @override
  void initState() {
    super.initState();

    var gecmis=widget.gecmisler;
    tfUrunAdet.text=gecmis.sepet_birim.toString();
    eskiAdet=gecmis.sepet_birim;
    urunFiyat=gecmis.urun_fiyat;
    eskitoplam = gecmis.toplam_tutar;
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
          int? textBg = ayarlistesi?[1].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(backgroundColor: Color(barBg!),
              title:  Text("Ürünü Güncelle",style: TextStyle(color: Color(yaziRenk!)),),
            ),
            body:  Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 50,right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 100,width: 300,
                        child: Container(
                          decoration: BoxDecoration(color: Color(barBg),borderRadius: BorderRadius.circular(30.0)),
                          alignment: Alignment.center,
                            child: Text(widget.gecmisler.urun_ad,style: TextStyle(color: Color(yaziRenk),fontSize: 20),)
                        ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(textBg!), width: 5.0), // Kenarlık özellikleri
                        borderRadius: BorderRadius.circular(8.0), // Köşeleri yuvarlatma
                      ),
                      child: TextField(textAlign: TextAlign.center,
                        controller: tfUrunAdet,
                        decoration: InputDecoration(hintText: "Ürün Adetini Gir",border: InputBorder.none),
                      ),
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(textBg),),
                        onPressed: (){
                          gecmisGuncelle(urun_id: widget.gecmisler.urun_id, urun_adet: int.parse(tfUrunAdet.text), toplam_tutar: eskitoplam-((eskiAdet-int.parse(tfUrunAdet.text))*urunFiyat));
                          stokGuncelle(urun_id: widget.gecmisler.urun_id, eskiAdet: eskiAdet, yeniAdet: int.parse(tfUrunAdet.text));
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>botNavbar()),(route)=>false);
                        },
                        icon: Icon(Icons.save,color: Color(yaziRenk),),
                        label: Text("Geçmiş Satışı Güncelle",style: TextStyle(color: Color(yaziRenk)),),
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

