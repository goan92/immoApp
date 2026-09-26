/// L'ecran « Modifier le bien » — le cœur du produit.
///
/// Specification V1, § F4. Cinq onglets en DEUX groupes, et l'onglet « Par
/// pièce » avec un bloc par element.
library;

// ⛔ `hide Element` — ET C'EST LE PREMIER COUT DU VOCABULAIRE FRANCAIS, paye ici
// une fois pour toutes. `Element` est aussi le nom de l'implementation du
// BuildContext chez Flutter : sans ce masque, le compilateur refuse le fichier
// pour ambiguite. On masque celui de Flutter, qu'aucun ecran n'utilise, plutot
// que de renommer le mot de la specification — c'est justement pour pouvoir
// chercher `RG-F4-05` et tomber sur `Element` qu'on a choisi le francais.
import 'package:flutter/material.dart' hide Element;

import '../domaine/bien.dart';
import '../domaine/piece.dart';
import '../donnees/depot_pieces.dart';
import '../jetons/jetons.dart';
import '../jetons/theme.dart';

class EcranModifier extends StatefulWidget {
  final Bien bien;
  final DepotPieces depot;

  const EcranModifier({super.key, required this.bien, required this.depot});

  @override
  State<EcranModifier> createState() => _EcranModifierState();
}

class _EcranModifierState extends State<EcranModifier> {
  // `RG-F4-02` · l'atterrissage est le premier onglet, LU dans l'enum.
  OngletBien _onglet = OngletBien.atterrissage;
  int _piece = 0;
  late Future<List<Piece>> _pieces;

  @override
  void initState() {
    super.initState();
    _pieces = widget.depot.pourBien(widget.bien.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: FutureBuilder<List<Piece>>(
          future: _pieces,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final pieces = snap.data ?? const <Piece>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EnTete(bien: widget.bien, pieces: pieces),
                _BandeOnglets(
                  actif: _onglet,
                  compte: (o) => _compteOnglet(o, pieces),
                  choisir: (o) => setState(() => _onglet = o),
                ),
                Expanded(
                  child: switch (_onglet) {
                    OngletBien.piece => _ParPiece(
                        pieces: pieces,
                        rang: _piece,
                        choisir: (i) => setState(() => _piece = i),
                      ),
                    _ => _PasEncore(onglet: _onglet),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// `RG-F4-03` · le compte d'un onglet et le corps qu'il ouvre se lisent au
  /// MEME endroit. Ici, une seule fonction sert la bande et servira le corps.
  ///
  /// ⚠️ LES TROIS FAMILLES RENDENT ENCORE `null` : leur corps n'existe pas, et
  /// annoncer un nombre au-dessus d'un ecran vide serait pire que ne rien
  /// annoncer.
  int? _compteOnglet(OngletBien o, List<Piece> pieces) => null;
}

/// `RG-S-05` · les trois nombres de l'en-tete sont DERIVES, aucun n'est ecrit.
class _EnTete extends StatelessWidget {
  final Bien bien;
  final List<Piece> pieces;

  const _EnTete({required this.bien, required this.pieces});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    final aFaire = pieces.fold(0, (n, p) => n + p.lignesSansMatiere);
    final large = MediaQuery.sizeOf(context).width >= 700;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Fleche(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bien.adresse,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 2),
                Text('Biens › ${bien.course}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
          ),
          // ⛔ `RG-S-06` · LA DECISION SE PREND SUR LA LARGEUR, jamais sur la
          // plateforme. Les trois nombres apparaissent au-dela de 700 px, sur
          // tablette comme dans une fenetre web large — et disparaissent quand
          // la place manque, plutot que d'ecraser l'adresse.
          if (large) ...[
            const SizedBox(width: 14),
            _Nombre(n: aFaire, libelle: 'À faire'),
            const SizedBox(width: 14),
            _Nombre(n: pieces.length, libelle: 'Pièces'),
          ],
        ],
      ),
    );
  }
}

class _Fleche extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rayons.rMd),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rayons.rMd),
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
              child: Text('‹', style: TextStyle(fontSize: 17, color: c.ink2))),
        ),
      ),
    );
  }
}

class _Nombre extends StatelessWidget {
  final int n;
  final String libelle;

  const _Nombre({required this.n, required this.libelle});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    // ⚠️ UN ZERO SE REND ICI, contrairement au badge d'un onglet : le libelle
    // est SOUS le nombre, donc « 0 · À FAIRE » se lit « rien a faire » — une
    // bonne nouvelle. La teinte s'eteint, le nombre reste.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$n',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1,
                color: n == 0 ? c.ink3 : c.ink)),
        const SizedBox(height: 3),
        Text(libelle.toUpperCase(),
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .7,
                color: c.ink3)),
      ],
    );
  }
}

/// `RG-F4-01` · cinq onglets, deux groupes, un trait entre les deux.
///
/// ⛔ LE TRAIT SUIT LE CHANGEMENT DE GROUPE, jamais un rang : ecrit « apres le
/// deuxieme », il couperait au mauvais endroit des qu'un onglet entre ou sort.
class _BandeOnglets extends StatelessWidget {
  final OngletBien actif;
  final int? Function(OngletBien) compte;
  final void Function(OngletBien) choisir;

  const _BandeOnglets(
      {required this.actif, required this.compte, required this.choisir});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    final morceaux = <Widget>[];
    for (var i = 0; i < OngletBien.values.length; i++) {
      final o = OngletBien.values[i];
      if (i > 0 && OngletBien.values[i - 1].groupe != o.groupe) {
        morceaux.add(Container(width: 1, height: 20, color: c.line2,
            margin: const EdgeInsets.symmetric(horizontal: 5)));
      }
      morceaux.add(_Onglet(
        onglet: o,
        actif: o == actif,
        compte: compte(o),
        appui: () => choisir(o),
      ));
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Rayons.rFull),
      ),
      // ⚠️ `Wrap` ET NON `Row` : a 390 px les cinq libelles ne tiennent pas sur
      // une rangee. Mesure faite sur le prototype — deux rangees, zero debord.
      child: Wrap(spacing: 2, runSpacing: 2, children: morceaux),
    );
  }
}

class _Onglet extends StatelessWidget {
  final OngletBien onglet;
  final bool actif;
  final int? compte;
  final VoidCallback appui;

  const _Onglet(
      {required this.onglet,
      required this.actif,
      required this.compte,
      required this.appui});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    // `RG-F4-04` · un zero ne s'affiche pas sur un onglet : « Obligatoire · 0 »
    // se lirait comme un echec, alors que c'est la bonne nouvelle.
    final suffixe = (compte != null && compte! > 0) ? ' · $compte' : '';
    return Semantics(
      selected: actif,
      button: true,
      child: Material(
        color: actif ? c.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(Rayons.rFull),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rayons.rFull),
          onTap: appui,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('${onglet.titre}$suffixe',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: actif ? c.ink : c.ink3)),
          ),
        ),
      ),
    );
  }
}

class _ParPiece extends StatelessWidget {
  final List<Piece> pieces;
  final int rang;
  final void Function(int) choisir;

  const _ParPiece(
      {required this.pieces, required this.rang, required this.choisir});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    if (pieces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Ce bien n’a pas encore de pièces.',
              style: TextStyle(fontSize: 13.5, color: c.ink3)),
        ),
      );
    }
    final piece = pieces[rang.clamp(0, pieces.length - 1)];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (var i = 0; i < pieces.length; i++)
              _Puce(
                texte: pieces[i].nom,
                compte: pieces[i].lignesSansMatiere,
                actif: i == rang,
                appui: () => choisir(i),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (piece.elements.isEmpty)
          _PieceVide(nom: piece.nom)
        else
          for (final n in Nature.values)
            if (piece.parNature(n).isNotEmpty) _Section(nature: n, piece: piece),
      ],
    );
  }
}

class _Puce extends StatelessWidget {
  final String texte;
  final int compte;
  final bool actif;
  final VoidCallback appui;

  const _Puce(
      {required this.texte,
      required this.compte,
      required this.actif,
      required this.appui});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Material(
      color: actif ? c.coralSoft : c.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rayons.rFull),
        side: BorderSide(color: actif ? c.coral : c.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rayons.rFull),
        onTap: appui,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(texte,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: actif ? c.coral : c.ink2)),
            // Le compte d'une puce ne suit PAS le filtre : c'est un fait sur le
            // bien, pas sur la vue.
            if (compte > 0) ...[
              const SizedBox(width: 7),
              Text('$compte',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: actif ? c.coral : c.ink3)),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Nature nature;
  final Piece piece;

  const _Section({required this.nature, required this.piece});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    final elements = piece.parNature(nature);
    final lignes = elements.fold(0, (n, e) => n + e.quantite);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 12, 2, 7),
          child: Row(children: [
            Text(nature.titre.toUpperCase(),
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: c.ink3)),
            const Spacer(),
            Text('${elements.length} · $lignes lignes',
                style: TextStyle(fontSize: 10.5, color: c.ink3)),
          ]),
        ),
        for (final e in elements) _Bloc(element: e),
        _Ajouter(nature: nature),
      ],
    );
  }
}

/// `RG-F4-05` · un bloc par element, quel que soit son nombre de lignes.
///
/// ⛔ IL RECAPITULE ET IL OUVRE, et il n'a qu'un seul geste : depuis le retrait
/// de l'edition en masse, presser le bloc ne peut plus vouloir dire deux
/// choses. La quantite est ici en LECTURE — `RG-F4-08` la renvoie a la boite.
class _Bloc extends StatelessWidget {
  final Element element;

  const _Bloc({required this.element});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    final attend = element.lignesSansMatiere > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Rayons.rMd),
        border: attend
            ? Border(left: BorderSide(color: c.amber, width: 3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Rayons.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rayons.rMd),
          // ⚠️ LA BOITE DES LIGNES N'EXISTE PAS ENCORE. Presser ne fait rien, et
          // c'est annonce ici plutot que decouvert a l'usage.
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(element.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: c.ink)),
                      ),
                      if (attend) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: c.amberSoft,
                              borderRadius:
                                  BorderRadius.circular(Rayons.rFull)),
                          child: Text('À VÉRIFIER',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .5,
                                  color: c.amber)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(element.resume,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: c.ink3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${element.quantite}',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: c.ink2)),
              const SizedBox(width: 8),
              Text('›', style: TextStyle(fontSize: 15, color: c.ink4)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// `RG-F4-12` · une piece vide propose l'ajout des trois natures.
class _PieceVide extends StatelessWidget {
  final String nom;

  const _PieceVide({required this.nom});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: c.cyanSoft,
            border: Border(left: BorderSide(color: c.cyan, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('« $nom » ne fait constater aucune ligne',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: c.ink)),
              const SizedBox(height: 3),
              Text(
                  'Ajoutez ses éléments : chacun annoncera les lignes qu’il '
                  'ajoute avant d’être écrit.',
                  style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.45)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final n in Nature.values) _PorteAjout(nature: n)],
        ),
      ],
    );
  }
}

/// Les portes d'ajout se derivent de `Nature`, jamais ecrites trois fois : une
/// quatrieme nature apparaitrait seule.
class _PorteAjout extends StatelessWidget {
  final Nature nature;

  const _PorteAjout({required this.nature});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    final mot = nature.singulier;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rayons.rFull),
        border: Border.all(color: c.coral),
      ),
      child: Text('+ ${mot[0].toUpperCase()}${mot.substring(1)}',
          style: TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w600, color: c.coral)),
    );
  }
}

class _Ajouter extends StatelessWidget {
  final Nature nature;

  const _Ajouter({required this.nature});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Text('+ Ajouter ${nature.singulier}',
          style: TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: c.coral)),
    );
  }
}

class _PasEncore extends StatelessWidget {
  final OngletBien onglet;

  const _PasEncore({required this.onglet});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('« ${onglet.titre} » n’est pas encore écrit',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: c.ink2)),
            const SizedBox(height: 6),
            Text(
                'L’onglet existe parce que la bande en compte cinq. Son corps '
                'vient dans un prochain lot — mieux vaut le dire que le laisser '
                'vide sans rien annoncer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: c.ink3, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
