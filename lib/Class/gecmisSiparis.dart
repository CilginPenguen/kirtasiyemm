final class gecmisSiparis{
  int gecmis_id;
  int urun_id;
  String urun_ad;
  int urun_adet;
  double urun_fiyat;
  int sepet_birim;
  double toplam_tutar;
  String tarih;

  gecmisSiparis(
      this.gecmis_id,{
      required this.urun_id,
      required this.urun_ad,
      required this.urun_adet,
      required this.urun_fiyat,
      required this.sepet_birim,
      required this.toplam_tutar,
      required this.tarih});
}