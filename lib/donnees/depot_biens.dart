/// Le depot des biens — une interface, et les implementations derriere.
///
/// ⛔ POURQUOI UNE INTERFACE DES LE PREMIER ECRAN. La specification pose deux
/// couches de donnees — l'appareil et le serveur — derriere une MEME interface
/// de depot, pour que le domaine et les ecrans ignorent laquelle est active.
/// Poser l'interface plus tard voudrait dire reecrire les ecrans le jour ou la
/// seconde couche arrive ; elle ne coute rien maintenant.
///
/// ⚠️ CE QUI EXISTE AUJOURD'HUI EST UN DEPOT EN MEMOIRE, ET IL FAUT LE DIRE :
/// il sert les donnees d'essai du prototype et ne persiste RIEN. La base locale
/// chiffree se pose derriere cette meme interface, sans qu'un ecran bouge.
library;

import '../domaine/bien.dart';

abstract interface class DepotBiens {
  /// Tous les biens accessibles.
  ///
  /// ⚠️ `RG-F2-05` — la regle d'acces (proprietaire ou mandat actif, ET membre
  /// du compte) n'est pas appliquee ici : il n'y a ni compte ni mandat dans ce
  /// premier lot. Elle est ○ dans la specification, et ce depot est l'endroit
  /// ou elle s'appliquera — pas l'ecran.
  Future<List<Bien>> lister();

  /// Un bien par son identifiant, ou `null` s'il n'existe pas.
  Future<Bien?> parId(String id);
}

/// Les donnees d'essai, reprises du prototype.
///
/// ⛔ ELLES NE S'INVENTENT PAS. Ce sont exactement les trois biens de la
/// maquette, avec le meme bail, la meme surface et le meme complement : la
/// specification cite ces valeurs en exemple, et un jeu d'essai qui en
/// divergerait rendrait ses exemples invérifiables.
final class DepotBiensEnMemoire implements DepotBiens {
  static final _biens = <Bien>[
    Bien(
      id: '0199a7c3-0000-7a01-8b3c-000000000001',
      adresse: '12 rue Victor-Hugo, Lyon 3e',
      type: 'Appartement',
      typologie: 'T3',
      surfaceHabitable: '62 m²',
      nombrePieces: 6,
      bail: const Bail(debut: '01/03/2026', locataire: 'Porté par le bail en cours'),
    ),
    const Bien(
      id: '0199a7c3-0000-7a01-8b3c-000000000002',
      adresse: '8 chemin des Peupliers, Écully',
      type: 'Maison',
      typologie: 'T5',
      surfaceHabitable: '118 m²',
      nombrePieces: 9,
    ),
    const Bien(
      id: '0199a7c3-0000-7a01-8b3c-000000000003',
      adresse: '4 place Bellecour, Lyon 2e',
      type: 'Appartement',
      typologie: 'T2',
      surfaceHabitable: '41 m²',
      nombrePieces: 4,
      etat: EtatBien.brouillon,
      complement: ' — description à compléter',
    ),
  ];

  @override
  Future<List<Bien>> lister() async => List.unmodifiable(_biens);

  @override
  Future<Bien?> parId(String id) async {
    for (final b in _biens) {
      if (b.id == id) return b;
    }
    return null;
  }
}
