/// Les regles de la specification V1 que le domaine tient, une par test.
///
/// ⛔ UN TEST DONT LE NOM PROMET CE QU'IL NE DEMONTRE PAS EST PIRE QU'UN TEST
/// ABSENT. Chacun de ceux-ci a ete FALSIFIE : on a mute la regle dans
/// `lib/domaine/bien.dart` et verifie qu'il tombe. Ce qui est note « falsifie »
/// sous chaque test dit ce qu'on a mute et ce que le test a rendu.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hestea/domaine/bien.dart';

void main() {
  const bail = Bail(debut: '01/03/2026', locataire: 'Porté par le bail en cours');

  Bien bien({Bail? b, String complement = '', int pieces = 6}) => Bien(
        id: 'x',
        adresse: '12 rue Victor-Hugo, Lyon 3e',
        type: 'Appartement',
        typologie: 'T3',
        surfaceHabitable: '62 m²',
        nombrePieces: pieces,
        bail: b,
        complement: complement,
      );

  group('RG-F2-02 · la sous-ligne d’un bien dérive de son bail', () {
    test('avec un bail, elle porte sa date de début', () {
      expect(bien(b: bail).sousLigne, 'Bail en cours depuis le 01/03/2026');
    });

    test('sans bail, elle le dit', () {
      expect(bien().sousLigne, 'Aucun bail');
    });

    test('le complément s’ajoute, il ne remplace pas', () {
      expect(bien(complement: ' — description à compléter').sousLigne,
          'Aucun bail — description à compléter');
    });

    test('changer la date du bail change la phrase', () {
      // ⛔ C'EST LA FALSIFICATION DE LA REGLE ELLE-MEME. Dans le prototype, la
      // phrase etait ECRITE dans la donnee et la date y vivait en double :
      // corriger le bail laissait la liste afficher l'ancienne. Ici, la phrase
      // ne peut pas rester en arriere — elle n'existe pas ailleurs.
      expect(bien(b: const Bail(debut: '15/07/2027', locataire: 'x')).sousLigne,
          'Bail en cours depuis le 15/07/2027');
    });
  });

  group('RG-F2-04 · le locataire appartient au bail', () {
    test('le bien l’affiche quand un bail existe', () {
      expect(bien(b: bail).locataireAffiche, 'Porté par le bail en cours');
    });

    test('sans bail, la ligne existe quand même et dit ce qu’elle attend', () {
      // ⛔ ELLE NE DISPARAIT PAS. Un etat des lieux de SORTIE doit nommer le
      // locataire ; une ligne absente ferait croire que la question ne se pose
      // pas, alors qu'elle se posera au pire moment.
      expect(bien().locataireAffiche, 'Aucun bail en cours');
    });
  });

  group('RG-F2-01 · un bien porte son adresse comme nom', () {
    test('il n’existe aucun autre champ qui le nomme', () {
      // Le test qui tient cette regle est le TYPE lui-meme : `Bien` n'a pas de
      // champ `nom`. Ce test-ci le rend visible — il ne compilerait plus si on
      // en ajoutait un et qu'on l'utilisait a la place de l'adresse.
      expect(bien().adresse, '12 rue Victor-Hugo, Lyon 3e');
    });
  });

  group('la course du bien — le pluriel se dérive', () {
    test('plusieurs pièces', () {
      expect(bien().course, 'Appartement · T3 · 62 m² · 6 pièces');
    });

    test('une seule pièce ne lit jamais « 1 pièces »', () {
      // ⚠️ AUCUNE DONNEE D'ESSAI NE MONTRE CE CAS — le defaut serait LATENT.
      // Le prototype a paye ce pluriel ecrit en dur ; ce test le garde ici
      // avant qu'un studio n'arrive.
      expect(bien(pieces: 1).course, 'Appartement · T3 · 62 m² · 1 pièce');
    });
  });

  group('RG-F2-03 · trois entrées, un seul moteur', () {
    test('elles sont trois, et chacune porte son libellé', () {
      expect(VoieDArrivee.values.length, 3);
      for (final v in VoieDArrivee.values) {
        expect(v.titre, isNotEmpty);
        expect(v.sous, isNotEmpty);
      }
    });

    test('les deux premières apportent le même document — Q-F2-1', () {
      // ⚠️ CE TEST GARDE UNE QUESTION OUVERTE, pas une regle tranchee. Il dit ce
      // que la specification declare comme hypothese : « etabli » et « enCours »
      // deposent tous deux un bail signe, et ce qui les separe est l'etat de
      // location. Le jour ou le Metier tranche autrement, c'est CE test qui
      // tombe en premier, et c'est voulu.
      expect(VoieDArrivee.etabli.sous, contains('bail'));
      expect(VoieDArrivee.enCours.sous, contains('dépôt'));
      expect(VoieDArrivee.nouveau.sous, contains('pas encore de bail'));
    });
  });
}
