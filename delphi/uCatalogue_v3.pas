unit uCatalogue_v3;

{==============================================================================}
{ Catalogue & Bordereau des Prix Unitaires (BPU) BTPH - Delphi VCL             }
{ Gestion : Référentiel des prix, catégories de travaux, recherche instantanée,}
{ insertion directe vers la Fiche Technique active, import/export Excel/CSV    }
{ Compatible Delphi XE8, 10.x, 11 Alexandria, 12 Athens                        }
{==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, uBaseForm, uVCLModernizer;

type
  { Événement de sélection d'un article pour insertion dans un devis }
  TOnArticleSelectedEvent = procedure(
    Sender: TObject;
    const CodeArticle, Designation, Unite: string;
    PrixUnitaire: Double
  ) of object;

  TfrmCatalogue_v3 = class(TfrmBase)
    { Conteneur principal }
    pnlRoot: TPanel;

    { Barre d'en-tête & Actions }
    pnlTopActionBar: TPanel;
    lblFormTitle: TLabel;
    lblFormSubtitle: TLabel;
    btnInsererDansDevis: TSpeedButton;
    btnNouveauPrix: TSpeedButton;
    btnModifierPrix: TSpeedButton;
    btnSupprimerPrix: TSpeedButton;
    btnFermer: TSpeedButton;

    { Volet de filtrage et recherche (Carte moderne) }
    pnlFilterCard: TPanel;
    lblRecherche: TLabel;
    edtSearchText: TEdit;
    lblCategorie: TLabel;
    cbbCategories: TComboBox;
    btnRechercher: TSpeedButton;
    btnReinitialiserFiltres: TSpeedButton;
    lblCompteurArticles: TLabel;

    { Carte centrale contenant le tableau TDBGrid du BPU }
    pnlGridCard: TPanel;
    dbgCatalogue: TDBGrid;

    { Volet latéral droit : Détail et édition rapide de l'article sélectionné }
    pnlDetailCard: TPanel;
    lblDetailTitle: TLabel;
    lblDetailCode: TLabel;
    edtDetailCode: TEdit;
    lblDetailDesignation: TLabel;
    memDetailDesignation: TMemo;
    lblDetailUnite: TLabel;
    cbbDetailUnite: TComboBox;
    lblDetailPU: TLabel;
    edtDetailPU: TEdit;
    lblDetailDZD: TLabel;
    lblDetailCategorie: TLabel;
    cbbDetailCategorie: TComboBox;
    lblDetailObservations: TLabel;
    memDetailObservations: TMemo;
    btnSauvegarderDetail: TSpeedButton;
    btnAnnulerDetail: TSpeedButton;

    { Source de données & Dataset en mémoire FireDAC }
    dsCatalogue: TDataSource;
    mtCatalogue: TFDMemTable;
    mtCatalogueID: TIntegerField;
    mtCatalogueCATEGORIE_ID: TIntegerField;
    mtCatalogueCATEGORIE_NOM: TStringField;
    mtCatalogueCODE_ARTICLE: TStringField;
    mtCatalogueDESIGNATION: TStringField;
    mtCatalogueUNITE: TStringField;
    mtCataloguePRIX_UNITAIRE: TFloatField;
    mtCatalogueOBSERVATIONS: TStringField;
    mtCatalogueDATE_MAJ: TDateField;

    { Événements VCL }
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgCatalogueDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgCatalogueDblClick(Sender: TObject);
    procedure dsCatalogueDataChange(Sender: TObject; Field: TField);
    procedure edtSearchTextChange(Sender: TObject);
    procedure cbbCategoriesChange(Sender: TObject);
    procedure btnNouveauPrixClick(Sender: TObject);
    procedure btnModifierPrixClick(Sender: TObject);
    procedure btnSupprimerPrixClick(Sender: TObject);
    procedure btnSauvegarderDetailClick(Sender: TObject);
    procedure btnAnnulerDetailClick(Sender: TObject);
    procedure btnInsererDansDevisClick(Sender: TObject);
    procedure btnFermerClick(Sender: TObject);
  private
    FSelectMode: Boolean;
    FOnArticleSelected: TOnArticleSelectedEvent;
    procedure InitDataset;
    procedure SeedStandardArticlesBTPH;
    procedure AppliquerFiltres;
    procedure SynchroniserDetailDepuisDataset;
    function FormaterMonnaie(Valeur: Double): string;
  protected
    procedure SetupModernUI; override;
  public
    { Mode Sélection pour appel depuis la fiche technique }
    property SelectMode: Boolean read FSelectMode write FSelectMode;
    property OnArticleSelected: TOnArticleSelectedEvent read FOnArticleSelected write FOnArticleSelected;
  end;

var
  frmCatalogue_v3: TfrmCatalogue_v3;

implementation

{$R *.dfm}

procedure TfrmCatalogue_v3.FormCreate(Sender: TObject);
begin
  inherited;
  FSelectMode := False;
  InitDataset;
  SeedStandardArticlesBTPH;
end;

procedure TfrmCatalogue_v3.FormShow(Sender: TObject);
begin
  SetupModernUI;
  btnInsererDansDevis.Visible := FSelectMode;
  if FSelectMode then
  begin
    lblFormTitle.Caption := 'Sélectionner un Article du Bordereau des Prix';
    btnInsererDansDevis.Left := pnlTopActionBar.Width - 210;
  end;
  AppliquerFiltres;
end;

procedure TfrmCatalogue_v3.SetupModernUI;
begin
  inherited;
  // 1. Anti-scintillement pour tous les conteneurs
  TVCLModernizer.ModernizeForm(Self, 'Segoe UI');

  // 2. Application du Card UI épuré
  ApplyCardStyle(pnlTopActionBar);
  ApplyCardStyle(pnlFilterCard);
  ApplyCardStyle(pnlGridCard);
  ApplyCardStyle(pnlDetailCard);

  // 3. Configuration visuelle du TDBGrid
  dbgCatalogue.BorderStyle := bsNone;
  dbgCatalogue.DrawingStyle := gdsClassic;
  dbgCatalogue.Options := [
    dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines,
    dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete
  ];
end;

procedure TfrmCatalogue_v3.InitDataset;
begin
  if mtCatalogue.FieldCount = 0 then
  begin
    mtCatalogue.FieldDefs.Clear;
    mtCatalogue.FieldDefs.Add('ID', ftAutoInc);
    mtCatalogue.FieldDefs.Add('CATEGORIE_ID', ftInteger);
    mtCatalogue.FieldDefs.Add('CATEGORIE_NOM', ftString, 60);
    mtCatalogue.FieldDefs.Add('CODE_ARTICLE', ftString, 30);
    mtCatalogue.FieldDefs.Add('DESIGNATION', ftString, 255);
    mtCatalogue.FieldDefs.Add('UNITE', ftString, 15);
    mtCatalogue.FieldDefs.Add('PRIX_UNITAIRE', ftFloat);
    mtCatalogue.FieldDefs.Add('OBSERVATIONS', ftString, 150);
    mtCatalogue.FieldDefs.Add('DATE_MAJ', ftDate);
    mtCatalogue.CreateDataSet;
  end
  else if not mtCatalogue.Active then
    mtCatalogue.Open;
end;

procedure TfrmCatalogue_v3.SeedStandardArticlesBTPH;
begin
  mtCatalogue.DisableControls;
  try
    mtCatalogue.EmptyDataSet;

    // Catégorie 1 : Terrassements
    mtCatalogue.AppendRecord([1, 1, 'Terrassements', 'TER-001', 'Décapage terre végétale ep. 20cm', 'M²', 180.0, 'Mise en dépôt provisoire', Date]);
    mtCatalogue.AppendRecord([2, 1, 'Terrassements', 'TER-002', 'Fouilles en pleine masse terrain ordinaire', 'M³', 650.0, 'Évacuation comprise', Date]);
    mtCatalogue.AppendRecord([3, 1, 'Terrassements', 'TER-003', 'Fouilles en rigoles et tranchées pour fondations', 'M³', 850.0, 'Largeur < 2.00m', Date]);
    mtCatalogue.AppendRecord([4, 1, 'Terrassements', 'TER-004', 'Remblais d''apport en tuf sélectionné compacté', 'M³', 1400.0, 'Essai Proctor 95%', Date]);

    // Catégorie 2 : Béton & Gros Œuvres
    mtCatalogue.AppendRecord([5, 2, 'Gros Œuvres', 'BA-001', 'Béton de propreté dosé à 150 kg/m³', 'M³', 9500.0, 'Épaisseur 10cm', Date]);
    mtCatalogue.AppendRecord([6, 2, 'Gros Œuvres', 'BA-002', 'Béton armé pour semelles et longrines dosé à 350 kg/m³', 'M³', 24000.0, 'Coffrage soigné', Date]);
    mtCatalogue.AppendRecord([7, 2, 'Gros Œuvres', 'BA-003', 'Béton armé pour poteaux, poutres et chaînages dosé à 350 kg/m³', 'M³', 26500.0, 'Vibration comprise', Date]);
    mtCatalogue.AppendRecord([8, 2, 'Gros Œuvres', 'BA-004', 'Fourniture et façonnage d''aciers FeE400 pour béton armé', 'KG', 195.0, 'Cintrage et ligature', Date]);
    mtCatalogue.AppendRecord([9, 2, 'Gros Œuvres', 'BA-005', 'Plancher à corps creux 16+4cm y compris dalle de compression', 'M²', 4800.0, 'Hourdis et poutrelles', Date]);

    // Catégorie 3 : Maçonnerie & Enduits
    mtCatalogue.AppendRecord([10, 3, 'Maçonnerie', 'MAC-001', 'Maçonnerie en briques creuses de 15cm pour double cloison', 'M²', 1600.0, 'Mortier de ciment', Date]);
    mtCatalogue.AppendRecord([11, 3, 'Maçonnerie', 'MAC-002', 'Maçonnerie en briques creuses de 10cm pour cloisons intérieures', 'M²', 1250.0, 'Pose soignée', Date]);
    mtCatalogue.AppendRecord([12, 3, 'Maçonnerie', 'MAC-003', 'Enduit extérieur au mortier bâtard ciment en 2 couches', 'M²', 950.0, 'Finition talochée', Date]);
    mtCatalogue.AppendRecord([13, 3, 'Maçonnerie', 'MAC-004', 'Enduit intérieur au plâtre projeté ou lissé', 'M²', 750.0, 'Finition lisse pour peinture', Date]);

    // Catégorie 4 : VRD, Assainissement & Voirie
    mtCatalogue.AppendRecord([14, 4, 'VRD & Voirie', 'VRD-001', 'Canalisation en béton armé centrifugé classe 135A Diam. 300mm', 'ML', 3800.0, 'Joints élastomère', Date]);
    mtCatalogue.AppendRecord([15, 4, 'VRD & Voirie', 'VRD-002', 'Canalisation en béton armé centrifugé classe 135A Diam. 400mm', 'ML', 5200.0, 'Pose en tranchée', Date]);
    mtCatalogue.AppendRecord([16, 4, 'VRD & Voirie', 'VRD-003', 'Regard de visite préfabriqué 80x80cm avec tampon en fonte D400', 'U', 18500.0, 'Cadre et tampon fonte', Date]);
    mtCatalogue.AppendRecord([17, 4, 'VRD & Voirie', 'VRD-004', 'Fourniture et pose de bordures de trottoir type T2', 'ML', 1800.0, 'Lit de béton 10cm', Date]);
    mtCatalogue.AppendRecord([18, 4, 'VRD & Voirie', 'VRD-005', 'Revêtement en enrobé bitumineux à chaud épaisseur 6cm (0/10)', 'M²', 2200.0, 'Couche d''accrochage incluse', Date]);

    // Catégorie 5 : Électricité & Éclairage
    mtCatalogue.AppendRecord([19, 5, 'Électricité', 'ELEC-001', 'Candélabre d''éclairage public H=8m complet avec crosse et lanterne LED', 'U', 78000.0, 'Massif béton inclus', Date]);
    mtCatalogue.AppendRecord([20, 5, 'Électricité', 'ELEC-002', 'Câble armé cuivre U-1000 R2V 4x16 mm² sous gaine TPC 90', 'ML', 1650.0, 'Grillage avertisseur', Date]);
  finally
    mtCatalogue.EnableControls;
  end;
end;

procedure TfrmCatalogue_v3.dbgCatalogueDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  RowColor, TxtColor: TColor;
  TxtVal: string;
  TextRect: TRect;
  Flags: Cardinal;
begin
  Grid := TDBGrid(Sender);

  // Alternance moderne des lignes
  if gdSelected in State then
  begin
    RowColor := $00FEEFD8; // Bleu pastel sélection
    TxtColor := $00993D00;
  end
  else if (Grid.DataSource <> nil) and (Grid.DataSource.DataSet <> nil) and
          (Grid.DataSource.DataSet.RecNo mod 2 = 0) then
  begin
    RowColor := $00F8FAFC;
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

  // Formatage gras et monétaire pour Prix Unitaire
  if SameText(Column.FieldName, 'PRIX_UNITAIRE') then
  begin
    if Column.Field <> nil then
      TxtVal := FormatFloat('#,##0.00 "دج"', Column.Field.AsFloat);
    Grid.Canvas.Font.Style := [fsBold];
  end;

  TextRect := Rect;
  InflateRect(TextRect, -6, -2);
  Flags := DT_SINGLELINE or DT_VCENTER;

  case Column.Alignment of
    taLeftJustify:  Flags := Flags or DT_LEFT;
    taRightJustify: Flags := Flags or DT_RIGHT;
    taCenter:       Flags := Flags or DT_CENTER;
  end;

  DrawText(Grid.Canvas.Handle, PChar(TxtVal), Length(TxtVal), TextRect, Flags);

  // Délimitation fine
  Grid.Canvas.Pen.Color := $00E2E8F0;
  Grid.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
  Grid.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
end;

procedure TfrmCatalogue_v3.dsCatalogueDataChange(Sender: TObject; Field: TField);
begin
  SynchroniserDetailDepuisDataset;
end;

procedure TfrmCatalogue_v3.SynchroniserDetailDepuisDataset;
begin
  if mtCatalogue.IsEmpty then
  begin
    edtDetailCode.Text := '';
    memDetailDesignation.Text := '';
    cbbDetailUnite.ItemIndex := -1;
    edtDetailPU.Text := '0.00';
    memDetailObservations.Text := '';
    Exit;
  end;

  edtDetailCode.Text := mtCatalogue.FieldByName('CODE_ARTICLE').AsString;
  memDetailDesignation.Text := mtCatalogue.FieldByName('DESIGNATION').AsString;
  cbbDetailUnite.Text := mtCatalogue.FieldByName('UNITE').AsString;
  edtDetailPU.Text := FormatFloat('0.00', mtCatalogue.FieldByName('PRIX_UNITAIRE').AsFloat);
  cbbDetailCategorie.Text := mtCatalogue.FieldByName('CATEGORIE_NOM').AsString;
  memDetailObservations.Text := mtCatalogue.FieldByName('OBSERVATIONS').AsString;
end;

procedure TfrmCatalogue_v3.edtSearchTextChange(Sender: TObject);
begin
  AppliquerFiltres;
end;

procedure TfrmCatalogue_v3.cbbCategoriesChange(Sender: TObject);
begin
  AppliquerFiltres;
end;

procedure TfrmCatalogue_v3.AppliquerFiltres;
var
  FiltreExpr: string;
  MotCle: string;
begin
  MotCle := Trim(edtSearchText.Text);
  FiltreExpr := '';

  // Filtre par catégorie
  if (cbbCategories.ItemIndex > 0) and (cbbCategories.Text <> 'Toutes les catégories') then
  begin
    FiltreExpr := Format('CATEGORIE_NOM = ''%s''', [cbbCategories.Text]);
  end;

  // Filtre texte par mot-clé (code ou désignation)
  if MotCle <> '' then
  begin
    if FiltreExpr <> '' then FiltreExpr := FiltreExpr + ' AND ';
    FiltreExpr := FiltreExpr + Format('((CODE_ARTICLE LIKE ''%%%s%%'') OR (DESIGNATION LIKE ''%%%s%%''))', [MotCle, MotCle]);
  end;

  mtCatalogue.DisableControls;
  try
    if FiltreExpr <> '' then
    begin
      mtCatalogue.Filter := FiltreExpr;
      mtCatalogue.Filtered := True;
    end
    else
      mtCatalogue.Filtered := False;
  finally
    mtCatalogue.EnableControls;
  end;

  lblCompteurArticles.Caption := Format('%d article(s) trouvé(s)', [mtCatalogue.RecordCount]);
end;

procedure TfrmCatalogue_v3.btnNouveauPrixClick(Sender: TObject);
begin
  mtCatalogue.Append;
  mtCatalogue.FieldByName('CATEGORIE_ID').AsInteger := 1;
  mtCatalogue.FieldByName('CATEGORIE_NOM').AsString := 'Terrassements';
  mtCatalogue.FieldByName('CODE_ARTICLE').AsString := 'NOUV-01';
  mtCatalogue.FieldByName('DESIGNATION').AsString := 'Nouvel article BTPH...';
  mtCatalogue.FieldByName('UNITE').AsString := 'M²';
  mtCatalogue.FieldByName('PRIX_UNITAIRE').AsFloat := 0.0;
  mtCatalogue.FieldByName('DATE_MAJ').AsDateTime := Date;
  mtCatalogue.Post;

  edtDetailCode.SetFocus;
end;

procedure TfrmCatalogue_v3.btnModifierPrixClick(Sender: TObject);
begin
  if not mtCatalogue.IsEmpty then
    edtDetailPU.SetFocus;
end;

procedure TfrmCatalogue_v3.btnSupprimerPrixClick(Sender: TObject);
begin
  if mtCatalogue.IsEmpty then Exit;

  if MessageDlg('Confirmez-vous la suppression de cet article du bordereau ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    mtCatalogue.Delete;
    AppliquerFiltres;
  end;
end;

procedure TfrmCatalogue_v3.btnSauvegarderDetailClick(Sender: TObject);
begin
  if mtCatalogue.IsEmpty then Exit;

  mtCatalogue.Edit;
  mtCatalogue.FieldByName('CODE_ARTICLE').AsString := edtDetailCode.Text;
  mtCatalogue.FieldByName('DESIGNATION').AsString := memDetailDesignation.Text;
  mtCatalogue.FieldByName('UNITE').AsString := cbbDetailUnite.Text;
  mtCatalogue.FieldByName('PRIX_UNITAIRE').AsFloat := StrToFloatDef(edtDetailPU.Text, 0.0);
  mtCatalogue.FieldByName('CATEGORIE_NOM').AsString := cbbDetailCategorie.Text;
  mtCatalogue.FieldByName('OBSERVATIONS').AsString := memDetailObservations.Text;
  mtCatalogue.FieldByName('DATE_MAJ').AsDateTime := Date;
  mtCatalogue.Post;

  ShowMessage('Article mis à jour avec succès dans le Bordereau des Prix.');
end;

procedure TfrmCatalogue_v3.btnAnnulerDetailClick(Sender: TObject);
begin
  SynchroniserDetailDepuisDataset;
end;

procedure TfrmCatalogue_v3.dbgCatalogueDblClick(Sender: TObject);
begin
  if FSelectMode then
    btnInsererDansDevisClick(Sender);
end;

procedure TfrmCatalogue_v3.btnInsererDansDevisClick(Sender: TObject);
begin
  if mtCatalogue.IsEmpty then Exit;

  if Assigned(FOnArticleSelected) then
  begin
    FOnArticleSelected(
      Self,
      mtCatalogue.FieldByName('CODE_ARTICLE').AsString,
      mtCatalogue.FieldByName('DESIGNATION').AsString,
      mtCatalogue.FieldByName('UNITE').AsString,
      mtCatalogue.FieldByName('PRIX_UNITAIRE').AsFloat
    );
  end;

  ModalResult := mrOk;
end;

procedure TfrmCatalogue_v3.btnFermerClick(Sender: TObject);
begin
  Close;
end;

function TfrmCatalogue_v3.FormaterMonnaie(Valeur: Double): string;
begin
  Result := FormatFloat('#,##0.00 "دج"', Valeur);
end;

end.
