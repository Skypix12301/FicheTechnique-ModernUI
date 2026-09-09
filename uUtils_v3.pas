unit uUtils_v3;

{
  ==========================================================================
  uUtils_v3.pas - Utilitaires modernisés v3
  ==========================================================================
  Fonctions utilitaires reprises du projet original avec améliorations :
  - Utilise le nouveau uModernTheme au lieu des constantes locales
  - Conversion nombre → lettres arabes (inchangée, fonctionnelle)
  - Fonctions de formatage améliorées
  - Fonctions de validation UX (SKILL §Validation et Messages)
  - Dialogue modal GDI+ thémé
  ==========================================================================
}

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs, System.UITypes, Winapi.Windows,
  Winapi.Messages;

function ConvertirNombreEnLettresAR(Montant: Currency): string;
function FormaterMontant(Value: Currency): string;

function ValiderChampObligatoire(AEdit: TEdit; const NomChamp: string): Boolean;
function ValiderChampCombo(ACmb: TComboBox; const NomChamp: string): Boolean;
procedure ShowSucces(const Msg: string);
procedure ShowErreur(const Msg: string);
procedure ShowAvertissement(const Msg: string);
function Confirmer(const Msg: string): Boolean;
function Confirmer3(const Msg: string): Integer;

procedure DemarrerChargement(const Msg: string = '');
procedure ArreterChargement;
procedure ShowLoadingOverlay(const AMsg: string);
procedure HideLoadingOverlay;

implementation

uses
  uModernTheme, uGraphicsGDIP, uIconsSVG, Winapi.GDIPAPI, Winapi.GDIPOBJ, System.Math;

type
  TModernDlgKind = (mdSuccess, mdError, mdWarning, mdConfirm);

  TModernDialogForm = class(TForm)
  private
    FKind: TModernDlgKind;
    procedure DoPaint(Sender: TObject);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  end;

procedure TModernDialogForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TModernDialogForm.DoPaint(Sender: TObject);
var
  G: TGPGraphics;
  Accent: TColor;
  Glyph: string;
  Titre: string;
  Brush: TGPLinearGradientBrush;
begin
  case FKind of
    mdSuccess: begin Accent := ActiveTheme.Success; Glyph := ICO_ACCEPT;
      Titre := #1606#1580#1575#1581; end;
    mdError: begin Accent := ActiveTheme.Error; Glyph := ICO_ERROR;
      Titre := #1582#1591#1571; end;
    mdWarning: begin Accent := ActiveTheme.Warning; Glyph := ICO_WARNING;
      Titre := #1578#1606#1576#1610#1607; end;
  else
    Accent := ActiveTheme.Primary; Glyph := ICO_INFO; Titre := #1578#1571#1603#1610#1583;
  end;

  G := TGPGraphics.Create(TModernDialogForm(Sender).Canvas.Handle);
  try
    SetupHighQuality(G);
    G.Clear(GPColor(ActiveTheme.Surface));

    Brush := TGPLinearGradientBrush.Create(
      MakeRect(-1.0, -1.0, ClientWidth + 2.0, 78),
      GPColor(DarkenColor(Accent, 25)), GPColor(Accent), 90.0);
    try
      G.FillRectangle(Brush, MakeRect(0.0, 0.0, ClientWidth, 76));
    finally
      Brush.Free;
    end;

    if SvgForGlyph(Glyph) <> '' then
      DrawSvgIcon(G, SvgForGlyph(Glyph), MakeRect(ClientWidth - 70.0, 12, 54, 52),
        ActiveTheme.TextWhite)
    else
      DrawTextGP(G, Glyph, MakeRect(ClientWidth - 70.0, 12, 54, 52),
        ICON_FONT, 30, fgRegular, ActiveTheme.TextWhite, taCenterGP, True);
    DrawTextGP(G, Titre, MakeRect(20.0, 18, ClientWidth - 90.0, 40),
      FONT_BOLD, 15, fgBold, ActiveTheme.TextWhite, taRightGP, True);
  finally
    G.Free;
  end;
end;

function ShowModernDialog(const Msg: string; Kind: TModernDlgKind): Boolean;
var
  Dlg: TModernDialogForm;
  Lbl: TLabel;
  BtnOK: TButton;
  BtnCancel: TButton;
  BtnTop: Integer;
begin
  Dlg := TModernDialogForm.CreateNew(nil);
  try
    Dlg.FKind := Kind;
    Dlg.BiDiMode := bdRightToLeft;
    Dlg.Font.Name := FONT_MAIN;
    Dlg.Font.Size := FONT_SIZE_BODY;
    Dlg.BorderStyle := bsDialog;
    Dlg.Position := poScreenCenter;
    Dlg.ClientWidth := 420;
    Dlg.Color := ActiveTheme.Surface;
    Dlg.DoubleBuffered := True;
    Dlg.OnPaint := Dlg.DoPaint;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg;
    Lbl.Left := 24;
    Lbl.Top := 96;
    Lbl.Width := 420 - 48;
    Lbl.WordWrap := True;
    Lbl.AutoSize := True;
    Lbl.Alignment := taRightJustify;
    Lbl.Transparent := True;
    Lbl.Font.Name := FONT_MAIN;
    Lbl.Font.Size := FONT_SIZE_BODY;
    Lbl.Font.Color := ActiveTheme.TextMain;
    Lbl.Caption := Msg;

    BtnTop := Lbl.Top + Lbl.Height + 26;
    if BtnTop < 150 then
      BtnTop := 150;

    if Kind = mdConfirm then
    begin
      BtnOK := TButton.Create(Dlg);
      BtnOK.Parent := Dlg;
      BtnOK.Width := 130;
      BtnOK.Height := 42;
      BtnOK.Left := 24;
      BtnOK.Top := BtnTop;
      BtnOK.Caption := #1606#1593#1605;
      BtnOK.ModalResult := mrOk;
      AppliquerThemeBouton(BtnOK, bsPrimary);

      BtnCancel := TButton.Create(Dlg);
      BtnCancel.Parent := Dlg;
      BtnCancel.Width := 130;
      BtnCancel.Height := 42;
      BtnCancel.Left := 420 - 24 - 130;
      BtnCancel.Top := BtnTop;
      BtnCancel.Caption := #1604#1575;
      BtnCancel.ModalResult := mrCancel;
      AppliquerThemeBouton(BtnCancel, bsGhost);
    end
    else
    begin
      BtnOK := TButton.Create(Dlg);
      BtnOK.Parent := Dlg;
      BtnOK.Width := 140;
      BtnOK.Height := 42;
      BtnOK.Left := (420 - 140) div 2;
      BtnOK.Top := BtnTop;
      BtnOK.Caption := #1605#1608#1575#1601#1602;
      BtnOK.ModalResult := mrOk;
      AppliquerThemeBouton(BtnOK, bsPrimary);
    end;

    Dlg.ClientHeight := BtnTop + 42 + 22;
    Result := Dlg.ShowModal = mrOk;
  finally
    Dlg.Free;
  end;
end;

function Confirmer3(const Msg: string): Integer;
var
  Dlg: TModernDialogForm;
  Lbl: TLabel;
  B1, B2, B3: TButton;
  BtnTop: Integer;
begin
  Dlg := TModernDialogForm.CreateNew(nil);
  try
    Dlg.FKind := mdConfirm;
    Dlg.BiDiMode := bdRightToLeft;
    Dlg.Font.Name := FONT_MAIN;
    Dlg.Font.Size := FONT_SIZE_BODY;
    Dlg.BorderStyle := bsDialog;
    Dlg.Position := poScreenCenter;
    Dlg.ClientWidth := 420;
    Dlg.Color := ActiveTheme.Surface;
    Dlg.DoubleBuffered := True;
    Dlg.OnPaint := Dlg.DoPaint;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg;
    Lbl.Left := 24;
    Lbl.Top := 96;
    Lbl.Width := 420 - 48;
    Lbl.WordWrap := True;
    Lbl.AutoSize := True;
    Lbl.Alignment := taRightJustify;
    Lbl.Transparent := True;
    Lbl.Font.Name := FONT_MAIN;
    Lbl.Font.Size := FONT_SIZE_BODY;
    Lbl.Font.Color := ActiveTheme.TextMain;
    Lbl.Caption := Msg;

    BtnTop := Lbl.Top + Lbl.Height + 26;
    if BtnTop < 150 then
      BtnTop := 150;

    B1 := TButton.Create(Dlg);
    B1.Parent := Dlg;
    B1.SetBounds(24, BtnTop, 110, 42);
    B1.Caption := #1606#1593#1605;
    B1.ModalResult := mrYes;
    AppliquerThemeBouton(B1, bsPrimary);

    B2 := TButton.Create(Dlg);
    B2.Parent := Dlg;
    B2.SetBounds(155, BtnTop, 110, 42);
    B2.Caption := #1604#1575;
    B2.ModalResult := mrNo;
    AppliquerThemeBouton(B2, bsSecondary);

    B3 := TButton.Create(Dlg);
    B3.Parent := Dlg;
    B3.SetBounds(420 - 24 - 110, BtnTop, 110, 42);
    B3.Caption := #1573#1604#1594#1575#1569;
    B3.ModalResult := mrCancel;
    AppliquerThemeBouton(B3, bsGhost);

    Dlg.ClientHeight := BtnTop + 42 + 22;
    Result := Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

function UniteAR(N: Integer): string;
begin
  case N of
    0: Result := '';
    1: Result := #1608#1575#1581#1583;
    2: Result := #1575#1579#1606#1575#1606;
    3: Result := #1579#1604#1575#1579#1577;
    4: Result := #1571#1585#1576#1593#1577;
    5: Result := #1582#1605#1587#1577;
    6: Result := #1587#1578#1577;
    7: Result := #1587#1576#1593#1577;
    8: Result := #1579#1605#1575#1606#1610#1577;
    9: Result := #1578#1587#1593#1577;
    10: Result := #1593#1588#1585#1577;
    11: Result := #1571#1581#1583' '#1593#1588#1585;
    12: Result := #1575#1579#1606#1575' '#1593#1588#1585;
    13: Result := #1579#1604#1575#1579#1577' '#1593#1588#1585;
    14: Result := #1571#1585#1576#1593#1577' '#1593#1588#1585;
    15: Result := #1582#1605#1587#1577' '#1593#1588#1585;
    16: Result := #1587#1578#1577' '#1593#1588#1585;
    17: Result := #1587#1576#1593#1577' '#1593#1588#1585;
    18: Result := #1579#1605#1575#1606#1610#1577' '#1593#1588#1585;
    19: Result := #1578#1587#1593#1577' '#1593#1588#1585;
  else
    Result := '';
  end;
end;

function DizaineAR(N: Integer): string;
begin
  case N of
    2: Result := #1593#1588#1585#1608#1606;
    3: Result := #1579#1604#1575#1579#1608#1606;
    4: Result := #1571#1585#1576#1593#1608#1606;
    5: Result := #1582#1605#1587#1608#1606;
    6: Result := #1587#1578#1608#1606;
    7: Result := #1587#1576#1593#1608#1606;
    8: Result := #1579#1605#1575#1606#1608#1606;
    9: Result := #1578#1587#1593#1608#1606;
  else
    Result := '';
  end;
end;

function CentaineAR(N: Integer): string;
begin
  case N of
    1: Result := #1605#1575#1574#1577;
    2: Result := #1605#1575#1574#1578#1575#1606;
    3: Result := #1579#1604#1575#1579#1605#1575#1574#1577;
    4: Result := #1571#1585#1576#1593#1605#1575#1574#1577;
    5: Result := #1582#1605#1587#1605#1575#1574#1577;
    6: Result := #1587#1578#1605#1575#1574#1577;
    7: Result := #1587#1576#1593#1605#1575#1574#1577;
    8: Result := #1579#1605#1575#1606#1605#1575#1574#1577;
    9: Result := #1578#1587#1593#1605#1575#1574#1577;
  else
    Result := '';
  end;
end;

function ConvertirTroisChiffresAR(N: Integer): string;
var
  C, D, U: Integer;
begin
  Result := '';
  if N = 0 then
    Exit;

  C := N div 100;
  D := (N mod 100) div 10;
  U := N mod 10;

  if C > 0 then
    Result := CentaineAR(C);

  if (N mod 100) > 0 then
  begin
    if Result <> '' then
      Result := Result + ' '#1608' ';

    if (N mod 100) < 20 then
      Result := Result + UniteAR(N mod 100)
    else
    begin
      if U > 0 then
        Result := Result + UniteAR(U) + ' '#1608' ';
      Result := Result + DizaineAR(D);
    end;
  end;
end;

function ConvertirNombreEnLettresAR(Montant: Currency): string;
var
  Entier: Int64;
  Decimale: Integer;
  Milliards, Millions, Milliers, Reste: Integer;
  Parts: TStringList;
begin
  Entier := Trunc(Abs(Montant));
  Decimale := Round(Frac(Abs(Montant)) * 100);

  if Entier = 0 then
  begin
    Result := #1589#1601#1585;
    if Decimale > 0 then
      Result := Result + ' '#1608' ' + ConvertirTroisChiffresAR(Decimale) + ' '#1587#1606#1578#1610#1605;
    Result := Result + ' '#1583#1610#1606#1575#1585' '#1580#1586#1575#1574#1585#1610;
    Exit;
  end;

  Parts := TStringList.Create;
  try
    Milliards := Entier div 1000000000;
    Entier := Entier mod 1000000000;

    Millions := Entier div 1000000;
    Entier := Entier mod 1000000;

    Milliers := Entier div 1000;
    Reste := Entier mod 1000;

    if Milliards > 0 then
    begin
      if Milliards = 1 then
        Parts.Add(#1605#1604#1610#1575#1585)
      else if Milliards = 2 then
        Parts.Add(#1605#1604#1610#1575#1585#1575#1606)
      else
        Parts.Add(ConvertirTroisChiffresAR(Milliards) + ' '#1605#1604#1610#1575#1585#1575#1578);
    end;

    if Millions > 0 then
    begin
      if Millions = 1 then
        Parts.Add(#1605#1604#1610#1608#1606)
      else if Millions = 2 then
        Parts.Add(#1605#1604#1610#1608#1606#1575#1606)
      else if (Millions >= 3) and (Millions <= 10) then
        Parts.Add(ConvertirTroisChiffresAR(Millions) + ' '#1605#1604#1575#1610#1610#1606)
      else
        Parts.Add(ConvertirTroisChiffresAR(Millions) + ' '#1605#1604#1610#1608#1606);
    end;

    if Milliers > 0 then
    begin
      if Milliers = 1 then
        Parts.Add(#1571#1604#1601)
      else if Milliers = 2 then
        Parts.Add(#1571#1604#1601#1575#1606)
      else if (Milliers >= 3) and (Milliers <= 10) then
        Parts.Add(ConvertirTroisChiffresAR(Milliers) + ' '#1570#1604#1575#1601)
      else
        Parts.Add(ConvertirTroisChiffresAR(Milliers) + ' '#1571#1604#1601);
    end;

    if Reste > 0 then
      Parts.Add(ConvertirTroisChiffresAR(Reste));

    Result := '';
    for var I := 0 to Parts.Count - 1 do
    begin
      if I > 0 then
        Result := Result + ' '#1608' ';
      Result := Result + Parts[I];
    end;

    Result := Result + ' '#1583#1610#1606#1575#1585' '#1580#1586#1575#1574#1585#1610;

    if Decimale > 0 then
      Result := Result + ' '#1608' ' + ConvertirTroisChiffresAR(Decimale) + ' '#1587#1606#1578#1610#1605;
  finally
    Parts.Free;
  end;
end;

function FormaterMontant(Value: Currency): string;
begin
  Result := FormatFloat('#,##0.00', Value);
end;

function TryParseDecimal(const Text: string; out Value: Double): Boolean;
var
  Normalized: string;
  C: Char;
  Settings: TFormatSettings;
begin
  Normalized := Trim(Text);
  for C := #$0660 to #$0669 do
    Normalized := StringReplace(Normalized, C, Char(Ord('0') + Ord(C) - $0660), [rfReplaceAll]);
  Normalized := StringReplace(Normalized, #$066B, '.', [rfReplaceAll]);
  Normalized := StringReplace(Normalized, ',', '.', [rfReplaceAll]);
  Settings := TFormatSettings.Create;
  Settings.DecimalSeparator := '.';
  Result := TryStrToFloat(Normalized, Value, Settings);
  if Result then Result := not IsNan(Value) and not IsInfinite(Value);
end;

function ValiderChampObligatoire(AEdit: TEdit; const NomChamp: string): Boolean;
begin
  Result := True;
  if Trim(AEdit.Text) = '' then
  begin
    AEdit.Color := CLR_ERROR_BG;
    AEdit.SetFocus;
    ShowAvertissement(#1575#1604#1581#1602#1604' "' + NomChamp + '" ' + #1605#1591#1604#1608#1575#1576 + '.');
    Result := False;
  end
  else
    AEdit.Color := CLR_BG_SECONDARY;
end;

function ValiderChampCombo(ACmb: TComboBox; const NomChamp: string): Boolean;
begin
  Result := True;
  if ACmb.ItemIndex < 0 then
  begin
    ACmb.SetFocus;
    ShowAvertissement(#1575#1604#1585#1580#1575#1569' '#1575#1582#1578#1610#1575#1585' "' + NomChamp + '".');
    Result := False;
  end;
end;

procedure ShowSucces(const Msg: string);
begin
  ShowModernDialog(Msg, mdSuccess);
end;

procedure ShowErreur(const Msg: string);
begin
  ShowModernDialog(Msg, mdError);
end;

procedure ShowAvertissement(const Msg: string);
begin
  ShowModernDialog(Msg, mdWarning);
end;

function Confirmer(const Msg: string): Boolean;
begin
  Result := ShowModernDialog(Msg, mdConfirm);
end;

procedure DemarrerChargement(const Msg: string);
begin
  if Msg <> '' then
    ShowLoadingOverlay(Msg)
  else
    Screen.Cursor := crHourGlass;
  if Assigned(Screen.ActiveForm) then Screen.ActiveForm.Update;
end;

procedure ArreterChargement;
begin
  HideLoadingOverlay;
  Screen.Cursor := crDefault;
end;

{ TLoadingOverlay }

type
  TLoadingOverlay = class(TForm)
    FMsgLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  end;

var
  FLoadingOverlay: TLoadingOverlay = nil;

procedure TLoadingOverlay.FormCreate(Sender: TObject);
begin
  BorderStyle := bsNone;
  Color := clBlack;
  AlphaBlend := True;
  AlphaBlendValue := 180;
  Position := poScreenCenter;
  DoubleBuffered := True;
  FMsgLabel := TLabel.Create(Self);
  FMsgLabel.Parent := Self;
  FMsgLabel.Align := alClient;
  FMsgLabel.Alignment := taCenter;
  FMsgLabel.Layout := tlCenter;
  FMsgLabel.Font.Name := FONT_BOLD;
  FMsgLabel.Font.Size := FONT_SIZE_HEADING;
  FMsgLabel.Font.Color := clWhite;
  FMsgLabel.Transparent := True;
  FMsgLabel.Caption := '';
  ClientWidth := 300;
  ClientHeight := 100;
end;

procedure TLoadingOverlay.FormPaint(Sender: TObject);
var
  G: TGPGraphics;
  R: TGPRectF;
  Brush: TGPSolidBrush;
begin
  G := TGPGraphics.Create(Canvas.Handle);
  try
    SetupHighQuality(G);
    R := MakeRect(0.0, 0.0, ClientWidth, ClientHeight);
    Brush := TGPSolidBrush.Create(GPColor(RGB(0, 0, 0), 180));
    try
      G.FillRectangle(Brush, R);
    finally
      Brush.Free;
    end;
  finally
    G.Free;
  end;
end;

procedure ShowLoadingOverlay(const AMsg: string);
begin
  if Assigned(FLoadingOverlay) then Exit;
  FLoadingOverlay := TLoadingOverlay.CreateNew(nil);
  FLoadingOverlay.FormCreate(FLoadingOverlay);
  FLoadingOverlay.FMsgLabel.Caption := AMsg;
  FLoadingOverlay.Show;
  FLoadingOverlay.Update;
end;

procedure HideLoadingOverlay;
begin
  if Assigned(FLoadingOverlay) then
  begin
    FLoadingOverlay.Close;
    FreeAndNil(FLoadingOverlay);
  end;
end;

end.
