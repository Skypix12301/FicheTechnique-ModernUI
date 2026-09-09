unit uParametres_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, System.UITypes;

type
  TfrmParametres = class(TForm)
    pnlTitle: TPanel;
    lblTitle: TLabel;
    pnlContent: TPanel;
    lblEntreprise: TLabel;
    lblWilaya: TLabel;
    lblDaira: TLabel;
    lblCommune: TLabel;
    lblTVA: TLabel;
    lblDevise: TLabel;
    lblDirection: TLabel;
    edtEntreprise: TEdit;
    edtWilaya: TEdit;
    edtDaira: TEdit;
    edtCommune: TEdit;
    edtTVA: TEdit;
    edtDevise: TEdit;
    edtDirection: TEdit;
    btnSave: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    lblTheme: TLabel;
    cboTheme: TComboBox;
    procedure ChargerParametres;
    procedure SauvegarderParametres;
    procedure StylerFormulaire;
    procedure CreerSelecteurTheme;
    procedure cboThemeChange(Sender: TObject);
    procedure ApplyModernLayout;
  end;

var
  frmParametres: TfrmParametres;

implementation

{$R *.dfm}

uses uDataModule_v3, uModernTheme, uUtils_v3;

procedure TfrmParametres.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);
  ConfigurerRTL_v3(Self);

  StylerFormulaire;
  ChargerParametres;
end;

procedure TfrmParametres.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmParametres.StylerFormulaire;
begin
  Self.Color := CLR_BG_MAIN;

  pnlTitle.Color := CLR_BG_SECONDARY;
  pnlTitle.BevelOuter := bvNone;
  pnlTitle.ParentBackground := False;
  AppliquerThemeLabel(lblTitle, True, False);
  lblTitle.Caption := #1575#1604#1573#1593#1583#1575#1583#1575#1578;

  GVEnsureDecorPanel(Self, pnlTitle, 'pnlTitleBand',
    0, 0, pnlTitle.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  pnlContent.Color := CLR_BG_SECONDARY;
  pnlContent.BevelOuter := bvNone;
  pnlContent.ParentBackground := False;

  AppliquerThemeLabel(lblEntreprise, False, False); lblEntreprise.Caption := ':' + #1575#1587#1605' '#1575#1604#1605#1572#1587#1587#1577;
  AppliquerThemeLabel(lblWilaya, False, False);     lblWilaya.Caption     := ':' + #1575#1604#1608#1604#1575#1610#1577;
  AppliquerThemeLabel(lblDaira, False, False);      lblDaira.Caption      := ':' + #1575#1604#1583#1575#1574#1585#1577;
  AppliquerThemeLabel(lblCommune, False, False);    lblCommune.Caption    := ':' + #1575#1604#1576#1604#1583#1610#1577;
  AppliquerThemeLabel(lblTVA, False, False);        lblTVA.Caption        := ':' + #1606#1587#1576#1577' '#1575#1604#1585#1587#1605 + ' %';
  AppliquerThemeLabel(lblDevise, False, False);     lblDevise.Caption     := ':' + #1575#1604#1593#1605#1604#1577;
  AppliquerThemeLabel(lblDirection, False, False);  lblDirection.Caption  := ':' + #1575#1604#1605#1583#1610#1585#1610#1577;

  AppliquerThemeEdit(edtEntreprise);
  AppliquerThemeEdit(edtWilaya);
  AppliquerThemeEdit(edtDaira);
  AppliquerThemeEdit(edtCommune);
  AppliquerThemeEdit(edtTVA);
  edtTVA.BiDiMode := bdLeftToRight;
  AppliquerThemeEdit(edtDevise);
  AppliquerThemeEdit(edtDirection);

  AppliquerThemeBouton(btnSave, bsPrimary);
  btnSave.Caption := #1581#1601#1592' '#1575#1604#1573#1593#1583#1575#1583#1575#1578;
  btnSave.Width := 180;

  CreerSelecteurTheme;
end;

procedure TfrmParametres.CreerSelecteurTheme;
begin
  if not Assigned(lblTheme) then
  begin
    lblTheme := TLabel.Create(Self);
    lblTheme.Parent := pnlContent;
    lblTheme.AutoSize := True;
  end;
  lblTheme.Caption := ':' + #1575#1604#1605#1592#1607#1585;
  AppliquerThemeLabel(lblTheme, False, False);

  if not Assigned(cboTheme) then
  begin
    cboTheme := TComboBox.Create(Self);
    cboTheme.Parent := pnlContent;
    cboTheme.Items.Add(#1601#1575#1578#1581);
    cboTheme.Items.Add(#1583#1575#1603#1606);
    cboTheme.OnChange := cboThemeChange;
    cboTheme.Style := csDropDownList;
  end;
  AppliquerThemeComboBox(cboTheme);
  if ActiveTheme.Mode = tmDark then
    cboTheme.ItemIndex := 1
  else
    cboTheme.ItemIndex := 0;
end;

procedure TfrmParametres.cboThemeChange(Sender: TObject);
begin
  if cboTheme.ItemIndex = 1 then
    SetThemeMode(tmDark)
  else
    SetThemeMode(tmLight);
  StylerFormulaire;
  Invalidate;
end;

procedure TfrmParametres.ChargerParametres;
begin
  edtEntreprise.Text := dmMain.GetParametre('NOM_ENTREPRISE');
  edtWilaya.Text := dmMain.GetParametre('WILAYA');
  edtDaira.Text := dmMain.GetParametre('DAIRA');
  edtCommune.Text := dmMain.GetParametre('COMMUNE');
  edtTVA.Text := dmMain.GetParametre('TAUX_TVA');
  edtDevise.Text := dmMain.GetParametre('DEVISE');
  edtDirection.Text := dmMain.GetParametre('DIRECTION');

  if edtTVA.Text = '' then edtTVA.Text := '9';
  if edtDevise.Text = '' then edtDevise.Text := #1583#1610#1606#1575#1585' '#1580#1586#1575#1574#1585#1610;
end;

procedure TfrmParametres.SauvegarderParametres;
begin
  dmMain.SetParametre('NOM_ENTREPRISE', edtEntreprise.Text);
  dmMain.SetParametre('WILAYA', edtWilaya.Text);
  dmMain.SetParametre('DAIRA', edtDaira.Text);
  dmMain.SetParametre('COMMUNE', edtCommune.Text);
  dmMain.SetParametre('TAUX_TVA', edtTVA.Text);
  dmMain.SetParametre('DEVISE', edtDevise.Text);
  dmMain.SetParametre('DIRECTION', edtDirection.Text);
end;

procedure TfrmParametres.btnSaveClick(Sender: TObject);
begin
  ShowLoadingOverlay(#1581#1601#1592'...');
  try
    try
      SauvegarderParametres;
      ShowSucces(#1578#1605' '#1581#1601#1592' '#1575#1604#1573#1593#1583#1575#1583#1575#1578' '#1576#1606#1580#1575#1581 + ' !');
    except
      on E: Exception do
        ShowErreur(#1582#1591#1571' '#1601#1610' '#1575#1604#1581#1601#1592 + ': ' + E.Message);
    end;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmParametres.FormResize(Sender: TObject);
begin
  ApplyModernLayout;
end;

procedure TfrmParametres.ApplyModernLayout;
const
  Margin = 12;
  Gap = 12;
  ToolbarH = 80;
  FieldW = 200;
  LabelW = 120;
  RowH = 36;
  ColX1 = Margin + LabelW + 8;
  ColX2 = Margin + LabelW + FieldW + 24;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlTitle.SetBounds(0, 0, ClientWidth, ToolbarH);
  pnlTitle.Width := ClientWidth;

  lblTitle.SetBounds(Margin, 10, ClientWidth - Margin * 2, 28);

  pnlContent.SetBounds(Margin, ToolbarH + Gap, ClientWidth - Margin * 2,
    ClientHeight - ToolbarH - Gap * 2);

  edtEntreprise.SetBounds(ColX1, 10, FieldW, RowH);
  edtWilaya.SetBounds(ColX1, 10 + RowH + Gap, FieldW, RowH);
  edtDaira.SetBounds(ColX1, 10 + (RowH + Gap) * 2, FieldW, RowH);
  edtCommune.SetBounds(ColX1, 10 + (RowH + Gap) * 3, FieldW, RowH);

  edtTVA.SetBounds(ColX2, 10, 80, RowH);
  edtDevise.SetBounds(ColX2, 10 + RowH + Gap, FieldW, RowH);
  edtDirection.SetBounds(ColX2, 10 + (RowH + Gap) * 2, FieldW, RowH);

  btnSave.SetBounds(ColX2, 10 + (RowH + Gap) * 3, 180, 38);

  lblTheme.SetBounds(ColX1, 10 + (RowH + Gap) * 4, LabelW, RowH);
  cboTheme.SetBounds(ColX2, 10 + (RowH + Gap) * 4, FieldW, RowH);
end;

end.
