/// L'ecran « Vos biens » — le pivot : on y arrive, on en part.
///
/// Specification V1, § F2. Les regles ★ qu'il tient : `RG-F2-01` (l'adresse est
/// le nom), `RG-F2-02` (la sous-ligne derive du bail), `RG-F2-03` (trois
/// entrees, un seul moteur), `RG-F2-04` (le locataire appartient au bail).
library;

import 'package:flutter/material.dart';

import '../domaine/bien.dart';
import '../donnees/depot_biens.dart';
import '../jetons/jetons.dart';
import '../jetons/theme.dart';

class EcranBiens extends StatefulWidget {
  final DepotBiens depot;

  const EcranBiens({super.key, required this.depot});

  @override
  State<EcranBiens> createState() => _EcranBiensState();
}

class _EcranBiensState extends State<EcranBiens> {
  late Future<List<Bien>> _biens;

  @override
  void initState() {
    super.initState();
    _biens = widget.depot.lister();
  }

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EnTete(),
            Expanded(
              child: FutureBuilder<List<Bien>>(
                future: _biens,
                builder: (context, snap) {
                  // ⛔ TROIS ETATS, ET AUCUN N'EST MUET. Un ecran qui charge sans
                  // le dire se lit comme un ecran vide.
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _Message(
                      titre: 'Vos biens n’ont pas pu être lus',
                      texte: 'Réessayez dans un instant. Rien n’est perdu.',
                    );
                  }
                  final biens = snap.data ?? const <Bien>[];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      if (biens.isEmpty)
                        _Message(
                          titre: 'Aucun bien pour l’instant',
                          texte: 'Ajoutez-en un ci-dessous : trois façons '
                              'd’arriver, et la même suite.',
                        ),
                      for (final b in biens) _Rangee(bien: b),
                      const SizedBox(height: 10),
                      const _AjouterUnBien(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vos biens',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 3),
                Text('Le pivot — on y arrive, on en part',
                    style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Une rangee de bien.
///
/// ⛔ `RG-F2-01` : le titre EST l'adresse. `RG-F2-02` : la sous-ligne vient de
/// `bien.sousLigne`, jamais d'un champ saisi — c'est le domaine qui la calcule,
/// pas l'ecran, pour qu'aucun second endroit ne puisse la contredire.
class _Rangee extends StatelessWidget {
  final Bien bien;

  const _Rangee({required this.bien});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(Rayons.rLg),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Rayons.rLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rayons.rLg),
          // ⚠️ LE DETAIL RAPIDE N'EST PAS ENCORE LA. Le prototype l'ouvre en
          // pop-in sans quitter la liste ; ici, presser ne fait rien encore, et
          // ce commentaire est la seule chose qui l'annonce — le prochain lot
          // le cable ou retire l'InkWell.
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(bien.adresse,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: c.ink)),
                        ),
                        if (bien.etat == EtatBien.brouillon) ...[
                          const SizedBox(width: 8),
                          _Pastille(texte: 'brouillon'),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      Text(bien.sousLigne,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: c.ink3)),
                      const SizedBox(height: 6),
                      Text(bien.course,
                          style: TextStyle(fontSize: 12, color: c.ink3)),
                    ],
                  ),
                ),
                Text('›', style: TextStyle(fontSize: 17, color: c.ink4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  final String texte;

  const _Pastille({required this.texte});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.amberSoft,
        borderRadius: BorderRadius.circular(Rayons.rFull),
      ),
      child: Text(texte.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: c.amber)),
    );
  }
}

/// `RG-F2-03` · trois entrees, un seul moteur.
///
/// ⛔ LES TROIS SE DERIVENT DE L'ENUM, jamais ecrites trois fois : une
/// quatrieme voie apparaitrait seule — et la specification pose justement
/// `Q-F2-1`, qui pourrait les ramener a deux.
class _AjouterUnBien extends StatelessWidget {
  const _AjouterUnBien();

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        color: c.surface2,
        border: Border.all(color: c.coral, style: BorderStyle.solid, width: 1),
        borderRadius: BorderRadius.circular(Rayons.rMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('+ Ajouter un bien',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: c.coral)),
          const SizedBox(height: 3),
          Text(
              'Trois façons d’arriver, et la même suite : vos documents '
              'alimentent la description, vous validez ce qu’on en a lu.',
              style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.45)),
          const SizedBox(height: 6),
          for (final v in VoieDArrivee.values) _Voie(voie: v),
        ],
      ),
    );
  }
}

class _Voie extends StatelessWidget {
  final VoieDArrivee voie;

  const _Voie({required this.voie});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(Rayons.rMd),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Rayons.rMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rayons.rMd),
          // ⚠️ LE MOTEUR DE CREATION N'EXISTE PAS ENCORE. Presser ne mene nulle
          // part, et c'est annonce ici plutot que decouvert a l'usage.
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voie.titre,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: c.ink)),
                      const SizedBox(height: 2),
                      Text(voie.sous,
                          style: TextStyle(
                              fontSize: 11, color: c.ink3, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('›', style: TextStyle(fontSize: 15, color: c.ink4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String titre;
  final String texte;

  const _Message({required this.titre, required this.texte});

  @override
  Widget build(BuildContext context) {
    final c = Jetons.de(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.cyanSoft,
        border: Border(left: BorderSide(color: c.cyan, width: 3)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(Rayons.rMd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 3),
          Text(texte, style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.45)),
        ],
      ),
    );
  }
}
