# -*- coding: utf-8 -*-
"""Falsifie les regles du domaine : on MUTE le code de production et on verifie
que le test tombe.

Un test vert ne prouve rien tant qu'on ne l'a pas vu rouge pour la bonne raison.
Ce script mute, lance la suite, restaure, et dit pour chaque mutation si elle a
ete VUE — c'est-a-dire si un test est tombe.

⛔ TROIS PIEGES QUE CE SCRIPT EVITE. Une mutation qui ne compile pas ne prouve
rien (le rouge vient du compilateur). Une mutation qui ne change rien au
comportement ne prouve rien non plus. Et il faut un TEMOIN : au moins un test
doit rester vert, sinon on a casse la suite, pas la regle.

    python outillage/falsifier.py
"""
import io
import os
import re
import subprocess
import sys

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

BIEN = os.path.join(RACINE, "lib", "domaine", "bien.dart")
PIECE = os.path.join(RACINE, "lib", "domaine", "piece.dart")

# (fichier, nom de la regle, texte a remplacer, remplacement)
MUTATIONS = [
    (BIEN, u"RG-F2-02 \xb7 le complement s'ajoute",
     u"      (bail == null ? 'Aucun bail' : 'Bail en cours depuis le ${bail!.debut}') +\n"
     u"      complement;",
     u"      (bail == null ? 'Aucun bail' : 'Bail en cours depuis le ${bail!.debut}');"),

    (BIEN, u"RG-F2-02 \xb7 la date vient du bail",
     u"'Bail en cours depuis le ${bail!.debut}'",
     u"'Bail en cours depuis le 01/03/2026'"),

    (BIEN, u"le pluriel des pieces se derive",
     u"${nombrePieces > 1 ? 'pièces' : 'pièce'}",
     u"pièces"),

    (BIEN, u"RG-F2-04 \xb7 la ligne existe sans bail",
     u"      ? 'Aucun bail en cours'",
     u"      ? ''"),

    (PIECE, u"RG-F4-06 \xb7 le nombre est en tete",
     u"    return '$quantite ${quantite > 1 ? 'lignes' : 'ligne'} · ${dit.join(' · ')}';",
     u"    return dit.join(' · ');"),

    (PIECE, u"RG-F4-07 \xb7 deux matieres ne s'affichent pas comme une",
     u"      dit.add('${mats.length} matières');",
     u"      dit.add(mats.first);"),

    (PIECE, u"RG-F4-09 \xb7 une ligne sans valeur propre herite",
     u"      matiere: p != null && p.matiere != null ? p.matiere : matiere,",
     u"      matiere: p?.matiere,"),

    (PIECE, u"la sentinelle n'est pas une matiere",
     u"    v != null && v.isNotEmpty && !v.contains('renseigner');",
     u"    v != null && v.isNotEmpty;"),

    (PIECE, u"RG-F4-02 \xb7 l'atterrissage est le premier",
     u"  static OngletBien get atterrissage => OngletBien.values.first;",
     u"  static OngletBien get atterrissage => OngletBien.values.last;"),

    (PIECE, u"la piece compte des LIGNES",
     u"  int get lignes => elements.fold(0, (n, e) => n + e.quantite);",
     u"  int get lignes => elements.length;"),
]


def suite():
    """Rend (tombes, passes). Un echec de COMPILATION rend (-1, -1)."""
    r = subprocess.run(["flutter", "test", "--reporter", "compact"],
                       cwd=RACINE, capture_output=True, text=True, shell=True)
    sortie = (r.stdout or "") + (r.stderr or "")
    if "Error:" in sortie or "error •" in sortie:
        return -1, -1
    paires = re.findall(r"\+(\d+)\s*-(\d+)", sortie)
    if paires:
        return int(paires[-1][1]), int(paires[-1][0])
    seuls = re.findall(r"\+(\d+)", sortie)
    return 0, int(seuls[-1]) if seuls else 0


def main():
    origines = {f: io.open(f, encoding="utf-8").read() for f in {m[0] for m in MUTATIONS}}
    base_t, base_p = suite()
    print(u"reference : %d tombe(s), %d passe(s)\n" % (base_t, base_p))
    if base_t != 0:
        sys.exit(u"la suite n'est pas verte au depart — rien a falsifier")

    vues, muettes = [], []
    for fichier, nom, avant, apres in MUTATIONS:
        src = origines[fichier]
        if src.count(avant) != 1:
            muettes.append((nom, u"ancre vue %d fois" % src.count(avant)))
            continue
        io.open(fichier, "w", encoding="utf-8", newline="\n").write(
            src.replace(avant, apres, 1))
        t, p = suite()
        io.open(fichier, "w", encoding="utf-8", newline="\n").write(src)
        if t == -1:
            muettes.append((nom, u"ne compile pas — ne prouve rien"))
        elif t == 0:
            muettes.append((nom, u"AUCUN test n'est tombe"))
        elif p == 0:
            muettes.append((nom, u"TOUT est tombe — pas de temoin"))
        else:
            vues.append((nom, t, p))

    for nom, t, p in vues:
        print(u"  VUE    %-46s %d tombe(s), %d temoin(s)" % (nom, t, p))
    for nom, motif in muettes:
        print(u"  MUETTE %-46s %s" % (nom, motif))

    print(u"\n%d/%d mutations vues" % (len(vues), len(MUTATIONS)))
    intact = all(io.open(f, encoding="utf-8").read() == s for f, s in origines.items())
    print(u"code de production restaure : %s" % (u"oui" if intact else u"NON"))
    sys.exit(0 if len(vues) == len(MUTATIONS) and intact else 1)


if __name__ == "__main__":
    main()
