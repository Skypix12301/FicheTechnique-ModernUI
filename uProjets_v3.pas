unit uProjets_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.UITypes,
  AdvPanel,
  uModernTheme;

type
  TfrmProjets = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    pnlForm: TPanel;
    lblType: TLabel;
    lblCode: TLabel;
    lblNom: TLabel;
    lblWilaya: TLabel;
    lblDaira: TLabel;
    lblCommune: TLabel;
    lblMO: TLabel;
    cboType: TComboBox;
    edtCode: TEdit;
    edtNom: TEdit;
    edtWilaya: TEdit;
    edtDaira: TEdit;
    edtCommune: TEdit;
    edtMO: TEdit;
    btnAjouter: TButton;
    btnModifier: TButton;
    btnVider: TButton;
    gridProjets: TDBGrid;
    pnlBottomActions: TPanel;
    btnSupprimer: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure btnAjouterClick(Sender: TObject);
    procedure btnModifierClick(Sender: TObject);
    procedure btnViderClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
    procedure gridProjetsCellClick(Column: TColumn);
    procedure gridProjetsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    qryProjets: TFDQuery;
    dsProjets: TDataSource;
    FEditProjetID: Integer;
    FFormCard: TAdvPanel;
    procedure ChargerTypesProjets;
    procedure ChargerProjets;
    procedure ConfigurerGrille;
    procedure ViderForm;
    procedure ChargerProjetDansForm;
    procedure StylerFormulaire;
    procedure ApplyModernLayout;
  end;

var
  frmProjets: TfrmProjets;

implementation

{$R *.dfm}

uses uDataModule_v3, uUtils_v3;

procedure TfrmProjets.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);
  ConfigurerRTL_v3(Self);

  FEditProjetID := 0;

  qryProjets := TFDQuery.Create(Self);
  qryProjets.Connection := dmMain.FDConnection1;

  dsProjets := TDataSource.Create(Self);
  dsProjets.DataSet := qryProjets;
  gridProjets.DataSource := dsProjets;

  StylerFormulaire;
  ChargerTypesProjets;
  ChargerProjets;
  ConfigurerGrille;
end;

procedure TfrmProjets.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryProjets.Close;
  FreeAndNil(dsProjets);
  FreeAndNil(qryProjets);
  Action := caFree;
end;

procedure TfrmProjets.StylerFormulaire;
begin
  Self.Color := CLR_BG_MAIN;

  pnlTop.Color := CLR_BG_MAIN;
  pnlTop.BevelOuter := bvNone;
  pnlTop.ParentBackground := False;
  AppliquerThemeLabel(lblTitle, True, False);
  lblTitle.Caption := #1573#1583#1575#1585#1577' '#1575#1604#1605#1588#1575#1585#1610#1593;

  GVEnsureDecorPanel(Self, pnlTop, 'pnlTopBand',
    0, 0, pnlTop.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  pnlForm.Color := CLR_BG_MAIN;
  pnlForm.BevelOuter := bvNone;
  pnlForm.ParentBackground := False;

  FFormCard := TAdvPanel.Create(Self);
  FFormCard.Parent := pnlForm;
  FFormCard.SetBounds(8, 4, pnlForm.Width - 16, pnlForm.Height - 8);
  FFormCard.Anchors := [akLeft, akTop, akRight, akBottom];
  GVApplyCardStyle(FFormCard, CLR_BG_SECONDARY, CLR_BORDER);

  lblType.Parent := FFormCard;
  cboType.Parent := FFormCard;
  lblCode.Parent := FFormCard;
  edtCode.Parent := FFormCard;
  lblNom.Parent := FFormCard;
  edtNom.Parent := FFormCard;
  lblWilaya.Parent := FFormCard;
  edtWilaya.Parent := FFormCard;
  lblDaira.Parent := FFormCard;
  edtDaira.Parent := FFormCard;
  lblCommune.Parent := FFormCard;
  edtCommune.Parent := FFormCard;
  lblMO.Parent := FFormCard;
  edtMO.Parent := FFormCard;
  btnAjouter.Parent := FFormCard;
  btnModifier.Parent := FFormCard;
  btnVider.Parent := FFormCard;

  AppliquerThemeLabel(lblType, False, False);    lblType.Caption := ':' + #1575#1604#1606#1608#1593;
  AppliquerThemeLabel(lblCode, False, False);    lblCode.Caption := ':' + #1575#1604#1585#1605#1586;
  AppliquerThemeLabel(lblNom, False, False);     lblNom.Caption := ':' + #1575#1587#1605' '#1575#1604#1605#1588#1585#1608#1593;
  AppliquerThemeLabel(lblWilaya, False, False);  lblWilaya.Caption := ':' + #1575#1604#1608#1604#1575#1610#1577;
  AppliquerThemeLabel(lblDaira, False, False);   lblDaira.Caption := ':' + #1575#1604#1583#1575#1574#1585#1577;
  AppliquerThemeLabel(lblCommune, False, False); lblCommune.Caption := ':' + #1575#1604#1576#1604#1583#1610#1577;
  AppliquerThemeLabel(lblMO, False, False);      lblMO.Caption := ':' + #1589#1575#1581#1576' '#1575#1604#1605#1588#1585#1608#1593;

  AppliquerThemeComboBox(cboType);
  AppliquerThemeEdit(edtCode);
  edtCode.BiDiMode := bdLeftToRight;
  AppliquerThemeEdit(edtNom);
  AppliquerThemeEdit(edtWilaya);
  AppliquerThemeEdit(edtDaira);
  AppliquerThemeEdit(edtCommune);
  AppliquerThemeEdit(edtMO);

  StyleModernButton(btnAjouter, bsPrimary, ICO_ADD, #1573#1590#1575#1601#1577);
  StyleModernButton(btnModifier, bsSecondary, ICO_EDIT, #1578#1593#1583#1610#1604);
  StyleModernButton(btnVider, bsGhost, ICO_CANCEL, #1578#1601#1585#1610#1594);

  AppliquerThemeGrille(gridProjets);

  pnlBottomActions.Color := CLR_BG_SECONDARY;
  pnlBottomActions.BevelOuter := bvNone;
  pnlBottomActions.ParentBackground := False;
  StyleModernButton(btnSupprimer, bsDanger, ICO_DELETE, #1581#1584#1601);
end;

procedure TfrmProjets.ChargerTypesProjets;
var
  qry: TFDQuery;
begin
  cboType.Items.Clear;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text := 'SELECT TypeProjetID, NomType FROM TypesProjets WHERE Actif = 1';
    qry.Open;
    while not qry.Eof do
    begin
      cboType.Items.AddObject(
        qry.FieldByName('NomType').AsString,
        TObject(qry.FieldByName('TypeProjetID').AsInteger));
      qry.Next;
    end;
  finally
    qry.Free;
  end;
end;

procedure TfrmProjets.ChargerProjets;
begin
  qryProjets.Close;
  qryProjets.SQL.Text :=
    'SELECT p.ProjetID, tp.NomType, p.CodeProjet, p.NomProjet, ' +
    'p.Wilaya, p.Daira, p.Commune, p.MaitreOuvrage, p.DateCreation ' +
    'FROM Projets p ' +
    'INNER JOIN TypesProjets tp ON p.TypeProjetID = tp.TypeProjetID ' +
    'ORDER BY p.DateCreation DESC';
  try
    qryProjets.Open;
  except
  end;
end;

procedure TfrmProjets.ConfigurerGrille;
begin
  gridProjets.Columns.Clear;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'CodeProjet';
    Title.Caption := #1575#1604#1585#1605#1586;
    Width := 100;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'NomType';
    Title.Caption := #1575#1604#1606#1608#1593;
    Width := 100;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'NomProjet';
    Title.Caption := #1575#1587#1605' '#1575#1604#1605#1588#1585#1608#1593;
    Width := 250;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'Wilaya';
    Title.Caption := #1575#1604#1608#1604#1575#1610#1577;
    Width := 100;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'Commune';
    Title.Caption := #1575#1604#1576#1604#1583#1610#1577;
    Width := 100;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridProjets.Columns.Add do
  begin
    FieldName := 'MaitreOuvrage';
    Title.Caption := #1589#1575#1581#1576' '#1575#1604#1605#1588#1585#1608#1593;
    Width := 200;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;
end;

procedure TfrmProjets.gridProjetsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if not (gdSelected in State) then
  begin
    if gridProjets.DataSource.DataSet.RecNo mod 2 = 0 then
      gridProjets.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridProjets.Canvas.Brush.Color := CLR_BG_SECONDARY;
  end
  else
    gridProjets.Canvas.Brush.Color := CLR_GRID_SELECTED;

  gridProjets.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmProjets.ViderForm;
begin
  FEditProjetID := 0;
  cboType.ItemIndex := -1;
  edtCode.Clear;
  edtNom.Clear;
  edtWilaya.Clear;
  edtDaira.Clear;
  edtCommune.Clear;
  edtMO.Clear;
  if cboType.CanFocus then
    cboType.SetFocus;
end;

procedure TfrmProjets.ChargerProjetDansForm;
var
  I: Integer;
  TypeID: Integer;
  qry: TFDQuery;
begin
  if qryProjets.IsEmpty then Exit;
  FEditProjetID := qryProjets.FieldByName('ProjetID').AsInteger;
  edtCode.Text := qryProjets.FieldByName('CodeProjet').AsString;
  edtNom.Text := qryProjets.FieldByName('NomProjet').AsString;
  edtWilaya.Text := qryProjets.FieldByName('Wilaya').AsString;
  edtDaira.Text := qryProjets.FieldByName('Daira').AsString;
  edtCommune.Text := qryProjets.FieldByName('Commune').AsString;
  edtMO.Text := qryProjets.FieldByName('MaitreOuvrage').AsString;

  qry := TFDQuery.Create(nil);
  try
    qry.Connection := dmMain.FDConnection1;
    qry.SQL.Text := 'SELECT TypeProjetID FROM Projets WHERE ProjetID = :ID';
    qry.ParamByName('ID').AsInteger := FEditProjetID;
    qry.Open;
    TypeID := qry.FieldByName('TypeProjetID').AsInteger;

    for I := 0 to cboType.Items.Count - 1 do
    begin
      if Integer(cboType.Items.Objects[I]) = TypeID then
      begin
        cboType.ItemIndex := I;
        Break;
      end;
    end;
  finally
    qry.Free;
  end;
end;

procedure TfrmProjets.gridProjetsCellClick(Column: TColumn);
begin
  ChargerProjetDansForm;
end;

procedure TfrmProjets.btnAjouterClick(Sender: TObject);
begin
  if not ValiderChampCombo(cboType, #1606#1608#1593' '#1575#1604#1605#1588#1585#1608#1593) then Exit;
  if not ValiderChampObligatoire(edtCode, #1585#1605#1586' '#1575#1604#1605#1588#1585#1608#1593) then Exit;
  if not ValiderChampObligatoire(edtNom, #1575#1587#1605' '#1575#1604#1605#1588#1585#1608#1593) then Exit;

  ShowLoadingOverlay(#1573#1590#1575#1601#1577'...');
  try
    try
      dmMain.AjouterProjet(
        Integer(cboType.Items.Objects[cboType.ItemIndex]),
        edtCode.Text, edtNom.Text, edtWilaya.Text,
        edtDaira.Text, edtCommune.Text, edtMO.Text);
      ChargerProjets;
      ViderForm;
      ShowSucces(#1578#1605#1578' '#1575#1604#1573#1590#1575#1601#1577' '#1576#1606#1580#1575#1581 + ' !');
    except
      on E: Exception do
        ShowErreur(#1582#1591#1571 + ': ' + E.Message);
    end;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmProjets.btnModifierClick(Sender: TObject);
begin
  if FEditProjetID = 0 then
  begin
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1605#1588#1585#1608#1593);
    Exit;
  end;

  ShowLoadingOverlay(#1575#1585#1583#1585#1601'...');
  try
    try
      dmMain.ModifierProjet(FEditProjetID, edtNom.Text,
        edtWilaya.Text, edtDaira.Text, edtCommune.Text, edtMO.Text);
      ChargerProjets;
      ShowSucces(#1578#1605' '#1575#1604#1578#1593#1583#1610#1604' '#1576#1606#1580#1575#1581 + ' !');
    except
      on E: Exception do
        ShowErreur(#1582#1591#1571 + ': ' + E.Message);
    end;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmProjets.btnViderClick(Sender: TObject);
begin
  ViderForm;
end;

procedure TfrmProjets.btnSupprimerClick(Sender: TObject);
begin
  if FEditProjetID = 0 then
  begin
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' '#1605#1588#1585#1608#1593);
    Exit;
  end;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1607#1584#1575' '#1575#1604#1605#1588#1585#1608#1593' ?') then
  begin
    ShowLoadingOverlay(#1581#1601#1592'...');
    try
      try
        dmMain.SupprimerProjet(FEditProjetID);
        ChargerProjets;
        ViderForm;
        ShowSucces(#1578#1605' '#1575#1604#1581#1584#1601' '#1576#1606#1580#1575#1581);
      except
        on E: Exception do
          ShowErreur(#1582#1591#1571 + ': ' + E.Message);
      end;
    finally
      HideLoadingOverlay;
    end;
  end;
end;

procedure TfrmProjets.FormResize(Sender: TObject);
begin
  ApplyModernLayout;
end;

procedure TfrmProjets.ApplyModernLayout;
const
  Margin = 12;
  Gap = 12;
  ToolbarH = 80;
  FormH = 200;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlTop.SetBounds(0, 0, ClientWidth, ToolbarH);
  pnlTop.Width := ClientWidth;

  lblTitle.SetBounds(Margin, 10, ClientWidth - Margin * 2, 28);

  pnlForm.SetBounds(Margin, ToolbarH + Gap, ClientWidth - Margin * 2, ClientHeight - ToolbarH - Gap * 2);
  pnlForm.Width := ClientWidth - Margin * 2;
  pnlForm.Height := ClientHeight - ToolbarH - Gap * 2;

  if Assigned(FFormCard) then
  begin
    FFormCard.SetBounds(8, 4, pnlForm.Width - 16, pnlForm.Height - 8);
  end;

  gridProjets.SetBounds(Margin, FormH + Gap, ClientWidth - Margin * 2,
    ClientHeight - FormH - Gap * 2 - ToolbarH);
end;

end.
