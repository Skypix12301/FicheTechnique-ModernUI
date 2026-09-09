unit uCatalogue_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.UITypes,
  AdvPanel, AdvEdit,
  uModernTheme;

type
  TfrmCatalogue = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    edtSearch: TEdit;
    gridCatalogue: TDBGrid;
    pnlBottom: TPanel;
    btnAjouter: TButton;
    btnSupprimer: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure btnAjouterClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
    procedure gridCatalogueDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    qryCatalogue: TFDQuery;
    dsCatalogue: TDataSource;    FSearchTimer: TTimer;
    procedure SearchTimerTick(Sender: TObject);
    procedure ChargerCatalogue;
    procedure ConfigurerGrille;
    procedure StylerFormulaire;
    procedure ApplyModernLayout;
  end;

var
  frmCatalogue: TfrmCatalogue;

implementation

{$R *.dfm}

uses uDataModule_v3, uUtils_v3;

procedure TfrmCatalogue.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);
  ConfigurerRTL_v3(Self);

  qryCatalogue := TFDQuery.Create(Self);
  qryCatalogue.Connection := dmMain.FDConnection1;

  dsCatalogue := TDataSource.Create(Self);
  dsCatalogue.DataSet := qryCatalogue;
  gridCatalogue.DataSource := dsCatalogue;

  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Interval := 350;
  FSearchTimer.Enabled := False;
  FSearchTimer.OnTimer := SearchTimerTick;

  StylerFormulaire;
  ChargerCatalogue;
  ConfigurerGrille;
end;

procedure TfrmCatalogue.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryCatalogue.Close;
  FreeAndNil(dsCatalogue);
  FreeAndNil(qryCatalogue);
  Action := caFree;
end;

procedure TfrmCatalogue.StylerFormulaire;
begin
  Self.Color := CLR_BG_MAIN;

  pnlTop.Color := CLR_BG_MAIN;
  pnlTop.BevelOuter := bvNone;
  pnlTop.ParentBackground := False;
  pnlTop.Height := 80;

  GVEnsureDecorPanel(Self, pnlTop, 'pnlTopBand',
    0, 0, pnlTop.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  AppliquerThemeLabel(lblTitle, True, False);
  lblTitle.Caption := #1603#1578#1575#1604#1608#1580' '#1575#1604#1605#1608#1575#1583;
  lblTitle.Top := 10;

  AppliquerThemeEdit(edtSearch);

  AppliquerThemeGrille(gridCatalogue);

  pnlBottom.Color := CLR_BG_SECONDARY;
  pnlBottom.BevelOuter := bvNone;
  pnlBottom.ParentBackground := False;
  pnlBottom.Height := 55;
  pnlBottom.Align := alBottom;

  StyleModernButton(btnAjouter, bsPrimary, ICO_ADD, #1605#1575#1583#1577' '#1580#1583#1610#1583#1577);
  StyleModernButton(btnSupprimer, bsDanger, ICO_DELETE, #1581#1584#1601);
end;

procedure TfrmCatalogue.ChargerCatalogue;
var
  Q: string;
begin
  Q := Trim(edtSearch.Text);
  qryCatalogue.Close;
  qryCatalogue.SQL.Text :=
    'SELECT a.ArticleID, a.CodeArticle, a.Designation, ' +
    'u.Symbole AS Unite, a.PrixUnitaire, tp.NomType AS TypeProjet ' +
    'FROM CatalogueArticles a ' +
    'LEFT JOIN Unites u ON a.UniteID = u.UniteID ' +
    'LEFT JOIN TypesProjets tp ON a.TypeProjetID = tp.TypeProjetID ' +
    'WHERE a.Actif = 1';
  if Q <> '' then
    qryCatalogue.SQL.Add('AND (a.CodeArticle LIKE :Q1 OR a.Designation LIKE :Q2)');
  qryCatalogue.SQL.Add('ORDER BY a.CodeArticle');
  if Q <> '' then
  begin
    qryCatalogue.ParamByName('Q1').AsString := '%' + Q + '%';
    qryCatalogue.ParamByName('Q2').AsString := '%' + Q + '%';
  end;
  try
    qryCatalogue.Open;
  except
  end;
end;

procedure TfrmCatalogue.ConfigurerGrille;
begin
  gridCatalogue.Columns.Clear;

  with gridCatalogue.Columns.Add do
  begin
    FieldName := 'CodeArticle';
    Title.Caption := #1575#1604#1585#1605#1586;
    Width := 100;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridCatalogue.Columns.Add do
  begin
    FieldName := 'Designation';
    Title.Caption := #1575#1604#1578#1593#1610#1610#1606;
    Width := 350;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridCatalogue.Columns.Add do
  begin
    FieldName := 'Unite';
    Title.Caption := #1575#1604#1608#1581#1583#1577;
    Width := 60;
    Alignment := taCenter;
    Title.Alignment := taCenter;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridCatalogue.Columns.Add do
  begin
    FieldName := 'PrixUnitaire';
    Title.Caption := #1587#1593#1585' '#1575#1604#1608#1581#1583#1577;
    Width := 110;
    Alignment := taCenter;
    Title.Alignment := taCenter;
    Font.Style := [fsBold];
    Font.Color := CLR_PRIMARY;
    Title.Font.Style := [fsBold];
    Title.Font.Color := CLR_TEXT_MAIN;
  end;

  with gridCatalogue.Columns.Add do
  begin
    FieldName := 'TypeProjet';
    Title.Caption := #1606#1608#1593' '#1575#1604#1605#1588#1585#1608#1593;
    Width := 120;
    Title.Font.Color := CLR_TEXT_MAIN;
  end;
end;

procedure TfrmCatalogue.gridCatalogueDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if not (gdSelected in State) then
  begin
    if gridCatalogue.DataSource.DataSet.RecNo mod 2 = 0 then
      gridCatalogue.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridCatalogue.Canvas.Brush.Color := CLR_BG_SECONDARY;
  end
  else
    gridCatalogue.Canvas.Brush.Color := CLR_GRID_SELECTED;

  gridCatalogue.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmCatalogue.edtSearchChange(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  FSearchTimer.Enabled := True;
end;

procedure TfrmCatalogue.SearchTimerTick(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  ChargerCatalogue;
end;

procedure TfrmCatalogue.btnAjouterClick(Sender: TObject);
var
  Dlg: TForm;
  edtCode, edtDesign, edtPrix: TEdit;
  cboUnite, cboType: TComboBox;
  btnOK, btnAnn: TButton;
  qryU, qryT: TFDQuery;
  Y: Integer;
  Lbl: TLabel;
begin
  Dlg := TForm.Create(Self);
  try
    Dlg.Caption := #1573#1590#1575#1601#1577' '#1605#1575#1583#1577' '#1580#1583#1610#1583#1577;
    Dlg.Width := 520; Dlg.Height := 370;
    Dlg.Position := poScreenCenter;
    Dlg.BorderStyle := bsDialog;
    Dlg.BiDiMode := bdRightToLeft;
    Dlg.Font.Name := FONT_MAIN;
    Dlg.Font.Size := FONT_SIZE_BODY;
    Dlg.Color := CLR_BG_MAIN;
    Dlg.DoubleBuffered := True;

    Y := 20;

    Lbl := TLabel.Create(Dlg); Lbl.Parent := Dlg;
    Lbl.Left := 20; Lbl.Top := Y;
    Lbl.Caption := ':' + #1575#1604#1585#1605#1586;
    AppliquerThemeLabel(Lbl, False, False);
    Inc(Y, 24);
    edtCode := TEdit.Create(Dlg); edtCode.Parent := Dlg;
    edtCode.Left := 20; edtCode.Top := Y; edtCode.Width := 470;
    AppliquerThemeEdit(edtCode);
    edtCode.BiDiMode := bdLeftToRight;
    Inc(Y, 40);

    Lbl := TLabel.Create(Dlg); Lbl.Parent := Dlg;
    Lbl.Left := 20; Lbl.Top := Y;
    Lbl.Caption := ':' + #1575#1604#1578#1593#1610#1610#1606;
    AppliquerThemeLabel(Lbl, False, False);
    Inc(Y, 24);
    edtDesign := TEdit.Create(Dlg); edtDesign.Parent := Dlg;
    edtDesign.Left := 20; edtDesign.Top := Y; edtDesign.Width := 470;
    AppliquerThemeEdit(edtDesign);
    Inc(Y, 40);

    Lbl := TLabel.Create(Dlg); Lbl.Parent := Dlg;
    Lbl.Left := 20; Lbl.Top := Y;
    Lbl.Caption := ':' + #1575#1604#1608#1581#1583#1577;
    AppliquerThemeLabel(Lbl, False, False);
    Inc(Y, 24);
    cboUnite := TComboBox.Create(Dlg); cboUnite.Parent := Dlg;
    cboUnite.Left := 20; cboUnite.Top := Y; cboUnite.Width := 150;
    cboUnite.Style := csDropDownList;
    AppliquerThemeComboBox(cboUnite);

    Lbl := TLabel.Create(Dlg); Lbl.Parent := Dlg;
    Lbl.Left := 200; Lbl.Top := Y - 24;
    Lbl.Caption := ':' + #1587#1593#1585' '#1575#1604#1608#1581#1583#1577;
    AppliquerThemeLabel(Lbl, False, False);
    edtPrix := TEdit.Create(Dlg); edtPrix.Parent := Dlg;
    edtPrix.Left := 200; edtPrix.Top := Y; edtPrix.Width := 130;
    AppliquerThemeEdit(edtPrix);
    edtPrix.BiDiMode := bdLeftToRight;
    edtPrix.Text := '0';

    Lbl := TLabel.Create(Dlg); Lbl.Parent := Dlg;
    Lbl.Left := 360; Lbl.Top := Y - 24;
    Lbl.Caption := ':' + #1575#1604#1606#1608#1593;
    AppliquerThemeLabel(Lbl, False, False);
    cboType := TComboBox.Create(Dlg); cboType.Parent := Dlg;
    cboType.Left := 360; cboType.Top := Y; cboType.Width := 130;
    cboType.Style := csDropDownList;
    AppliquerThemeComboBox(cboType);
    Inc(Y, 50);

    qryU := TFDQuery.Create(nil);
    qryT := TFDQuery.Create(nil);
    try
      qryU.Connection := dmMain.FDConnection1;
      qryU.SQL.Text := 'SELECT UniteID, Symbole FROM Unites WHERE Actif = 1';
      qryU.Open;
      while not qryU.Eof do
      begin
        cboUnite.Items.AddObject(qryU.FieldByName('Symbole').AsString,
          TObject(qryU.FieldByName('UniteID').AsInteger));
        qryU.Next;
      end;

      qryT.Connection := dmMain.FDConnection1;
      qryT.SQL.Text := 'SELECT TypeProjetID, NomType FROM TypesProjets WHERE Actif = 1';
      qryT.Open;
      while not qryT.Eof do
      begin
        cboType.Items.AddObject(qryT.FieldByName('NomType').AsString,
          TObject(qryT.FieldByName('TypeProjetID').AsInteger));
        qryT.Next;
      end;
    finally
      qryU.Free;
      qryT.Free;
    end;

    btnOK := TButton.Create(Dlg); btnOK.Parent := Dlg;
    btnOK.Left := 300; btnOK.Top := Y; btnOK.Width := 90; btnOK.Height := 38;
    btnOK.Caption := #1573#1590#1575#1601#1577;
    btnOK.ModalResult := mrOk;
    AppliquerThemeBouton(btnOK, bsPrimary);

    btnAnn := TButton.Create(Dlg); btnAnn.Parent := Dlg;
    btnAnn.Left := 400; btnAnn.Top := Y; btnAnn.Width := 90; btnAnn.Height := 38;
    btnAnn.Caption := #1573#1604#1594#1575#1569;
    btnAnn.ModalResult := mrCancel;
    AppliquerThemeBouton(btnAnn, bsGhost);

    if Dlg.ShowModal = mrOk then
    begin
      if (Trim(edtCode.Text) <> '') and (Trim(edtDesign.Text) <> '') and
         (cboUnite.ItemIndex >= 0) then
      begin
        ShowLoadingOverlay(#1573#1590#1575#1601#1577'...');
        try
          var qryIns := TFDQuery.Create(nil);
          try
            qryIns.Connection := dmMain.FDConnection1;
            qryIns.SQL.Text :=
              'INSERT INTO CatalogueArticles (CodeArticle, Designation, UniteID, ' +
              'PrixUnitaire, TypeProjetID) VALUES (:Code, :Des, :Unite, :Prix, :TypeID)';
            qryIns.ParamByName('Code').AsString := edtCode.Text;
            qryIns.ParamByName('Des').AsString := edtDesign.Text;
            qryIns.ParamByName('Unite').AsInteger :=
              Integer(cboUnite.Items.Objects[cboUnite.ItemIndex]);
            qryIns.ParamByName('Prix').AsFloat := StrToFloatDef(edtPrix.Text, 0);
            if cboType.ItemIndex >= 0 then
              qryIns.ParamByName('TypeID').AsInteger :=
                Integer(cboType.Items.Objects[cboType.ItemIndex])
            else
              qryIns.ParamByName('TypeID').Clear;
            qryIns.ExecSQL;
            ChargerCatalogue;
            ShowSucces(#1578#1605#1578' '#1575#1604#1573#1590#1575#1601#1577' '#1576#1606#1580#1575#1581 + ' !');
          finally
            qryIns.Free;
          end;
        except
          on E: Exception do
            ShowErreur(#1582#1591#1571' '#1601#1610' '#1575#1604#1573#1590#1575#1601#1577 + ': ' + E.Message);
        end;
        HideLoadingOverlay;
      end
      else
        ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1605#1604#1569' '#1580#1605#1610#1593' '#1575#1604#1581#1602#1608#1604);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmCatalogue.btnSupprimerClick(Sender: TObject);
var
  ArticleID: Integer;
  qry: TFDQuery;
begin
  if (not qryCatalogue.Active) or qryCatalogue.IsEmpty then Exit;

  ArticleID := qryCatalogue.FieldByName('ArticleID').AsInteger;

  if Confirmer(#1607#1604' '#1578#1585#1610#1583' '#1581#1584#1601' '#1607#1584#1607' '#1575#1604#1605#1575#1583#1577' ?') then
  begin
    ShowLoadingOverlay(#1581#1601#1592'...');
    try
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := dmMain.FDConnection1;
        qry.SQL.Text :=
          'UPDATE CatalogueArticles SET Actif = 0 WHERE ArticleID = :ID';
        qry.ParamByName('ID').AsInteger := ArticleID;
        qry.ExecSQL;
        ChargerCatalogue;
        ShowSucces(#1578#1605' '#1575#1604#1581#1584#1601' '#1576#1606#1580#1575#1581);
      finally
        qry.Free;
      end;
    finally
      HideLoadingOverlay;
    end;
  end;
end;

procedure TfrmCatalogue.FormResize(Sender: TObject);
begin
  ApplyModernLayout;
end;

procedure TfrmCatalogue.ApplyModernLayout;
const
  Margin = 12;
  Gap = 12;
  ToolbarH = 80;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlTop.SetBounds(0, 0, ClientWidth, ToolbarH);
  pnlTop.Width := ClientWidth;

  lblTitle.SetBounds(Margin, 10, ClientWidth - Margin * 2 - 200, 28);
  edtSearch.SetBounds(ClientWidth - Margin - 180, 38, 180, 36);

  gridCatalogue.SetBounds(Margin, ToolbarH + Gap, ClientWidth - Margin * 2,
    ClientHeight - ToolbarH - Gap * 2);
end;

end.
