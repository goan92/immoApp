/// Les pieces d'un bien, leurs elements, et les lignes de chaque element.
///
/// Specification V1, § F4. Les regles que ce fichier tient sont nommees dans le
/// commentaire du membre qui les porte, et chacune a son test dans
/// `test/domaine/piece_test.dart`.
library;

import 'package:flutter/foundation.dart';

/// Les trois natures d'element. Elles ne se melangent jamais.
enum Nature {
  surfaces('Surfaces', 'une surface'),
  equipements('Équipements', 'un équipement'),
  mobilier('Mobilier', 'un meuble');

  final String titre;

  /// Le singulier, lu une fois. Ecrit en chaine de `si` dans le prototype, il y
  /// avait quatre lecteurs — un bouton par nature, et la boite d'ajout.
  final String singulier;

  const Nature(this.titre, this.singulier);
}

/// ⛔ CE N'EST PAS UNE MATIERE, C'EST UNE SENTINELLE. Le prototype ecrit cette
/// chaine dans le champ d'un element qui n'a pas encore de matiere, pour que le
/// manque se DISE au lieu de rester un vide muet. La confondre avec une valeur
/// ferait entrer « matériau à renseigner » dans un etat des lieux signe.
const sentinelleSansMatiere = 'matériau à renseigner';

/// `RG-F4-06` · ce qui compte comme une matiere.
///
/// La regle porte sur une CHAINE et non sur un element : dans le prototype elle
/// etait ecrite sur l'element, et le recapitulatif la lisait en fabriquant un
/// faux element — un tour qui marche et ne se relit pas.
bool estMatiere(String? v) =>
    v != null && v.isNotEmpty && !v.contains('renseigner');

/// La valeur d'UNE ligne d'un element.
@immutable
class Valeur {
  final String? matiere;
  final String? detail;

  const Valeur({this.matiere, this.detail});
}

/// Un element du bien — « Murs », « Prise », « Canapé ».
///
/// `RG-S-08` · un element en quantite N fait N lignes constatees separement :
/// chacune recoit son propre etat et ses propres photos, a chaque etat des
/// lieux.
@immutable
class Element {
  final String id;
  final String nom;
  final Nature nature;

  /// La valeur de l'ELEMENT — celle dont heritent les lignes qui n'ont pas la
  /// leur.
  final String? matiere;
  final String? detail;

  /// `RG-F4-08` · elle ne se regle pas sur le bloc, mais dans la boite, et
  /// jamais sous 1 : une quantite nulle laisserait un nom que rien ne fait
  /// constater.
  final int quantite;

  /// Les lignes qui portent leur PROPRE valeur, par rang.
  ///
  /// ⛔ `RG-F4-09` · UNE ABSENCE N'EST PAS UN VIDE. Un rang absent de cette
  /// table veut dire « cette ligne suit l'element », pas « cette ligne n'a rien
  /// ». Les confondre ferait d'un mur jamais touche un mur sans matiere, et la
  /// liste des taches reclamerait une valeur que l'element porte deja.
  final Map<int, Valeur> valeursPropres;

  const Element({
    required this.id,
    required this.nom,
    required this.nature,
    this.matiere,
    this.detail,
    this.quantite = 1,
    this.valeursPropres = const {},
  });

  /// La valeur d'une ligne : la sienne si elle en a une, celle de l'element
  /// sinon.
  Valeur valeurDe(int rang) {
    final p = valeursPropres[rang];
    return Valeur(
      matiere: p != null && p.matiere != null ? p.matiere : matiere,
      detail: p != null && p.detail != null ? p.detail : detail,
    );
  }

  /// Le nom d'une ligne — « Mur 1 », « Mur 2 ».
  String libelleDe(int rang) {
    final n = nom.endsWith('s') ? nom.substring(0, nom.length - 1) : nom;
    return '$n ${rang + 1}';
  }

  /// `RG-F4-06` · le recapitulatif porte TOUJOURS son nombre de lignes.
  /// `RG-F4-07` · et il ne ment jamais sur ce que les lignes portent.
  ///
  /// ⛔ TOUT SE DERIVE DES LIGNES, ligne par ligne. Ecrire « N lignes » depuis
  /// la quantite pendant que les valeurs viennent de la table des lignes
  /// donnerait deux lectures d'un meme fait. Et montrer une seule matiere
  /// quand deux murs en portent deux ferait passer pour commun ce qui ne l'est
  /// plus — le defaut que ce produit a deja paye ailleurs.
  String get resume {
    final mats = <String>{};
    final dets = <String>{};
    var sans = 0;
    for (var i = 0; i < quantite; i++) {
      final v = valeurDe(i);
      if (v.detail != null && v.detail!.isNotEmpty) dets.add(v.detail!);
      if (!estMatiere(v.matiere)) {
        sans++;
        continue;
      }
      mats.add(v.matiere!);
    }

    final dit = <String>[];
    if (mats.length > 1) {
      dit.add('${mats.length} matières');
    } else if (mats.length == 1) {
      dit.add(mats.first);
    }
    if (dets.length == 1) {
      dit.add(dets.first);
    } else if (dets.length > 1) {
      dit.add('${dets.length} détails');
    }
    if (sans > 0) dit.add('$sans sans matière');

    // ⛔ `dit` NE PEUT PAS ETRE VIDE, et c'est pour cela qu'il n'y a pas de
    // repli : chaque ligne porte une matiere ou n'en porte pas, donc
    // `mats.length + sans` vaut toujours au moins un. Un repli ecrit ici serait
    // une branche qu'aucune donnee n'atteint — du code qu'on croit garde.
    return '$quantite ${quantite > 1 ? 'lignes' : 'ligne'} · ${dit.join(' · ')}';
  }

  /// Une ligne qui attend un geste, c'est une ligne sans matiere.
  int get lignesSansMatiere {
    var n = 0;
    for (var i = 0; i < quantite; i++) {
      if (!estMatiere(valeurDe(i).matiere)) n++;
    }
    return n;
  }
}

/// Une piece du bien.
@immutable
class Piece {
  final String id;
  final String nom;
  final List<Element> elements;

  const Piece({required this.id, required this.nom, this.elements = const []});

  List<Element> parNature(Nature n) =>
      elements.where((e) => e.nature == n).toList(growable: false);

  /// Le nombre de LIGNES de la piece, jamais le nombre d'elements : ce sont
  /// deux faits differents, et c'est le nombre de lignes qu'un locataire signe.
  int get lignes => elements.fold(0, (n, e) => n + e.quantite);

  int get lignesSansMatiere =>
      elements.fold(0, (n, e) => n + e.lignesSansMatiere);
}

/// Les cinq onglets de l'ecran de modification, en DEUX groupes.
///
/// `RG-F4-01` · « Par pièce » et « Bail » disent ce que le bien EST ; les trois
/// familles disent ce qui RESTE A FAIRE dessus. Le trait se derive du
/// changement de groupe — pose a un RANG, il couperait au mauvais endroit des
/// qu'un onglet entre ou sort.
///
/// `RG-F4-02` · l'atterrissage est le PREMIER de la liste. Le nommer ailleurs
/// en ferait une seconde source, deja fausse le jour ou l'ordre change.
enum OngletBien {
  piece('Par pièce', GroupeOnglet.bien),
  bail('Bail', GroupeOnglet.bien),
  obligatoire('Obligatoire', GroupeOnglet.aFaire),
  facultatif('Facultatif', GroupeOnglet.aFaire),
  recommandation('Recommandation', GroupeOnglet.aFaire);

  final String titre;
  final GroupeOnglet groupe;

  const OngletBien(this.titre, this.groupe);

  static OngletBien get atterrissage => OngletBien.values.first;
}

enum GroupeOnglet { bien, aFaire }
