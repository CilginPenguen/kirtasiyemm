import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../Class/gunduzRenkler.dart';
import '../../dao/kirtasiyeDao.dart';
class Ayarlar2 extends StatefulWidget {
  const Ayarlar2({super.key});

  @override
  State<Ayarlar2> createState() => _Ayarlar2State();
}

class _Ayarlar2State extends State<Ayarlar2> {




  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }
  Future<void> guncelle (int id,int renk_kod) async{
    await kirtasiyeDao().ayarlariGuncelle(id, renk_kod);
  }
  _openColorPickerDialog({required int id,required int renk_kod}) {
    int selectedRenkKod = renk_kod;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Renk Seç'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(renk_kod),
              onColorChanged: (color) {
                selectedRenkKod = color.value;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  guncelle(id, selectedRenkKod);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Değiştir'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarListesi =snapshot.data;
          int? yaziRenk =ayarListesi?[0].renk_kod;
          int? butonBg = ayarListesi?[1].renk_kod;
          int? BarBg = ayarListesi?[2].renk_kod;
          int? mainBg = ayarListesi?[3].renk_kod;
          return Scaffold(
            backgroundColor: Color(mainBg!),
            appBar: AppBar(
              backgroundColor: Color(BarBg!),
              title: Text("Ayarlar",style: TextStyle(color: Color(yaziRenk!)),),
            ),
            body: Center(
              child: ListView.builder(
                  itemCount: ayarListesi!.length,
                  itemBuilder: (context,indeks){
                    var ayar = ayarListesi[indeks];
                    return GestureDetector(
                      onTap: (){
                        _openColorPickerDialog(renk_kod: ayarListesi[indeks].renk_kod,id: ayarListesi[indeks].gunduz_id);
                      },
                      child: Card(
                        color: Color(butonBg!),
                        child: SizedBox(
                          height: 110,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ayar.renk_aciklama,style: TextStyle(color: Color(yaziRenk),fontSize: 20),),
                                Text("Ayarla",style: TextStyle(color: Color(yaziRenk)),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
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