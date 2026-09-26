/// Le depot des pieces d'un bien.
///
/// Meme forme que `DepotBiens` : une interface, et la base locale se posera
/// derriere sans qu'un ecran bouge.
library;

import '../domaine/piece.dart';

abstract interface class DepotPieces {
  /// Les pieces d'un bien, dans l'ordre ou elles s'affichent.
  Future<List<Piece>> pourBien(String idBien);
}

/// Les donnees d'essai, reprises du prototype.
///
/// ⛔ UNE SEULE PIECE EST DETAILLEE, comme dans la maquette, et c'est un choix
/// qui se defend : ce qu'une piece contient habituellement n'est une donnee
/// NULLE PART, et l'inventer produirait des nombres faux la ou ils comptent le
/// plus — sur un document qu'un locataire signe. La specification en fait une
/// question ouverte (`Q-F4-3`) plutot qu'un remplissage.
final class DepotPiecesEnMemoire implements DepotPieces {
  static const _idBienDetaille = '0199a7c3-0000-7a01-8b3c-000000000001';

  static final _sejour = Piece(
    id: 'p-sejour',
    nom: 'Séjour',
    elements: [
      const Element(
        id: 'e-sol',
        nom: 'Sol',
        nature: Nature.surfaces,
        matiere: 'Parquet stratifié',
        detail: 'Chêne clair',
      ),
      const Element(
        id: 'e-murs',
        nom: 'Murs',
        nature: Nature.surfaces,
        matiere: sentinelleSansMatiere,
        quantite: 2,
      ),
      const Element(
        id: 'e-murs-renfoncement',
        nom: 'Murs du renfoncement',
        nature: Nature.surfaces,
        matiere: sentinelleSansMatiere,
        quantite: 2,
      ),
      const Element(
        id: 'e-plafond',
        nom: 'Plafond',
        nature: Nature.surfaces,
        matiere: sentinelleSansMatiere,
      ),
      const Element(
        id: 'e-plinthes',
        nom: 'Plinthes',
        nature: Nature.surfaces,
        matiere: sentinelleSansMatiere,
      ),
      const Element(
        id: 'e-fenetre',
        nom: 'Fenêtre',
        nature: Nature.equipements,
        matiere: 'Double vitrage, oscillo-battant',
        quantite: 2,
      ),
      const Element(
        id: 'e-volet',
        nom: 'Volet roulant',
        nature: Nature.equipements,
        matiere: 'PVC blanc',
        quantite: 2,
      ),
      const Element(
        id: 'e-porte',
        nom: 'Porte',
        nature: Nature.equipements,
        matiere: 'Bois peint',
      ),
      const Element(
        id: 'e-prise',
        nom: 'Prise',
        nature: Nature.equipements,
        quantite: 6,
      ),
      const Element(
        id: 'e-canape',
        nom: 'Canapé',
        nature: Nature.mobilier,
        matiere: 'Tissu gris',
      ),
      const Element(
        id: 'e-table',
        nom: 'Table',
        nature: Nature.mobilier,
        matiere: 'Chêne massif',
      ),
      const Element(
        id: 'e-chaise',
        nom: 'Chaise',
        nature: Nature.mobilier,
        matiere: 'Chêne massif',
        quantite: 4,
      ),
    ],
  );

  /// ⚠️ LES CINQ AUTRES PIECES SONT VIDES, ET L'ECRAN LE DIRA. Une piece vide
  /// n'est pas une piece en erreur : elle propose ses trois ajouts.
  static final _pieces = <Piece>[
    const Piece(id: 'p-entree', nom: 'Entrée'),
    _sejour,
    const Piece(id: 'p-cuisine', nom: 'Cuisine'),
    const Piece(id: 'p-chambre1', nom: 'Chambre 1'),
    const Piece(id: 'p-sdb', nom: 'Salle de bain'),
    const Piece(id: 'p-wc', nom: 'WC'),
  ];

  @override
  Future<List<Piece>> pourBien(String idBien) async =>
      idBien == _idBienDetaille ? List.unmodifiable(_pieces) : const [];
}
