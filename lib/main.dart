import 'package:flutter/material.dart';
import 'package:Kirtasiyem/views/NavBarSayfalar/AnaSayfa.dart';
import 'package:Kirtasiyem/views/NavBarSayfalar/Ayarlar2.dart';
import 'package:Kirtasiyem/views/NavBarSayfalar/UrunlerSayfasi.dart';

import 'Class/gunduzRenkler.dart';
import 'dao/kirtasiyeDao.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarListesi = snapshot.data;
          int? mainBg = ayarListesi?[3].renk_kod;
          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Color(mainBg!),
              useMaterial3: true,
            ),
            home: const botNavbar(),
          );
        }else{
          return const Center();
        }
      },
    );
  }
}
class botNavbar extends StatefulWidget {
  const botNavbar({super.key});

  @override
  State<botNavbar> createState() => _botNavbarState();
}

class _botNavbarState extends State<botNavbar> {
  Future<List<gunduzRenkler>> ayarlariGoster() async{
    var ayarListesi = await kirtasiyeDao().ayarlar();
    return ayarListesi;
  }



  var  sayfaListesi = [const AnaSayfa(), const UrunlerSayfasi(),const Ayarlar2(),];

  int secilenIndeks =0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ayarlariGoster(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          var ayarListesi =snapshot.data;
          int? butonBg = ayarListesi?[1].renk_kod;
          int? barBg = ayarListesi?[2].renk_kod;
          int? secilmemis = ayarListesi?[4].renk_kod;
          return Scaffold(
            body: sayfaListesi[secilenIndeks],
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Ana Sayfa",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.catching_pokemon_rounded),
                  label: "Ürünler",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.palette),
                  label: "Ayarlar",
                ),
              ],
              backgroundColor: Color(barBg!),
              selectedItemColor: Color(butonBg!),
              selectedLabelStyle: const TextStyle(fontSize: 17),
              selectedIconTheme: const IconThemeData(size: 30.0),
              unselectedItemColor: Color(secilmemis!),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              currentIndex: secilenIndeks,
              onTap: (indeks){
                setState(() {
                  secilenIndeks=indeks;
                });
              },
            ),
          );
        }else{
          return const Center();
        }
      },
    );
  }
}
