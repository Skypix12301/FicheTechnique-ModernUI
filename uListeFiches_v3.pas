unit uListeFiches_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.UITypes,
  uModernTheme;

type
  TfrmListeFiches = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    lblFiltre: TLabel;
    cboFiltreProjet: TComboBox;
    lblRecherche: TLabel;
    edtRecherche: TEdit;
    gridFiches: TDBGrid;
    pnlBottom: TPanel;
    btnNouvelle: TButton;
    btnModifier: TButton;
    btnSupprimer: TButton;
    btnDupliquer: TButton;
    btnImprimer: TButton;
    lblCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure cboFiltreProjetChange(Sender: TObject);
    procedure edtRechercheChange(Sender: TObject);
    procedure gridFichesDblClick(Sender: TObject);
    procedure gridFichesDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnNouvelleClick(Sender: TObject);
    procedure btnModifierClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
    procedure btnDupliquerClick(Sender: TObject);
    procedure btnImprimerClick(Sender: TObject);
  private
    qryFiches: TFDQuery;
    dsFiches: TDataSource;    FSearchTimer: TTimer;
    procedure SearchTimerTick(Sender: TObject);
    procedure ChargerProjets;
    procedure ChargerFiches;
    procedure ConfigurerGrille;
    procedure OuvrirFiche(FicheID: Integer);
    procedure StylerFormulaire;
    procedure ApplyModernLayout;
  public
    procedure RefreshData;
  end;

var
  frmListeFiches: TfrmListeFiches;

implementation

{$R *.dfm}

uses uDataModule_v3, uFicheTechnique_v3, uUtils_v3;

procedure TfrmListeFiches.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);
  ConfigurerRTL_v3(Self);

  qryFiches := TFDQuery.Create(Self);
  qryFiches.Connection := dmMain.FDConnection1;

  dsFiches := TDataSource.Create(Self);
  dsFiches.DataSet := qryFiches;
  gridFiches.DataSource := dsFiches;

  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Interval := 350;
  FSearchTimer.Enabled := False;
  FSearchTimer.OnTimer := SearchTimerTick;

  StylerFormulaire;
  ChargerProjets;
  ConfigurerGrille;
  ChargerFiches;
end;

procedure TfrmListeFiches.FormResize(Sender: TObject);
begin
  ApplyModernLayout;
end;

procedure TfrmListeFiches.ApplyModernLayout;
const
  Margin = 12;
  Gap = 12;
  ToolbarH = 90;
  BottomH = 55;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlTop.SetBounds(0, 0, ClientWidth, ToolbarH);
  pnlTop.Width := ClientWidth;

  lblTitle.SetBounds(Margin, 10, ClientWidth - Margin * 2, 28);
  lblFiltre.SetBounds(Margin, 42, 60, 18);
  cboFiltreProjet.SetBounds(Margin + 64, 38, 200, 36);
  lblRecherche.SetBounds(Margin + 272, 42, 40, 18);
  edtRecherche.SetBounds(Margin + 316, 38, ClientWidth - Margin - 316 - 130, 36);

  pnlBottom.SetBounds(0, ClientHeight - BottomH, ClientWidth, BottomH);
  pnlBottom.Width := ClientWidth;

  btnNouvelle.SetBounds(Margin, ClientHeight - BottomH + 8, 140, 38);
  btnModifier.SetBounds(Margin + 156, ClientHeight - BottomH + 8, 120, 38);
  btnSupprimer.SetBounds(Margin + 284, ClientHeight - BottomH + 8, 120, 38);
  btnDupliquer.SetBounds(Margin + 412, ClientHeight - BottomH + 8, 120, 38);
  btnImprimer.SetBounds(Margin + 540, ClientHeight - BottomH + 8, 120, 38);

  lblCount.SetBounds(ClientWidth - Margin - 100, ClientHeight - BottomH + 12, 100, 18);

  gridFiches.SetBounds(Margin, ToolbarH + Gap, ClientWidth - Margin * 2, ClientHeight - ToolbarH - BottomH - Gap * 2);
end;

procedure TfrmListeFiches.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryFiches.Close;
  FreeAndNil(dsFiches);
  FreeAndNil(qryFiches);
  Action := caFree;
end;

procedure TfrmListeFiches.StylerFormulaire;
begin
  Self.Color := CLR_BG_MAIN;

  pnlTop.Color := CLR_BG_MAIN;
  pnlTop.BevelOuter := bvNone;
  pnlTop.ParentBackground := False;
  pnlTop.Height := 90;
  pnlTop.Align := alTop;

  GVEnsureDecorPanel(Self, pnlTop, 'pnlTopBand',
    0, 0, pnlTop.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  AppliquerThemeLabel(lblTitle, True, False);
  lblTitle.Caption := #1602#1575#1574#1605#1577' '#1575#1604#1576#1591#1575#1602#1575#1578' '#1575#1604#1578#1602#1606#1610#1577;
  lblTitle.Top := 10;

  AppliquerThemeLabel(lblFiltre, False, False);
  lblFiltre.Caption := ':' + #1575#1604#1605#1588#1585#1608#1593;

  AppliquerThemeComboBox(cboFiltreProjet);

  AppliquerThemeLabel(lblRecherche, False, False);
  lblRecherche.Caption := ':' + #1576#1581#1579;

  AppliquerThemeEdit(edtRecherche);

  AppliquerThemeGrille(gridFiches);

  pnlBottom.Color := CLR_BG_SECONDARY;
  pnlBottom.BevelOuter := bvNone;
  pnlBottom.ParentBackground := False;
  pnlBottom.Height := 55;
  pnlBottom.Align := alBottom;

  StyleModernButton(btnNouvelle, bsPrimary, ICO_ADD, #1576#1591#1575#1602#1577' '#1580#1583#1610#1583#1577);
  StyleModernButton(btnModifier, bsSecondary, ICO_EDIT, #1578#1593#1583#1610#1604);
  StyleModernButton(btnSupprimer, bsDanger, ICO_DELETE, #1581#1584#1601);
  StyleModernButton(btnDupliquer, bsSecondary, ICO_COPY, #1606#1587#1582);
  StyleModernButton(btnImprimer, bsSecondary, ICO_PRINT, #1591#1576#1575#1593#1577);

  AppliquerThemeLabel(lblCount, False, True);
  lblCount.Caption := '0 ' + #1576#1591#1575#1602#1577;
end;

procedure TfrmListeFiches.ChargerProjets;
var
  qry: TFDQuery;
begin
  cboFiltreProjet.Items.Clear;
  cboFiltreProjet.Items.AddObject(#1603#1604' '#1575#1604#1605#1588#1575#1585#1610#1593, TObject(0));

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text := 'SELECT ProjetID, NomProjet FROM Projets ORDER BY NomProjet';
    qry.Open;
    while not qry.Eof do
    begin
      cboFiltreProjet.Items.AddObject(
        qry.FieldByName('NomProjet').AsString,
        TObject(qry.FieldByName('ProjetID').AsInteger));
      qry.Next;
    end;
  finally
    qry.Free;
  end;

  cboFiltreProjet.ItemIndex := 0;
end;

procedure TfrmListeFiches.ChargerFiches;
var
  Q: string;
  HasWhere: Boolean;
begin
  Q := Trim(edtRecherche.Text);
  qryFiches.Close;
  qryFiches.SQL.Text := 'SELECT * FROM Vue_FichesResume';
  HasWhere := False;
  if cboFiltreProjet.ItemIndex > 0 then
  begin
    qryFiches.SQL.Add('WHERE ProjetID = :PID');
    HasWhere := True;
  end;
  if Q <> '' then
  begin
    if HasWhere then
      qryFiches.SQL.Add('AND (NumeroFiche LIKE :Q1 OR Operation LIKE :Q2 OR NomProjet LIKE :Q3)')
    else
      qryFiches.SQL.Add('WHERE (NumeroFiche LIKE :Q1 OR Operation LIKE :Q2 OR NomProjet LIKE :Q3)');
  end;
  qryFiches.SQL.Add('ORDER BY DateCreation DESC');
  if cboFiltreProjet.ItemIndex > 0 then
    qryFiches.ParamByName('PID').AsInteger :=
      Integer(cboFiltreProjet.Items.Objects[cboFiltreProjet.ItemIndex]);
  if Q <> '' then
  begin
    qryFiches.ParamByName('Q1').AsString := '%' + Q + '%';
    qryFiches.ParamByName('Q2').AsString := '%' + Q + '%';
    qryFiches.ParamByName('Q3').AsString := '%' + Q + '%';
  end;
  try
    qryFiches.Open;
    lblCount.Caption := IntToStr(qryFiches.RecordCount) + ' ' + #1576#1591#1575#1602#1577;
  except
    on E: Exception do
      ShowErreur(#1582#1591#1571 + ': ' + E.Message);
  end;
end;

procedure TfrmListeFiches.ConfigurerGrille;
begin
  gridFiches.Columns.Clear;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'NumeroFiche';
    Title.Caption := #1585#1602#1605' '#1575#1604#1576#1591#1575#1602#1577;
    Width := 120;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
    Title.Alignment := taCenter;
    Alignment := taCenter;
  end;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'NomProjet';
    Title.Caption := #1575#1604#1605#1588#1585#1608#1593;
    Width := 200;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'Operation';
    Title.Caption := #1575#1604#1593#1605#1604#1610#1577;
    Width := 280;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'DateFiche';
    Title.Caption := #1575#1604#1578#1575#1585#1610#1582;
    Width := 100;
    Alignment := taCenter;
    Title.Alignment := taCenter;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'MontantTTC';
    Title.Caption := #1575#1604#1605#1576#1604#1594 + ' TTC';
    Width := 130;
    Alignment := taCenter;
    Title.Alignment := taCenter;
    Font.Style := [fsBold];
    Font.Color := CLR_PRIMARY;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridFiches.Columns.Add do
  begin
    FieldName := 'Statut';
    Title.Caption := #1575#1604#1581#1575#1604#1577;
    Width := 110;
    Alignment := taCenter;
    Title.Alignment := taCenter;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;
end;

procedure TfrmListeFiches.gridFichesDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Statut: string;
begin
  if SameText(Column.FieldName, 'Statut') then
  begin
    if gdSelected in State then
      gridFiches.Canvas.Brush.Color := CLR_GRID_SELECTED
    else if gridFiches.DataSource.DataSet.RecNo mod 2 = 0 then
      gridFiches.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridFiches.Canvas.Brush.Color := CLR_BG_SECONDARY;
    gridFiches.Canvas.FillRect(Rect);

    Statut := Column.Field.AsString;
    DrawStatusBadge(gridFiches.Canvas, Rect, Statut, StatutColor(Statut));
    Exit;
  end;

  if not (gdSelected in State) then
  begin
    if gridFiches.DataSource.DataSet.RecNo mod 2 = 0 then
      gridFiches.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridFiches.Canvas.Brush.Color := CLR_BG_SECONDARY;
  end
  else
    gridFiches.Canvas.Brush.Color := CLR_GRID_SELECTED;

  gridFiches.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmListeFiches.cboFiltreProjetChange(Sender: TObject);
begin
  ChargerFiches;
end;

procedure TfrmListeFiches.edtRechercheChange(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  FSearchTimer.Enabled := True;
end;

procedure TfrmListeFiches.SearchTimerTick(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  ChargerFiches;
end;

procedure TfrmListeFiches.RefreshData;
begin
  ChargerFiches;
end;

procedure TfrmListeFiches.OuvrirFiche(FicheID: Integer);
var
  Frm: TfrmFicheTechnique;
begin
  Frm := TfrmFicheTechnique.Create(Application.MainForm);
  Frm.ChargerFiche(FicheID);
end;

procedure TfrmListeFiches.gridFichesDblClick(Sender: TObject);
begin
  if (qryFiches.Active) and (not qryFiches.IsEmpty) then
    OuvrirFiche(qryFiches.FieldByName('FicheID').AsInteger);
end;

procedure TfrmListeFiches.btnNouvelleClick(Sender: TObject);
var
  Frm: TfrmFicheTechnique;
begin
  Frm := TfrmFicheTechnique.Create(Application.MainForm);
  Frm.NouveauMode;
end;

procedure TfrmListeFiches.btnModifierClick(Sender: TObject);
begin
  if (qryFiches.Active) and (not qryFiches.IsEmpty) then
    OuvrirFiche(qryFiches.FieldByName('FicheID').AsInteger)
  else
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1576#1591#1575#1602#1577);
end;

procedure TfrmListeFiches.btnSupprimerClick(Sender: TObject);
var
  FicheID: Integer;
begin
  if (not qryFiches.Active) or qryFiches.IsEmpty then
  begin
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1576#1591#1575#1602#1577);
    Exit;
  end;

  FicheID := qryFiches.FieldByName('FicheID').AsInteger;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1575#1604#1576#1591#1575#1602#1577' '#1585#1602#1605 + ' ' +
    qryFiches.FieldByName('NumeroFiche').AsString + ' ?') then
  begin
    ShowLoadingOverlay(#1581#1601#1592'...');
    try
      try
        dmMain.SupprimerFiche(FicheID);
        ChargerFiches;
        ShowSucces(#1578#1605' '#1575#1604#1581#1584#1601' '#1576#1606#1580#1575#1581);
      except
        on E: Exception do
          ShowErreur(#1582#1591#1571' '#1601#1610' '#1575#1604#1581#1584#1601 + ': ' + E.Message);
      end;
    finally
      HideLoadingOverlay;
    end;
  end;
end;

procedure TfrmListeFiches.btnDupliquerClick(Sender: TObject);
var
  FicheID, NewFicheID: Integer;
  NouveauNumero: string;
begin
  if (not qryFiches.Active) or qryFiches.IsEmpty then
  begin
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1576#1591#1575#1602#1577);
    Exit;
  end;

  FicheID := qryFiches.FieldByName('FicheID').AsInteger;

  if InputQuery(#1606#1587#1582' '#1576#1591#1575#1602#1577,
    #1585#1602#1605' '#1575#1604#1576#1591#1575#1602#1577' '#1575#1604#1580#1583#1610#1583#1577 + ':', NouveauNumero) then
  begin
    ShowLoadingOverlay(#1606#1587#1582'...');
    try
      try
        NewFicheID := dmMain.DupliquerFiche(FicheID, NouveauNumero);
        if NewFicheID > 0 then
        begin
          ChargerFiches;
          ShowSucces(#1578#1605' '#1575#1604#1606#1587#1582' '#1576#1606#1580#1575#1581 + ' !');
        end;
      except
        on E: Exception do
          ShowErreur(#1582#1591#1571' '#1601#1610' '#1575#1604#1606#1587#1582 + ': ' + E.Message);
      end;
    finally
      HideLoadingOverlay;
    end;
  end;
end;

procedure TfrmListeFiches.btnImprimerClick(Sender: TObject);
begin
  ShowAvertissement('الطباعة غير متوفرة في هذا الإصدار');
end;

end.
