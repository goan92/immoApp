/// Les regles de la specification V1 § F4 que le domaine tient.
///
/// ⛔ Chacune a ete FALSIFIEE — `python outillage/falsifier.py` mute le code de
/// production et verifie que le test tombe, avec des temoins qui restent verts.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hestea/domaine/piece.dart';

void main() {
  Element el({
    String? matiere,
    String? detail,
    int quantite = 1,
    Map<int, Valeur> propres = const {},
  }) =>
      Element(
        id: 'e',
        nom: 'Murs',
        nature: Nature.surfaces,
        matiere: matiere,
        detail: detail,
        quantite: quantite,
        valeursPropres: propres,
      );

  group('RG-F4-06 · le récapitulatif porte toujours son nombre de lignes', () {
    test('une ligne avec sa matière et son détail', () {
      expect(el(matiere: 'Parquet stratifié', detail: 'Chêne clair').resume,
          '1 ligne · Parquet stratifié · Chêne clair');
    });

    test('deux lignes sans matière', () {
      expect(el(matiere: sentinelleSansMatiere, quantite: 2).resume,
          '2 lignes · 2 sans matière');
    });

    test('le nombre est là même quand tout va bien', () {
      // ⛔ C'EST LE POINT DE LA REGLE. Dans le prototype, un bloc sans manque
      // disait « Parquet stratifié » et son voisin « 2 lignes · 2 sans
      // matière » : deux grammaires cote a cote, impossibles a comparer d'un
      // coup d'œil. Le nombre est en tete, toujours.
      expect(el(matiere: 'Béton ciré', quantite: 4).resume.startsWith('4 lignes · '),
          isTrue);
    });
  });

  group('RG-F4-07 · le récapitulatif ne ment jamais', () {
    test('deux lignes de deux matières le disent', () {
      final e = el(matiere: 'Peinture', quantite: 2, propres: {
        1: const Valeur(matiere: 'Papier peint'),
      });
      expect(e.resume, '2 lignes · 2 matières');
    });

    test('deux lignes de la MÊME matière ne comptent pas double', () {
      final e = el(matiere: 'Peinture', quantite: 2, propres: {
        1: const Valeur(matiere: 'Peinture'),
      });
      expect(e.resume, '2 lignes · Peinture');
    });

    test('une matière posée sur une seule ligne laisse l’autre visible', () {
      final e = el(matiere: sentinelleSansMatiere, quantite: 2, propres: {
        0: const Valeur(matiere: 'Peinture'),
      });
      expect(e.resume, '2 lignes · Peinture · 1 sans matière');
    });
  });

  group('RG-F4-09 · une occurrence sans valeur propre suit l’élément', () {
    test('un rang absent hérite, il ne vide pas', () {
      final e = el(matiere: 'Peinture', quantite: 4);
      for (var i = 0; i < 4; i++) {
        expect(e.valeurDe(i).matiere, 'Peinture');
      }
    });

    test('une valeur propre ne déborde pas sur les voisines', () {
      final e = el(matiere: 'Peinture', quantite: 3, propres: {
        1: const Valeur(matiere: 'Papier peint'),
      });
      expect(e.valeurDe(0).matiere, 'Peinture');
      expect(e.valeurDe(1).matiere, 'Papier peint');
      expect(e.valeurDe(2).matiere, 'Peinture');
    });

    test('une ligne peut porter son détail sans porter sa matière', () {
      final e = el(matiere: 'Peinture', detail: 'Blanc', quantite: 2, propres: {
        0: const Valeur(detail: 'Bleu'),
      });
      expect(e.valeurDe(0).matiere, 'Peinture');
      expect(e.valeurDe(0).detail, 'Bleu');
      expect(e.valeurDe(1).detail, 'Blanc');
    });
  });

  group('la sentinelle n’est pas une matière', () {
    test('« matériau à renseigner » ne compte pas comme une valeur', () {
      expect(estMatiere(sentinelleSansMatiere), isFalse);
      expect(estMatiere(null), isFalse);
      expect(estMatiere(''), isFalse);
      expect(estMatiere('Peinture'), isTrue);
    });

    test('elle n’apparaît jamais dans le récapitulatif', () {
      // ⛔ SINON ELLE ENTRERAIT DANS UN ETAT DES LIEUX SIGNE. Elle dit un
      // manque ; la confondre avec une valeur ferait constater un mur en
      // « matériau à renseigner ».
      expect(el(matiere: sentinelleSansMatiere, quantite: 2).resume,
          isNot(contains('renseigner')));
    });
  });

  group('RG-F4-01 · cinq onglets en deux groupes', () {
    test('ils sont cinq', () => expect(OngletBien.values.length, 5));

    test('deux groupes, et le trait se dérive du changement', () {
      final g = OngletBien.values.map((o) => o.groupe).toList();
      // Le groupe ne change qu'UNE fois : les deux groupes sont contigus, donc
      // un seul trait. Ecrit a un rang, il couperait au mauvais endroit des
      // qu'un onglet entre ou sort.
      var changements = 0;
      for (var i = 1; i < g.length; i++) {
        if (g[i] != g[i - 1]) changements++;
      }
      expect(changements, 1);
    });

    test('« Par pièce » et « Bail » disent ce que le bien EST', () {
      expect(OngletBien.piece.groupe, GroupeOnglet.bien);
      expect(OngletBien.bail.groupe, GroupeOnglet.bien);
      expect(OngletBien.obligatoire.groupe, GroupeOnglet.aFaire);
    });
  });

  group('RG-F4-02 · l’atterrissage est « Par pièce »', () {
    test('il se lit dans l’ordre, il ne se nomme pas ailleurs', () {
      expect(OngletBien.atterrissage, OngletBien.piece);
      expect(OngletBien.atterrissage, OngletBien.values.first);
    });
  });

  group('la pièce compte des LIGNES, jamais des éléments', () {
    final p = Piece(id: 'p', nom: 'Séjour', elements: [
      el(matiere: 'Peinture', quantite: 4),
      el(matiere: sentinelleSansMatiere, quantite: 2),
    ]);

    test('six lignes pour deux éléments', () {
      expect(p.lignes, 6);
      expect(p.elements.length, 2);
    });

    test('deux lignes attendent un geste', () {
      // ⚠️ C'est le nombre de LIGNES sans matiere, pas d'elements : un element
      // de quantite 2 qui n'a pas de matiere en fait attendre deux.
      expect(p.lignesSansMatiere, 2);
    });
  });

  group('les trois natures portent leur singulier', () {
    test('lu une fois, jamais en chaîne de « si »', () {
      expect(Nature.surfaces.singulier, 'une surface');
      expect(Nature.equipements.singulier, 'un équipement');
      expect(Nature.mobilier.singulier, 'un meuble');
    });
  });
}
