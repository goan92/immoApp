/// Le bien et son bail — le pivot du produit.
///
/// Les regles que ce fichier tient sont celles de la specification V1, § F2 et
/// § F5. Chacune est nommee dans le commentaire du membre qui la porte, et
/// chacune a son test dans `test/domaine/bien_test.dart`.
library;

// `@immutable` vient de `package:meta`, que Flutter reexporte : on prend la
// reexportation plutot que d'ajouter une dependance que le domaine n'utilise
// que pour une annotation.
import 'package:flutter/foundation.dart';

/// Un bail. Il porte le locataire — le bien ne le saisit jamais.
///
/// `RG-F2-04` · Le locataire appartient au bail ; le bien l'affiche seulement.
@immutable
class Bail {
  /// Au format `jj/mm/aaaa`, tel qu'il s'affiche.
  final String debut;

  /// ⚠️ LE LOCATAIRE EST UNE CHAINE, ET C'EST PROVISOIRE. La specification pose
  /// `Q-F5-1` : ni le loyer, ni la date de fin, ni le type de bail n'existent
  /// encore. Le jour ou le Metier les tranche, cette classe grandit — et c'est
  /// le bon moment, parce qu'on ne reprend pas de donnees dans une migration.
  final String locataire;

  const Bail({required this.debut, required this.locataire});
}

/// Ce qu'un bien porte au-dela de son bail, et que le bail ne dit pas.
enum EtatBien {
  /// Le bien existe et sa description avance.
  decrit,

  /// Le bien est ne, sa description n'est pas finie.
  brouillon,
}

/// Un bien.
///
/// ⛔ IL N'Y A PAS DE CHAMP `nom`. `RG-F2-01` · un bien porte son adresse comme
/// nom. Un libelle saisi a part serait une seconde source : on le corrigerait
/// d'un cote et pas de l'autre.
@immutable
class Bien {
  /// Engendre par le client. `RG-F3-08` — encore ○ dans la specification : rien
  /// ne le montre a l'ecran, mais il existe des maintenant parce qu'un objet
  /// doit exister avant d'avoir vu le reseau.
  final String id;

  /// `RG-F2-01` · c'est le nom du bien.
  final String adresse;

  /// « Appartement » ou « Maison ».
  final String type;

  /// « T3 ».
  final String typologie;

  /// « 62 m² » — telle qu'elle s'affiche, unite comprise.
  ///
  /// ⚠️ ELLE EST LA VALEUR LA PLUS DANGEREUSE DU PRODUIT : c'est celle qui se
  /// propage dans tous les etats des lieux du bien, et `RG-S-04` dit qu'une
  /// valeur lue dans un document n'ecrase jamais une saisie.
  final String surfaceHabitable;

  final int nombrePieces;

  /// `RG-F5-02` · un bien peut n'avoir aucun bail. Un etat des lieux se
  /// rattache au BIEN, pas au bail.
  final Bail? bail;

  final EtatBien etat;

  /// Ce que la sous-ligne dit EN PLUS du bail — « description a completer ».
  ///
  /// ⛔ IL NE CONTIENT JAMAIS CE QUE LE BAIL DIT DEJA. Ecrire ici « Aucun bail »
  /// donnerait « Aucun bail — Aucun bail » le jour ou la derivation change.
  final String complement;

  const Bien({
    required this.id,
    required this.adresse,
    required this.type,
    required this.typologie,
    required this.surfaceHabitable,
    required this.nombrePieces,
    this.bail,
    this.etat = EtatBien.decrit,
    this.complement = '',
  });

  /// `RG-F2-02` · la sous-ligne d'un bien DERIVE de son bail.
  ///
  /// ⛔ ELLE NE SE SAISIT PAS. Dans le prototype, l'existence d'un bail se
  /// lisait d'abord dans cette phrase — `indexOf("Bail en cours") == 0` — et
  /// trois lectures en dependaient : renommer le libelle aurait fait
  /// disparaitre le locataire de deux ecrans sans qu'aucun ne bronche. La
  /// source est la donnee, la phrase en sort.
  String get sousLigne =>
      (bail == null ? 'Aucun bail' : 'Bail en cours depuis le ${bail!.debut}') +
      complement;

  /// La course du bien, telle que la rangee et la pop-in l'affichent.
  ///
  /// ⚠️ LE PLURIEL SE DERIVE. Ecrit en dur, un bien d'UNE piece lirait
  /// « 1 pièces » — ce defaut a deja ete paye dans le prototype.
  String get course =>
      '$type · $typologie · $surfaceHabitable · $nombrePieces '
      '${nombrePieces > 1 ? 'pièces' : 'pièce'}';

  /// `RG-F2-04` · ce que le bien affiche du locataire, sans jamais le saisir.
  String get locataireAffiche => bail == null
      ? 'Aucun bail en cours'
      : bail!.locataire;
}

/// `RG-F2-03` · trois entrees, un seul moteur.
///
/// ⚠️ HYPOTHESE DECLAREE, A VALIDER (specification `Q-F2-1`). Les deux
/// premieres apportent LE MEME document : un bail signe. Ce qui les separe
/// n'est pas ce qu'on depose, c'est si un locataire est en place — et cela
/// change la suite : `enCours` annonce un etat des lieux de SORTIE, `etabli`
/// n'annonce rien. Si la lecture est fausse, c'est cet enum qu'on corrige.
enum VoieDArrivee {
  /// Le bail est signe et l'utilisateur l'a.
  etabli,

  /// Un locataire est en place.
  enCours,

  /// Il n'y a pas encore de bail.
  nouveau;

  String get titre => switch (this) {
        VoieDArrivee.etabli => 'Avec un bail déjà établi',
        VoieDArrivee.enCours => 'Avec un bail en cours',
        VoieDArrivee.nouveau => 'Avec un nouveau bail',
      };

  String get sous => switch (this) {
        VoieDArrivee.etabli =>
          'Le bail est signé et vous l’avez. Vous le déposez, on en lit les données.',
        VoieDArrivee.enCours =>
          'Un locataire est en place. Même dépôt, et un état des lieux de '
              'sortie viendra.',
        VoieDArrivee.nouveau =>
          'Il n’y a pas encore de bail. Vous déposez les documents du logement, '
              'il se construit.',
      };
}
