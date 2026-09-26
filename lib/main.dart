import 'package:flutter/material.dart';

import 'donnees/depot_biens.dart';
import 'ecrans/ecran_biens.dart';
import 'jetons/theme.dart';

void main() => runApp(const Hestea());

class Hestea extends StatelessWidget {
  const Hestea({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hestea',
      debugShowCheckedModeBanner: false,
      theme: themeHestea(sombre: false),
      darkTheme: themeHestea(sombre: true),
      // ⛔ LES DEUX MODES SE DECIDENT SUR LE REGLAGE DU SYSTEME, jamais dans
      // l'application. Un selecteur de theme dans le produit serait un reglage
      // de plus a tenir, et la charte porte deja ses deux jeux complets.
      themeMode: ThemeMode.system,
      home: EcranBiens(depot: DepotBiensEnMemoire()),
    );
  }
}
