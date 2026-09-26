// ⛔ FICHIER ENGENDRE — ne pas modifier a la main.
// Source unique : prototype/maquette.html, bloc `:root` et bloc
// `:root[data-theme="dark"]`. Pour le regenerer :
//     python outillage/extraire_jetons.py
//
// 25 couleurs, 25 redefinies en sombre.

import 'package:flutter/widgets.dart';

/// Les couleurs de la charte, un jeu par mode.
///
/// ⛔ Aucune de ces valeurs ne s'ecrit dans un ecran : un ecran lit
/// `Jetons.de(context)`, jamais un hexadecimal.
@immutable
class Couleurs {
  final Color amber;
  final Color amberSoft;
  final Color bg;
  final Color bg2;
  final Color border;
  final Color coral;
  final Color coralSoft;
  final Color cyan;
  final Color cyanSoft;
  final Color danger;
  final Color error;
  final Color glow;
  final Color glowSoft;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color inkSoft;
  final Color line;
  final Color line2;
  final Color muted;
  final Color ok;
  final Color okSoft;
  final Color surface;
  final Color surface2;

  const Couleurs({
    required this.amber,
    required this.amberSoft,
    required this.bg,
    required this.bg2,
    required this.border,
    required this.coral,
    required this.coralSoft,
    required this.cyan,
    required this.cyanSoft,
    required this.danger,
    required this.error,
    required this.glow,
    required this.glowSoft,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.inkSoft,
    required this.line,
    required this.line2,
    required this.muted,
    required this.ok,
    required this.okSoft,
    required this.surface,
    required this.surface2,
  });

  static const clair = Couleurs(
    amber: Color(0xFFF5A524),
    amberSoft: Color(0x24F5A524),
    bg: Color(0xFFFFFCF5),
    bg2: Color(0xFFFAF6EA),
    border: Color(0x1F0B0E1A),
    coral: Color(0xFFE8623F),
    coralSoft: Color(0x1AE8623F),
    cyan: Color(0xFF0BBBA8),
    cyanSoft: Color(0x1F0BBBA8),
    danger: Color(0xFFD64545),
    error: Color(0xFFC8421A),
    glow: Color(0xFF5B3FE0),
    glowSoft: Color(0x1A5B3FE0),
    ink: Color(0xFF0B0E1A),
    ink2: Color(0xB80B0E1A),
    ink3: Color(0x7A0B0E1A),
    ink4: Color(0x4C0B0E1A),
    inkSoft: Color(0xFF3A3F55),
    line: Color(0x1A0B0E1A),
    line2: Color(0x2E0B0E1A),
    muted: Color(0xFF7A7E8E),
    ok: Color(0xFF2EA856),
    okSoft: Color(0x212EA856),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4EEE0),
  );

  static const sombre = Couleurs(
    amber: Color(0xFFFFC661),
    amberSoft: Color(0x29FFC661),
    bg: Color(0xFF0B0E1A),
    bg2: Color(0xFF10142A),
    border: Color(0x29FFFCF5),
    coral: Color(0xFFFF8B6B),
    coralSoft: Color(0x24FF8B6B),
    cyan: Color(0xFF5BEFDC),
    cyanSoft: Color(0x245BEFDC),
    danger: Color(0xFFF47B7B),
    error: Color(0xFFFF8B6B),
    glow: Color(0xFF9B82FF),
    glowSoft: Color(0x299B82FF),
    ink: Color(0xFFFFFCF5),
    ink2: Color(0xB8FFFCF5),
    ink3: Color(0x7AFFFCF5),
    ink4: Color(0x4CFFFCF5),
    inkSoft: Color(0xFFD4D8E5),
    line: Color(0x1AFFFCF5),
    line2: Color(0x2EFFFCF5),
    muted: Color(0xFF8A90A8),
    ok: Color(0xFF7BD389),
    okSoft: Color(0x267BD389),
    surface: Color(0xFF161B30),
    surface2: Color(0xFF1F2540),
  );

}

/// Les rayons de la charte, en pixels logiques.
abstract final class Rayons {
  static const rSm = 6.0;
  static const rMd = 10.0;
  static const rLg = 14.0;
  static const rXl = 20.0;
  static const rFull = 999.0;
}

/// Les deux familles de la charte. Le repli est declare, jamais implicite :
/// une police absente qui retombe en silence est un ecart qu'on ne voit pas.
abstract final class Polices {
  static const titre = 'Cinzel';
  static const texte = 'Manrope';
  static const repliTitre = <String>['Georgia', 'Times New Roman', 'serif'];
  static const repliTexte = <String>['Segoe UI', 'Roboto', 'sans-serif'];
}
