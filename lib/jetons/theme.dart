import 'package:flutter/material.dart';

import 'jetons.dart';

/// Les jetons de la charte, portes par le theme.
///
/// ⛔ UN ECRAN NE LIT JAMAIS UN HEXADECIMAL. Il lit `Jetons.de(context)`, et
/// c'est ce qui fait que le mode sombre existe sans qu'aucun ecran ne s'en
/// occupe : les deux jeux viennent de `jetons.dart`, engendre depuis le
/// prototype.
@immutable
class Jetons extends ThemeExtension<Jetons> {
  final Couleurs c;

  const Jetons(this.c);

  /// ⚠️ LE REPLI EST SUR LE CLAIR, ET IL EST DELIBERE. Un `!` ici ferait tomber
  /// l'ecran entier le jour ou quelqu'un construit un `MaterialApp` sans
  /// l'extension — un mode qui manque doit degrader, pas crasher.
  static Couleurs de(BuildContext context) =>
      Theme.of(context).extension<Jetons>()?.c ?? Couleurs.clair;

  @override
  Jetons copyWith({Couleurs? c}) => Jetons(c ?? this.c);

  /// ⛔ AUCUNE INTERPOLATION ENTRE LES DEUX MODES. Basculer clair/sombre en
  /// fondant vingt-cinq couleurs deux a deux produit, a mi-chemin, un jeu qui
  /// n'est celui d'aucun des deux : des contrastes qu'aucune charte n'a
  /// valides. La bascule est franche.
  @override
  Jetons lerp(covariant Jetons? autre, double t) => t < 0.5 ? this : (autre ?? this);
}

/// Le theme complet, pour un mode.
///
/// ⚠️ ON THEMATISE MATERIAL 3, ON NE LE REMPLACE PAS : un composant maison ne
/// s'ecrit que si aucun existant ne repond.
ThemeData themeHestea({required bool sombre}) {
  final c = sombre ? Couleurs.sombre : Couleurs.clair;
  final base = sombre ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[Jetons(c)],
    scaffoldBackgroundColor: c.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: c.coral,
      secondary: c.cyan,
      tertiary: c.glow,
      surface: c.surface,
      error: c.danger,
      onPrimary: const Color(0xFFFFFFFF),
      onSurface: c.ink,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: Polices.texte,
      fontFamilyFallback: Polices.repliTexte,
      bodyColor: c.ink,
      displayColor: c.ink,
    ),
    dividerColor: c.line,
  );
}
