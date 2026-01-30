import 'beduerfnis_page.dart';

class BeduerfnisNavigationParams {

  BeduerfnisNavigationParams({
    required this.wbkType,
    required this.wbkColor,
    required this.weaponType,
    required this.anzahlWaffen,
    required this.currentPage,
  });
  final String wbkType; // 'neu' or 'bestehend'
  final String wbkColor; // 'gelb' or 'gruen'
  final String weaponType; // 'kurz' or 'lang'
  final int anzahlWaffen;
  final BeduerfnisPage currentPage;

  BeduerfnisNavigationParams copyWith({
    String? wbkType,
    String? wbkColor,
    String? weaponType,
    int? anzahlWaffen,
    BeduerfnisPage? currentPage,
  }) {
    return BeduerfnisNavigationParams(
      wbkType: wbkType ?? this.wbkType,
      wbkColor: wbkColor ?? this.wbkColor,
      weaponType: weaponType ?? this.weaponType,
      anzahlWaffen: anzahlWaffen ?? this.anzahlWaffen,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
