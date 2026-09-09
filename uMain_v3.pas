unit uMain_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  AdvPanel, AdvSmoothButton, AdvStyleIF,
  uModernTheme;

type
  TfrmMain = class(TForm)
    pnlRoot: TPanel;
    pnlSidebar: TAdvPanel;
    pnlTopbar: TAdvPanel;
    pnlContent: TPanel;
    lblBrand: TLabel;
    lblSub: TLabel;
    btnNavDashboard: TAdvSmoothButton;
    btnNavListe: TAdvSmoothButton;
    btnNavAjouter: TAdvSmoothButton;
    btnNavProjets: TAdvSmoothButton;
    btnNavCatalogue: TAdvSmoothButton;
    btnNavParametres: TAdvSmoothButton;
    btnNavDeconnexion: TAdvSmoothButton;
    lblTitle: TLabel;
    lblUser: TLabel;
    lblContext: TLabel;
    lblClock: TLabel;
    StatusBar1: TStatusBar;
    TimerDate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerDateTimer(Sender: TObject);
    procedure NavItemClick(Sender: TObject);
  private
    FCurrentForm: TForm;
    FCurrentCached: Boolean;
    FFormCache: TDictionary<TFormClass, TForm>;
    FActiveNav: TAdvSmoothButton;
    FNavHistory: TStack<TFormClass>;
    FFadeTimer: TTimer;
    FFadeInA: Integer;
    FFadeOutA: Integer;
    FFadingIn: Boolean;
    FFadingOut: Boolean;
    FClosingForm: TForm;
    FClosingCached: Boolean;
    FBrandIcon: TPanel;
    FBrandGlyph: TLabel;
    FSecAdmin: TLabel;
    btnThemeToggle: TAdvSmoothButton;
    procedure CollectNavItems;
    procedure BuildSidebarChrome;
    procedure ThemeToggleClick(Sender: TObject);
    procedure StyleNavButton(const ABtn: TAdvSmoothButton; const Active: Boolean);
    procedure StyleTopButton(const ABtn: TAdvSmoothButton; const AccentColor: TColor);
    procedure SetActiveNav(Item: TAdvSmoothButton);
    procedure ApplyAllStyles;
    procedure ShowChildInContent(AForm: TForm);
    procedure CloseCurrentChild;
    procedure NavigateTo(const Titre: string; FormClass: TFormClass;
      Cacheable: Boolean = True);
    procedure StatusBarSetup;
    procedure ApplyModernLayout;
    procedure NavigateBack;
    procedure FadeTimerTimer(Sender: TObject);
  public
    procedure ApresConnexion;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uDashboard_v3, uListeFiches_v3, uFicheTechnique_v3,
  uProjets_v3, uCatalogue_v3, uParametres_v3, uUtils_v3, uDataModule_v3;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FCurrentForm := nil;
  FCurrentCached := False;
  FFadeInA := 0;
  FFadeOutA := 255;
  FFadingIn := False;
  FFadingOut := False;
  FClosingForm := nil;
  FClosingCached := False;
  FBrandIcon := nil;
  FBrandGlyph := nil;
  FSecAdmin := nil;
  btnThemeToggle := nil;
  FFormCache := TDictionary<TFormClass, TForm>.Create;
  FNavHistory := TStack<TFormClass>.Create;

  FFadeTimer := TTimer.Create(Self);
  FFadeTimer.Interval := 16;
  FFadeTimer.OnTimer := FadeTimerTimer;
  FFadeTimer.Enabled := False;

  CollectNavItems;
  ApplyAllStyles;
  StatusBarSetup;

  TimerDate.Interval := 1000;
  TimerDate.Enabled := True;
  lblClock.Caption := FormatDateTime('ddd dd/mm/yyyy  hh:nn:ss', Now);

  RegisterThemeObserver(ApplyAllStyles);

  BuildSidebarChrome;

  KeyPreview := True;
  OnKeyDown := FormKeyDown;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TimerDate.Enabled := False;
  UnregisterThemeObserver(ApplyAllStyles);
  FFadeTimer.Enabled := False;
  if Assigned(FCurrentForm) then
  begin
    if not FCurrentCached then
      FreeAndNil(FCurrentForm)
    else
      FCurrentForm.Visible := False;
    FCurrentForm := nil;
  end;
  FCurrentCached := False;
  FreeAndNil(FFormCache);
  FreeAndNil(FNavHistory);
  FreeAndNil(FFadeTimer);
  Action := caFree;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  pnlRoot.Align := alClient;
  if pnlSidebar.Width <> 240 then
    pnlSidebar.Width := 240;
  pnlTopbar.Height := 68;
  pnlContent.Left := pnlSidebar.Width;
  pnlContent.Top := pnlTopbar.Height;
  pnlContent.Width := pnlRoot.ClientWidth - pnlSidebar.Width;
  pnlContent.Height := pnlRoot.ClientHeight - pnlTopbar.Height;
  ApplyModernLayout;

  FBrandIcon.SetBounds(18, 18, 44, 44);
  lblBrand.SetBounds(72, 20, 152, 26);
  lblSub.SetBounds(72, 46, 152, 16);
  btnNavDashboard.SetBounds(14, 84, 212, 40);
  btnNavListe.SetBounds(14, 128, 212, 40);
  btnNavAjouter.SetBounds(14, 172, 212, 40);
  FSecAdmin.SetBounds(14, 226, 212, 16);
  btnNavProjets.SetBounds(14, 246, 212, 40);
  btnNavCatalogue.SetBounds(14, 290, 212, 40);
  btnNavParametres.SetBounds(14, 334, 212, 40);
  btnNavDeconnexion.SetBounds(14, pnlSidebar.Height - 54, 212, 40);
end;

procedure TfrmMain.CollectNavItems;
begin
  btnNavDashboard.Tag := 1;
  btnNavListe.Tag := 2;
  btnNavAjouter.Tag := 3;
  btnNavProjets.Tag := 4;
  btnNavCatalogue.Tag := 5;
  btnNavParametres.Tag := 6;
  btnNavDeconnexion.Tag := 99;
end;

procedure TfrmMain.ApplyAllStyles;

  procedure StyleLabel(ALbl: TLabel; AColor: TColor; ASize: Integer;
    ABold: Boolean; const AName: string = FONT_MAIN);
  begin
    if ALbl = nil then Exit;
    ALbl.ParentFont := False;
    ALbl.Transparent := True;
    ALbl.Font.Name := AName;
    ALbl.Font.Size := ASize;
    ALbl.Font.Color := AColor;
    if ABold then
      ALbl.Font.Style := [fsBold]
    else
      ALbl.Font.Style := [];
  end;

var
  Navs: array[0..6] of TAdvSmoothButton;
  I: Integer;
begin
  GVApplyCardStyle(pnlSidebar, CLR_SIDEBAR, CLR_SIDEBAR, CLR_SIDEBAR_DARK);
  GVApplyCardStyle(pnlTopbar, CLR_BG_SECONDARY, CLR_BORDER, CLR_BG_MAIN);
  pnlContent.Color := CLR_BG_MAIN;

  StyleLabel(lblBrand, CLR_TEXT_WHITE, 18, True, FONT_BOLD);
  StyleLabel(lblSub, RGB(150, 188, 230), 10, False);
  StyleLabel(lblTitle, CLR_TEXT_MAIN, 18, True, FONT_BOLD);
  StyleLabel(lblContext, CLR_TEXT_SECONDARY, 10, False);
  StyleLabel(lblUser, CLR_TEXT_SECONDARY, 10, False);
  StyleLabel(lblClock, CLR_TEXT_SECONDARY, 10, False);

  Navs[0] := btnNavDashboard;
  Navs[1] := btnNavListe;
  Navs[2] := btnNavAjouter;
  Navs[3] := btnNavProjets;
  Navs[4] := btnNavCatalogue;
  Navs[5] := btnNavParametres;
  Navs[6] := btnNavDeconnexion;

  for I := 0 to 6 do
    StyleNavButton(Navs[I], False);

  if Assigned(FActiveNav) then
    StyleNavButton(FActiveNav, True);

  BuildSidebarChrome;
end;

procedure TfrmMain.StyleNavButton(const ABtn: TAdvSmoothButton; const Active: Boolean);
begin
  ABtn.UIStyle := tsCustom;
  ABtn.Appearance.SimpleLayout := True;
  ABtn.Appearance.SimpleLayoutBorder := False;
  ABtn.Appearance.Rounding := 10;
  ABtn.Appearance.Font.Name := FONT_MAIN;
  ABtn.Appearance.Font.Size := FONT_SIZE_BODY;
  ABtn.DoubleBuffered := True;
  ABtn.Cursor := crHandPoint;

  if Active then
  begin
    ABtn.Color := CLR_SIDEBAR_ACTIVE;
    ABtn.BevelColor := CLR_SIDEBAR_ACTIVE;
    ABtn.Appearance.Font.Color := CLR_TEXT_WHITE;
    ABtn.Appearance.Font.Style := [fsBold];
  end
  else
  begin
    ABtn.Color := CLR_SIDEBAR;
    ABtn.BevelColor := CLR_SIDEBAR;
    ABtn.Appearance.Font.Color := ActiveTheme.SidebarText;
    ABtn.Appearance.Font.Style := [];
  end;
end;

procedure TfrmMain.StyleTopButton(const ABtn: TAdvSmoothButton; const AccentColor: TColor);
begin
  ABtn.UIStyle := tsCustom;
  ABtn.Appearance.SimpleLayout := True;
  ABtn.Appearance.SimpleLayoutBorder := False;
  ABtn.Appearance.Rounding := 10;
  ABtn.Appearance.Font.Name := FONT_MAIN;
  ABtn.Appearance.Font.Size := FONT_SIZE_BODY;
  ABtn.Color := clWhite;
  ABtn.BevelColor := AccentColor;
  ABtn.Appearance.Font.Color := AccentColor;
  ABtn.Appearance.Font.Style := [];
  ABtn.DoubleBuffered := True;
  ABtn.Cursor := crHandPoint;
end;

procedure TfrmMain.SetActiveNav(Item: TAdvSmoothButton);
var
  Navs: array[0..6] of TAdvSmoothButton;
  I: Integer;
begin
  Navs[0] := btnNavDashboard;
  Navs[1] := btnNavListe;
  Navs[2] := btnNavAjouter;
  Navs[3] := btnNavProjets;
  Navs[4] := btnNavCatalogue;
  Navs[5] := btnNavParametres;
  Navs[6] := btnNavDeconnexion;

  for I := 0 to 6 do
    StyleNavButton(Navs[I], Navs[I] = Item);

  FActiveNav := Item;
end;

procedure TfrmMain.NavItemClick(Sender: TObject);
var
  Item: TAdvSmoothButton;
begin
  if not (Sender is TAdvSmoothButton) then Exit;
  Item := TAdvSmoothButton(Sender);

  if Item.Tag <> 99 then
    SetActiveNav(Item);

  case Item.Tag of
    1: NavigateTo(#1604#1608#1581#1577' '#1575#1604#1602#1610#1575#1583#1577, TfrmDashboard);
    2: NavigateTo(#1602#1575#1574#1605#1577' '#1575#1604#1576#1591#1575#1602#1575#1578, TfrmListeFiches);
    3: NavigateTo(#1576#1591#1575#1602#1577' '#1580#1583#1610#1583#1577, TfrmFicheTechnique, False);
    4: NavigateTo(#1575#1604#1605#1588#1575#1585#1610#1593, TfrmProjets);
    5: NavigateTo(#1603#1578#1575#1604#1608#1582' '#1575#1604#1605#1608#1575#1583, TfrmCatalogue);
    6: NavigateTo(#1575#1604#1573#1593#1583#1575#1583#1575#1578, TfrmParametres);
    99: Close;
  end;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) then
  begin
    case Key of
      Ord('1'): NavigateTo(#1604#1608#1581#1577' '#1575#1604#1602#1610#1575#1583#1577, TfrmDashboard);
      Ord('2'): NavigateTo(#1602#1575#1574#1605#1577' '#1575#1604#1576#1591#1575#1602#1575#1578, TfrmListeFiches);
      Ord('3'): NavigateTo(#1576#1591#1575#1602#1577' '#1580#1583#1610#1583#1577, TfrmFicheTechnique, False);
      Ord('4'): NavigateTo(#1575#1604#1605#1588#1575#1585#1610#1593, TfrmProjets);
      Ord('5'): NavigateTo(#1603#1578#1575#1604#1608#1582' '#1575#1604#1605#1608#1575#1583, TfrmCatalogue);
      Ord('6'): NavigateTo(#1575#1604#1573#1593#1583#1575#1583#1575#1578, TfrmParametres);
      Ord('Q'): Close;
    end;
    Key := 0;
  end
  else if Key = VK_F5 then
  begin
    if Assigned(FCurrentForm) and (FCurrentForm is TfrmDashboard) then
      TfrmDashboard(FCurrentForm).btnRefreshClick(nil);
    Key := 0;
  end
  else if Key = VK_Escape then
  begin
    if Assigned(FCurrentForm) and (FCurrentForm is TfrmFicheTechnique) then
      TfrmFicheTechnique(FCurrentForm).Close
    else
      CloseCurrentChild;
    Key := 0;
  end
  else if (ssAlt in Shift) and (Key = VK_Left) then
  begin
    NavigateBack;
    Key := 0;
  end;
end;

procedure TfrmMain.NavigateTo(const Titre: string; FormClass: TFormClass;
  Cacheable: Boolean);
var
  Frm: TForm;
begin
  if Assigned(FCurrentForm) then
    FNavHistory.Push(TFormClass(FCurrentForm.ClassType));

  CloseCurrentChild;

  if Cacheable and FFormCache.TryGetValue(FormClass, Frm) then
  begin
    ShowChildInContent(Frm);
    FCurrentCached := True;
  end
  else
  begin
    Screen.Cursor := crHourGlass;
    try
      Frm := FormClass.Create(Self);
      if Frm.BiDiMode = bdLeftToRight then
        ConfigurerRTL_v3(Frm);
      ShowChildInContent(Frm);
      FCurrentCached := Cacheable;
      if Cacheable then
        FFormCache.Add(FormClass, Frm);
    finally
      Screen.Cursor := crDefault;
    end;
  end;

  lblTitle.Caption := Titre;
end;

procedure TfrmMain.NavigateBack;
begin
  if FNavHistory.Count > 0 then
  begin
    CloseCurrentChild;
    NavigateTo('', FNavHistory.Pop, True);
  end;
end;

procedure TfrmMain.ShowChildInContent(AForm: TForm);
begin
  FCurrentForm := AForm;
  FCurrentForm.BorderStyle := bsNone;
  FCurrentForm.Align := alClient;
  FCurrentForm.Parent := pnlContent;
  FCurrentForm.Visible := True;
  FCurrentForm.BringToFront;
  FCurrentForm.AlphaBlend := True;
  FCurrentForm.AlphaBlendValue := 0;
  FFadeInA := 0;
  FFadingIn := True;
  FFadeTimer.Enabled := True;
end;

procedure TfrmMain.CloseCurrentChild;
begin
  if (not FFadingOut) and Assigned(FCurrentForm) then
  begin
    FClosingForm := FCurrentForm;
    FClosingCached := FCurrentCached;
    FCurrentForm := nil;
    FCurrentCached := False;
    FFadeOutA := 255;
    FFadingOut := True;
    FFadeTimer.Enabled := True;
  end;
end;

procedure TfrmMain.FadeTimerTimer(Sender: TObject);
const
  FadeStep = 8;
begin
  if FFadingOut then
  begin
    if Assigned(FClosingForm) then
    begin
      Dec(FFadeOutA, FadeStep);
      if FFadeOutA <= 0 then
      begin
        FFadeOutA := 0;
        FClosingForm.AlphaBlendValue := 0;
        if not FClosingCached then
          FClosingForm.Free
        else
          FClosingForm.Visible := False;
        FClosingForm := nil;
        FFadingOut := False;
      end
      else
        FClosingForm.AlphaBlendValue := FFadeOutA;
    end
    else
      FFadingOut := False;
  end;

  if FFadingIn then
  begin
    if Assigned(FCurrentForm) then
    begin
      Inc(FFadeInA, FadeStep);
      if FFadeInA >= 255 then
      begin
        FFadeInA := 255;
        FFadingIn := False;
      end;
      FCurrentForm.AlphaBlendValue := FFadeInA;
    end
    else
      FFadingIn := False;
  end;

  FFadeTimer.Enabled := FFadingOut or FFadingIn;
end;

procedure TfrmMain.TimerDateTimer(Sender: TObject);
begin
  lblClock.Caption := FormatDateTime('ddd dd/mm/yyyy  hh:nn:ss', Now);
end;

procedure TfrmMain.StatusBarSetup;
begin
  StatusBar1.Panels[0].Width := 200;
  StatusBar1.Panels[0].Text := APP_NAME + '  |  ' + APP_VERSION;
  StatusBar1.Panels[1].Width := 200;
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Width := 300;
  StatusBar1.Panels[2].Text := '';
end;

procedure TfrmMain.ApresConnexion;
begin
  lblUser.Caption := dmMain.NomComplet + '  |  ' + dmMain.NomUtilisateur;
  lblClock.Caption := FormatDateTime('ddd dd/mm/yyyy  hh:nn:ss', Now);
  lblContext.Caption := APP_NAME + '  |  ' + APP_VERSION;
  StatusBar1.Panels[0].Text := APP_NAME + '  |  ' + APP_VERSION;
  StatusBar1.Panels[1].Text := dmMain.NomComplet;
  StatusBar1.Panels[2].Text := dmMain.NomUtilisateur;
  NavItemClick(btnNavDashboard);
end;

procedure TfrmMain.ApplyModernLayout;
const
  Margin = 12;
  Gap = 16;
begin
  if (pnlContent.ClientWidth <= 0) or (pnlContent.ClientHeight <= 0) then Exit;

  if Assigned(FCurrentForm) then
  begin
    FCurrentForm.SetBounds(Margin, Margin,
      pnlContent.ClientWidth - Margin * 2,
      pnlContent.ClientHeight - Margin * 2);
  end;
end;

procedure TfrmMain.BuildSidebarChrome;
begin
  if FBrandIcon = nil then
  begin
    FBrandIcon := TPanel.Create(Self);
    FBrandIcon.Parent := pnlSidebar;
    FBrandIcon.SetBounds(18, 18, 44, 44);
    FBrandIcon.BevelOuter := bvNone;
    FBrandIcon.ParentBackground := False;
    FBrandIcon.Color := CLR_PRIMARY;
  end;
  if FBrandGlyph = nil then
  begin
    FBrandGlyph := TLabel.Create(Self);
    FBrandGlyph.Parent := FBrandIcon;
    FBrandGlyph.SetBounds(0, 0, 44, 44);
    FBrandGlyph.Alignment := taCenter;
    FBrandGlyph.Layout := tlCenter;
    FBrandGlyph.Caption := ICO_DOC;
    FBrandGlyph.Font.Name := ICON_FONT;
    FBrandGlyph.Font.Size := 18;
    FBrandGlyph.Font.Color := CLR_TEXT_WHITE;
    FBrandGlyph.ParentFont := False;
    FBrandGlyph.Transparent := True;
  end;
  if FSecAdmin = nil then
  begin
    FSecAdmin := TLabel.Create(Self);
    FSecAdmin.Parent := pnlSidebar;
    FSecAdmin.AutoSize := False;
    FSecAdmin.Alignment := taCenter;
    FSecAdmin.Transparent := True;
    FSecAdmin.Caption := #1575#1604#1573#1583#1575#1585#1577;
    FSecAdmin.Font.Name := FONT_BOLD;
    FSecAdmin.Font.Size := 8;
    FSecAdmin.Font.Color := RGB(140, 165, 200);
    FSecAdmin.ParentFont := False;
  end;
  lblSub.Alignment := taCenter;
  lblSub.Caption := #1575#1604#1602#1575#1574#1605#1577 + Chr(32) + #1575#1604#1585#1574#1610#1587#1610#1577;
  lblSub.Font.Size := 8;
  lblSub.Font.Style := [fsBold];
  lblSub.Font.Color := RGB(140, 165, 200);
  if btnThemeToggle = nil then
  begin
    btnThemeToggle := TAdvSmoothButton.Create(Self);
    btnThemeToggle.Parent := pnlTopbar;
    btnThemeToggle.Cursor := crHandPoint;
    btnThemeToggle.OnClick := ThemeToggleClick;
  end;
  btnThemeToggle.SetBounds(14, 15, 42, 38);
  btnThemeToggle.Appearance.SimpleLayout := True;
  btnThemeToggle.Appearance.Rounding := 10;
  btnThemeToggle.Color := ActiveTheme.BgMain;
  btnThemeToggle.BevelColor := ActiveTheme.Border;
  btnThemeToggle.Appearance.Font.Name := ICON_FONT;
  btnThemeToggle.Appearance.Font.Size := 14;
  btnThemeToggle.Appearance.Font.Color := ActiveTheme.TextSecondary;
  if ActiveTheme.Mode = tmDark then
    btnThemeToggle.Caption := #$E706
  else
    btnThemeToggle.Caption := #$E708;
end;

procedure TfrmMain.ThemeToggleClick(Sender: TObject);
begin
  if ActiveTheme.Mode = tmDark then
    SetThemeMode(tmLight)
  else
    SetThemeMode(tmDark);
  SaveThemeMode;
end;

end.

