# -*- coding: utf-8 -*-
"""Engendre `lib/jetons/jetons.dart` depuis la charte du prototype.

POURQUOI UNE EXTRACTION ET PAS UNE RECOPIE. Le prototype porte trente-cinq jetons
en clair et vingt-six en sombre. Recopies a la main dans du Dart, ils divergent a la
premiere correction de charte, et l'ecart ne se voit qu'a l'ecran, tard, sur un
seul mode. Ici il n'y a qu'une source : `prototype/maquette.html`.

CE QUE CE SCRIPT NE FAIT PAS, et il vaut mieux le dire : il ne lit que le bloc
`:root` clair et le bloc `:root[data-theme="dark"]`. Le bloc sous
`@media (prefers-color-scheme:dark)` porte les MEMES valeurs que le second — c'est
la regle du prototype — mais ce script ne le verifie pas. S'ils divergeaient un
jour, le Dart suivrait le bloc `[data-theme]` et personne ne le saurait.

    python outillage/extraire_jetons.py
"""
import io
import os
import re
import sys

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(RACINE, "prototype", "maquette.html")
CIBLE = os.path.join(RACINE, "lib", "jetons", "jetons.dart")

# Les jetons qui ne sont pas des couleurs, et ce qu'ils deviennent en Dart.
RAYONS = ["r-sm", "r-md", "r-lg", "r-xl", "r-full"]


def bloc(texte, motif):
    m = re.search(motif + r"\{(.*?)\n\}", texte, re.S)
    if not m:
        sys.exit(u"bloc introuvable : %s" % motif)
    return m.group(1)


def jetons(txt):
    return {n: v.strip() for n, v in
            re.findall(r"--([a-zA-Z0-9-]+)\s*:\s*([^;}\r\n]+)", txt)}


def dart_couleur(v):
    """`#RRGGBB` ou `rgba(r,g,b,a)` -> un litteral Dart `Color(0xAARRGGBB)`."""
    v = v.strip()
    m = re.match(r"^#([0-9A-Fa-f]{6})$", v)
    if m:
        return "Color(0xFF%s)" % m.group(1).upper()
    m = re.match(r"^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)$", v)
    if m:
        r, g, b = (int(m.group(i)) for i in (1, 2, 3))
        a = int(round(float(m.group(4)) * 255))
        return "Color(0x%02X%02X%02X%02X)" % (a, r, g, b)
    return None


def nom_dart(cle):
    """`r-sm` -> `rSm`, `glow-soft` -> `glowSoft`."""
    t = cle.split("-")
    return t[0] + "".join(x.capitalize() for x in t[1:])


def main():
    if not os.path.isfile(SOURCE):
        sys.exit(u"prototype absent : %s" % SOURCE)
    M = io.open(SOURCE, encoding="utf-8").read()
    clair = jetons(bloc(M, r"\n:root"))
    sombre = jetons(bloc(M, r':root\[data-theme="dark"\]'))

    # Le sombre n'override QUE ce qu'il redefinit : le reste herite du clair.
    # Ecrire deux listes completes ferait de chaque jeton non redefini une seconde
    # source, et c'est exactement ce qu'on cherche a eviter.
    couleurs = [(k, dart_couleur(v)) for k, v in sorted(clair.items())]
    couleurs = [(k, d) for k, d in couleurs if d]
    inconnues = [k for k, v in sorted(clair.items())
                 if dart_couleur(v) is None and k not in RAYONS
                 and k not in ("display", "ui", "shadow", "appui-x", "appui-y")]

    L = []
    L.append(u"// ⛔ FICHIER ENGENDRE — ne pas modifier a la main.")
    L.append(u"// Source unique : prototype/maquette.html, bloc `:root` et bloc")
    L.append(u"// `:root[data-theme=\"dark\"]`. Pour le regenerer :")
    L.append(u"//     python outillage/extraire_jetons.py")
    L.append(u"//")
    L.append(u"// %d couleurs, %d redefinies en sombre." % (len(couleurs), len(
        [k for k, _ in couleurs if k in sombre])))
    L.append(u"")
    L.append(u"import 'package:flutter/widgets.dart';")
    L.append(u"")
    L.append(u"/// Les couleurs de la charte, un jeu par mode.")
    L.append(u"///")
    L.append(u"/// ⛔ Aucune de ces valeurs ne s'ecrit dans un ecran : un ecran lit")
    L.append(u"/// `Jetons.de(context)`, jamais un hexadecimal.")
    L.append(u"@immutable")
    L.append(u"class Couleurs {")
    for k, _ in couleurs:
        L.append(u"  final Color %s;" % nom_dart(k))
    L.append(u"")
    L.append(u"  const Couleurs({")
    for k, _ in couleurs:
        L.append(u"    required this.%s," % nom_dart(k))
    L.append(u"  });")
    L.append(u"")

    for mode, table in ((u"clair", clair), (u"sombre", sombre)):
        L.append(u"  static const %s = Couleurs(" % mode)
        for k, d in couleurs:
            # Le sombre herite du clair pour tout ce qu'il ne redefinit pas.
            val = dart_couleur(table[k]) if k in table else d
            L.append(u"    %s: %s," % (nom_dart(k), val))
        L.append(u"  );")
        L.append(u"")
    L.append(u"}")
    L.append(u"")
    L.append(u"/// Les rayons de la charte, en pixels logiques.")
    L.append(u"abstract final class Rayons {")
    for k in RAYONS:
        v = clair.get(k, "0")
        px = re.match(r"^(\d+)px$", v)
        L.append(u"  static const %s = %s;" % (
            nom_dart(k), px.group(1) + ".0" if px else "999.0"))
    L.append(u"}")
    L.append(u"")
    L.append(u"/// Les deux familles de la charte. Le repli est declare, jamais implicite :")
    L.append(u"/// une police absente qui retombe en silence est un ecart qu'on ne voit pas.")
    L.append(u"abstract final class Polices {")
    L.append(u"  static const titre = 'Cinzel';")
    L.append(u"  static const texte = 'Manrope';")
    L.append(u"  static const repliTitre = <String>['Georgia', 'Times New Roman', 'serif'];")
    L.append(u"  static const repliTexte = <String>['Segoe UI', 'Roboto', 'sans-serif'];")
    L.append(u"}")
    L.append(u"")

    os.makedirs(os.path.dirname(CIBLE), exist_ok=True)
    io.open(CIBLE, "w", encoding="utf-8", newline="\n").write(u"\n".join(L))

    print(u"%d couleurs (%d redefinies en sombre), %d rayons"
          % (len(couleurs), len([k for k, _ in couleurs if k in sombre]), len(RAYONS)))
    if inconnues:
        print(u"⚠ jetons non traduits, laisses de cote : %s" % ", ".join(inconnues))
    print(u"-> %s" % os.path.relpath(CIBLE, RACINE))


if __name__ == "__main__":
    main()
