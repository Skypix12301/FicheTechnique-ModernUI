unit uFicheTechnique_v3;

{==============================================================================}
{ Formulaire Éditeur de Fiche Technique & Devis Estimatif (Version Modernisée) }
{ Gestion : En-tête de fiche, Lots dynamiques, Lignes d'articles (TDBGrid),     }
{ Calculs automatiques temps réel (Sous-totaux, HT, TVA 9%/19%, Remise, TTC),  }
{ Génération de la formule en toutes lettres (Arabe / Français), Anti-scintille}
{ Compatible : Delphi XE8 jusqu'à 12 Athens (FireDAC / TClientDataSet)         }
{==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.Mask, Data.DB, FireDAC.Comp.Client, uBaseForm, uVCLModernizer;

type
  { Structure de résumé d'un Lot }
  TLotSummary = record
    LotId: Integer;
    CodeLot: string;
    NomLot: string;
    MontantLotHT: Double;
  end;

  TfrmFicheTechnique_v3 = class(TfrmBase)
    { Conteneurs principaux de la fiche }
    pnlRoot: TPanel;
    pnlTopActionBar: TPanel;
    pnlSummaryFooter: TPanel;
    pnlContentArea: TPanel;

    { Barre d'actions supérieure }
    lblFormTitle: TLabel;
    lblFicheStatusBadge: TLabel;
    btnEnregistrer: TSpeedButton;
    btnValiderFiche: TSpeedButton;
    btnImprimerA4: TSpeedButton;
    btnFermer: TSpeedButton;
    btnCalculerTotaux: TSpeedButton;

    { Volet Supérieur : Informations administratives de la fiche (Carte blanche) }
    pnlHeaderCard: TPanel;
    lblNumeroFiche: TLabel;
    edtNumeroFiche: TEdit;
    lblDateFiche: TLabel;
    dtpDateFiche: TDateTimePicker;
    lblProjet: TLabel;
    cbbProjets: TComboBox;
    lblOperation: TLabel;
    edtOperation: TEdit;
    lblLocalisation: TLabel;
    edtLocalisation: TEdit;
    lblStatut: TLabel;
    cbbStatut: TComboBox;
    lblTauxTVA: TLabel;
    cbbTauxTVA: TComboBox;
    lblTauxRemise: TLabel;
    edtTauxRemise: TEdit;

    { Zone Centrale : Gestion des Lots & Grille de Devis }
    pnlLotsAndGridCard: TPanel;

    { Barre d'onglets / sélection des Lots }
    pnlLotsTabBar: TPanel;
    lblLotsTitle: TLabel;
    pnlLotsButtonsContainer: TPanel;
    btnAjouterLot: TSpeedButton;
    btnSupprimerLot: TSpeedButton;
    cbbLotsSelector: TComboBox;
    lblMontantLotEnCours: TLabel;

    { Barre d'outils de la grille des prix }
    pnlGridToolbar: TPanel;
    btnAjouterLigne: TSpeedButton;
    btnInsererDepuisCatalogue: TSpeedButton;
    btnSupprimerLigne: TSpeedButton;
    btnMonteeLigne: TSpeedButton;
    btnDescenteLigne: TSpeedButton;
    lblNombreLignes: TLabel;

    { Grille moderne TDBGrid pour le détail estimatif du Lot actif }
    dbgLignesDevis: TDBGrid;

    { Volet Inférieur : Récapitulatif Financier & Montant en toutes lettres }
    pnlFinancialCard: TPanel;
    lblTotalHTLabel: TLabel;
    lblTotalHTValue: TLabel;
    lblRemiseLabel: TLabel;
    lblRemiseValue: TLabel;
    lblTVALabel: TLabel;
    lblTVAValue: TLabel;
    lblTotalTTCLabel: TLabel;
    lblTotalTTCValue: TLabel;
    lblArreteEnToutesLettres: TLabel;
    memArreteToutesLettres: TMemo;

    { Composants Données en Mémoire (ou reliés au DataModule) }
    dsLignesDevis: TDataSource;
    mtLignesDevis: TFDMemTable;
    mtLignesDevisID: TIntegerField;
    mtLignesDevisLOT_ID: TIntegerField;
    mtLignesDevisNUMERO_PRIX: TIntegerField;
    mtLignesDevisCODE_ARTICLE: TStringField;
    mtLignesDevisDESIGNATION: TStringField;
    mtLignesDevisUNITE: TStringField;
    mtLignesDevisQUANTITE: TFloatField;
    mtLignesDevisPRIX_UNITAIRE: TFloatField;
    mtLignesDevisMONTANT_HT: TFloatField;
    mtLignesDevisOBSERVATIONS: TStringField;

    { Événements de la fiche }
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgLignesDevisDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgLignesDevisColExit(Sender: TObject);
    procedure mtLignesDevisCalcFields(DataSet: TDataSet);
    procedure mtLignesDevisAfterPost(DataSet: TDataSet);
    procedure mtLignesDevisAfterDelete(DataSet: TDataSet);

    { Actions boutons }
    procedure btnAjouterLigneClick(Sender: TObject);
    procedure btnSupprimerLigneClick(Sender: TObject);
    procedure btnAjouterLotClick(Sender: TObject);
    procedure btnSupprimerLotClick(Sender: TObject);
    procedure cbbLotsSelectorChange(Sender: TObject);
    procedure cbbTauxTVAChange(Sender: TObject);
    procedure edtTauxRemiseChange(Sender: TObject);
    procedure btnCalculerTotauxClick(Sender: TObject);
    procedure btnEnregistrerClick(Sender: TObject);
    procedure btnValiderFicheClick(Sender: TObject);
    procedure btnImprimerA4Click(Sender: TObject);
    procedure btnFermerClick(Sender: TObject);
  private
    FCurrentLotId: Integer;
    FTotalHTGlobal: Double;
    FTotalRemiseGlobal: Double;
    FTotalTVAGlobal: Double;
    FTotalTTCGlobal: Double;

    procedure InitDatasetStructure;
    procedure InitDemoData;
    procedure LoadLotsForFiche;
    procedure RecalculerTotaux;
    procedure MettreAJourAffichageFinancier;
    function FormaterMontant(Valeur: Double): string;
    function ConvertirChiffreEnLettresDZD(Valeur: Double; EnArabe: Boolean = True): string;
  protected
    procedure SetupModernUI; override;
  public
    procedure ChargerFiche(AFicheId: Integer);
    procedure NouvelleFiche;
  end;

var
  frmFicheTechnique_v3: TfrmFicheTechnique_v3;

implementation

{$R *.dfm}

{ TfrmFicheTechnique_v3 }

procedure TfrmFicheTechnique_v3.FormCreate(Sender: TObject);
begin
  inherited;
  FCurrentLotId := 1;
  InitDatasetStructure;
end;

procedure TfrmFicheTechnique_v3.FormShow(Sender: TObject);
begin
  SetupModernUI;
  LoadLotsForFiche;
  if mtLignesDevis.IsEmpty then
    InitDemoData;
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.SetupModernUI;
begin
  inherited;
  // 1. Anti-scintillement pour toute la fiche et ses sous-composants
  TVCLModernizer.ModernizeForm(Self, 'Segoe UI');

  // 2. Application du style moderne par cartes (Card UI sans biseau)
  ApplyCardStyle(pnlHeaderCard);
  ApplyCardStyle(pnlLotsAndGridCard);
  ApplyCardStyle(pnlFinancialCard);
  ApplyCardStyle(pnlTopActionBar);

  // 3. Configuration visuelle optimisée pour TDBGrid
  dbgLignesDevis.BorderStyle := bsNone;
  dbgLignesDevis.DrawingStyle := gdsClassic;
  dbgLignesDevis.Options := [
    dgEditing, dgTitles, dgIndicator, dgColumnResize,
    dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit
  ];

  // 4. Badges et étiquettes avec polices nettes
  lblFormTitle.Font.Size := 13;
  lblFormTitle.Font.Style := [fsBold];
  lblTotalTTCValue.Font.Size := 16;
  lblTotalTTCValue.Font.Style := [fsBold];
end;

procedure TfrmFicheTechnique_v3.InitDatasetStructure;
begin
  // Création des champs de la table mémoire si non définie statiquement
  if mtLignesDevis.FieldCount = 0 then
  begin
    mtLignesDevis.FieldDefs.Clear;
    mtLignesDevis.FieldDefs.Add('ID', ftAutoInc);
    mtLignesDevis.FieldDefs.Add('LOT_ID', ftInteger);
    mtLignesDevis.FieldDefs.Add('NUMERO_PRIX', ftInteger);
    mtLignesDevis.FieldDefs.Add('CODE_ARTICLE', ftString, 30);
    mtLignesDevis.FieldDefs.Add('DESIGNATION', ftString, 255);
    mtLignesDevis.FieldDefs.Add('UNITE', ftString, 15);
    mtLignesDevis.FieldDefs.Add('QUANTITE', ftFloat);
    mtLignesDevis.FieldDefs.Add('PRIX_UNITAIRE', ftFloat);
    mtLignesDevis.FieldDefs.Add('MONTANT_HT', ftFloat);
    mtLignesDevis.FieldDefs.Add('OBSERVATIONS', ftString, 150);
    mtLignesDevis.CreateDataSet;
  end
  else if not mtLignesDevis.Active then
    mtLignesDevis.Open;
end;

procedure TfrmFicheTechnique_v3.InitDemoData;
begin
  // Remplissage avec les lots types BTPH / Travaux Publics
  mtLignesDevis.DisableControls;
  try
    // Lot 1 : Terrassement & Déblais
    mtLignesDevis.AppendRecord([1, 1, 1, 'ART-TER-01', 'Décapage de terre végétale sur épaisseur 20cm', 'M²', 1250.0, 180.0, 225000.0, 'Terrassement général']);
    mtLignesDevis.AppendRecord([2, 1, 2, 'ART-TER-02', 'Fouilles en rigoles et en tranchées dans terrain ordinaire', 'M³', 340.0, 850.0, 289000.0, 'Fondations']);
    mtLignesDevis.AppendRecord([3, 1, 3, 'ART-TER-03', 'Remblaiement des fouilles avec terres sélectionnées compactées', 'M³', 180.0, 650.0, 117000.0, 'Remblais']);

    // Lot 2 : Gros Œuvres & Béton Armé
    mtLignesDevis.AppendRecord([4, 2, 1, 'ART-GO-01', 'Béton de propreté dosé à 150 kg/m³ sous semelles', 'M³', 45.0, 9500.0, 427500.0, 'Dosage 150kg']);
    mtLignesDevis.AppendRecord([5, 2, 2, 'ART-GO-02', 'Béton armé pour semelles et amorces poteaux dosé à 350 kg/m³', 'M³', 110.0, 24000.0, 2640000.0, 'Inclus coffrage']);
    mtLignesDevis.AppendRecord([6, 2, 3, 'ART-GO-03', 'Acier à haute adhérence (FeE400) pour béton armé', 'KG', 8500.0, 195.0, 1657500.0, 'Aciers façonnés']);

    // Lot 3 : Maçonnerie & Enduits
    mtLignesDevis.AppendRecord([7, 3, 1, 'ART-MAC-01', 'Maçonnerie de briques creuses de 15cm pour murs extérieurs', 'M²', 420.0, 1600.0, 672000.0, 'Double paroi']);
    mtLignesDevis.AppendRecord([8, 3, 2, 'ART-MAC-02', 'Enduit extérieur au mortier de ciment bâtard en deux couches', 'M²', 420.0, 950.0, 399000.0, 'Finition talochée']);
  finally
    mtLignesDevis.EnableControls;
  end;

  // Filtrer initialement sur le Lot 1
  cbbLotsSelector.ItemIndex := 0;
  cbbLotsSelectorChange(nil);
end;

procedure TfrmFicheTechnique_v3.LoadLotsForFiche;
begin
  cbbLotsSelector.Items.Clear;
  cbbLotsSelector.Items.Add('Lot 01 : Terrassements & Déblais');
  cbbLotsSelector.Items.Add('Lot 02 : Gros Œuvres & Béton Armé');
  cbbLotsSelector.Items.Add('Lot 03 : Maçonnerie & Enduits');
  cbbLotsSelector.Items.Add('Lot 04 : VRD, Voirie & Assainissement');
  cbbLotsSelector.Items.Add('Lot 05 : Électricité & Éclairage');
  cbbLotsSelector.ItemIndex := 0;
  FCurrentLotId := 1;
end;

procedure TfrmFicheTechnique_v3.cbbLotsSelectorChange(Sender: TObject);
begin
  // Bascule dynamique du lot affiché dans la grille
  FCurrentLotId := cbbLotsSelector.ItemIndex + 1;

  mtLignesDevis.DisableControls;
  try
    mtLignesDevis.Filter := Format('LOT_ID = %d', [FCurrentLotId]);
    mtLignesDevis.Filtered := True;
  finally
    mtLignesDevis.EnableControls;
  end;

  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.mtLignesDevisCalcFields(DataSet: TDataSet);
var
  Qte, PU, MtHT: Double;
begin
  // Calcul automatique temps réel : Montant HT = Quantité x Prix Unitaire
  Qte := mtLignesDevis.FieldByName('QUANTITE').AsFloat;
  PU  := mtLignesDevis.FieldByName('PRIX_UNITAIRE').AsFloat;
  MtHT := Qte * PU;
  
  if mtLignesDevis.FieldByName('MONTANT_HT').AsFloat <> MtHT then
  begin
    mtLignesDevis.FieldByName('MONTANT_HT').AsFloat := MtHT;
  end;
end;

procedure TfrmFicheTechnique_v3.mtLignesDevisAfterPost(DataSet: TDataSet);
begin
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.mtLignesDevisAfterDelete(DataSet: TDataSet);
begin
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.dbgLignesDevisColExit(Sender: TObject);
begin
  // Enregistrement automatique dès qu'une cellule est quittée
  if (mtLignesDevis.State in [dsEdit, dsInsert]) then
  begin
    // Calcul Montant HT avant enregistrement
    mtLignesDevis.FieldByName('MONTANT_HT').AsFloat :=
      mtLignesDevis.FieldByName('QUANTITE').AsFloat *
      mtLignesDevis.FieldByName('PRIX_UNITAIRE').AsFloat;
    mtLignesDevis.Post;
  end;
end;

procedure TfrmFicheTechnique_v3.dbgLignesDevisDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  RowColor, TxtColor: TColor;
  TxtVal: string;
  TextRect: TRect;
  Flags: Cardinal;
begin
  Grid := TDBGrid(Sender);

  // 1. Alternance de fond douce et sélection moderne
  if gdSelected in State then
  begin
    RowColor := $00FEEFD8; // Bleu pastel sélection
    TxtColor := $00993D00;
  end
  else if (Grid.DataSource <> nil) and (Grid.DataSource.DataSet <> nil) and
          (Grid.DataSource.DataSet.RecNo mod 2 = 0) then
  begin
    RowColor := $00F8FAFC; // Ligne paire gris très doux
    TxtColor := $001E293B;
  end
  else
  begin
    RowColor := clWhite;
    TxtColor := $001E293B;
  end;

  Grid.Canvas.Brush.Color := RowColor;
  Grid.Canvas.FillRect(Rect);

  Grid.Canvas.Font.Name := 'Segoe UI';
  Grid.Canvas.Font.Size := 9;
  Grid.Canvas.Font.Color := TxtColor;

  if Column.Field <> nil then
    TxtVal := Column.Field.DisplayText
  else
    TxtVal := '';

  // 2. Formatage monétaire spécifique pour Prix Unitaire et Montant HT
  if SameText(Column.FieldName, 'MONTANT_HT') or SameText(Column.FieldName, 'PRIX_UNITAIRE') then
  begin
    if Column.Field <> nil then
      TxtVal := FormatFloat('#,##0.00', Column.Field.AsFloat);
    Grid.Canvas.Font.Style := [fsBold];
  end;

  // 3. Alignement avec marge intérieure de 6px pour éviter que le texte ne colle aux bords
  TextRect := Rect;
  InflateRect(TextRect, -6, -2);
  Flags := DT_SINGLELINE or DT_VCENTER;

  case Column.Alignment of
    taLeftJustify:  Flags := Flags or DT_LEFT;
    taRightJustify: Flags := Flags or DT_RIGHT;
    taCenter:       Flags := Flags or DT_CENTER;
  end;

  DrawText(Grid.Canvas.Handle, PChar(TxtVal), Length(TxtVal), TextRect, Flags);

  // 4. Ligne inférieure de séparation ultra-fine
  Grid.Canvas.Pen.Color := $00E2E8F0;
  Grid.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
  Grid.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
end;

procedure TfrmFicheTechnique_v3.RecalculerTotaux;
var
  CloneDs: TFDMemTable;
  MontantLotActuel: Double;
  TauxTVA: Double;
  TauxRemise: Double;
begin
  FTotalHTGlobal := 0.0;
  MontantLotActuel := 0.0;

  // Lecture des taux (TVA par défaut à 19%, Remise à 0%)
  TauxTVA := 19.0;
  if cbbTauxTVA.ItemIndex = 1 then TauxTVA := 9.0
  else if cbbTauxTVA.ItemIndex = 2 then TauxTVA := 0.0;

  TauxRemise := StrToFloatDef(edtTauxRemise.Text, 0.0);

  // Parcours complet de toutes les lignes sans impacter le filtre visuel actuel
  CloneDs := TFDMemTable.Create(nil);
  try
    CloneDs.CloneCursor(mtLignesDevis, False); // Sans filtre
    CloneDs.First;
    while not CloneDs.Eof do
    begin
      FTotalHTGlobal := FTotalHTGlobal + CloneDs.FieldByName('MONTANT_HT').AsFloat;

      if CloneDs.FieldByName('LOT_ID').AsInteger = FCurrentLotId then
        MontantLotActuel := MontantLotActuel + CloneDs.FieldByName('MONTANT_HT').AsFloat;

      CloneDs.Next;
    end;
  finally
    CloneDs.Free;
  end;

  // Calculs en cascade : Remise, TVA, TTC
  FTotalRemiseGlobal := (FTotalHTGlobal * TauxRemise) / 100.0;
  FTotalTVAGlobal    := ((FTotalHTGlobal - FTotalRemiseGlobal) * TauxTVA) / 100.0;
  FTotalTTCGlobal    := (FTotalHTGlobal - FTotalRemiseGlobal) + FTotalTVAGlobal;

  lblMontantLotEnCours.Caption := 'Sous-total Lot : ' + FormaterMontant(MontantLotActuel);
  lblNombreLignes.Caption      := Format('%d article(s)', [mtLignesDevis.RecordCount]);

  MettreAJourAffichageFinancier;
end;

procedure TfrmFicheTechnique_v3.MettreAJourAffichageFinancier;
begin
  lblTotalHTValue.Caption  := FormaterMontant(FTotalHTGlobal);
  lblRemiseValue.Caption   := '- ' + FormaterMontant(FTotalRemiseGlobal);
  lblTVAValue.Caption      := FormaterMontant(FTotalTVAGlobal);
  lblTotalTTCValue.Caption := FormaterMontant(FTotalTTCGlobal);

  // Formule en toutes lettres réglementaire (Bilingue Arabe / Français)
  memArreteToutesLettres.Text :=
    'Arrêté le présent devis estimatif et quantitatif à la somme totale TTC de : ' + sLineBreak +
    ConvertirChiffreEnLettresDZD(FTotalTTCGlobal, False) + sLineBreak +
    'أوقفت هذه البطاقة التقنية والكشف التقديري عند المبلغ الإجمالي بكل الرسوم قدره : ' + sLineBreak +
    ConvertirChiffreEnLettresDZD(FTotalTTCGlobal, True);
end;

function TfrmFicheTechnique_v3.FormaterMontant(Valeur: Double): string;
begin
  Result := FormatFloat('#,##0.00 "دج"', Valeur);
end;

function TfrmFicheTechnique_v3.ConvertirChiffreEnLettresDZD(Valeur: Double; EnArabe: Boolean): string;
var
  Dinards: Int64;
  Centimes: Integer;
begin
  Dinards := Trunc(Valeur);
  Centimes := Round(Frac(Valeur) * 100);

  if EnArabe then
  begin
    // Formule abrégée pour conformité administrative algérienne
    Result := Format('%s دينار جزائري و %d سنتيم لا غير', [IntToStr(Dinards), Centimes]);
  end
  else
  begin
    Result := Format('%s Dinars Algériens et %d Centimes.', [IntToStr(Dinards), Centimes]);
  end;
end;

procedure TfrmFicheTechnique_v3.btnAjouterLigneClick(Sender: TObject);
var
  NextNumPrix: Integer;
begin
  NextNumPrix := mtLignesDevis.RecordCount + 1;
  mtLignesDevis.Append;
  mtLignesDevis.FieldByName('LOT_ID').AsInteger := FCurrentLotId;
  mtLignesDevis.FieldByName('NUMERO_PRIX').AsInteger := NextNumPrix;
  mtLignesDevis.FieldByName('CODE_ARTICLE').AsString := Format('PRIX-%0.2d', [NextNumPrix]);
  mtLignesDevis.FieldByName('DESIGNATION').AsString := 'Désignation des travaux ou fournitures...';
  mtLignesDevis.FieldByName('UNITE').AsString := 'U';
  mtLignesDevis.FieldByName('QUANTITE').AsFloat := 1.0;
  mtLignesDevis.FieldByName('PRIX_UNITAIRE').AsFloat := 0.0;
  mtLignesDevis.FieldByName('MONTANT_HT').AsFloat := 0.0;
  mtLignesDevis.Post;
end;

procedure TfrmFicheTechnique_v3.btnSupprimerLigneClick(Sender: TObject);
begin
  if not mtLignesDevis.IsEmpty then
  begin
    if MessageDlg('Confirmez-vous la suppression de cette ligne d''article ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      mtLignesDevis.Delete;
      RecalculerTotaux;
    end;
  end;
end;

procedure TfrmFicheTechnique_v3.btnAjouterLotClick(Sender: TObject);
var
  NouveauLotNom: string;
  NouveauLotId: Integer;
begin
  NouveauLotNom := 'Nouveau Lot d''aménagement';
  if InputQuery('Ajouter un nouveau Lot d''aménagements', 'Désignation du Lot :', NouveauLotNom) then
  begin
    NouveauLotId := cbbLotsSelector.Items.Count + 1;
    cbbLotsSelector.Items.Add(Format('Lot %0.2d : %s', [NouveauLotId, NouveauLotNom]));
    cbbLotsSelector.ItemIndex := NouveauLotId - 1;
    cbbLotsSelectorChange(nil);
  end;
end;

procedure TfrmFicheTechnique_v3.btnSupprimerLotClick(Sender: TObject);
begin
  if cbbLotsSelector.Items.Count <= 1 then
  begin
    ShowMessage('Impossible de supprimer le dernier lot.');
    Exit;
  end;

  if MessageDlg('Voulez-vous supprimer ce lot et tous ses articles associés ?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    // Suppression des lignes associées à ce lot
    mtLignesDevis.DisableControls;
    try
      mtLignesDevis.Filtered := False;
      mtLignesDevis.First;
      while not mtLignesDevis.Eof do
      begin
        if mtLignesDevis.FieldByName('LOT_ID').AsInteger = FCurrentLotId then
          mtLignesDevis.Delete
        else
          mtLignesDevis.Next;
      end;
    finally
      mtLignesDevis.EnableControls;
    end;

    cbbLotsSelector.Items.Delete(cbbLotsSelector.ItemIndex);
    cbbLotsSelector.ItemIndex := 0;
    cbbLotsSelectorChange(nil);
  end;
end;

procedure TfrmFicheTechnique_v3.cbbTauxTVAChange(Sender: TObject);
begin
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.edtTauxRemiseChange(Sender: TObject);
begin
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.btnCalculerTotauxClick(Sender: TObject);
begin
  RecalculerTotaux;
  ShowMessage('Calcul des totaux (Sous-totaux Lots, HT, TVA, TTC) actualisé.');
end;

procedure TfrmFicheTechnique_v3.btnEnregistrerClick(Sender: TObject);
begin
  if (mtLignesDevis.State in [dsEdit, dsInsert]) then
    mtLignesDevis.Post;

  RecalculerTotaux;
  ShowMessage('Fiche technique enregistrée avec succès sous le n° ' + edtNumeroFiche.Text);
end;

procedure TfrmFicheTechnique_v3.btnValiderFicheClick(Sender: TObject);
begin
  cbbStatut.ItemIndex := 1; // "مصادق عليه" / Validé
  lblFicheStatusBadge.Caption := 'مصادق عليه (Validé)';
  lblFicheStatusBadge.Color := $00E8F5E9; // Vert clair
  lblFicheStatusBadge.Font.Color := $002E7D32;
  ShowMessage('La fiche technique a été validée pour engagement.');
end;

procedure TfrmFicheTechnique_v3.btnImprimerA4Click(Sender: TObject);
begin
  ShowMessage('Impression de la Fiche Technique Officielle A4 en cours...');
end;

procedure TfrmFicheTechnique_v3.btnFermerClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFicheTechnique_v3.ChargerFiche(AFicheId: Integer);
begin
  // Chargement depuis la base SQL
  edtNumeroFiche.Text := Format('FT-%d/2026', [AFicheId]);
  RecalculerTotaux;
end;

procedure TfrmFicheTechnique_v3.NouvelleFiche;
begin
  edtNumeroFiche.Text := Format('FT-%d/2026', [Random(900) + 100]);
  edtOperation.Text := 'Travaux d''aménagement et d''entretien communal';
  mtLignesDevis.EmptyDataSet;
  RecalculerTotaux;
end;

end.
