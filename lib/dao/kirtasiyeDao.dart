import 'package:Kirtasiyem/Class/gecmisSiparis.dart';
import 'package:Kirtasiyem/Class/gunduzRenkler.dart';
import 'package:Kirtasiyem/Class/sepetListe.dart';
import 'package:Kirtasiyem/Class/urunlerListe.dart';
import 'package:Kirtasiyem/dberisim/VeritabaniErisim.dart';

class kirtasiyeDao {

  Future<List<gunduzRenkler>> ayarlar() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM gunduzRenkler");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return gunduzRenkler(
          satir["gunduz_id"], satir["renk_aciklama"], satir["renk_kod"]);
    });
  }

  Future<void> ayarlariGuncelle(int id, int renk_kod) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var bilgiler = <String, dynamic>{};
    bilgiler["renk_kod"] = renk_kod;
    await db.update("gunduzRenkler", bilgiler, where: "gunduz_id=?", whereArgs: [id]);
  }

  Future<List<urunlerListe>> urunListe() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM urunlerListe");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return urunlerListe(urun_id: satir["urun_id"],
          urun_barkod: satir["urun_barkod"],
          urun_ad: satir["urun_ad"],
          urun_adet: satir["urun_adet"],
          urun_fiyat: satir["urun_fiyat"]);
    });
  }

  Future<void> barkodSorgulaVeEkle(String urun_barkod, String urun_ad, int urun_adet, double urun_fiyat) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();


    var varKontrol = await db.query("urunlerListe",where: "urun_barkod=?",whereArgs: [urun_barkod]);

    if(varKontrol.isEmpty){
      var bilgiler = <String, dynamic>{};
      bilgiler["urun_barkod"] = urun_barkod;
      bilgiler["urun_ad"] = urun_ad;
      bilgiler["urun_adet"] = urun_adet;
      bilgiler["urun_fiyat"] = urun_fiyat;

      await db.insert("urunlerListe", bilgiler);
    }

  }

  Future <void> urunKaydet(String urun_barkod, String urun_ad, int urun_adet, double urun_fiyat) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var bilgiler = <String, dynamic>{};
    bilgiler["urun_barkod"] = urun_barkod;
    bilgiler["urun_ad"] = urun_ad;
    bilgiler["urun_adet"] = urun_adet;
    bilgiler["urun_fiyat"] = urun_fiyat;

    await db.insert("urunlerListe", bilgiler);
  }

  Future<void> urunGuncelle({required int urun_id, required String urun_barkod, required String urun_ad, required int urun_adet, required double urun_fiyat}) async{
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var bilgiler = <String,dynamic>{};
    bilgiler["urun_barkod"]=urun_barkod;
    bilgiler["urun_ad"]=urun_ad;
    bilgiler["urun_adet"]=urun_adet;
    bilgiler["urun_fiyat"]=urun_fiyat;

    await db.update("urunlerListe", bilgiler, where: "urun_id=?", whereArgs: [urun_id]);
  }

  Future<List<urunlerListe>> stokKritik(int stokLimiti) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM urunlerListe WHERE urun_adet < $stokLimiti");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return urunlerListe(
          urun_id: satir["urun_id"],
          urun_barkod: satir["urun_barkod"],
          urun_ad: satir["urun_ad"],
          urun_adet: satir["urun_adet"],
          urun_fiyat: satir["urun_fiyat"]);
    });
  }


  Future<void> alisverisStokGuncelleme(int urun_id, int urun_adet) async{
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var bilgiler = <String,dynamic>{};
    bilgiler["urun_adet"] = urun_adet;
    await db.update("urunlerListe", bilgiler,where: "urun_id=?",whereArgs: [urun_id]);
  }

  Future<void> stokGuncelle({required int urun_id, required int stokAdet}) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.rawUpdate(
        "UPDATE urunlerListe SET urun_adet = urun_adet + ? WHERE urun_id = ?",
        [stokAdet, urun_id]);
  }

  Future <void> urunSil(int urun_id) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.delete("urunlerListe", where: "urun_id=?", whereArgs: [urun_id]);
  }

  Future<List<sepetList>> sepetListe() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM sepetList");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return sepetList(
          urun_id: satir["urun_id"],
          urun_barkod: satir["urun_barkod"],
          urun_ad: satir["urun_ad"],
          urun_adet: satir["urun_adet"],
          urun_fiyat: satir["urun_fiyat"],
          sepet_birim: satir["sepet_birim"],
          ilkToplam: satir["ilkToplam"]
      );
    });
  }

  Future<void> sepeteEkle({
    required int urun_id,
    required int urun_barkod,
    required String urun_ad,
    required int urun_adet,
    required double urun_fiyat,
    required int sepet_birim,
    required double ilkToplam
  }) async {
    try {
      var db = await VeritabaniYardimcisi.veritabaniErisim();

      var bilgiler = <String, dynamic>{
        "urun_id": urun_id,
        "urun_barkod": urun_barkod,
        "urun_ad": urun_ad,
        "urun_adet": urun_adet,
        "urun_fiyat": urun_fiyat,
        "sepet_birim": sepet_birim,
        "ilkToplam": ilkToplam,
      };

      await db.insert("sepetList", bilgiler);
    } catch (e) {

    }
  }

  Future <void> sepetUrunSil(int urun_id) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.delete("sepetList", where: "urun_id=?", whereArgs: [urun_id]);
  }

  Future<void> sepetBirimArttir(int urun_id) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.rawUpdate(
        "UPDATE sepetList SET sepet_birim = sepet_birim +1 WHERE urun_id=?",
        [urun_id]);
  }

  Future<void> sepetBirimAzalt(int urun_id) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.rawUpdate(
        "UPDATE sepetList SET sepet_birim = sepet_birim -1 WHERE urun_id=?",
        [urun_id]);
  }

  Future<void> sepetSil() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.rawDelete("DELETE FROM sepetList");
  }

  Future<double> getIlkToplam() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> rows = await db.rawQuery(
        'SELECT ilkToplam FROM sepetList');

    double toplamFiyat = 0;
    for (var row in rows) {
      double ilkToplam = row['ilkToplam'];
      toplamFiyat += ilkToplam;
    }

    return toplamFiyat;
  }

  Future<int> stokLimitiniGetir() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT stok_limit FROM stokLimit WHERE limit_id = 1");

    if (maps.isNotEmpty) {
      return maps.first["stok_limit"];
    }


    return 8;
  }
  Future<void>stokLimitGuncelle({required int filtre})async{
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var bilgiler = <String,dynamic>{};
    bilgiler["stok_limit"]=filtre;

    await db.update("stokLimit", bilgiler,where: "limit_id=?",whereArgs: [1]);
  }

  Future<void> updateIlkToplam(int urun_id, double ilkToplam) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.rawUpdate('UPDATE sepetList SET ilkToplam = ? WHERE urun_id = ?',
        [ilkToplam, urun_id]);
  }

  Future<List<gecmisSiparis>> gecmisListe({required String aranacakTarih}) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM gecmisSiparis WHERE tarih = ?", [aranacakTarih]);

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return gecmisSiparis(
          satir["gecmis_id"],
          urun_id: satir["urun_id"],
          urun_ad: satir["urun_ad"],
          urun_adet: satir["urun_adet"],
          urun_fiyat: satir["urun_fiyat"],
          sepet_birim: satir["sepet_birim"],
          toplam_tutar: satir["toplam_tutar"],
          tarih: satir["tarih"]
      );
    });
  }

  Future<void> gecmisEkle({
    required int urun_id,
    required String urun_ad,
    required int urun_adet,
    required double urun_fiyat,
    required int sepet_birim,
    required double toplamTutar,
    required String tarih,
  }) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var varmiKontrol = await db.query(
      'gecmisSiparis',
      where: 'tarih = ? AND urun_id = ?',
      whereArgs: [tarih, urun_id],
      limit: 1,
    );

    if (varmiKontrol.isNotEmpty) {
      for (var existingRecord in varmiKontrol) {
        var gecmisAdet = existingRecord['sepet_birim'] as int;
        var gecmisToplamTutar = existingRecord['toplam_tutar'] as double;

        var guncelAdet = gecmisAdet + sepet_birim;
        var guncelToplamTutar = gecmisToplamTutar + toplamTutar;

        await db.update('gecmisSiparis', {'sepet_birim': guncelAdet, 'toplam_tutar': guncelToplamTutar,}, where: 'tarih = ? AND urun_id = ?', whereArgs: [tarih, urun_id],);
      }
    } else {
      var bilgiler = <String, dynamic>{
        'urun_id': urun_id,
        'urun_ad': urun_ad,
        'urun_adet': urun_adet,
        'urun_fiyat': urun_fiyat,
        'sepet_birim': sepet_birim,
        'toplam_tutar': toplamTutar,
        'tarih': tarih,
      };
      await db.insert('gecmisSiparis', bilgiler);
    }
  }

  Future<void> gecmisGuncelle({required int urun_id,  required int sepet_birim,required toplam_tutar}) async{
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    var bilgiler = <String,dynamic>{};
    bilgiler["sepet_birim"]=sepet_birim;
    bilgiler["toplam_tutar"] = toplam_tutar;
    await db.update("gecmisSiparis", bilgiler, where: "urun_id=?", whereArgs: [urun_id]);
  }
  Future <void> gecmisSil({required int urun_id}) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    await db.delete("gecmisSiparis", where: "urun_id=?", whereArgs: [urun_id]);
  }

  Future<void> barkodSorgulaVeAktar(String barkod) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    final List<Map<String, dynamic>> sorgu = await db.rawQuery(
      'SELECT * FROM urunlerListe WHERE urun_barkod = ?',
      [barkod],
    );
    var varKontrol = await db.query("sepetList",where: "urun_barkod=?",whereArgs: [barkod]);

    if(varKontrol.isEmpty){
      if (sorgu.isNotEmpty) {
        Map<String, dynamic> satir = sorgu.first;

        var bilgiler = <String, dynamic>{
          "urun_id": satir['urun_id'],
          "urun_barkod": satir['urun_barkod'],
          "urun_ad": satir['urun_ad'],
          "urun_adet": satir['urun_adet'],
          "urun_fiyat": satir['urun_fiyat'],
          "sepet_birim": 1,
          "ilkToplam": satir["urun_fiyat"]
        };

        await db.insert("sepetList", bilgiler);
      }
    }
  }

  Future<List<urunlerListe>> urunArama({required String kelime}) async{
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    List<Map<String,dynamic>> maps = await db.rawQuery("SELECT * FROM urunlerListe WHERE urun_ad like '%$kelime%'");
     return List.generate(maps.length, (i)  {
       var satir = maps[i];
       return urunlerListe(
           urun_id: satir["urun_id"],
           urun_barkod: satir["urun_barkod"],
           urun_ad: satir["urun_ad"],
           urun_adet: satir["urun_adet"],
           urun_fiyat: satir["urun_fiyat"]
       );
     });
  }

}
