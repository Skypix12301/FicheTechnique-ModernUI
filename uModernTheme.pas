unit uModernTheme;

{
  ==========================================================================
  uModernTheme.pas - Theme Engine v4 (TMS UI Pack + Skia4Delphi)
  ==========================================================================
  Clean rewrite. TAdvSmoothButton uses Color / BevelColor (no gradient).
  TAdvPanel for cards. Guide §2 palette (blue modern).
  ==========================================================================
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Math, System.Types, System.UITypes, System.IniFiles,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  AdvPanel, AdvSmoothButton, AdvEdit, AdvCombo, AdvStyleIF,
  Winapi.GDIPAPI, Winapi.GDIPOBJ,
  uGraphicsGDIP;

const
  APP_NAME      = #1575#1583#1575#1585#1577' '#1575#1604#1576#1591#1575#1602#1575#1578' '#1575#1604#1578#1602#1606#1610#1577;
  APP_SUBTITLE  = #1605#1583#1610#1585#1610#1577' '#1575#1604#1605#1589#1575#1604#1581' '#1575#1604#1578#1602#1606#1610#1577;
  APP_VERSION   = '4.0';

  FONT_MAIN          = 'Segoe UI';
  FONT_BOLD          = 'Segoe UI Semibold';
  ICON_FONT          = 'Segoe MDL2 Assets';

  FONT_SIZE_TITLE    = 20;
  FONT_SIZE_SUBTITLE = 14;
  FONT_SIZE_HEADING  = 12;
  FONT_SIZE_BODY     = 10;
  FONT_SIZE_SMALL    = 9;
  FONT_SIZE_CAPTION  = 8;
  FONT_SIZE_BADGE    = 7;

  DIM_BTN_HEIGHT     = 40;
  DIM_EDIT_HEIGHT    = 36;
  DIM_BTN_RADIUS     = 18;
  DIM_CARD_RADIUS    = 14;
  DIM_TOOLBAR_HEIGHT = 56;

  ICO_HOME     = #$E80F;
  ICO_LIST     = #$E8FD;
  ICO_ADD      = #$E710;
  ICO_FOLDER   = #$E8B7;
  ICO_LIBRARY  = #$E8F1;
  ICO_SETTINGS = #$E713;
  ICO_POWER    = #$E7E8;
  ICO_SAVE     = #$E74E;
  ICO_ACCEPT   = #$E73E;
  ICO_PRINT    = #$E749;
  ICO_CANCEL   = #$E711;
  ICO_EDIT     = #$E70F;
  ICO_DELETE   = #$E74D;
  ICO_SEARCH   = #$E721;
  ICO_COPY     = #$E8C8;
  ICO_INFO     = #$E946;
  ICO_WARNING  = #$E7BA;
  ICO_ERROR    = #$EA39;
  ICO_USER     = #$E77B;
  ICO_MONEY    = #$E1D6;
  ICO_DOC      = #$E8A5;

type
  TThemeMode = (tmLight, tmDark);

  TThemePalette = record
    Mode: TThemeMode;
    BgMain, BgSecondary, Surface, SurfaceAlt: TColor;
    TextMain, TextSecondary, TextWhite: TColor;
    Border, BorderFocus: TColor;
    Primary, PrimaryDark, PrimaryLight, Secondary: TColor;
    Success, Warning, Error: TColor;
    StatBlue, StatGreen, StatOrange, StatPurple: TColor;
    Sidebar, SidebarDark, SidebarHover, SidebarActive, SidebarText: TColor;
    GridAlt, GridSelected, ErrorBg, BgDisabled, Shadow: TColor;
  end;

  TBtnStyle = (bsPrimary, bsSecondary, bsSuccess, bsWarning, bsDanger, bsGhost);
  TThemeChangeProc = procedure of object;

var
  CLR_PRIMARY, CLR_PRIMARY_DARK, CLR_PRIMARY_LIGHT, CLR_SECONDARY: TColor;
  CLR_BG_MAIN, CLR_BG_SECONDARY, CLR_BG_DARK: TColor;
  CLR_SUCCESS, CLR_WARNING, CLR_ERROR, CLR_DANGER: TColor;
  CLR_TEXT_MAIN, CLR_TEXT_SECONDARY, CLR_TEXT_WHITE: TColor;
  CLR_BORDER, CLR_BORDER_FOCUS: TColor;
  CLR_STAT_BLUE, CLR_STAT_GREEN, CLR_STAT_ORANGE, CLR_STAT_PURPLE: TColor;
  CLR_SIDEBAR, CLR_SIDEBAR_DARK, CLR_SIDEBAR_HOVER, CLR_SIDEBAR_ACTIVE: TColor;
  CLR_GRID_ALT, CLR_GRID_SELECTED, CLR_ERROR_BG, CLR_BG_DISABLED: TColor;

function ActiveTheme: TThemePalette;

procedure InitTheme(const IniPath: string = '');
procedure SetThemeMode(Mode: TThemeMode);
procedure SaveThemeMode(const IniPath: string = '');
procedure RegisterThemeObserver(const AProc: TThemeChangeProc);
procedure UnregisterThemeObserver(const AProc: TThemeChangeProc);
function ThemeIniPath: string;

procedure GVApplyCardStyle(const APanel: TAdvPanel;
  const ABackColor, ABorderColor: TColor; const AToColor: TColor = clNone);
procedure GVApplyButtonStyle(const ABtn: TAdvSmoothButton; APrimary: Boolean);
procedure GVApplyEditStyle(const AEdit: TAdvEdit;
  const AEmptyText: string; const ABackColor: TColor);
procedure GVApplyComboStyle(const ACombo: TAdvComboBox;
  const ABackColor: TColor);
procedure GVApplyLabelStyle(const ALabel: TLabel;
  const ATextColor: TColor; const AFontSize: Integer;
  const ABold: Boolean; const AFontName: string = FONT_MAIN);
procedure GVApplyBadgePanelStyle(const APanel: TAdvPanel;
  const ABgColor, ABorderColor: TColor);
procedure GVApplyBadgeLabelStyle(const ALabel: TLabel;
  const AStatus: string);
procedure GVEnsureDecorPanel(const AOwner: TComponent;
  const AParent: TWinControl; const AName: string;
  ALeft, ATop, AWidth, AHeight: Integer;
  AColor, ABorderColor: TColor; const AAnchors: TAnchors);

procedure AppliquerThemeFormulaire(AForm: TForm);
procedure ConfigurerRTL_v3(AForm: TForm);
procedure AppliquerThemeEdit(AEdit: TCustomEdit);
procedure AppliquerThemeComboBox(ACbo: TCustomComboBox);
procedure AppliquerThemeMemo(AMemo: TCustomMemo);
procedure AppliquerThemeGrille(AGrid: TCustomDBGrid);
procedure AppliquerThemeStringGrid(AGrid: TStringGrid);
procedure AppliquerThemeLabel(ALabel: TLabel; IsTitle, IsSecondary: Boolean);
procedure AppliquerThemePanel(APanel: TCustomPanel; IsCard: Boolean);
procedure AppliquerThemeBouton(ABtn: TButton; Style: TBtnStyle);
procedure StyleModernButton(ABtn: TButton; Style: TBtnStyle;
  const AIcon, ACaption: string);
procedure AppliquerThemeTousLesComposants(AForm: TForm);
function UIScale(AControl: TControl; Value: Integer): Integer;
function CreateWorkspace(AForm: TForm): TScrollBox;
procedure PlaceControl(AControl: TControl; X, Y, W, H: Integer);
procedure PlaceField(ALabel: TLabel; AField: TWinControl;
  X, Y, W, TabIndex: Integer);
function LayoutActions(AParent: TWinControl; const Buttons: array of TButton;
  AWidth: Integer): Integer;

function ContrastRatio(C1, C2: TColor): Double;
function IsContrastAccessible(C1, C2: TColor; AMinRatio: Double): Boolean;

procedure DrawStatusBadge(ACanvas: TCanvas; const R: TRect;
  const AText: string; AColor: TColor);
procedure PaintVerticalGradient(ACanvas: TCanvas; const R: TRect;
  ColorTop, ColorBottom: TColor);
function FormatStatValue(Value: Currency): string;
function StatutColor(const Statut: string): TColor;
function BtnStyleToColors(Style: TBtnStyle): TColor;

implementation

type
  TButtonAccess = class(TButton)
  public
    procedure SetColor(const AColor: TColor); inline;
  end;

var
  FCurrentMode: TThemeMode;
  FLightPalette, FDarkPalette: TThemePalette;
  FObservers: TList<TThemeChangeProc>;
  FThemeLoaded: Boolean;

{ -- Palette definitions (Guide section 2) -- }

function MakeLightPalette: TThemePalette;
begin
  Result.Mode := tmLight;
  Result.BgMain       := RGB(236, 244, 255);
  Result.BgSecondary  := RGB(255, 255, 255);
  Result.Surface      := RGB(250, 252, 255);
  Result.SurfaceAlt   := RGB(247, 250, 255);
  Result.TextMain     := RGB(42, 49, 79);
  Result.TextSecondary:= RGB(80, 90, 120);
  Result.TextWhite    := clWhite;
  Result.Border       := RGB(219, 229, 245);
  Result.BorderFocus  := RGB(38, 104, 228);
  Result.Primary      := RGB(38, 104, 228);
  Result.PrimaryDark  := RGB(27, 82, 194);
  Result.PrimaryLight := RGB(130, 204, 255);
  Result.Secondary    := RGB(116, 122, 150);
  Result.Success      := RGB(22, 138, 106);
  Result.Warning      := RGB(186, 117, 23);
  Result.Error        := RGB(163, 45, 45);
  Result.StatBlue     := RGB(38, 104, 228);
  Result.StatGreen    := RGB(22, 138, 106);
  Result.StatOrange   := RGB(186, 117, 23);
  Result.StatPurple   := RGB(130, 92, 194);
  Result.Sidebar      := RGB(8, 25, 51);
  Result.SidebarDark  := RGB(4, 15, 35);
  Result.SidebarHover := RGB(18, 45, 80);
  Result.SidebarActive:= RGB(38, 104, 228);
  Result.SidebarText  := RGB(180, 200, 225);
  Result.GridAlt      := RGB(247, 250, 255);
  Result.GridSelected := RGB(220, 235, 255);
  Result.ErrorBg      := RGB(251, 238, 239);
  Result.BgDisabled   := RGB(240, 242, 246);
  Result.Shadow       := RGB(0, 0, 0);
end;

function MakeDarkPalette: TThemePalette;
begin
  Result.Mode := tmDark;
  Result.BgMain       := RGB(18, 22, 30);
  Result.BgSecondary  := RGB(25, 30, 40);
  Result.Surface      := RGB(30, 35, 48);
  Result.SurfaceAlt   := RGB(38, 44, 58);
  Result.TextMain     := RGB(230, 235, 245);
  Result.TextSecondary:= RGB(140, 150, 175);
  Result.TextWhite    := clWhite;
  Result.Border       := RGB(50, 58, 72);
  Result.BorderFocus  := RGB(80, 150, 255);
  Result.Primary      := RGB(80, 150, 255);
  Result.PrimaryDark  := RGB(50, 120, 220);
  Result.PrimaryLight := RGB(130, 185, 255);
  Result.Secondary    := RGB(120, 130, 155);
  Result.Success      := RGB(50, 190, 140);
  Result.Warning      := RGB(220, 160, 50);
  Result.Error        := RGB(220, 80, 80);
  Result.StatBlue     := RGB(80, 150, 255);
  Result.StatGreen    := RGB(50, 190, 140);
  Result.StatOrange   := RGB(220, 160, 50);
  Result.StatPurple   := RGB(160, 120, 220);
  Result.Sidebar      := RGB(12, 15, 22);
  Result.SidebarDark  := RGB(8, 10, 16);
  Result.SidebarHover := RGB(25, 30, 42);
  Result.SidebarActive:= RGB(80, 150, 255);
  Result.SidebarText  := RGB(160, 170, 190);
  Result.GridAlt      := RGB(28, 33, 44);
  Result.GridSelected := RGB(35, 45, 65);
  Result.ErrorBg      := RGB(50, 25, 30);
  Result.BgDisabled   := RGB(22, 26, 34);
  Result.Shadow       := RGB(0, 0, 0);
end;

function ActiveTheme: TThemePalette;
begin
  if FCurrentMode = tmDark then
    Result := FDarkPalette
  else
    Result := FLightPalette;
end;

procedure ApplyPaletteToVars(const P: TThemePalette);
begin
  CLR_PRIMARY := P.Primary;         CLR_PRIMARY_DARK := P.PrimaryDark;
  CLR_PRIMARY_LIGHT := P.PrimaryLight; CLR_SECONDARY := P.Secondary;
  CLR_BG_MAIN := P.BgMain;          CLR_BG_SECONDARY := P.BgSecondary;
  CLR_BG_DARK := P.SidebarDark;
  CLR_SUCCESS := P.Success;         CLR_WARNING := P.Warning;
  CLR_ERROR := P.Error;             CLR_DANGER := P.Error;
  CLR_TEXT_MAIN := P.TextMain;      CLR_TEXT_SECONDARY := P.TextSecondary;
  CLR_TEXT_WHITE := P.TextWhite;
  CLR_BORDER := P.Border;           CLR_BORDER_FOCUS := P.BorderFocus;
  CLR_STAT_BLUE := P.StatBlue;      CLR_STAT_GREEN := P.StatGreen;
  CLR_STAT_ORANGE := P.StatOrange;  CLR_STAT_PURPLE := P.StatPurple;
  CLR_SIDEBAR := P.Sidebar;         CLR_SIDEBAR_DARK := P.SidebarDark;
  CLR_SIDEBAR_HOVER := P.SidebarHover; CLR_SIDEBAR_ACTIVE := P.SidebarActive;
  CLR_GRID_ALT := P.GridAlt;        CLR_GRID_SELECTED := P.GridSelected;
  CLR_ERROR_BG := P.ErrorBg;        CLR_BG_DISABLED := P.BgDisabled;
end;

procedure NotifyObservers;
var
  I: Integer;
begin
  for I := FObservers.Count - 1 downto 0 do
    FObservers[I]();
end;

{ -- Theme engine -- }

function ThemeIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

procedure InitTheme(const IniPath: string);
var
  Ini: TIniFile;
  Path: string;
begin
  FLightPalette := MakeLightPalette;
  FDarkPalette := MakeDarkPalette;
  FCurrentMode := tmLight;

  Path := IniPath;
  if Path = '' then
    Path := ThemeIniPath;

  if FileExists(Path) then
  begin
    Ini := TIniFile.Create(Path);
    try
      if Ini.ReadInteger('UI', 'ThemeMode', 0) = 1 then
        FCurrentMode := tmDark;
    finally
      Ini.Free;
    end;
  end;

  ApplyPaletteToVars(ActiveTheme);
  FThemeLoaded := True;
end;

procedure SetThemeMode(Mode: TThemeMode);
var
  I: Integer;
begin
  if FCurrentMode = Mode then
    Exit;
  FCurrentMode := Mode;
  ApplyPaletteToVars(ActiveTheme);
  SaveThemeMode;
  NotifyObservers;
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible then
      Screen.Forms[I].Invalidate;
end;

procedure SaveThemeMode(const IniPath: string);
var
  Ini: TIniFile;
  Path: string;
begin
  Path := IniPath;
  if Path = '' then
    Path := ThemeIniPath;
  Ini := TIniFile.Create(Path);
  try
    if FCurrentMode = tmDark then
      Ini.WriteInteger('UI', 'ThemeMode', 1)
    else
      Ini.WriteInteger('UI', 'ThemeMode', 0);
  finally
    Ini.Free;
  end;
end;

procedure RegisterThemeObserver(const AProc: TThemeChangeProc);
begin
  if not Assigned(FObservers) then
    FObservers := TList<TThemeChangeProc>.Create;
  if not FObservers.Contains(AProc) then
    FObservers.Add(AProc);
end;

procedure UnregisterThemeObserver(const AProc: TThemeChangeProc);
begin
  if Assigned(FObservers) then
    FObservers.Remove(AProc);
end;

{ -- TMS Component Styles (Guide section 5) -- }

procedure GVApplyCardStyle(const APanel: TAdvPanel;
  const ABackColor, ABorderColor: TColor; const AToColor: TColor);
begin
  APanel.Color := ABackColor;
  if AToColor <> clNone then
    APanel.ColorTo := AToColor
  else
    APanel.ColorTo := ABackColor;
  APanel.BevelOuter := bvNone;
  APanel.BevelInner := bvNone;
  APanel.BorderColor := ABorderColor;
  APanel.BorderShadow := False;
  APanel.Caption.Color := ABackColor;
  APanel.Caption.ColorTo := clNone;
end;

procedure GVApplyButtonStyle(const ABtn: TAdvSmoothButton; APrimary: Boolean);
begin
  ABtn.UIStyle := tsCustom;
  ABtn.Cursor := crHandPoint;
  ABtn.Height := DIM_BTN_HEIGHT;
  ABtn.Appearance.SimpleLayout := True;
  ABtn.Appearance.SimpleLayoutBorder := False;
  ABtn.Appearance.Rounding := DIM_BTN_RADIUS;
  ABtn.Appearance.Font.Name := FONT_BOLD;
  ABtn.Appearance.Font.Size := FONT_SIZE_BODY;
  if APrimary then
  begin
    ABtn.Color := ActiveTheme.Primary;
    ABtn.Appearance.Font.Color := ActiveTheme.TextWhite;
    ABtn.BevelColor := ActiveTheme.PrimaryDark;
  end
  else
  begin
    ABtn.Color := ActiveTheme.BgSecondary;
    ABtn.Appearance.Font.Color := ActiveTheme.TextMain;
    ABtn.BevelColor := ActiveTheme.Border;
  end;
  ABtn.DoubleBuffered := True;
end;

procedure GVApplyEditStyle(const AEdit: TAdvEdit;
  const AEmptyText: string; const ABackColor: TColor);
begin
  AEdit.ParentFont := False;
  AEdit.Font.Name := FONT_MAIN;
  AEdit.Font.Size := FONT_SIZE_BODY;
  AEdit.Color := ABackColor;
  AEdit.Ctl3D := False;
  AEdit.EmptyText := AEmptyText;
  AEdit.Height := DIM_EDIT_HEIGHT;
end;

procedure GVApplyComboStyle(const ACombo: TAdvComboBox;
  const ABackColor: TColor);
begin
  ACombo.ParentFont := False;
  ACombo.Font.Name := FONT_MAIN;
  ACombo.Font.Size := FONT_SIZE_BODY;
  ACombo.Style := csDropDownList;
  ACombo.Color := ABackColor;
  ACombo.ButtonWidth := 19;
  ACombo.Height := DIM_EDIT_HEIGHT;
end;

procedure GVApplyLabelStyle(const ALabel: TLabel;
  const ATextColor: TColor; const AFontSize: Integer;
  const ABold: Boolean; const AFontName: string);
begin
  ALabel.ParentFont := False;
  ALabel.Transparent := True;
  ALabel.Font.Name := AFontName;
  ALabel.Font.Height := AFontSize;
  ALabel.Font.Color := ATextColor;
  if ABold then
    ALabel.Font.Style := [fsBold]
  else
    ALabel.Font.Style := [];
end;

procedure GVApplyBadgePanelStyle(const APanel: TAdvPanel;
  const ABgColor, ABorderColor: TColor);
begin
  APanel.Color := ABgColor;
  APanel.ColorTo := ABgColor;
  APanel.BevelOuter := bvNone;
  APanel.BevelInner := bvNone;
  APanel.BorderColor := ABorderColor;
  APanel.BorderShadow := False;
  APanel.Height := 24;
end;

procedure GVApplyBadgeLabelStyle(const ALabel: TLabel;
  const AStatus: string);
var
  TxtClr: TColor;
begin
  ALabel.ParentFont := False;
  ALabel.Transparent := True;
  ALabel.Font.Name := FONT_BOLD;
  ALabel.Font.Size := FONT_SIZE_BADGE;
  ALabel.Caption := AStatus;

  if SameText(AStatus, #1605#1589#1575#1583#1602' '#1593#1604#1610#1607)
    or SameText(AStatus, 'ACTIF') or SameText(AStatus, 'VALIDEE')
    or SameText(AStatus, 'PAYEE') then
  begin
    TxtClr := RGB(22, 138, 106);
  end
  else if SameText(AStatus, #1605#1587#1608#1583) or SameText(AStatus, 'CREDIT')
    or SameText(AStatus, #1591#1576#1610#1593' '#1605#1587#1608#1583#1577) then
  begin
    TxtClr := RGB(186, 117, 23);
  end
  else if SameText(AStatus, 'RUPTURE') or SameText(AStatus, 'INACTIF')
    or SameText(AStatus, #1576#1591#1604#1575#1602#1577' '#1605#1581#1590#1601#1577) then
  begin
    TxtClr := RGB(163, 45, 45);
  end
  else
  begin
    TxtClr := RGB(105, 115, 141);
  end;

  ALabel.Font.Color := TxtClr;
end;

procedure GVEnsureDecorPanel(const AOwner: TComponent;
  const AParent: TWinControl; const AName: string;
  ALeft, ATop, AWidth, AHeight: Integer;
  AColor, ABorderColor: TColor; const AAnchors: TAnchors);
var
  Panel: TAdvPanel;
begin
  Panel := TAdvPanel(AOwner.FindComponent(AName));
  if Panel = nil then
  begin
    Panel := TAdvPanel.Create(AOwner);
    Panel.Name := AName;
    Panel.Parent := AParent;
    Panel.Text := '';
    Panel.TabStop := False;
    Panel.Enabled := False;
  end;
  Panel.Left := ALeft;
  Panel.Top := ATop;
  Panel.Width := AWidth;
  Panel.Height := AHeight;
  Panel.Color := AColor;
  Panel.ColorTo := AColor;
  Panel.BevelOuter := bvNone;
  Panel.BevelInner := bvNone;
  Panel.Anchors := AAnchors;
  Panel.SendToBack;
end;

function UIScale(AControl: TControl; Value: Integer): Integer;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(AControl);
  if AControl is TCustomForm then Form := TCustomForm(AControl);
  if Assigned(Form) then
    Result := MulDiv(Value, Form.CurrentPPI, 96)
  else
    Result := MulDiv(Value, Screen.PixelsPerInch, 96);
end;

function CreateWorkspace(AForm: TForm): TScrollBox;
var
  I: Integer;
begin
  Result := TScrollBox.Create(AForm);
  Result.BorderStyle := bsNone;
  Result.ParentBiDiMode := False;
  // Positions are explicitly RTL; do not let Windows mirror them a second time.
  Result.BiDiMode := bdRightToLeftReadingOnly;
  for I := AForm.ControlCount - 1 downto 0 do
  begin
    AForm.Controls[I].Align := alNone;
    AForm.Controls[I].Parent := Result;
  end;
  AForm.AutoScroll := False;
  Result.Parent := AForm;
  Result.Align := alClient;
  Result.VertScrollBar.Tracking := True;
  Result.HorzScrollBar.Tracking := True;
end;

procedure PlaceControl(AControl: TControl; X, Y, W, H: Integer);
begin
  AControl.Align := alNone;
  AControl.Anchors := [akLeft, akTop];
  if AControl is TLabel then
  begin
    TLabel(AControl).AutoSize := False;
    TLabel(AControl).Alignment := taRightJustify;
    TLabel(AControl).Layout := tlCenter;
    TLabel(AControl).EllipsisPosition := epEndEllipsis;
    TLabel(AControl).ShowHint := True;
    TLabel(AControl).Hint := TLabel(AControl).Caption;
  end;
  AControl.SetBounds(X, Y, Max(1, W), Max(1, H));
end;

procedure PlaceField(ALabel: TLabel; AField: TWinControl;
  X, Y, W, TabIndex: Integer);
begin
  PlaceControl(ALabel, X, Y, W, UIScale(AField, 24));
  ALabel.FocusControl := AField;
  PlaceControl(AField, X, Y + UIScale(AField, 26), W, UIScale(AField, 36));
  AField.TabOrder := TabIndex;
end;

function LayoutActions(AParent: TWinControl; const Buttons: array of TButton;
  AWidth: Integer): Integer;
var
  I, X, Y, W, Gap, H: Integer;
begin
  Gap := UIScale(AParent, 12);
  H := UIScale(AParent, 40);
  X := AWidth - Gap;
  Y := Gap;
  for I := Low(Buttons) to High(Buttons) do
  begin
    W := Min(UIScale(AParent, 144), AWidth - 2 * Gap);
    if X - W < Gap then
    begin
      X := AWidth - Gap;
      Inc(Y, H + Gap);
    end;
    Buttons[I].Parent := AParent;
    PlaceControl(Buttons[I], X - W, Y, W, H);
    Buttons[I].TabOrder := I;
    Dec(X, W + Gap);
  end;
  Result := Y + H + Gap;
end;

{ -- VCL Native Theming -- }

procedure AppliquerThemeFormulaire(AForm: TForm);
begin
  AForm.Color := ActiveTheme.BgMain;
  AForm.Font.Name := FONT_MAIN;
  AForm.Font.Size := FONT_SIZE_BODY;
  AForm.Font.Color := ActiveTheme.TextMain;
  AForm.DoubleBuffered := True;
end;

procedure ConfigurerRTL_v3(AForm: TForm);
begin
  AForm.BiDiMode := bdRightToLeft;
end;

procedure AppliquerThemeEdit(AEdit: TCustomEdit);
begin
  (AEdit as TEdit).Font.Name := FONT_MAIN;
  (AEdit as TEdit).Font.Size := FONT_SIZE_BODY;
  (AEdit as TEdit).Font.Color := ActiveTheme.TextMain;
  (AEdit as TEdit).Color := ActiveTheme.BgSecondary;
end;

procedure AppliquerThemeComboBox(ACbo: TCustomComboBox);
begin
  (ACbo as TComboBox).Font.Name := FONT_MAIN;
  (ACbo as TComboBox).Font.Size := FONT_SIZE_BODY;
  (ACbo as TComboBox).Font.Color := ActiveTheme.TextMain;
  (ACbo as TComboBox).Color := ActiveTheme.BgSecondary;
end;

procedure AppliquerThemeMemo(AMemo: TCustomMemo);
begin
  (AMemo as TMemo).Font.Name := FONT_MAIN;
  (AMemo as TMemo).Font.Size := FONT_SIZE_BODY;
  (AMemo as TMemo).Font.Color := ActiveTheme.TextMain;
  (AMemo as TMemo).Color := ActiveTheme.BgSecondary;
end;

procedure AppliquerThemeGrille(AGrid: TCustomDBGrid);
var
  G: TDBGrid;
begin
  G := AGrid as TDBGrid;
  G.Font.Name := FONT_MAIN;
  G.Font.Size := FONT_SIZE_SMALL;
  G.Font.Color := ActiveTheme.TextMain;
  G.Color := ActiveTheme.BgSecondary;
  G.FixedColor := ActiveTheme.Sidebar;
  G.Options := G.Options + [dgRowSelect, dgAlwaysShowSelection, dgAlwaysShowEditor];
end;

procedure AppliquerThemeStringGrid(AGrid: TStringGrid);
begin
  AGrid.Font.Name := FONT_MAIN;
  AGrid.Font.Size := FONT_SIZE_SMALL;
  AGrid.Font.Color := ActiveTheme.TextMain;
  AGrid.Color := ActiveTheme.BgSecondary;
  AGrid.FixedColor := ActiveTheme.Sidebar;
  AGrid.DefaultRowHeight := 28;
end;

procedure AppliquerThemeLabel(ALabel: TLabel; IsTitle, IsSecondary: Boolean);
begin
  ALabel.ParentFont := False;
  ALabel.Transparent := True;
  if IsTitle then
  begin
    ALabel.Font.Name := FONT_BOLD;
    ALabel.Font.Size := FONT_SIZE_TITLE;
    ALabel.Font.Color := ActiveTheme.TextMain;
    ALabel.Font.Style := [fsBold];
  end
  else if IsSecondary then
  begin
    ALabel.Font.Name := FONT_MAIN;
    ALabel.Font.Size := FONT_SIZE_SMALL;
    ALabel.Font.Color := ActiveTheme.TextSecondary;
    ALabel.Font.Style := [];
  end
  else
  begin
    ALabel.Font.Name := FONT_MAIN;
    ALabel.Font.Size := FONT_SIZE_BODY;
    ALabel.Font.Color := ActiveTheme.TextMain;
    ALabel.Font.Style := [];
  end;
end;

procedure AppliquerThemePanel(APanel: TCustomPanel; IsCard: Boolean);
begin
  if IsCard then
  begin
    (APanel as TPanel).Color := ActiveTheme.BgSecondary;
    (APanel as TPanel).ParentBackground := False;
  end
  else
  begin
    (APanel as TPanel).Color := ActiveTheme.BgMain;
    (APanel as TPanel).ParentBackground := False;
  end;
end;

{ -- Button theming -- }

procedure TButtonAccess.SetColor(const AColor: TColor);
begin
  Color := AColor;
end;

procedure AppliquerThemeBouton(ABtn: TButton; Style: TBtnStyle);
begin
  ABtn.Font.Name := FONT_BOLD;
  ABtn.Font.Size := FONT_SIZE_BODY;
  ABtn.Font.Style := [];
  case Style of
    bsPrimary:
      begin
        ABtn.Font.Color := clWhite;
        TButtonAccess(ABtn).SetColor(ActiveTheme.Primary);
      end;
    bsSecondary:
      begin
        ABtn.Font.Color := ActiveTheme.TextMain;
        TButtonAccess(ABtn).SetColor(ActiveTheme.BgSecondary);
      end;
    bsSuccess:
      begin
        ABtn.Font.Color := clWhite;
        TButtonAccess(ABtn).SetColor(ActiveTheme.Success);
      end;
    bsWarning:
      begin
        ABtn.Font.Color := clWhite;
        TButtonAccess(ABtn).SetColor(ActiveTheme.Warning);
      end;
    bsDanger:
      begin
        ABtn.Font.Color := clWhite;
        TButtonAccess(ABtn).SetColor(ActiveTheme.Error);
      end;
    bsGhost:
      begin
        ABtn.Font.Color := ActiveTheme.Primary;
        TButtonAccess(ABtn).SetColor(clNone);
      end;
  end;
end;

procedure StyleModernButton(ABtn: TButton; Style: TBtnStyle;
  const AIcon, ACaption: string);
begin
  AppliquerThemeBouton(ABtn, Style);
  ABtn.Caption := AIcon + '  ' + ACaption;
end;

{ -- Drawing helpers -- }

procedure AppliquerThemeTousLesComposants(AForm: TForm);
var
  I: Integer;
  Ctrl: TControl;
begin
  for I := 0 to AForm.ControlCount - 1 do
  begin
    Ctrl := AForm.Controls[I];
    if Ctrl is TEdit then
      AppliquerThemeEdit(TCustomEdit(Ctrl))
    else if Ctrl is TComboBox then
      AppliquerThemeComboBox(TCustomComboBox(Ctrl))
    else if Ctrl is TMemo then
      AppliquerThemeMemo(TCustomMemo(Ctrl))
    else if Ctrl is TDBGrid then
      AppliquerThemeGrille(TCustomDBGrid(Ctrl))
    else if Ctrl is TStringGrid then
      AppliquerThemeStringGrid(TStringGrid(Ctrl))
    else if Ctrl is TLabel then
    begin
      if TLabel(Ctrl).Font.Size >= FONT_SIZE_TITLE then
        AppliquerThemeLabel(TLabel(Ctrl), True, False)
      else if TLabel(Ctrl).Font.Size <= FONT_SIZE_SMALL then
        AppliquerThemeLabel(TLabel(Ctrl), False, True)
      else
        AppliquerThemeLabel(TLabel(Ctrl), False, False);
    end
    else if Ctrl is TPanel then
      AppliquerThemePanel(TCustomPanel(Ctrl), False);
  end;
end;

function ContrastRatio(C1, C2: TColor): Double;
var
  R1, G1, B1, R2, G2, B2: Byte;
  L1, L2: Double;
begin
  R1 := GetRValue(ColorToRGB(C1));
  G1 := GetGValue(ColorToRGB(C1));
  B1 := GetBValue(ColorToRGB(C1));
  R2 := GetRValue(ColorToRGB(C2));
  G2 := GetGValue(ColorToRGB(C2));
  B2 := GetBValue(ColorToRGB(C2));

  L1 := (0.299 * R1 + 0.587 * G1 + 0.114 * B1) / 255;
  L2 := (0.299 * R2 + 0.587 * G2 + 0.114 * B2) / 255;

  if L1 > L2 then
    Result := (L1 + 0.05) / (L2 + 0.05)
  else
    Result := (L2 + 0.05) / (L1 + 0.05);
end;

function IsContrastAccessible(C1, C2: TColor; AMinRatio: Double): Boolean;
begin
  Result := ContrastRatio(C1, C2) >= AMinRatio;
end;

procedure DrawStatusBadge(ACanvas: TCanvas; const R: TRect;
  const AText: string; AColor: TColor);
var
  TextRect: TRect;
  OldBrush, OldPen: TColor;
begin
  OldBrush := ACanvas.Brush.Color;
  OldPen := ACanvas.Pen.Color;
  try
    ACanvas.Brush.Color := LightenColor(AColor, 40);
    ACanvas.Pen.Color := AColor;
    TextRect := R;
    InflateRect(TextRect, -8, -4);
    ACanvas.RoundRect(TextRect.Left, TextRect.Top,
      TextRect.Right, TextRect.Bottom, 12, 12);

    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Name := FONT_BOLD;
    ACanvas.Font.Size := FONT_SIZE_BADGE;
    ACanvas.Font.Color := AColor;
    ACanvas.Font.Style := [fsBold];
    DrawText(ACanvas.Handle, PChar(AText), Length(AText),
      TextRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    ACanvas.Brush.Style := bsSolid;
  finally
    ACanvas.Brush.Color := OldBrush;
    ACanvas.Pen.Color := OldPen;
  end;
end;

procedure PaintVerticalGradient(ACanvas: TCanvas; const R: TRect;
  ColorTop, ColorBottom: TColor);
var
  Row: Integer;
  Ratio: Double;
  R1, G1, B1, R2, G2, B2: Byte;
  C: TColor;
begin
  R1 := GetRValue(ColorTop);
  G1 := GetGValue(ColorTop);
  B1 := GetBValue(ColorTop);
  R2 := GetRValue(ColorBottom);
  G2 := GetGValue(ColorBottom);
  B2 := GetBValue(ColorBottom);

  for Row := R.Top to R.Bottom - 1 do
  begin
    if R.Bottom = R.Top then
      Ratio := 0
    else
      Ratio := (Row - R.Top) / (R.Bottom - R.Top);
    C := RGB(
      Round(R1 + (R2 - R1) * Ratio),
      Round(G1 + (G2 - G1) * Ratio),
      Round(B1 + (B2 - B1) * Ratio));
    ACanvas.Brush.Color := C;
    ACanvas.FillRect(Rect(R.Left, Row, R.Right, Row + 1));
  end;
end;

function FormatStatValue(Value: Currency): string;
begin
  if Value >= 1000000 then
    Result := FormatFloat('#,##0.0"M"', Value / 1000000)
  else if Value >= 1000 then
    Result := FormatFloat('#,##0.0"K"', Value / 1000)
  else
    Result := FormatFloat('#,##0.00', Value);
end;

function StatutColor(const Statut: string): TColor;
begin
  if SameText(Statut, #1605#1589#1575#1583#1602' '#1593#1604#1610#1607)
    or SameText(Statut, 'ACTIF') or SameText(Statut, 'VALIDEE')
    or SameText(Statut, 'PAYEE') then
    Result := ActiveTheme.Success
  else if SameText(Statut, #1576#1591#1604#1575#1602#1577' '#1605#1581#1586#1608#1601#1577)
    or SameText(Statut, 'RUPTURE') then
    Result := ActiveTheme.Error
  else
    Result := ActiveTheme.TextSecondary;
end;

function BtnStyleToColors(Style: TBtnStyle): TColor;
begin
  case Style of
    bsPrimary:   Result := ActiveTheme.Primary;
    bsSecondary: Result := ActiveTheme.Secondary;
    bsSuccess:   Result := ActiveTheme.Success;
    bsWarning:   Result := ActiveTheme.Warning;
    bsDanger:    Result := ActiveTheme.Error;
  else
    Result := ActiveTheme.Primary;
  end;
end;

initialization
  FObservers := TList<TThemeChangeProc>.Create;
  FCurrentMode := tmLight;

finalization
  FreeAndNil(FObservers);

end.
