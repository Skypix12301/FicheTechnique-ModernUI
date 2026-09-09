unit uFicheTechnique_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.UITypes,
  AdvSmoothButton, AdvPanel;

type
  TfrmFicheTechnique = class(TForm)
    pnlToolbar: TPanel;
    btnSave: TButton;
    btnValidate: TButton;
    btnPrint: TButton;
    btnClose: TButton;
    pnlHeader: TPanel;
    lblProjet: TLabel;
    lblNumFiche: TLabel;
    lblDate: TLabel;
    lblTVA: TLabel;
    lblStatut: TLabel;
    lblOperation: TLabel;
    cboProjet: TComboBox;
    edtNumFiche: TEdit;
    dtpDate: TDateTimePicker;
    edtTVA: TEdit;
    edtStatut: TEdit;
    memoOperation: TMemo;
    PageControlLots: TPageControl;
    pnlRecap: TPanel;
    gridRecap: TStringGrid;
    lblMontantLettres: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnValidateClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cboProjetChange(Sender: TObject);
    procedure PageControlLotsChange(Sender: TObject);
  private
    FFicheID: Integer;
    FIsNew: Boolean;
    FModified: Boolean;
    FLoading: Boolean;
    FSaving: Boolean;
    FWorkspace: TScrollBox;
    FRecapScroll: TScrollBox;
    procedure FieldChanged(Sender: TObject);
    procedure EditorCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ThemeChanged;
    FMontantHT: Currency;
    FMontantTVA: Currency;
    FMontantTTC: Currency;
    FRecapBox: TPaintBox;
    FRecapNames: TArray<string>;
    FRecapTotals: TArray<Currency>;
    FTVARate: Double;
    procedure RecapBoxPaint(Sender: TObject);
    procedure StylerFormulaire;
    procedure ChargerProjets;
    procedure ChargerLots;
    procedure CreerOngletLot(LotFicheID: Integer; const NomLot: string);
    procedure CreerOngletAjouterLot;
    function CreerGrilleLot(Parent: TWinControl; LotFicheID: Integer): TDBGrid;
    procedure ConfigurerColonnesGrille(Grid: TDBGrid);
    procedure CreerBoutonsLot(Parent: TWinControl; LotFicheID: Integer);
    procedure MettreAJourRecapitulatif;
    procedure MettreAJourMontantLettres;
    procedure btnAjouterLigneClick(Sender: TObject);
    procedure btnSupprimerLigneClick(Sender: TObject);
    procedure btnSupprimerLotClick(Sender: TObject);
    procedure OnPageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure OnGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ApplyModernLayout;
  public
    destructor Destroy; override;
    function ConfirmLeave: Boolean;
    function SaveFiche: Boolean;
    procedure NouveauMode;
    procedure ChargerFiche(AFicheID: Integer);
  end;

var
  frmFicheTechnique: TfrmFicheTechnique;

implementation

{$R *.dfm}

uses uDataModule_v3, uModernTheme, uUtils_v3, uGraphicsGDIP, uMain_v3, System.Math,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

procedure TfrmFicheTechnique.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);
  ConfigurerRTL_v3(Self);

  Self.KeyPreview := True;

  FFicheID := 0;
  FIsNew := True;
  FModified := False;
  FMontantHT := 0;
  FMontantTVA := 0;
  FMontantTTC := 0;

  FLoading := True;
  FWorkspace := CreateWorkspace(Self);
  OnResize := FormResize;
  OnKeyDown := FormKeyDown;
  OnCloseQuery := EditorCloseQuery;
  memoOperation.OnChange := FieldChanged;
  edtTVA.OnChange := FieldChanged;
  cboProjet.OnChange := cboProjetChange;
  dtpDate.Enabled := False;
  dtpDate.ShowHint := True;
  dtpDate.Hint := 'تاريخ الإنشاء يحدده النظام';
  dtpDate.ParentBiDiMode := False;
  dtpDate.BiDiMode := bdLeftToRight;
  PageControlLots.OnChanging := OnPageControlChanging;
  StylerFormulaire;
  ChargerProjets;
  dtpDate.Date := Now;
  edtTVA.Text := '9.00';
  edtStatut.Text := #1605#1587#1608#1583#1577;

  gridRecap.FixedRows := 0;
  gridRecap.FixedCols := 0;
  FLoading := False;
  FModified := False;
  RegisterThemeObserver(ThemeChanged);
  ApplyModernLayout;
end;

destructor TfrmFicheTechnique.Destroy;
begin
  UnregisterThemeObserver(ThemeChanged);
  inherited;
end;

procedure TfrmFicheTechnique.ThemeChanged;
begin
  AppliquerThemeTousLesComposants(Self);
  StylerFormulaire;
  ApplyModernLayout;
  Invalidate;
end;

procedure TfrmFicheTechnique.FieldChanged(Sender: TObject);
begin
  if not FLoading then FModified := True;
end;

function TfrmFicheTechnique.ConfirmLeave: Boolean;
begin
  Result := not FSaving;
  if not Result or not FModified then Exit;
  case Confirmer3('هل تريد حفظ تغييرات بيانات البطاقة؟' + sLineBreak +
    'تعديلات الحصص والسطور تُحفظ مباشرة ولا يلغيها الخروج.') of
    mrYes: Result := SaveFiche;
    mrNo: Result := True;
  else
    Result := False;
  end;
end;

procedure TfrmFicheTechnique.EditorCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmLeave;
end;

procedure TfrmFicheTechnique.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfrmFicheTechnique.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('S')) and (ssCtrl in Shift) then
  begin
    btnSaveClick(nil);
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    btnCloseClick(nil);
    Key := 0;
  end;
end;

procedure TfrmFicheTechnique.StylerFormulaire;
begin
  Self.Color := CLR_BG_MAIN;

  pnlToolbar.Color := CLR_BG_SECONDARY;
  pnlToolbar.BevelOuter := bvNone;
  pnlToolbar.ParentBackground := False;
  pnlToolbar.Align := alTop;
  pnlToolbar.Height := DIM_TOOLBAR_HEIGHT;

  GVEnsureDecorPanel(Self, pnlToolbar, 'pnlToolbarBand',
    0, 0, pnlToolbar.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  StyleModernButton(btnSave, bsPrimary, ICO_SAVE, #1581#1601#1592);
  StyleModernButton(btnValidate, bsSuccess, ICO_ACCEPT, #1605#1589#1575#1583#1602#1577);
  StyleModernButton(btnPrint, bsSecondary, ICO_PRINT, #1591#1576#1575#1593#1577);
  StyleModernButton(btnClose, bsDanger, ICO_CANCEL, #1573#1590#1604#1575#1602);

  pnlHeader.Color := CLR_BG_SECONDARY;
  pnlHeader.BevelOuter := bvNone;
  pnlHeader.ParentBackground := False;

  AppliquerThemeLabel(lblProjet, False, False);
  lblProjet.Caption := ':' + #1575#1604#1605#1588#1585#1608#1593;

  AppliquerThemeLabel(lblNumFiche, False, False);
  lblNumFiche.Caption := ':' + #1585#1602#1605' '#1575#1604#1576#1591#1575#1602#1577;

  AppliquerThemeLabel(lblDate, False, False);
  lblDate.Caption := ':' + #1575#1604#1578#1575#1585#1610#1582;

  AppliquerThemeLabel(lblTVA, False, False);
  lblTVA.Caption := ':' + #1606#1587#1576#1577' '#1575#1604#1585#1587#1605 + ' %';

  AppliquerThemeLabel(lblStatut, False, False);
  lblStatut.Caption := ':' + #1575#1604#1581#1575#1604#1577;

  AppliquerThemeLabel(lblOperation, False, False);
  lblOperation.Caption := ':' + #1575#1604#1593#1605#1604#1610#1577;

  AppliquerThemeComboBox(cboProjet);
  AppliquerThemeEdit(edtNumFiche);
  edtNumFiche.ReadOnly := True;
  edtNumFiche.Color := CLR_BG_DISABLED;
  AppliquerThemeEdit(edtTVA);
  edtTVA.BiDiMode := bdLeftToRight;
  AppliquerThemeEdit(edtStatut);
  edtStatut.ReadOnly := True;
  edtStatut.Color := CLR_BG_DISABLED;
  AppliquerThemeMemo(memoOperation);

  pnlRecap.Color := CLR_BG_SECONDARY;
  pnlRecap.BevelOuter := bvNone;
  pnlRecap.ParentBackground := False;
  pnlRecap.Height := 150;

  GVEnsureDecorPanel(Self, pnlRecap, 'pnlRecapBand',
    0, 0, pnlRecap.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  gridRecap.Visible := False;

  lblMontantLettres.Font.Name := FONT_BOLD;
  lblMontantLettres.Font.Size := FONT_SIZE_BODY;
  lblMontantLettres.Font.Style := [fsBold];
  lblMontantLettres.Font.Color := CLR_PRIMARY;
  lblMontantLettres.WordWrap := True;
  lblMontantLettres.AutoSize := False;
  lblMontantLettres.Align := alBottom;
  lblMontantLettres.AlignWithMargins := True;
  lblMontantLettres.Height := 40;

  if FRecapBox = nil then
  begin
    FRecapScroll := TScrollBox.Create(Self);
    FRecapScroll.Parent := pnlRecap;
    FRecapScroll.BorderStyle := bsNone;
    FRecapScroll.BiDiMode := bdLeftToRight;
    FRecapScroll.VertScrollBar.Tracking := True;
    FRecapBox := TPaintBox.Create(Self);
    FRecapBox.Parent := FRecapScroll;
    FRecapBox.OnPaint := RecapBoxPaint;
  end;
  FRecapScroll.Color := CLR_BG_SECONDARY;
  edtNumFiche.ParentBiDiMode := False;
  edtNumFiche.BiDiMode := bdLeftToRight;
  edtNumFiche.TabStop := False;
  edtStatut.TabStop := False;
  btnPrint.Enabled := False;
  btnPrint.ShowHint := True;
  btnPrint.Hint := 'الطباعة غير متاحة في هذا الإصدار';
end;

procedure TfrmFicheTechnique.ChargerProjets;
var
  qry: TFDQuery;
begin
  cboProjet.Items.Clear;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text := 'SELECT ProjetID, NomProjet FROM Projets ORDER BY NomProjet';
    qry.Open;
    while not qry.Eof do
    begin
      cboProjet.Items.AddObject(
        qry.FieldByName('NomProjet').AsString,
        TObject(qry.FieldByName('ProjetID').AsInteger));
      qry.Next;
    end;
  finally
    qry.Free;
  end;
end;

procedure TfrmFicheTechnique.NouveauMode;
begin
  FIsNew := True;
  FFicheID := 0;
  Caption := #1576#1591#1575#1602#1577' '#1578#1602#1606#1610#1577' '#1580#1583#1610#1583#1577;
  edtNumFiche.Text := '';
  edtStatut.Text := #1605#1587#1608#1583#1577;
  memoOperation.Clear;
  dtpDate.Date := Now;
end;

procedure TfrmFicheTechnique.ChargerFiche(AFicheID: Integer);
var
  qry: TFDQuery;
  I: Integer;
begin
  FLoading := True;
  FFicheID := AFicheID;
  FIsNew := False;
  cboProjet.Enabled := False;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text :=
      'SELECT f.*, p.NomProjet FROM FichesTechniques f ' +
      'INNER JOIN Projets p ON f.ProjetID = p.ProjetID ' +
      'WHERE f.FicheID = :ID';
    qry.ParamByName('ID').AsInteger := AFicheID;
    qry.Open;

    if not qry.IsEmpty then
    begin
      for I := 0 to cboProjet.Items.Count - 1 do
      begin
        if Integer(cboProjet.Items.Objects[I]) = qry.FieldByName('ProjetID').AsInteger then
        begin
          cboProjet.ItemIndex := I;
          Break;
        end;
      end;

      edtNumFiche.Text := qry.FieldByName('NumeroFiche').AsString;
      dtpDate.Date := qry.FieldByName('DateFiche').AsDateTime;
      edtTVA.Text := FormatFloat('0.00', qry.FieldByName('TauxTVA').AsFloat);
      edtStatut.Text := qry.FieldByName('Statut').AsString;
      memoOperation.Text := qry.FieldByName('Operation').AsString;

      FMontantHT := qry.FieldByName('MontantHT').AsCurrency;
      FMontantTVA := qry.FieldByName('MontantTVA').AsCurrency;
      FMontantTTC := qry.FieldByName('MontantTTC').AsCurrency;

      Caption := #1576#1591#1575#1602#1577' '#1578#1602#1606#1610#1577 + ' - ' + edtNumFiche.Text;

      ChargerLots;
      MettreAJourRecapitulatif;
    end
    else
      raise Exception.Create('البطاقة غير موجودة أو حُذفت');
    FModified := False;
  finally
    qry.Free;
    FLoading := False;
  end;
end;

procedure TfrmFicheTechnique.ChargerLots;
var
  qry: TFDQuery;
  I: Integer;
begin
  for I := PageControlLots.PageCount - 1 downto 0 do
    PageControlLots.Pages[I].Free;

  if FFicheID <= 0 then Exit;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text :=
      'SELECT LotFicheID, CodeLot, NomLot, OrdreAffichage, TotalLot ' +
      'FROM LotsFiches WHERE FicheID = :FicheID ORDER BY OrdreAffichage';
    qry.ParamByName('FicheID').AsInteger := FFicheID;
    qry.Open;

    while not qry.Eof do
    begin
      CreerOngletLot(
        qry.FieldByName('LotFicheID').AsInteger,
        qry.FieldByName('NomLot').AsString);
      qry.Next;
    end;
  finally
    qry.Free;
  end;

  CreerOngletAjouterLot;

  if PageControlLots.PageCount > 1 then
    PageControlLots.ActivePageIndex := 0;
end;

procedure TfrmFicheTechnique.CreerOngletLot(LotFicheID: Integer;
  const NomLot: string);
var
  Tab: TTabSheet;
  Grid: TDBGrid;
  pnlActions: TPanel;
begin
  Tab := TTabSheet.Create(PageControlLots);
  Tab.PageControl := PageControlLots;
  Tab.Caption := NomLot;
  Tab.Tag := LotFicheID;

  pnlActions := TPanel.Create(Tab);
  pnlActions.Parent := Tab;
  pnlActions.Align := alBottom;
  pnlActions.Height := 50;
  pnlActions.BevelOuter := bvNone;
  pnlActions.ParentBackground := False;
  pnlActions.Color := CLR_BG_SECONDARY;
  CreerBoutonsLot(pnlActions, LotFicheID);

  Grid := CreerGrilleLot(Tab, LotFicheID);
  Grid.Align := alClient;
end;

procedure TfrmFicheTechnique.CreerOngletAjouterLot;
var
  Tab: TTabSheet;
begin
  Tab := TTabSheet.Create(PageControlLots);
  Tab.PageControl := PageControlLots;
  Tab.Caption := ' + ';
  Tab.Tag := -1;
end;

procedure TfrmFicheTechnique.OnPageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  NewIndex: Integer;
  CodeLot, NomLot: string;
  LotID: Integer;
begin
  NewIndex := PageControlLots.IndexOfTabAt(
    PageControlLots.ScreenToClient(Mouse.CursorPos).X,
    PageControlLots.ScreenToClient(Mouse.CursorPos).Y);

  if (NewIndex >= 0) and (NewIndex < PageControlLots.PageCount) then
  begin
    if PageControlLots.Pages[NewIndex].Tag = -1 then
    begin
      AllowChange := False;

      if FFicheID <= 0 then
      begin
        ShowAvertissement(#1610#1580#1576' '#1581#1601#1592' '#1575#1604#1576#1591#1575#1602#1577' '#1571#1608#1604#1575);
        Exit;
      end;

      if InputQuery(#1581#1589#1577' '#1580#1583#1610#1583#1577,
        #1585#1605#1586' '#1575#1604#1581#1589#1577 + ':', CodeLot) then
      begin
        if InputQuery(#1581#1589#1577' '#1580#1583#1610#1583#1577,
          #1575#1587#1605' '#1575#1604#1581#1589#1577 + ':', NomLot) then
        begin
          LotID := dmMain.AjouterLot(FFicheID, CodeLot, NomLot);
          if LotID > 0 then
          begin
            ChargerLots;
            FModified := True;
          end;
        end;
      end;
    end;
  end;
end;

function TfrmFicheTechnique.CreerGrilleLot(Parent: TWinControl;
  LotFicheID: Integer): TDBGrid;
var
  DS: TDataSource;
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Parent);
  qry.Connection := dmMain.FDConnection1;
  qry.SQL.Text :=
    'SELECT l.LigneID, l.NumeroLigne, l.Designation, ' +
    'u.Symbole AS Unite, l.Quantite, l.PrixUnitaire, l.Montant ' +
    'FROM LignesFiches l ' +
    'INNER JOIN Unites u ON l.UniteID = u.UniteID ' +
    'WHERE l.LotFicheID = :LotFicheID ' +
    'ORDER BY l.OrdreAffichage';
  qry.ParamByName('LotFicheID').AsInteger := LotFicheID;
  try
    qry.Open;
  except
  end;

  DS := TDataSource.Create(Parent);
  DS.DataSet := qry;

  Result := TDBGrid.Create(Parent);
  Result.Parent := Parent;
  Result.DataSource := DS;
  Result.Tag := LotFicheID;

  AppliquerThemeGrille(Result);
  Result.OnDrawColumnCell := OnGridDrawColumnCell;

  ConfigurerColonnesGrille(Result);
end;

procedure TfrmFicheTechnique.OnGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
begin
  Grid := Sender as TDBGrid;

  if not (gdSelected in State) then
  begin
    if Grid.DataSource.DataSet.RecNo mod 2 = 0 then
      Grid.Canvas.Brush.Color := CLR_GRID_ALT
    else
      Grid.Canvas.Brush.Color := CLR_BG_SECONDARY;
  end
  else
    Grid.Canvas.Brush.Color := CLR_GRID_SELECTED;

  if Column.FieldName = 'Montant' then
  begin
    Grid.Canvas.FillRect(Rect);
    Grid.Canvas.Font.Style := [fsBold];
    Grid.Canvas.Font.Color := CLR_PRIMARY;
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 4,
      Column.Field.DisplayText);
  end
  else
    Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmFicheTechnique.ConfigurerColonnesGrille(Grid: TDBGrid);
begin
  Grid.Columns.Clear;

  with Grid.Columns.Add do
  begin
    FieldName := 'NumeroLigne';
    Title.Caption := #1585#1602#1605;
    Width := 60;
    Title.Alignment := taCenter;
    Alignment := taCenter;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with Grid.Columns.Add do
  begin
    FieldName := 'Designation';
    Title.Caption := #1578#1593#1610#1610#1606' '#1575#1604#1571#1588#1594#1575#1604;
    Width := 380;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with Grid.Columns.Add do
  begin
    FieldName := 'Unite';
    Title.Caption := #1575#1604#1608#1581#1583#1577;
    Width := 60;
    Title.Alignment := taCenter;
    Alignment := taCenter;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with Grid.Columns.Add do
  begin
    FieldName := 'Quantite';
    Title.Caption := #1575#1604#1603#1605#1610#1577;
    Width := 100;
    Title.Alignment := taCenter;
    Alignment := taCenter;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with Grid.Columns.Add do
  begin
    FieldName := 'PrixUnitaire';
    Title.Caption := #1587#1593#1585' '#1575#1604#1608#1581#1583#1577;
    Width := 110;
    Title.Alignment := taCenter;
    Alignment := taCenter;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with Grid.Columns.Add do
  begin
    FieldName := 'Montant';
    Title.Caption := #1575#1604#1605#1576#1604#1594;
    Width := 130;
    Title.Alignment := taCenter;
    Alignment := taCenter;
    Font.Style := [fsBold];
    Font.Color := CLR_PRIMARY;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
    Color := CLR_GRID_ALT;
  end;
end;

procedure TfrmFicheTechnique.CreerBoutonsLot(Parent: TWinControl;
  LotFicheID: Integer);
var
  Btn: TAdvSmoothButton;
  LblTotal: TLabel;
begin
  Btn := TAdvSmoothButton.Create(Parent);
  Btn.Parent := Parent;
  Btn.SetBounds(10, 8, 130, 35);
  Btn.Caption := #1587#1591#1585' '#1580#1583#1610#1583;
  Btn.Tag := LotFicheID;
  Btn.OnClick := btnAjouterLigneClick;
  GVApplyButtonStyle(Btn, True);

  Btn := TAdvSmoothButton.Create(Parent);
  Btn.Parent := Parent;
  Btn.SetBounds(150, 8, 130, 35);
  Btn.Caption := #1581#1584#1601' '#1587#1591#1585;
  Btn.Tag := LotFicheID;
  Btn.OnClick := btnSupprimerLigneClick;
  GVApplyButtonStyle(Btn, False);

  Btn := TAdvSmoothButton.Create(Parent);
  Btn.Parent := Parent;
  Btn.SetBounds(290, 8, 130, 35);
  Btn.Caption := #1581#1584#1601' '#1575#1604#1581#1589#1577;
  Btn.Tag := LotFicheID;
  Btn.OnClick := btnSupprimerLotClick;
  Btn.Color := CLR_BG_SECONDARY;
  Btn.BevelColor := CLR_DANGER;

  LblTotal := TLabel.Create(Parent);
  LblTotal.Parent := Parent;
  LblTotal.Left := Parent.Width - 300;
  LblTotal.Top := 12;
  LblTotal.Width := 280;
  LblTotal.Alignment := taLeftJustify;
  LblTotal.Font.Name := FONT_BOLD;
  LblTotal.Font.Size := FONT_SIZE_HEADING;
  LblTotal.Font.Style := [fsBold];
  LblTotal.Font.Color := CLR_PRIMARY;
  LblTotal.Caption := #1575#1604#1605#1580#1605#1608#1593 + ': 0.00 ' + #1583#1580;
  LblTotal.Name := 'lblTotal_' + IntToStr(LotFicheID);
  LblTotal.Anchors := [akTop, akLeft];
end;

procedure TfrmFicheTechnique.btnAjouterLigneClick(Sender: TObject);
var
  LotFicheID: Integer;
  Dlg: TForm;
  edtNum, edtDesign, edtQte, edtPU: TEdit;
  cboUnite: TComboBox;
  btnOK, btnAnnuler: TButton;
  lblN, lblD, lblU, lblQ, lblP: TLabel;
  qryU: TFDQuery;
  Y: Integer;
begin
  LotFicheID := (Sender as TControl).Tag;

  Dlg := TForm.Create(Self);
  try
    Dlg.Caption := #1573#1590#1575#1601#1577' '#1587#1591#1585' '#1580#1583#1610#1583;
    Dlg.Width := 560;
    Dlg.Height := 400;
    Dlg.Position := poScreenCenter;
    Dlg.BorderStyle := bsDialog;
    Dlg.BiDiMode := bdRightToLeft;
    Dlg.Font.Name := FONT_MAIN;
    Dlg.Font.Size := FONT_SIZE_BODY;
    Dlg.Color := CLR_BG_MAIN;
    Dlg.DoubleBuffered := True;

    Y := 20;

    lblN := TLabel.Create(Dlg); lblN.Parent := Dlg;
    lblN.Left := 20; lblN.Top := Y;
    lblN.Caption := ':' + #1585#1602#1605' '#1575#1604#1587#1591#1585;
    AppliquerThemeLabel(lblN, False, False);
    Inc(Y, 24);
    edtNum := TEdit.Create(Dlg); edtNum.Parent := Dlg;
    edtNum.Left := 20; edtNum.Top := Y; edtNum.Width := 510;
    AppliquerThemeEdit(edtNum);
    edtNum.BiDiMode := bdLeftToRight;
    Inc(Y, 40);

    lblD := TLabel.Create(Dlg); lblD.Parent := Dlg;
    lblD.Left := 20; lblD.Top := Y;
    lblD.Caption := ':' + #1578#1593#1610#1610#1606' '#1575#1604#1571#1588#1594#1575#1604;
    AppliquerThemeLabel(lblD, False, False);
    Inc(Y, 24);
    edtDesign := TEdit.Create(Dlg); edtDesign.Parent := Dlg;
    edtDesign.Left := 20; edtDesign.Top := Y; edtDesign.Width := 510;
    AppliquerThemeEdit(edtDesign);
    Inc(Y, 40);

    lblU := TLabel.Create(Dlg); lblU.Parent := Dlg;
    lblU.Left := 20; lblU.Top := Y;
    lblU.Caption := ':' + #1575#1604#1608#1581#1583#1577;
    AppliquerThemeLabel(lblU, False, False);
    Inc(Y, 24);
    cboUnite := TComboBox.Create(Dlg); cboUnite.Parent := Dlg;
    cboUnite.Left := 20; cboUnite.Top := Y; cboUnite.Width := 200;
    cboUnite.Style := csDropDownList;
    AppliquerThemeComboBox(cboUnite);

    qryU := TFDQuery.Create(nil);
    try
      qryU.Connection := dmMain.FDConnection1;
      qryU.SQL.Text := 'SELECT UniteID, Symbole FROM Unites WHERE Actif = 1';
      qryU.Open;
      while not qryU.Eof do
      begin
        cboUnite.Items.AddObject(
          qryU.FieldByName('Symbole').AsString,
          TObject(qryU.FieldByName('UniteID').AsInteger));
        qryU.Next;
      end;
    finally
      qryU.Free;
    end;

    lblQ := TLabel.Create(Dlg); lblQ.Parent := Dlg;
    lblQ.Left := 250; lblQ.Top := Y - 24;
    lblQ.Caption := ':' + #1575#1604#1603#1605#1610#1577;
    AppliquerThemeLabel(lblQ, False, False);
    edtQte := TEdit.Create(Dlg); edtQte.Parent := Dlg;
    edtQte.Left := 250; edtQte.Top := Y; edtQte.Width := 120;
    AppliquerThemeEdit(edtQte);
    edtQte.BiDiMode := bdLeftToRight;
    edtQte.Text := '0';

    lblP := TLabel.Create(Dlg); lblP.Parent := Dlg;
    lblP.Left := 390; lblP.Top := Y - 24;
    lblP.Caption := ':' + #1587#1593#1585' '#1575#1604#1608#1581#1583#1577;
    AppliquerThemeLabel(lblP, False, False);
    edtPU := TEdit.Create(Dlg); edtPU.Parent := Dlg;
    edtPU.Left := 390; edtPU.Top := Y; edtPU.Width := 140;
    AppliquerThemeEdit(edtPU);
    edtPU.BiDiMode := bdLeftToRight;
    edtPU.Text := '0';

    Inc(Y, 55);

    btnOK := TButton.Create(Dlg); btnOK.Parent := Dlg;
    btnOK.Left := 280; btnOK.Top := Y; btnOK.Width := 130; btnOK.Height := 40;
    btnOK.Caption := #10133 + ' ' + #1573#1590#1575#1601#1577;
    btnOK.ModalResult := mrOk;
    AppliquerThemeBouton(btnOK, bsPrimary);

    btnAnnuler := TButton.Create(Dlg); btnAnnuler.Parent := Dlg;
    btnAnnuler.Left := 420; btnAnnuler.Top := Y; btnAnnuler.Width := 110; btnAnnuler.Height := 40;
    btnAnnuler.Caption := #1573#1604#1594#1575#1569;
    btnAnnuler.ModalResult := mrCancel;
    AppliquerThemeBouton(btnAnnuler, bsGhost);

    if Dlg.ShowModal = mrOk then
    begin
      if (Trim(edtNum.Text) <> '') and (Trim(edtDesign.Text) <> '') and
         (cboUnite.ItemIndex >= 0) then
      begin
        ShowLoadingOverlay(#1573#1590#1575#1601#1577'...');
        try
          try
            dmMain.AjouterLigne(
              FFicheID,
              LotFicheID,
              edtNum.Text,
              edtDesign.Text,
              Integer(cboUnite.Items.Objects[cboUnite.ItemIndex]),
              StrToFloatDef(edtQte.Text, 0),
              StrToFloatDef(edtPU.Text, 0));

            ChargerLots;
            dmMain.RecalculerTotaux(FFicheID);
            MettreAJourRecapitulatif;
            FModified := True;
          except
            on E: Exception do
              ShowErreur(#1582#1591#1571' '#1601#1610' '#1575#1604#1573#1590#1575#1601#1577 + ': ' + E.Message);
          end;
        finally
          HideLoadingOverlay;
        end;
      end
      else
        ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1605#1604#1569' '#1580#1605#1610#1593' '#1575#1604#1581#1602#1608#1604);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmFicheTechnique.btnSupprimerLigneClick(Sender: TObject);
var
  Grid: TDBGrid;
  LigneID: Integer;
  I: Integer;
begin
  Grid := nil;
  for I := 0 to PageControlLots.ActivePage.ControlCount - 1 do
  begin
    if PageControlLots.ActivePage.Controls[I] is TDBGrid then
    begin
      Grid := TDBGrid(PageControlLots.ActivePage.Controls[I]);
      Break;
    end;
  end;

  if (Grid = nil) or (Grid.DataSource = nil) or (Grid.DataSource.DataSet = nil) then Exit;
  if Grid.DataSource.DataSet.IsEmpty then Exit;

  LigneID := Grid.DataSource.DataSet.FieldByName('LigneID').AsInteger;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1607#1584#1575' '#1575#1604#1587#1591#1585' ?') then
  begin
    dmMain.SupprimerLigne(LigneID);
    ChargerLots;
    dmMain.RecalculerTotaux(FFicheID);
    MettreAJourRecapitulatif;
    FModified := True;
  end;
end;

procedure TfrmFicheTechnique.btnSupprimerLotClick(Sender: TObject);
var
  LotFicheID: Integer;
begin
  LotFicheID := (Sender as TControl).Tag;

  if PageControlLots.PageCount <= 2 then
  begin
    ShowAvertissement(#1604#1575' '#1610#1605#1603#1606' '#1581#1584#1601' '#1575#1604#1581#1589#1577' '#1575#1604#1571#1582#1610#1585#1577);
    Exit;
  end;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1607#1584#1607' '#1575#1604#1581#1589#1577' '#1608#1580#1605#1610#1593' '#1587#1591#1608#1585#1607#1575' ?') then
  begin
    dmMain.SupprimerLot(LotFicheID);
    ChargerLots;
    dmMain.RecalculerTotaux(FFicheID);
    MettreAJourRecapitulatif;
    FModified := True;
  end;
end;

procedure TfrmFicheTechnique.cboProjetChange(Sender: TObject);
begin
  if FLoading then Exit;
  FieldChanged(Sender);
  if FIsNew and (cboProjet.ItemIndex >= 0) then
  begin
    try
      edtNumFiche.Text := dmMain.GenererNumeroFiche(
        Integer(cboProjet.Items.Objects[cboProjet.ItemIndex]));
    except
    end;
  end;
end;

procedure TfrmFicheTechnique.PageControlLotsChange(Sender: TObject);
begin
end;

procedure TfrmFicheTechnique.MettreAJourRecapitulatif;
var
  qry: TFDQuery;
  n: Integer;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text :=
      'SELECT NomLot, TotalLot FROM Vue_TotauxParLot ' +
      'WHERE FicheID = :FicheID ORDER BY OrdreAffichage';
    qry.ParamByName('FicheID').AsInteger := FFicheID;
    qry.Open;

    SetLength(FRecapNames, qry.RecordCount);
    SetLength(FRecapTotals, qry.RecordCount);
    FMontantHT := 0;
    n := 0;
    while not qry.Eof do
    begin
      FRecapNames[n] := qry.FieldByName('NomLot').AsString;
      FRecapTotals[n] := qry.FieldByName('TotalLot').AsCurrency;
      FMontantHT := FMontantHT + FRecapTotals[n];
      Inc(n);
      qry.Next;
    end;

    FTVARate := StrToFloatDef(edtTVA.Text, 9.0);
    FMontantTVA := FMontantHT * (FTVARate / 100);
    FMontantTTC := FMontantHT + FMontantTVA;

    if FRecapBox <> nil then
      FRecapBox.Invalidate;

    MettreAJourMontantLettres;
  finally
    qry.Free;
  end;
end;

procedure TfrmFicheTechnique.RecapBoxPaint(Sender: TObject);
var
  G: TGPGraphics;
  Pen: TGPPen;
  W: Integer;
  Y, RowH: Single;
  i: Integer;
  Devise: string;

  procedure DrawRow(const ALabel, AAmount: string; ABold: Boolean;
    AColor: TColor; ASize: Integer);
  var
    LR, AR: TGPRectF;
    FS: TFontStyleGP;
  begin
    if ABold then FS := fgBold else FS := fgRegular;
    LR := MakeRect(W * 0.40, Y, W * 0.58, RowH);
    AR := MakeRect(6, Y, W * 0.38, RowH);
    DrawTextGP(G, ALabel, LR, FONT_MAIN, ASize, FS, AColor, taRightGP, True);
    DrawTextGP(G, AAmount, AR, FONT_BOLD, ASize, fgBold, AColor, taLeftGP, True);
    Y := Y + RowH;
  end;

  procedure DrawDivider(AThick: Single);
  begin
    Pen := TGPPen.Create(GPColor(ActiveTheme.Border), AThick);
    try
      G.DrawLine(Pen, 6.0, Y + 3, W - 6.0, Y + 3);
    finally
      Pen.Free;
    end;
    Y := Y + 8;
  end;

begin
  if FRecapBox = nil then Exit;
  W := FRecapBox.Width;
  Devise := ' ' + #1583#1580;

  G := TGPGraphics.Create(FRecapBox.Canvas.Handle);
  try
    SetupHighQuality(G);
    G.Clear(GPColor(ActiveTheme.BgSecondary));
    RowH := 22;
    Y := 4;

    for i := 0 to High(FRecapNames) do
      DrawRow(FRecapNames[i], FormaterMontant(FRecapTotals[i]) + Devise,
        False, ActiveTheme.TextSecondary, 10);

    DrawDivider(1.0);

    DrawRow(#1575#1604#1605#1580#1605#1608#1593' '#1583#1608#1606' '#1575#1604#1585#1587#1608#1605,
      FormaterMontant(FMontantHT) + Devise, True, ActiveTheme.TextMain, FONT_SIZE_BODY);

    DrawRow(#1575#1604#1585#1587#1605' '#1593#1604#1609' '#1575#1604#1602#1610#1605#1577' '#1575#1604#1605#1590#1575#1601#1577 +
      ' ' + FormatFloat('0.00', FTVARate) + '%',
      FormaterMontant(FMontantTVA) + Devise, False, ActiveTheme.TextMain, FONT_SIZE_BODY);

    DrawDivider(1.5);

    FillRoundRect(G, MakeRect(4, Y, W - 8.0, RowH + 6), 8,
      BlendColor(ActiveTheme.Primary, ActiveTheme.BgSecondary, 0.82), 255);
    DrawTextGP(G, #1575#1604#1605#1580#1605#1608#1593' '#1576#1603#1604' '#1575#1604#1585#1587#1608#1605,
      MakeRect(W * 0.40, Y + 3, W * 0.56, RowH), FONT_BOLD, FONT_SIZE_HEADING, fgBold,
      ActiveTheme.PrimaryDark, taRightGP, True);
    DrawTextGP(G, FormaterMontant(FMontantTTC) + Devise,
      MakeRect(10, Y + 3, W * 0.38, RowH), FONT_BOLD, FONT_SIZE_HEADING, fgBold,
      ActiveTheme.PrimaryDark, taLeftGP, True);
  finally
    G.Free;
  end;
end;

procedure TfrmFicheTechnique.MettreAJourMontantLettres;
begin
  lblMontantLettres.Caption := #1581#1583#1583' '#1605#1576#1604#1594' '#1607#1584#1607' '#1575#1604#1576#1591#1575#1602#1577' '#1576 + ': ' +
    ConvertirNombreEnLettresAR(FMontantTTC);
end;

procedure TfrmFicheTechnique.btnSaveClick(Sender: TObject);
begin
  SaveFiche;
end;

function TfrmFicheTechnique.SaveFiche: Boolean;
var
  ProjetID: Integer;
  TauxTVA: Double;
begin
  Result := False;
  if FSaving then Exit;
  if not ValiderChampCombo(cboProjet, 'المشروع') then Exit;
  if Trim(memoOperation.Text) = '' then
  begin
    ShowAvertissement('الرجاء إدخال العملية');
    if memoOperation.CanFocus then memoOperation.SetFocus;
    Exit;
  end;
  if not TryParseDecimal(edtTVA.Text, TauxTVA) or
    (TauxTVA < 0) or (TauxTVA > 100) then
  begin
    ShowAvertissement('أدخل نسبة رسم صحيحة بين 0 و100');
    if edtTVA.CanFocus then edtTVA.SetFocus;
    Exit;
  end;
  ProjetID := Integer(cboProjet.Items.Objects[cboProjet.ItemIndex]);
  FSaving := True;
  btnSave.Enabled := False;
  btnValidate.Enabled := False;
  try
    ShowLoadingOverlay('جارٍ الحفظ...');
    try
      if FIsNew then
      begin
        if Trim(edtNumFiche.Text) = '' then
          edtNumFiche.Text := dmMain.GenererNumeroFiche(ProjetID);
        FFicheID := dmMain.CreerFicheVide(ProjetID, edtNumFiche.Text, memoOperation.Text);
        if FFicheID <= 0 then raise Exception.Create('تعذر إنشاء البطاقة');
        // The ID already exists: retries must update it, never insert a duplicate.
        FIsNew := False;
        cboProjet.Enabled := False;
        Caption := 'بطاقة تقنية - ' + edtNumFiche.Text;
      end;
      dmMain.ModifierFiche(FFicheID, memoOperation.Text, TauxTVA);
      FModified := False;
      Result := True;
      if PageControlLots.PageCount = 0 then ChargerLots;
      MettreAJourRecapitulatif;
    finally
      HideLoadingOverlay;
    end;
    ShowSucces('تم حفظ البطاقة بنجاح');
  except
    on E: Exception do
    begin
      Result := False;
      FModified := True;
      ShowErreur('تعذر إكمال الحفظ: ' + E.Message);
    end;
  end;
  FSaving := False;
  btnSave.Enabled := True;
  btnValidate.Enabled := FFicheID > 0;
end;

procedure TfrmFicheTechnique.btnValidateClick(Sender: TObject);
begin
  if FFicheID <= 0 then
  begin
    ShowAvertissement(#1610#1580#1576' '#1581#1601#1592' '#1575#1604#1576#1591#1575#1602#1577' '#1571#1608#1604#1575);
    Exit;
  end;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1575#1604#1605#1589#1575#1583#1602#1577' '#1593#1604#1609' '#1607#1584#1607' '#1575#1604#1576#1591#1575#1602#1577' ?') then
  begin
    ShowLoadingOverlay(#1585#1589#1575#1583#1602'...');
    try
      try
        dmMain.ValiderFiche(FFicheID);
        edtStatut.Text := #1575#1589#1575#1583#1602' '#1593#1604#1610#1607;
        ShowSucces(#1578#1605#1578' '#1575#1604#1605#1589#1575#1583#1602#1577' '#1576#1606#1580#1575#1581 + ' !');
      except
        on E: Exception do
          ShowErreur(#1582#1591#1571 + ': ' + E.Message);
      end;
    finally
      HideLoadingOverlay;
    end;
  end;
end;

procedure TfrmFicheTechnique.btnPrintClick(Sender: TObject);
begin
  ShowSucces(#1602#1585#1610#1576#1575);
end;

procedure TfrmFicheTechnique.btnCloseClick(Sender: TObject);
begin
  if (Parent <> nil) and (Owner is TfrmMain) then
    TfrmMain(Owner).RequestCloseEditor
  else
    Close;
end;

procedure TfrmFicheTechnique.FormResize(Sender: TObject);
begin
  ApplyModernLayout;
end;

procedure TfrmFicheTechnique.ApplyModernLayout;
const
  Margin = 12;
  Gap = 12;
  ToolbarH = 56;
  RecapH = 150;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlToolbar.SetBounds(0, 0, ClientWidth, ToolbarH);
  pnlToolbar.Width := ClientWidth;

  pnlHeader.SetBounds(Margin, ToolbarH + Gap, ClientWidth - Margin * 2, 30);

  pnlRecap.SetBounds(Margin, pnlHeader.Top + pnlHeader.Height + Gap,
    ClientWidth - Margin * 2, RecapH);

  if FRecapBox <> nil then
  begin
    FRecapBox.SetBounds(6, 6, pnlRecap.ClientWidth - 12, pnlRecap.ClientHeight - 12);
  end;

  lblMontantLettres.SetBounds(Margin, pnlRecap.Top + pnlRecap.Height + Gap,
    ClientWidth - Margin * 2, 40);

  PageControlLots.SetBounds(Margin, lblMontantLettres.Top + lblMontantLettres.Height + Gap,
    ClientWidth - Margin * 2,
    ClientHeight - lblMontantLettres.Top - lblMontantLettres.Height - Gap * 2 - Margin);
end;

end.
