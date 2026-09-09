# Guide Complet — Techniques de Design Delphi VCL

> **Stack** : Delphi 12 Athens · TMS UI Pack · Skia4Delphi · SQL Server
> **Contexte** : Application POS / Gestion de stock (boucherie)

---

## Table des matières

1. [Architecture Générale](#1-architecture-générale)
2. [Palette de Couleurs](#2-palette-de-couleurs)
3. [Typographie](#3-typographie)
4. [Système de Thème Centralisé](#4-système-de-thème-centralisé)
5. [Style des Composants](#5-style-des-composants)
6. [Layouts et Dispositions](#6-layouts-et-dispositions)
7. [Grilles et Tableaux](#7-grilles-et-tableaux)
8. [Badges et Statuts](#8-badges-et-statuts)
9. [Feedback Visuel](#9-feedback-visuel)
10. [Organisation du Code](#10-organisation-du-code)
11. [Patterns de Réutilisation](#11-patterns-de-réutilisation)
12. [Checklist de Création d'un Nouveau Formulaire](#12-checklist-de-création-dun-nouveau-formulaire)

---

## 1. Architecture Générale

### 1.1 Structure des Dossiers

```
MonProjet/
├── src/
│   ├── core/           → Modules centraux (DB, Session, Config, Models)
│   ├── forms/          → Formulaires (écrans)
│   ├── utils/          → Utilitaires (dates, crypto, export)
│   ├── printing/       → Impression (tickets, PDF)
│   ├── reports/        → Rapports / états
│   └── settings/       → Paramétrage
├── resources/          → Images, icônes
├── database/           → Scripts SQL
└── MonProjet.dpr       → Point d'entrée
```

### 1.2 Modules Core (Singleton)

| Module | Rôle | Pattern |
|--------|------|---------|
| `uDBConnection` | Connexion ADO centralisée | **DataModule** + singleton global `DMConn` |
| `uSession` | Données utilisateur connecté | **Singleton** avec `class var` |
| `uAppConfig` | Lecture/écriture INI | **Singleton** avec clés `section.key` |
| `uModels` | Records métier (TProduit, TClient, etc.) | **Records** pas de classes lourdes |
| `uPermissions` | Droits d'accès | **Static class** |
| `uLangue` | Labels multilingues | **Static class** |

### 1.3 Cycle de Vie d'un Formulaire

```
1. DMConn (DataModule) crée en premier → connexion DB
2. TFormLogin.ShowModal → récupère les infos utilisateur
3. TFormMainModern crée → SetUserContext(userId, brancheId, nom, role, typeVente)
4. Navigation = création dynamique de forms enfants dans pnlContent
```

**Règle d'or** : Le formulaire principal ne libère jamais les formulaires enfants lui-même — c'est `ShowChildInContent` qui gère le cycle.

---

## 2. Palette de Couleurs

### 2.1 Système de Noms

Chaque couleur a **3 variantes** :
- **Base** : couleur principale
- **Dark** : version assombrie (hover/pressed)
- **Light/Bg** : version pâle (fonds, badges)

### 2.2 Tableau Complet

| Nom | RGB | Hex | Usage |
|-----|-----|-----|-------|
| **Primary** | `RGB(38, 104, 228)` | `#2668E4` | Boutons principaux, liens, accents |
| **Primary Dark** | `RGB(27, 82, 194)` | `#1B52C2` | Hover, pressed |
| **Primary Light** | `RGB(130, 204, 255)` | `#82CCFF` | Fonds subtils |
| **Primary BG** | `RGB(236, 244, 255)` | `#ECF4FF` | Fond de page |
| **Green** | `RGB(22, 138, 106)` | `#168A6A` | Succès, validation |
| **Green Dark** | `RGB(17, 116, 89)` | `#117459` | Hover succès |
| **Green BG** | `RGB(240, 252, 246)` | `#F0FCF6` | Fond succès |
| **Red** | `RGB(163, 45, 45)` | `#A32D2D` | Danger, suppression |
| **Red BG** | `RGB(251, 238, 239)` | `#FBEEEF` | Fond danger |
| **Amber** | `RGB(186, 117, 23)` | `#BA7517` | Avertissement |
| **Amber BG** | `RGB(255, 249, 239)` | `#FFF9EF` | Fond avertissement |
| **Surface** | `RGB(250, 252, 255)` | `#FAFCFF` | Fond général |
| **Card** | `RGB(255, 255, 255)` | `#FFFFFF` | Fond cartes |
| **Border** | `RGB(219, 229, 245)` | `#DBE5F5` | Bordures légères |
| **Text Primary** | `RGB(42, 49, 79)` | `#2A314F` | Texte principal |
| **Text Secondary** | `RGB(116, 122, 150)` | `#747A96` | Texte secondaire |
| **Text Muted** | `RGB(174, 188, 207)` | `#AEBCDF` | Texte désactivé |
| **Sidebar BG** | `RGB(8, 25, 51)` | `#081933` | Fond sidebar dark |
| **Sidebar Accent** | `RGB(83, 161, 255)` | `#53A1FF` | Accent sidebar |
| **Grid Header** | `RGB(22, 52, 94)` | `#16345E` | En-tête grille |

### 2.3 Conversion Skia → VCL

Skia utilise `TAlphaColor` (ARGB), VCL utilise `TColor` (BGR). Conversion :

```delphi
function SkiaToVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := RGB(
    (AColor shr 16) and $FF,  // Rouge
    (AColor shr 8) and $FF,   // Vert
    AColor and $FF             // Bleu
  );
end;
```

### 2.4 Définition dans le Code

```delphi
// Option 1 : Constantes (recommandé pour les couleurs statiques)
const
  CLR_PRIMARY = RGB(38, 104, 228);

// Option 2 : Fonctions (pour TColor dynamique)
function DS_Primary: TColor;
begin
  Result := RGB(38, 104, 228);
end;

// Option 3 : Inline dans FormCreate (rapide mais non réutilisable)
Color := RGB(236, 244, 255);
```

---

## 3. Typographie

### 3.1 Police de Référence

| Police | Usage |
|--------|-------|
| `Segoe UI` | Police principale (labels, edits, grilles) |
| `Segoe UI Semibold` | Titres, badges, headers de grille |
| `Segoe MDL2 Assets` | Icônes Windows (optionnel) |

### 3.2 Tailles Standardisées

| Constante | Height | Taille ≈ | Usage |
|-----------|--------|----------|-------|
| `FS_TITLE` | -26 | 20pt | Titre principal d'écran |
| `FS_SUBTITLE` | -18 | 14pt | Sous-titre |
| `FS_HEADING` | -16 | 12pt | Titre de section |
| `FS_BODY` | -13 | 10pt | Texte de corps |
| `FS_SMALL` | -11 | 8.5pt | Texte secondaire |
| `FS_CAPTION` | -10 | 8pt | Labels de champ |
| `FS_BADGE` | -9 | 7pt | Badges, tags |

> **Note** : `Font.Height` est négatif en VCL. `Height = -Size * 96/72` approximativement.

### 3.3 Application Typographique

```delphi
// Titre principal
lblTitle.Font.Name := 'Segoe UI Semibold';
lblTitle.Font.Height := -26;
lblTitle.Font.Color := RGB(42, 49, 79);

// Sous-titre
lblSub.Font.Name := 'Segoe UI';
lblSub.Font.Height := -11;
lblSub.Font.Color := RGB(116, 122, 150);

// Label de champ
lblField.Font.Name := 'Segoe UI';
lblField.Font.Height := -10;
lblField.Font.Color := RGB(88, 102, 124);
lblField.Font.Style := [fsBold];
```

---

## 4. Système de Thème Centralisé

### 4.1 Le Module Thème (`uModernTheme.pas`)

Toutes les procédures de style sont regroupées dans **une seule unité**. Chaque formulaire appelle ces procédures au lieu de dupliquer le code.

**Principe** : Un seul endroit à modifier pour changer l'apparence de toute l'application.

### 4.2 Procédures Thème

```delphi
// Application à un formulaire
procedure TFormMonForm.FormCreate(Sender: TObject);
begin
  // 1. Fond de page
  Color := RGB(236, 244, 255);

  // 2. Cartes
  GVApplyCardStyle(pnlCard, RGB(255, 255, 255), RGB(219, 229, 245));

  // 3. Boutons
  GVApplyButtonStyle(btnAction, RGB(38, 104, 228), RGB(27, 82, 194),
    clWhite, RGB(38, 104, 228), 11, 18);

  // 4. Champs de saisie
  GVApplyEditStyle(edtNom, 'Saisissez le nom...', clWhite);

  // 5. ComboBox
  GVApplyComboStyle(cmbCategorie, clWhite);

  // 6. Labels
  GVApplyLabelStyle(lblTitre, RGB(42, 49, 79), 22, True);

  // 7. Badges
  GVApplyBadgePanelStyle(pnlBadge, RGB(236, 250, 243), RGB(199, 231, 213));

  // 8. Decor panels (bandeaux colorés)
  GVEnsureDecorPanel(Self, pnlCard, 'pnlCardBand',
    0, 0, pnlCard.Width, 5, RGB(83, 161, 255), RGB(83, 161, 255),
    [akLeft, akTop, akRight]);
end;
```

### 4.3 Architecture du Thème

```
┌─────────────────────────────────────────────────┐
│  uModernTheme.pas (VCL - TMS UI Pack)          │
│  ├── GVApplyCardStyle()                         │
│  ├── GVApplyButtonStyle()                       │
│  ├── GVApplyEditStyle()                         │
│  ├── GVApplyComboStyle()                        │
│  ├── GVApplyLabelStyle()                        │
│  ├── GVApplyBadgePanelStyle()                   │
│  ├── GVApplySmoothEditStyle()                   │
│  ├── GVApplyOfficeSelectorStyle()               │
│  └── GVEnsureDecorPanel()                       │
├─────────────────────────────────────────────────┤
│  uSkiaTheme.pas (Skia - Rendu avancé)          │
│  ├── DrawGradientBg()                           │
│  ├── DrawCard()                                 │
│  ├── DrawButtonPrimary()                        │
│  ├── DrawButtonOutlined()                       │
│  ├── DrawBadge()                                │
│  ├── DrawInputField()                           │
│  └── DrawStockBar()                             │
└─────────────────────────────────────────────────┘
```

---

## 5. Style des Composants

### 5.1 Carte (TAdvPanel)

**Principe** : Fond blanc + bordure légère + pas de bevel + ombre optionnelle.

```delphi
procedure GVApplyCardStyle(const APanel: TAdvPanel;
  const ABackColor, ABorderColor: TColor;
  const AToColor: TColor = clNone);
begin
  APanel.Color := ABackColor;
  APanel.ColorTo := AToColor;
  APanel.BevelOuter := bvNone;      // PAS de bevel
  APanel.BevelInner := bvNone;      // PAS de bevel
  APanel.BorderColor := ABorderColor;
  APanel.BorderShadow := False;     // Ombre gérée séparément
  APanel.Caption.Color := ABackColor;
  APanel.Caption.ColorTo := clNone;
end;
```

**Variantes de couleurs pour cartes** :
- Carte standard : `clWhite` + `RGB(219, 229, 245)`
- Carte métrique : couleur thématique en fond + bordure assortie
- Carte info : fond pastel + bordure douce

### 5.2 Bouton (TAdvSmoothButton)

**Propriétés critiques** :
```
UIStyle := tsCustom
Cursor := crHandPoint
Appearance.SimpleLayout := True    // Design plat
Appearance.SimpleLayoutBorder := False
Appearance.Rounding := 18          // Coins arrondis
Appearance.Font.Name := 'Segoe UI Semibold'
```

**5 styles de boutons** :

| Style | From | To | Font | Border |
|-------|------|-----|------|--------|
| Primaire | Primary | Primary Dark | White | Primary |
| Secondaire | White | Light Blue | Blue | Light Blue |
| Danger | Red BG | Red BG Dark | Red | Red Border |
| Succès | Green | Green Dark | White | Green |
| Outline | White | White | Accent | Accent |

### 5.3 Champ de Saisie (TAdvEdit)

```delphi
procedure GVApplyEditStyle(const AEdit: TAdvEdit;
  const AEmptyText: string; const ABackColor: TColor);
begin
  AEdit.ParentFont := False;
  AEdit.Font.Name := 'Segoe UI';
  AEdit.Font.Height := -13;
  AEdit.Color := ABackColor;          // Fond
  AEdit.Ctl3D := False;               // PAS de 3D
  AEdit.EmptyText := AEmptyText;      // Placeholder
  AEdit.Height := 36;                 // Hauteur fixe
end;
```

### 5.4 ComboBox (TAdvComboBox)

```delphi
procedure GVApplyComboStyle(const ACombo: TAdvComboBox;
  const ABackColor: TColor);
begin
  ACombo.ParentFont := False;
  ACombo.Font.Name := 'Segoe UI';
  ACombo.Font.Height := -13;
  ACombo.Style := csDropDownList;    // Pas d'édition libre
  ACombo.Color := ABackColor;
  ACombo.ButtonWidth := 19;
  ACombo.Height := 36;
end;
```

### 5.5 Label

```delphi
procedure GVApplyLabelStyle(const ALabel: TLabel;
  const ATextColor: TColor; const AFontSize: Integer;
  const ABold: Boolean; const AFontName: string);
begin
  ALabel.ParentFont := False;        // IMPORTANT : ignorer font parent
  ALabel.Transparent := True;        // Toujours transparent
  ALabel.Font.Name := AFontName;
  ALabel.Font.Height := AFontSize;   // Négatif = pixels
  ALabel.Font.Color := ATextColor;
  if ABold then
    ALabel.Font.Style := [fsBold]
  else
    ALabel.Font.Style := [];
end;
```

### 5.6 Decor Panel (Bandeau Décoratif)

Petit panel coloré servant de barre d'accentuation au sommet ou sur le côté d'une carte.

```delphi
procedure GVEnsureDecorPanel(const AOwner: TComponent;
  const AParent: TWinControl; const AName: string;
  ALeft, ATop, AWidth, AHeight: Integer;
  AColor, ABorderColor: TColor;
  const AAnchors: TAnchors);
var
  Panel: TAdvPanel;
begin
  // Chercher ou créer le panel
  Panel := TAdvPanel(AOwner.FindComponent(AName));
  if Panel = nil then
  begin
    Panel := TAdvPanel.Create(AOwner);
    Panel.Name := AName;
    Panel.Parent := AParent;
    Panel.Text := '';
    Panel.TabStop := False;
    Panel.Enabled := False;          // Non interactif
    Panel.UseDockManager := True;
  end;

  Panel.Left := ALeft;
  Panel.Top := ATop;
  Panel.Width := AWidth;
  Panel.Height := AHeight;
  Panel.Color := AColor;
  Panel.ColorTo := AColor;
  Panel.Anchors := AAnchors;
  Panel.SendToBack;                  // Derrière le contenu
end;
```

**Usages typiques** :
```delphi
// Bandeau horizontal au sommet d'une carte
GVEnsureDecorPanel(Self, pnlCard, 'pnlCardBand',
  0, 0, pnlCard.Width, 5,         // 5px de haut
  RGB(83, 161, 255), RGB(83, 161, 255),
  [akLeft, akTop, akRight]);

// Bandeau vertical sur le côté gauche
GVEnsureDecorPanel(Self, pnlCard, 'pnlCardSide',
  0, 0, 5, pnlCard.Height,        // 5px de large
  RGB(22, 138, 106), RGB(22, 138, 106),
  [akLeft, akTop, akBottom]);
```

---

## 6. Layouts et Dispositions

### 6.1 Layout Principal (Sidebar + Topbar + Content)

```
┌──────────────────────────────────────────────────┐
│  pnlTopbar (Height = 68px, Align = alTop)        │
├──────────┬───────────────────────────────────────┤
│          │                                       │
│ pnlSide  │         pnlContent                    │
│ (Width   │         (Align = alClient)            │
│  = 248)  │                                       │
│          │    ┌─────────────────────────────┐    │
│  [Menu]  │    │  Formulaire Enfant          │    │
│          │    │  (BorderStyle = bsNone)     │    │
│          │    │  (Align = alClient)         │    │
│          │    │  (Parent = pnlContent)      │    │
│          │    └─────────────────────────────┘    │
└──────────┴───────────────────────────────────────┘
```

**Implémentation** :
```delphi
procedure TFormMain.FormCreate(Sender: TObject);
begin
  // Sidebar
  pnlSidebar.Align := alLeft;
  pnlSidebar.Width := 248;
  GVApplyCardStyle(pnlSidebar, RGB(8, 25, 51), RGB(20, 54, 102));

  // Topbar
  pnlTopbar.Align := alTop;
  pnlTopbar.Height := 68;
  GVApplyCardStyle(pnlTopbar, clWhite, RGB(221, 230, 244));

  // Content
  pnlContent.Align := alClient;
  pnlContent.Color := RGB(242, 247, 255);
end;

// Navigation : embedre un formulaire dans pnlContent
procedure TFormMain.ShowChildInContent(AForm: TForm);
begin
  // Libérer l'ancien
  if Assigned(FCurrentChild) then
  begin
    FCurrentChild.Free;
    FCurrentChild := nil;
  end;

  // Configurer le formulaire enfant
  FCurrentChild := AForm;
  FCurrentChild.BorderStyle := bsNone;    // PAS de bordure
  FCurrentChild.Align := alClient;        // Remplir tout
  FCurrentChild.Parent := pnlContent;     // Container
  FCurrentChild.Visible := True;
  FCurrentChild.BringToFront;
end;
```

### 6.2 Layout Login (Hero + Card centré)

```
┌────────────────┬────────────────────────────────┐
│                │                                │
│   pnlHero      │      pnlContent                │
│   (Gradient    │      ┌──────────────────┐      │
│    navy→blue)  │      │  pnlLoginCard     │      │
│                │      │  (centré verticalement  │
│  [Branding]    │      │   et horizontalement)   │
│  [Metrics]     │      │                      │      │
│  [Preview]     │      │  [Champs] [Boutons]  │      │
│                │      └──────────────────┘      │
└────────────────┴────────────────────────────────┘
```

**Centrage de la carte** :
```delphi
procedure TFormLogin.UpdateCardPosition;
begin
  pnlLoginCard.Left := Max(34,
    (pnlContent.ClientWidth - pnlLoginCard.Width) div 2);
  pnlLoginCard.Top := Max(28,
    (pnlContent.ClientHeight - pnlLoginCard.Height) div 2);
end;

procedure TFormLogin.FormResize(Sender: TObject);
begin
  UpdateCardPosition;
end;
```

### 6.3 Layout Dashboard (4 cartes + sections)

```
┌─────────┬─────────┬─────────┬─────────┐
│ Card 1  │ Card 2  │ Card 3  │ Card 4  │
│ (CA)    │ (Fact.) │ (Alertes)│ (Créances)│
└─────────┴─────────┴─────────┴─────────┘
┌───────────────────────┬─────────────────┐
│                       │                 │
│   Graphique (Chart)   │  Top Produits   │
│                       │  Alertes        │
│                       │  Récent         │
│                       │                 │
└───────────────────────┴─────────────────┘
```

**Layout responsive** :
```delphi
procedure TFormDashboard.FormResize(Sender: TObject);
var
  Gap, CardsPerRow, TopCardW: Integer;
begin
  Gap := 20;

  // Nombre de cartes par ligne selon la largeur
  if ClientWidth < 600 then
    CardsPerRow := 1
  else if ClientWidth < 900 then
    CardsPerRow := 2
  else
    CardsPerRow := 4;

  TopCardW := (ClientWidth - Gap * (CardsPerRow + 1)) div CardsPerRow;

  // Positionnement automatique
  pnlCard1.SetBounds(Gap, Gap, TopCardW, 112);
  pnlCard2.SetBounds(Gap + (TopCardW + Gap), Gap, TopCardW, 112);
  // ... etc
end;
```

### 6.4 Layout Liste + Éditeur (Split)

```
┌──────────────────────┬──────────────────────┐
│                      │                      │
│   pnlList            │   pnlEditor          │
│   (Grille + Filtres) │   (Formulaire)       │
│                      │                      │
│   [Recherche]        │   [Champ 1]          │
│   [ComboBox]         │   [Champ 2]          │
│   [Grille]           │   [Champ 3]          │
│                      │   [Boutons]          │
│                      │                      │
└──────────────────────┴──────────────────────┘
     ≈ 60%                     ≈ 40%
```

---

## 7. Grilles et Tableaux

### 7.1 Configuration de Base

```delphi
procedure InitGrid(AGrid: TAdvStringGrid);
begin
  AGrid.BeginUpdate;
  try
    // Structure
    AGrid.ColCount := 7;
    AGrid.RowCount := 2;        // 1 header + 1 ligne min
    AGrid.FixedRows := 1;
    AGrid.FixedCols := 0;

    // Style
    AGrid.Look := glCustom;
    AGrid.Color := clWhite;
    AGrid.FixedColor := RGB(22, 52, 94);      // Header dark
    AGrid.FixedFont.Color := clWhite;
    AGrid.FixedFont.Name := 'Segoe UI Semibold';
    AGrid.FixedFont.Size := 9;

    // Sélection
    AGrid.SelectionColor := RGB(232, 242, 255);
    AGrid.SelectionTextColor := RGB(22, 52, 94);
    AGrid.ShowSelection := True;

    // Bandes alternées
    AGrid.Bands.PrimaryColor := clWhite;
    AGrid.Bands.SecondaryColor := RGB(247, 250, 255);
    AGrid.Bands.Active := True;

    // Lignes de grille
    AGrid.GridLineColor := RGB(226, 234, 244);
    AGrid.GridLineStyle := psSolid;

    // Police
    AGrid.Font.Name := 'Segoe UI';
    AGrid.Font.Size := 9;
    AGrid.Font.Color := RGB(51, 65, 85);

    // Dimensions
    AGrid.DefaultRowHeight := 30;
    AGrid.FixedRowHeight := 34;

    // Options
    AGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine,
      goHorzLine, goRangeSelect, goRowSelect, goTabs];
  finally
    AGrid.EndUpdate;
  end;
end;
```

### 7.2 Dessin Personnalisé des Cellules

```delphi
procedure TFormGrid.sgGridDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Canvas: TCanvas;
  TextRect: TRect;
begin
  Canvas := TAdvStringGrid(Sender).Canvas;

  // ── EN-TÊTE (row 0) ──
  if ARow = 0 then
  begin
    Canvas.Brush.Color := RGB(22, 52, 94);
    Canvas.Font.Name := 'Segoe UI Semibold';
    Canvas.Font.Size := 9;
    Canvas.Font.Color := clWhite;
    Canvas.Font.Style := [fsBold];
    Canvas.FillRect(Rect);

    TextRect := Rect;
    InflateRect(TextRect, -6, 0);
    DrawText(Canvas.Handle, PChar(sgGrid.Cells[ACol, ARow]),
      Length(sgGrid.Cells[ACol, ARow]), TextRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    Exit;
  end;

  // ── LIGNES ALTERNÉES ──
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 9;
  Canvas.Font.Color := RGB(28, 40, 51);

  if gdSelected in State then
    Canvas.Brush.Color := RGB(232, 242, 255)
  else if Odd(ARow) then
    Canvas.Brush.Color := clWhite
  else
    Canvas.Brush.Color := RGB(247, 250, 255);

  Canvas.FillRect(Rect);
  Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 3,
    sgGrid.Cells[ACol, ARow]);
end;
```

### 7.3 Cellule Badge dans la Grille

```delphi
// Dans DrawCell, pour une colonne de statut :
if ACol = ColStatut then
begin
  CellText := sgGrid.Cells[ACol, ARow];

  // Couleurs selon le statut
  if SameText(CellText, 'ACTIF') then
  begin
    BgColor := RGB(234, 247, 238);
    BorderColor := RGB(206, 229, 214);
    TextColor := RGB(39, 80, 10);
  end
  else if SameText(CellText, 'RUPTURE') then
  begin
    BgColor := RGB(252, 237, 237);
    BorderColor := RGB(240, 205, 205);
    TextColor := RGB(163, 45, 45);
  end
  else
  begin
    BgColor := RGB(241, 239, 232);
    BorderColor := RGB(226, 224, 218);
    TextColor := RGB(95, 94, 90);
  end;

  // Dessiner le badge arrondi
  Canvas.Brush.Color := BgColor;
  Canvas.Pen.Color := BorderColor;
  TextRect := Rect;
  InflateRect(TextRect, -10, -6);
  Canvas.RoundRect(TextRect.Left, TextRect.Top,
    TextRect.Right, TextRect.Bottom, 12, 12);

  // Texte centré
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := 'Segoe UI Semibold';
  Canvas.Font.Size := 8;
  Canvas.Font.Color := TextColor;
  Canvas.Font.Style := [fsBold];
  DrawText(Canvas.Handle, PChar(CellText), Length(CellText),
    TextRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  Canvas.Brush.Style := bsSolid;
end;
```

---

## 8. Badges et Statuts

### 8.1 Tableau des Statuts

| Statut | Fond | Bordure | Texte |
|--------|------|---------|-------|
| ACTIF / VALIDEE / PAYEE | `RGB(236, 250, 243)` | `RGB(199, 231, 213)` | Green Dark |
| STOCK FAIBLE / CREDIT / ALERTE | `RGB(255, 246, 226)` | `RGB(243, 223, 181)` | Amber |
| RUPTURE / INACTIF | `RGB(255, 239, 239)` | `RGB(245, 208, 208)` | Red |
| Par défaut | `RGB(244, 246, 250)` | `RGB(222, 229, 239)` | Muted |

### 8.2 Application Dynamique

```delphi
procedure ApplyStatusBadge(ALabel: TLabel; const AStatus: string);
begin
  ALabel.ParentFont := False;
  ALabel.Transparent := True;
  ALabel.Font.Name := 'Segoe UI Semibold';
  ALabel.Font.Size := 9;
  ALabel.Caption := AStatus;

  if SameText(AStatus, 'ACTIF') or SameText(AStatus, 'VALIDEE') then
  begin
    ALabel.Font.Color := RGB(17, 116, 89);     // Green Dark
    // Le panel badge doit avoir le fond vert
  end
  else if SameText(AStatus, 'RUPTURE') then
  begin
    ALabel.Font.Color := RGB(163, 45, 45);     // Red
  end
  else
    ALabel.Font.Color := RGB(105, 115, 141);   // Muted
end;
```

---

## 9. Feedback Visuel

### 9.1 Animation de Scan (Flash)

```delphi
procedure FlashSuccess(AEdit: TCustomEdit);
begin
  AEdit.Color := RGB(227, 246, 236);    // Vert clair
  AEdit.Invalidate;
  Application.ProcessMessages;
  Sleep(150);                           // Pause visible
  AEdit.Color := clWhite;               // Retour normal
  AEdit.Invalidate;
end;

procedure FlashError(AEdit: TCustomEdit);
begin
  AEdit.Color := RGB(251, 232, 232);    // Rouge clair
  AEdit.Invalidate;
  Application.ProcessMessages;
  Sleep(200);
  AEdit.Color := clWhite;
  AEdit.Invalidate;
end;
```

### 9.2 Messages d'Erreur

```delphi
procedure ShowError(ALabel: TLabel; const AMsg: string);
begin
  ALabel.Caption := AMsg;
  ALabel.Font.Color := RGB(163, 45, 45);  // Rouge
  ALabel.Visible := True;
end;

procedure HideError(ALabel: TLabel);
begin
  ALabel.Visible := False;
  ALabel.Caption := '';
end;
```

### 9.3 États d'un Champ (Focus/Blur)

```delphi
procedure ApplyInputState(APanel, ALine: TPanel;
  const Active: Boolean; const AAccentColor: TColor);
begin
  APanel.ParentBackground := False;
  if Active then
  begin
    APanel.Color := RGB(243, 248, 255);    // Fond bleu clair
    ALine.Color := AAccentColor;
    ALine.Height := 3;                      // Plus épais
  end
  else
  begin
    APanel.Color := RGB(246, 250, 255);    // Fond neutre
    ALine.Color := AAccentColor;
    ALine.Height := 2;                      // Plus fin
  end;
  ALine.Visible := True;
end;
```

---

## 10. Organisation du Code

### 10.1 Structure Type d'un Formulaire

```delphi
unit uFormMaForm;

interface

uses
  // Windows / System
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Math,
  // VCL
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  // Data
  Data.DB, Data.Win.ADODB,
  // TMS
  AdvPanel, AdvSmoothButton, AdvEdit, AdvGrid, AdvCombo,
  // Projet
  uDBConnection, uSession, uModernTheme;

type
  TFormMaForm = class(TForm)
    // ── Composants DFM ──
    pnlTop: TAdvPanel;
    pnlContent: TPanel;
    btnAction: TAdvSmoothButton;
    lblTitle: TLabel;
    // ...

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnActionClick(Sender: TObject);

  private
    // ── Variables privées ──
    FSelectedId: Integer;

    // ── Méthodes de style (appelle le thème centralisé) ──
    procedure ApplyCardStyle(const APanel: TAdvPanel;
      const ABackColor, ABorderColor: TColor);
    procedure ApplyButtonStyle(const AButton: TAdvSmoothButton;
      const AFromColor, AToColor, AFontColor, ABorderColor: TColor);
    procedure ApplyLabelStyle(const ALabel: TLabel;
      const ATextColor: TColor; const AFontSize: Integer;
      const ABold: Boolean = False);
    procedure EnsureDecorPanel(const AParent: TWinControl;
      const AName: string; ALeft, ATop, AWidth, AHeight: Integer;
      AColor, ABorderColor: TColor; const AAnchors: TAnchors);

    // ── Méthodes métier ──
    procedure LoadData;
    procedure SaveRecord;
    procedure ApplyModernLayout;
    procedure ApplyModernStyle;

  public
    // ── Interface publique ──
    procedure RefreshData;
  end;

implementation

{$R *.dfm}

// ════════════════════════════════════════════════════════════════
//  STYLES — Délégation au thème centralisé
// ════════════════════════════════════════════════════════════════

procedure TFormMaForm.ApplyCardStyle(const APanel: TAdvPanel;
  const ABackColor, ABorderColor: TColor);
begin
  GVApplyCardStyle(APanel, ABackColor, ABorderColor, ABackColor);
end;

procedure TFormMaForm.ApplyButtonStyle(const AButton: TAdvSmoothButton;
  const AFromColor, AToColor, AFontColor, ABorderColor: TColor);
begin
  GVApplyButtonStyle(AButton, AFromColor, AToColor, AFontColor,
    ABorderColor, 10, 16);
end;

procedure TFormMaForm.ApplyLabelStyle(const ALabel: TLabel;
  const ATextColor: TColor; const AFontSize: Integer;
  const ABold: Boolean);
begin
  GVApplyLabelStyle(ALabel, ATextColor, AFontSize, ABold);
end;

procedure TFormMaForm.EnsureDecorPanel(const AParent: TWinControl;
  const AName: string; ALeft, ATop, AWidth, AHeight: Integer;
  AColor, ABorderColor: TColor; const AAnchors: TAnchors);
begin
  GVEnsureDecorPanel(Self, AParent, AName, ALeft, ATop,
    AWidth, AHeight, AColor, ABorderColor, AAnchors);
end;

// ════════════════════════════════════════════════════════════════
//  CRÉATION DU FORMULAIRE
// ════════════════════════════════════════════════════════════════

procedure TFormMaForm.FormCreate(Sender: TObject);
begin
  // 1. Fond de page
  Color := RGB(241, 247, 255);

  // 2. Appliquer les styles
  ApplyModernStyle;

  // 3. Appliquer le layout
  ApplyModernLayout;

  // 4. Charger les données
  LoadData;
end;

procedure TFormMaForm.FormResize(Sender: TObject);
begin
  ApplyModernLayout;    // Responsive
end;

// ════════════════════════════════════════════════════════════════
//  STYLE MODERNE — Application de tous les styles
// ════════════════════════════════════════════════════════════════

procedure TFormMaForm.ApplyModernStyle;
begin
  // Cartes
  ApplyCardStyle(pnlTop, clWhite, CLR_BORDER, clWhite);
  ApplyCardStyle(pnlContent, clWhite, CLR_BORDER, clWhite);

  // Boutons
  ApplyButtonStyle(btnAction, CLR_PRIMARY, CLR_PRIMARY_DARK,
    clWhite, CLR_PRIMARY);

  // Labels
  ApplyLabelStyle(lblTitle, CLR_TEXT_PRIMARY, -22, True);

  // Decor panels
  EnsureDecorPanel(pnlTop, 'pnlTopBand',
    0, 0, pnlTop.Width, 5,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);
end;

// ════════════════════════════════════════════════════════════════
//  LAYOUT — Positionnement manuel dans FormResize
// ════════════════════════════════════════════════════════════════

procedure TFormMaForm.ApplyModernLayout;
const
  Margin = 18;
  Gap = 16;
  FieldH = 36;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  lblTitle.SetBounds(Margin, Margin, 300, 28);
  lblTitle.AutoSize := False;

  // Positionner les autres composants...
end;

// ════════════════════════════════════════════════════════════════
//  MÉTIER
// ════════════════════════════════════════════════════════════════

procedure TFormMaForm.LoadData;
var
  Qry: TADOQuery;
begin
  Screen.Cursor := crHourGlass;
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := DMConn.ADOConn;
    Qry.SQL.Text := 'SELECT * FROM MaTable WHERE ...';
    Qry.Open;

    // Remplir la grille...
  finally
    Qry.Free;
    Screen.Cursor := crDefault;
  end;
end;

end.
```

### 10.2 Règles d'Or

1. **Jamais de couleur en dur dans les formulaires** → utiliser les constantes du thème
2. **Un seul endroit pour le style** → `uModernTheme.pas`
3. **Layout dans FormResize** → pour le responsive
4. **TAdvPanel.Create dynamique** → pour les decor panels et badges
5. **Free dans FormDestroy** → pas avant
6. **try/finally pour TADOQuery** → toujours libérer
7. **Screen.Cursor** → indiquer les opérations longues

---

## 11. Patterns de Réutilisation

### 11.1 Pattern "Card with Accent Band"

```
┌─ [Bande colorée 5px] ─────────────────────────┐
│                                                 │
│  Titre de la carte                              │
│  Valeur principale                              │
│  Méta-information                               │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 11.2 Pattern "Toolbar + Grid + Editor"

```
┌─ Toolbar (Recherche + Filtres + Boutons) ──────┐
├──────────────────────┬──────────────────────────┤
│   Grille (60%)       │   Éditeur (40%)          │
│   [Colonnes]         │   [Champs formulaires]   │
│   [Lignes]           │   [Boutons Saver/Cancel] │
└──────────────────────┴──────────────────────────┘
```

### 11.3 Pattern "Metric Dashboard Card"

```
┌─ [Bande latérale 5px] ─┬──────────────────────┐
│                         │  Titre               │
│                         │  VALEUR (grande)      │
│                         │  Description          │
│                         │                       │
│                         │  [Icône à droite]     │
└─────────────────────────┴──────────────────────┘
```

### 11.4 Pattern "Status Badge"

```
┌─────────────────┐
│   STATUT        │   Fond pastel + bordure + texte coloré
└─────────────────┘
```

---

## 12. Checklist de Création d'un Nouveau Formulaire

- [ ] Créer le fichier `.pas` et `.dfm` dans `src/forms/`
- [ ] Ajouter l'unité dans le `.dpr`
- [ ] Ajouter les uses : `uDBConnection, uSession, uModernTheme`
- [ ] Définir `Color := RGB(241, 247, 255)` dans `FormCreate`
- [ ] Créer les procédures de style wrapper (ApplyCardStyle, etc.)
- [ ] Créer `ApplyModernStyle` avec tous les styles
- [ ] Créer `ApplyModernLayout` pour le positionnement
- [ ] Appeler `ApplyModernLayout` dans `FormResize`
- [ ] Ajouter les decor panels (bandeaux)
- [ ] Implémenter le chargement des données avec `try/finally`
- [ ] Ajouter `Screen.Cursor` pour les opérations longues
- [ ] Vérifier le responsive (1 colonne si étroit, 2+ si large)
- [ ] Tester les états hover/focus des champs

---

## Annexe : Conversion Rapide des Couleurs

Pour convertir une couleur hexadécimale en `RGB()` Delphi :

```
#RRGGBB → RGB(R, G, B)

Exemples :
#2668E4 → RGB(38, 104, 228)   → CLR_PRIMARY
#168A6A → RGB(22, 138, 106)   → CLR_GREEN
#A32D2D → RGB(163, 45, 45)    → CLR_RED
#BA7517 → RGB(186, 117, 23)   → CLR_AMBER
#FAFCFF → RGB(250, 252, 255)  → CLR_SURFACE
#DBE5F5 → RGB(219, 229, 245)  → CLR_BORDER
```
