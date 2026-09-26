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
"""
import io
import os
import re
import subprocess
import sys

RACINE = r"C:/Dev/hestea"
CIBLE = os.path.join(RACINE, "lib", "domaine", "bien.dart")

MUTATIONS = [
    (u"RG-F2-02 \xb7 le complement s'ajoute",
     u"      (bail == null ? 'Aucun bail' : 'Bail en cours depuis le ${bail!.debut}') +\n"
     u"      complement;",
     u"      (bail == null ? 'Aucun bail' : 'Bail en cours depuis le ${bail!.debut}');"),

    (u"RG-F2-02 \xb7 la date vient du bail",
     u"'Bail en cours depuis le ${bail!.debut}'",
     u"'Bail en cours depuis le 01/03/2026'"),

    (u"le pluriel se derive",
     u"${nombrePieces > 1 ? 'pièces' : 'pièce'}",
     u"pièces"),

    (u"RG-F2-04 \xb7 la ligne existe sans bail",
     u"      ? 'Aucun bail en cours'",
     u"      ? ''"),
]


def suite():
    """Rend (tombes, passes). Un echec de COMPILATION rend (-1, -1)."""
    r = subprocess.run(["flutter", "test", "--reporter", "compact"],
                       cwd=RACINE, capture_output=True, text=True, shell=True)
    sortie = (r.stdout or "") + (r.stderr or "")
    if "Error:" in sortie or "error •" in sortie:
        return -1, -1
    m = re.search(r"\+(\d+)(?:\s*-(\d+))?", sortie[::-1].replace("\n", " ")[::-1])
    passes = len(re.findall(r"\+(\d+)", sortie))
    m2 = re.findall(r"\+(\d+)\s*-(\d+)", sortie)
    if m2:
        return int(m2[-1][1]), int(m2[-1][0])
    m3 = re.findall(r"\+(\d+)", sortie)
    return 0, int(m3[-1]) if m3 else 0


origine = io.open(CIBLE, encoding="utf-8").read()
base_t, base_p = suite()
print(u"reference : %d tombe(s), %d passe(s)\n" % (base_t, base_p))
if base_t != 0:
    sys.exit(u"la suite n'est pas verte au depart")

vues, muettes = [], []
for nom, avant, apres in MUTATIONS:
    if origine.count(avant) != 1:
        muettes.append((nom, u"ancre vue %d fois" % origine.count(avant)))
        continue
    io.open(CIBLE, "w", encoding="utf-8", newline="\n").write(
        origine.replace(avant, apres, 1))
    t, p = suite()
    io.open(CIBLE, "w", encoding="utf-8", newline="\n").write(origine)
    if t == -1:
        muettes.append((nom, u"ne compile pas \u2014 ne prouve rien"))
    elif t == 0:
        muettes.append((nom, u"AUCUN test n'est tombe"))
    elif p == 0:
        muettes.append((nom, u"TOUT est tombe \u2014 pas de temoin"))
    else:
        vues.append((nom, t, p))

for nom, t, p in vues:
    print(u"  VUE    %-42s %d tombe(s), %d temoin(s) vert(s)" % (nom, t, p))
for nom, motif in muettes:
    print(u"  MUETTE %-42s %s" % (nom, motif))

print(u"\n%d/%d mutations vues" % (len(vues), len(MUTATIONS)))
apres = io.open(CIBLE, encoding="utf-8").read()
print(u"code de production restaure : %s" % ("oui" if apres == origine else "NON"))
sys.exit(0 if len(vues) == len(MUTATIONS) else 1)
