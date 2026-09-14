# 🎨 Guide d'Amélioration Graphique VCL (Delphi)

Ce guide détaille les meilleures pratiques pour moderniser l'interface de votre application Delphi **Fiches Techniques** afin d'obtenir un rendu digne d'une application de bureau Windows 11 contemporaine, fluide et sans scintillement.

---

## 1. 📐 Disposition des Panels & Hiérarchie Moderne

### ❌ Ce qu'il faut éliminer (Style Windows 98 / XP) :
- Les biseaux 3D : `BevelOuter = bvRaised` ou `bvLowered`.
- Les bordures `BorderStyle = bsSingle` épaisses.
- Les panels collés les uns aux autres sans marge (`Align = alClient` sans espacement).
- Le scintillement au redimensionnement (absence de `DoubleBuffered`).

### ✅ Les règles du design moderne par "Cartes" (Card UI) :
1. **Supprimer tous les biseaux :**
   ```pascal
   Panel.BevelOuter := bvNone;
   Panel.BevelInner := bvNone;
   Panel.BevelKind  := bkNone;
   Panel.BorderStyle := bsNone;
   Panel.ParentBackground := False;
   Panel.Color := clWhite; // ou votre couleur de carte
   ```
2. **Utiliser `AlignWithMargins = True` :**
   - Mettez toujours `Panel.AlignWithMargins := True;`
   - Définissez des marges régulières : `Margins.Left := 8; Margins.Right := 8; Margins.Top := 8; Margins.Bottom := 8;`
   - Le conteneur parent doit avoir une couleur légèrement plus foncée (ex: gris très clair `$00F8FAFC`), ce qui fait "flotter" les cartes blanches en relief subtil sans ombre lourde.

3. **Disposition type du Dashboard :**
   - **pnlSidebar** (`Align = alLeft`, largeur 220px ou 64px rétractée, fond foncé ou bleu nuit `$001E293B`).
   - **pnlMain** (`Align = alClient`, fond `$00F8FAFC`).
     - **pnlHeader** (`Align = alTop`, hauteur 56px, fond blanc, titre, utilisateur, bouton bascule langue).
     - **pnlKpiContainer** (`Align = alTop`, hauteur 110px, contient 4 panels alignés à gauche pour les stats).
     - **pnlGridContainer** (`Align = alClient`, carte blanche contenant la grille des fiches).

---

## 2. 🧩 Remplacement par les Composants VCL Modernes

Si vous utilisez Delphi 10 Seattle ou supérieur (10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athens) :

| Ancien Composant | Composant VCL Moderne Recommandé | Avantage |
| :--- | :--- | :--- |
| `TPanel` coulissant fait main | `TSplitView` | Sidebar animée fluide, mode compact (icônes seules) et complet, fermeture auto sur petit écran. |
| `TPageControl` (onglets cachés) | `TCardPanel` + `TCard` | Conçu spécifiquement pour basculer d'un écran à l'autre sans scintillement et sans créer de faux onglets. |
| `TImageList` (BMP 16x16 / 32x32) | `TImageCollection` + `TVirtualImageList` | Support SVG / PNG multi-résolutions avec rendu net sur écran 4K / HiDPI (PerMonitorV2). |
| `TToolBar` classique | `TActionToolBar` ou boutons plats `TSpeedButton` | Boutons plats avec états Hover/Down bien définis (`Flat = True`). |
| Sablier `crHourGlass` | `TActivityIndicator` | Indicateur de chargement circulaire fluide (ring/dots). |

---

## 3. ✍️ Polices & Typographie (HiDPI & Bilingue)

1. **Police recommandée pour l'interface :**
   - Pour Windows 10/11 : **`Segoe UI`** (taille 9pt pour les libellés, 11pt gras pour les titres, 16-18pt pour les chiffres clés des cartes).
   - Pour l'arabe : **`Segoe UI`** (supporte très bien l'arabe sous Windows), ou **`Cairo`** / **`Tahoma`**.
   - Qualité de rendu : Définir toujours `Font.Quality := fqClearTypeNatural;` pour éviter le crénelage.

2. **Gestion bilingue Arabe (RTL) / Français (LTR) :**
   - Définir `Form.BiDiMode := bdRightToLeft;` pour l'arabe.
   - **Attention importante pour les fiches techniques :**
     - Les colonnes de montants (DZD), les codes d'articles (`ART-001`), et les numéros de téléphone doivent conserver un alignement et une lecture LTR.
     - Pour un `TDBEdit` ou `TDBGrid` de montant : `Alignment := taRightJustify;` et forcer le format monétaire (`#,##0.00 "دج"`).

---

## 4. 📊 Modernisation du TDBGrid (Fin des grilles grises des années 90)

Pour transformer le `TDBGrid` standard en tableau moderne sans acheter de composant tiers :

1. Dans l'inspecteur d'objets :
   - `BorderStyle := bsNone;`
   - `DrawingStyle := gdsClassic;` (ou gdsThemed si VCL Styles)
   - `Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowSelect, dgAlwaysShowSelection];`
   - Retirez `dgColLines` si vous voulez un tableau épuré sans traits verticaux.

2. Dans l'événement `OnDrawColumnCell` :
   ```pascal
   procedure TfrmFicheTechnique.DBGridLignesDrawColumnCell(Sender: TObject;
     const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
   begin
     // Utiliser l'unité uVCLModernizer fournie :
     TVCLModernizer.DrawModernDBGridCell(Sender, Rect, DataCol, Column, State, 'Segoe UI');
   end;
   ```
   **Résultat obtenu :**
   - Lignes paires/impaires alternées automatiquement.
   - Sélection sur fond bleu ciel doux (au lieu du bleu vif agressif par défaut).
   - Badges arrondis colorés pour la colonne "Statut" (vert pour Validé, orange pour Attente).
   - Marges de respiration internes dans chaque cellule (le texte ne touche plus les bords).

---

## 5. 🎨 Thèmes VCL (`VCL Styles`)

Delphi intègre en natif les **VCL Styles** (Projet > Options > Application > Appearance) :
- Pour un look clair moderne : **`Windows10`**, **`Windows10 SlateGray`** ou **`Light`**.
- Pour un look sombre moderne : **`Windows10 Dark`**, **`Carbon`**, ou **`Glow`**.

Pour appliquer ou changer le style dynamiquement à l'exécution :
```pascal
uses Vcl.Themes;

// Basculer en mode sombre
TStyleManager.SetStyle('Windows10 Dark');

// Basculer en mode clair
TStyleManager.SetStyle('Windows10 SlateGray');
```

---

## 6. 🚀 Règle d'or contre le scintillement (Anti-Flicker)

Ajoutez cette simple ligne dans le `FormCreate` de toutes vos fiches :
```pascal
Self.DoubleBuffered := True;
```
Et activez `ParentDoubleBuffered := True` sur vos panels et grids. Cela supprime instantanément tous les scintillements blancs lors du rafraîchissement des calculs de devis.
