unit uLogin_v3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, System.UITypes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.IniFiles,
  AdvEdit, AdvSmoothButton, AdvSmoothPanel,
  System.Skia,
  uModernTheme, uSkiaTheme, uIconsSVG;

type
// ---------------------------------------------------------------------------
// TfrmLogin
// ---------------------------------------------------------------------------
  TfrmLogin = class(TForm)
    pnlBrand: TAdvSmoothPanel;
    lblBrandTitle: TLabel;
    lblBrandSubtitle: TLabel;
    lblVersionLeft: TLabel;
    pnlForm: TAdvSmoothPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblUserLabel: TLabel;
    lblPasswordLabel: TLabel;
    lblVersionRight: TLabel;
    svgBtnClose: TAdvSmoothPanel;
    svgBtnMin: TAdvSmoothPanel;
    pnlUserContainer: TAdvSmoothPanel;
    svgUserIcon: TAdvSmoothPanel;
    edtUser: TAdvEdit;
    pnlPasswordContainer: TAdvSmoothPanel;
    svgPassIcon: TAdvSmoothPanel;
    svgToggle: TAdvSmoothPanel;
    edtPassword: TAdvEdit;
    pnlOptions: TPanel;
    chkRemember: TCheckBox;
    lblForgotPassword: TLabel;
    btnLogin: TAdvSmoothButton;
    btnConfig: TAdvSmoothButton;
    procedure FormCreate(Sender: TObject);
    procedure pnlTogglePasswordClick(Sender: TObject);
    procedure lblForgotPasswordClick(Sender: TObject);
    procedure FormKeyHandler(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnLoginClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtUserEnter(Sender: TObject);
    procedure edtUserExit(Sender: TObject);
    procedure edtPasswordEnter(Sender: TObject);
    procedure edtPasswordExit(Sender: TObject);

    // Paint handlers (TAdvSmoothPanel.OnDraw, Skia-based)
    procedure PaintBrand(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure PaintForm(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure PaintUserCont(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure PaintPassCont(Sender: TObject; Canvas: TCanvas; Rect: TRect);

    // Icon draw handlers (TAdvSmoothPanel.OnDraw, Skia-based)
    procedure DrawBtnClose(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure DrawBtnMin(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure DrawUserIcon(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure DrawPassIcon(Sender: TObject; Canvas: TCanvas; Rect: TRect);
    procedure DrawToggle(Sender: TObject; Canvas: TCanvas; Rect: TRect);

    // Icon hover state
    procedure svgCloseMouseEnter(Sender: TObject);
    procedure svgCloseMouseLeave(Sender: TObject);
    procedure svgMinMouseEnter(Sender: TObject);
    procedure svgMinMouseLeave(Sender: TObject);
  private
    FLoginOK: Boolean;
    FShowPassword: Boolean;
    FUserFocused: Boolean;
    FPasswordFocused: Boolean;
    FCloseHover: Boolean;
    FMinHover: Boolean;

    procedure ApplyTheme;
    procedure ApplyLayout;
    procedure LoadSavedUser;
    procedure SaveUserIfRemembered;
    procedure AfficherConfigConnexion;
    procedure btnTestConnClick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    property LoginOK: Boolean read FLoginOK;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses uDataModule_v3, uUtils_v3;
var
  GCfgSrv: TEdit;
  GCfgDb: TEdit;
  GCfgUsr: TEdit;
  GCfgPwd: TEdit;
  GCfgWin: TCheckBox;

// ---------------------------------------------------------------------------
// Form creation
// ---------------------------------------------------------------------------

procedure TfrmLogin.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

procedure TfrmLogin.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FLoginOK := False;
  FShowPassword := False;
  FUserFocused := False;
  FPasswordFocused := False;
  FCloseHover := False;
  FMinHover := False;
  DoubleBuffered := True;

  KeyPreview := True;
  OnKeyDown := FormKeyHandler;

  ApplyTheme;
  ApplyLayout;
  LoadSavedUser;

  if edtUser.CanFocus then
    edtUser.SetFocus;
end;

procedure TfrmLogin.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, 61458, 0);
  end;
end;

// ---------------------------------------------------------------------------
// Ini helpers
// ---------------------------------------------------------------------------

procedure TfrmLogin.LoadSavedUser;
var
  Ini: TIniFile;
  IniPath: string;
begin
  IniPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  if FileExists(IniPath) then
  begin
    Ini := TIniFile.Create(IniPath);
    try
      chkRemember.Checked := Ini.ReadBool('Login', 'RememberMe', True);
      if chkRemember.Checked then
        edtUser.Text := Ini.ReadString('Login', 'LastUser', 'admin');
    finally
      Ini.Free;
    end;
  end;
end;

procedure TfrmLogin.SaveUserIfRemembered;
var
  Ini: TIniFile;
  IniPath: string;
begin
  IniPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  Ini := TIniFile.Create(IniPath);
  try
    Ini.WriteBool('Login', 'RememberMe', chkRemember.Checked);
    if chkRemember.Checked then
      Ini.WriteString('Login', 'LastUser', Trim(edtUser.Text))
    else
      Ini.WriteString('Login', 'LastUser', '');
  finally
    Ini.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Theme & Layout
// ---------------------------------------------------------------------------

procedure TfrmLogin.ApplyTheme;
begin
  Self.Color := RGB(237, 242, 236);

  // IMPORTANT: Transparent labels do NOT work over TSkPanel (Skia bypasses GDI erasure).
  // Each label must have Transparent=False and a Color matching its background panel.

  // --- Brand panel labels (approx gradient midpoint ~RGB(40,66,53)) ---
  lblBrandTitle.Transparent   := False;
  lblBrandTitle.Color         := RGB(40, 66, 53);
  lblBrandTitle.ParentColor   := False;
  lblBrandTitle.Font.Name     := FONT_BOLD;
  lblBrandTitle.Font.Size     := 22;
  lblBrandTitle.Font.Color    := clWhite;
  lblBrandTitle.Caption       :=
    #1573#1583#1575#1585#1577 + ' ' + #1575#1604#1576#1591#1575#1602#1575#1578 + ' ' + #1575#1604#1578#1602#1606#1610#1577;

  lblBrandSubtitle.Transparent := False;
  lblBrandSubtitle.Color       := RGB(40, 66, 53);
  lblBrandSubtitle.ParentColor := False;
  lblBrandSubtitle.Font.Name   := FONT_MAIN;
  lblBrandSubtitle.Font.Size   := 11;
  lblBrandSubtitle.Font.Color  := RGB(169, 186, 158);
  lblBrandSubtitle.Caption     :=
    #1605#1583#1610#1585#1610#1577 + ' ' + #1605#1589#1575#1604#1581 + ' ' + #1575#1604#1578#1602#1606#1610#1577;

  lblVersionLeft.Transparent   := False;
  lblVersionLeft.Color         := RGB(35, 59, 47);
  lblVersionLeft.ParentColor   := False;
  lblVersionLeft.Font.Name     := FONT_MAIN;
  lblVersionLeft.Font.Size     := 9;
  lblVersionLeft.Font.Color    := RGB(149, 163, 145);
  lblVersionLeft.Caption       := 'v' + APP_VERSION;

  // --- Form panel labels (mint background RGB(237,242,236)) ---
  lblTitle.Transparent   := False;
  lblTitle.Color         := RGB(237, 242, 236);
  lblTitle.ParentColor   := False;
  lblTitle.Font.Name     := FONT_BOLD;
  lblTitle.Font.Size     := 23;
  lblTitle.Font.Color    := RGB(30, 56, 46);
  lblTitle.Caption       := #1578#1587#1580#1610#1604 + ' ' + #1575#1604#1583#1582#1608#1604;

  lblSubtitle.Transparent   := False;
  lblSubtitle.Color         := RGB(237, 242, 236);
  lblSubtitle.ParentColor   := False;
  lblSubtitle.Font.Name     := FONT_MAIN;
  lblSubtitle.Font.Size     := 11;
  lblSubtitle.Font.Color    := RGB(95, 123, 110);
  lblSubtitle.Caption       := #1571#1583#1582#1604 + ' ' + #1576#1610#1575#1606#1575#1578#1603 + ' ' + #1604#1604#1605#1578#1575#1576#1593#1577;

  lblUserLabel.Transparent   := False;
  lblUserLabel.Color         := RGB(237, 242, 236);
  lblUserLabel.ParentColor   := False;
  lblUserLabel.Font.Name     := FONT_BOLD;
  lblUserLabel.Font.Size     := 10;
  lblUserLabel.Font.Color    := RGB(42, 70, 59);
  lblUserLabel.Caption       := #1575#1587#1605 + ' ' + #1575#1604#1605#1587#1578#1582#1583#1605;

  lblPasswordLabel.Transparent   := False;
  lblPasswordLabel.Color         := RGB(237, 242, 236);
  lblPasswordLabel.ParentColor   := False;
  lblPasswordLabel.Font.Name     := FONT_BOLD;
  lblPasswordLabel.Font.Size     := 10;
  lblPasswordLabel.Font.Color    := RGB(42, 70, 59);
  lblPasswordLabel.Caption       := #1603#1604#1605#1577 + ' ' + #1575#1604#1605#1585#1608#1585;

  edtUser.Font.Name  := FONT_MAIN;
  edtUser.Font.Size  := 11;
  edtUser.Font.Color := RGB(29, 53, 43);
  edtUser.Color      := RGB(227, 233, 224);

  edtPassword.Font.Name    := FONT_MAIN;
  edtPassword.Font.Size    := 11;
  edtPassword.Font.Color   := RGB(29, 53, 43);
  edtPassword.Color        := RGB(227, 233, 224);
  edtPassword.PasswordChar := '*';

  chkRemember.Font.Name  := FONT_BOLD;
  chkRemember.Font.Size  := 9;
  chkRemember.Font.Color := RGB(42, 70, 59);
  chkRemember.Caption    := #1578#1580#1603#1585#1606#1610;

  lblForgotPassword.Font.Name  := FONT_MAIN;
  lblForgotPassword.Font.Size  := 9;
  lblForgotPassword.Font.Color := RGB(53, 86, 72);
  lblForgotPassword.Caption    :=
    #1606#1587#1610#1578 + ' ' + #1603#1604#1605#1577 + ' ' + #1575#1604#1605#1585#1608#1585 + ' ?';

  btnLogin.Cursor := crHandPoint;
  btnLogin.Height := 48;
  btnLogin.Appearance.SimpleLayout := True;
  btnLogin.Appearance.SimpleLayoutBorder := False;
  btnLogin.Appearance.Rounding := 24;
  btnLogin.Appearance.Font.Name  := FONT_BOLD;
  btnLogin.Appearance.Font.Size  := 12;
  btnLogin.Appearance.Font.Color := clWhite;
  btnLogin.Color      := RGB(35, 66, 55);
  btnLogin.BevelColor := RGB(27, 51, 41);
  btnLogin.Caption    := #1583#1582#1608#1604 + '  ' + #10140;

  btnConfig.Cursor := crHandPoint;
  btnConfig.Height := 42;
  btnConfig.Appearance.SimpleLayout := True;
  btnConfig.Appearance.SimpleLayoutBorder := False;
  btnConfig.Appearance.Rounding := 21;
  btnConfig.Appearance.Font.Name  := FONT_BOLD;
  btnConfig.Appearance.Font.Size  := 10;
  btnConfig.Appearance.Font.Color := RGB(35, 66, 55);
  btnConfig.Color      := RGB(228, 237, 230);
  btnConfig.BevelColor := RGB(53, 86, 72);
  btnConfig.Caption    := #1573#1593#1583#1575#1583#1575#1578 + ' ' + #1575#1604#1575#1578#1589#1575#1604;

  lblVersionRight.Transparent   := False;
  lblVersionRight.Color         := RGB(237, 242, 236);
  lblVersionRight.ParentColor   := False;
  lblVersionRight.Font.Name     := FONT_MAIN;
  lblVersionRight.Font.Size     := 9;
  lblVersionRight.Font.Color    := RGB(122, 150, 135);
  lblVersionRight.Caption       := 'v' + APP_VERSION;
end;

procedure TfrmLogin.ApplyLayout;
var
  FW, FH: Integer;
begin
  FW := ClientWidth;
  FH := ClientHeight;

  pnlBrand.SetBounds(0, 0, 440, FH);
  pnlForm.SetBounds(440, 0, FW - 440, FH);

  // Brand panel children
  lblBrandTitle.SetBounds(20, 126, 400, 38);
  lblBrandSubtitle.SetBounds(20, 172, 400, 24);
  lblVersionLeft.SetBounds(24, FH - 38, 60, 20);

  // Form panel children (relative to pnlForm)
  lblTitle.SetBounds(90, 68, 360, 40);
  lblSubtitle.SetBounds(90, 114, 360, 22);
  lblUserLabel.SetBounds(90, 186, 360, 18);
  lblPasswordLabel.SetBounds(90, 272, 360, 18);
  lblVersionRight.SetBounds(90, FH - 38, 360, 20);

  svgBtnClose.SetBounds((FW - 440) - 44, 14, 30, 30);
  svgBtnMin.SetBounds((FW - 440) - 80, 14, 30, 30);

  // User input container (relative to pnlForm)
  pnlUserContainer.SetBounds(90, 208, 360, 48);
  svgUserIcon.SetBounds(4, 4, 40, 40);
  edtUser.SetBounds(52, 8, 296, 32);

  // Password input container (relative to pnlForm)
  pnlPasswordContainer.SetBounds(90, 294, 360, 48);
  svgPassIcon.SetBounds(4, 4, 40, 40);
  svgToggle.SetBounds(320, 8, 32, 32);
  edtPassword.SetBounds(52, 8, 260, 32);

  // Options row (relative to pnlForm)
  pnlOptions.SetBounds(90, 352, 360, 28);
  chkRemember.SetBounds(250, 4, 110, 20);
  lblForgotPassword.SetBounds(0, 4, 130, 20);

  // Buttons (relative to pnlForm)
  btnLogin.SetBounds(90, 396, 360, 50);
  btnConfig.SetBounds(90, 502, 360, 44);
end;

// ---------------------------------------------------------------------------
// Focus events
// ---------------------------------------------------------------------------

procedure TfrmLogin.edtUserEnter(Sender: TObject);
begin
  FUserFocused := True;
  pnlUserContainer.Invalidate;
end;

procedure TfrmLogin.edtUserExit(Sender: TObject);
begin
  FUserFocused := False;
  pnlUserContainer.Invalidate;
end;

procedure TfrmLogin.edtPasswordEnter(Sender: TObject);
begin
  FPasswordFocused := True;
  pnlPasswordContainer.Invalidate;
end;

procedure TfrmLogin.edtPasswordExit(Sender: TObject);
begin
  FPasswordFocused := False;
  pnlPasswordContainer.Invalidate;
end;

// ---------------------------------------------------------------------------
// Skia Paint procedures
// ---------------------------------------------------------------------------

procedure TfrmLogin.PaintBrand(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    var
      Paint: ISkPaint;
      Shader: ISkShader;
      PB: ISkPathBuilder;
      BadgeR: TRectF;
    begin
      // Background gradient
      Shader := TSkShader.MakeGradientLinear(
        PointF(0, 0), PointF(0, H),
        SkColor(RGB(46, 75, 62), 255), SkColor(RGB(33, 57, 47), 255));
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Shader := Shader;
      ACanvas.DrawRect(RectF(0, 0, W, H), Paint);

      // Sunlight ray 1
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Color := SkColor(clWhite, 16);
      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.15, 0); PB.LineTo(W * 0.70, 0);
      PB.LineTo(W * 1.0, H * 0.45); PB.LineTo(W * 1.0, H * 0.80);
      PB.Close;
      ACanvas.DrawPath(PB.Detach, Paint);

      // Shadow strip
      Paint.Color := SkColor(clBlack, 25);
      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.45, 0); PB.LineTo(W * 0.58, 0);
      PB.LineTo(W * 1.0, H * 0.65); PB.LineTo(W * 1.0, H * 0.78);
      PB.Close;
      ACanvas.DrawPath(PB.Detach, Paint);

      // Header badge
      BadgeR := RectF((W - 64) / 2, 46, (W + 64) / 2, 110);
      SkFillRoundRect(ACanvas, BadgeR, 18, RGB(27, 54, 42), 255);
      SkDrawRoundRectBorder(ACanvas, BadgeR, 18, RGB(74, 93, 78), 140, 1.2);
      SkDrawSvg(ACanvas, SvgForGlyph(G_DB_GEAR),
        RectF((W - 36) / 2, 61, (W + 36) / 2, 97), clWhite, 255);

      // Title underline accent
      SkFillRoundRect(ACanvas,
        RectF((W - 46) / 2, 204, (W + 46) / 2, 207), 1.5, RGB(76, 112, 94), 220);

      // Shelf/floor area
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Color := SkColor(RGB(26, 39, 32), 180);
      ACanvas.DrawRect(RectF(0, H - 56, W, H), Paint);

      // Pot body (trapezoid)
      PB := TSkPathBuilder.Create;
      PB.MoveTo((W - 120) / 2, H - 190);
      PB.LineTo((W + 120) / 2, H - 190);
      PB.LineTo((W + 90) / 2, H - 65);
      PB.LineTo((W - 90) / 2, H - 65);
      PB.Close;
      Shader := TSkShader.MakeGradientLinear(
        PointF((W - 120) / 2, H - 190), PointF((W + 120) / 2, H - 65),
        SkColor(RGB(104, 128, 115), 255), SkColor(RGB(56, 78, 66), 255));
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Shader := Shader;
      ACanvas.DrawPath(PB.Detach, Paint);

      // Pot rim
      SkFillGradientRoundRect(ACanvas,
        RectF((W - 128) / 2, H - 196, (W + 128) / 2, H - 184), 6,
        RGB(122, 148, 134), RGB(69, 94, 81), 255);

      // Plant stems
      Paint := TSkPaint.Create(TSkPaintStyle.Stroke);
      Paint.AntiAlias := True;
      Paint.StrokeWidth := 5.0;
      Paint.Color := SkColor(RGB(72, 115, 88), 255);

      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.44, H - 190);
      PB.QuadTo(W * 0.35, H - 280, W * 0.28, H - 360);
      ACanvas.DrawPath(PB.Detach, Paint);

      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.50, H - 190);
      PB.QuadTo(W * 0.48, H - 310, W * 0.42, H - 420);
      ACanvas.DrawPath(PB.Detach, Paint);

      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.54, H - 190);
      PB.QuadTo(W * 0.66, H - 250, W * 0.74, H - 300);
      ACanvas.DrawPath(PB.Detach, Paint);

      // Main large leaf
      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.42, H - 430);
      PB.CubicTo(W * 0.12, H - 410, W * 0.15, H - 290, W * 0.42, H - 240);
      PB.CubicTo(W * 0.70, H - 290, W * 0.72, H - 410, W * 0.42, H - 430);
      PB.Close;
      Shader := TSkShader.MakeGradientLinear(
        PointF(W * 0.42, H - 430), PointF(W * 0.42, H - 240),
        SkColor(RGB(123, 179, 137), 255), SkColor(RGB(59, 100, 71), 255));
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Shader := Shader;
      ACanvas.DrawPath(PB.Detach, Paint);

      // Leaf midrib & veins
      Paint := TSkPaint.Create(TSkPaintStyle.Stroke);
      Paint.AntiAlias := True;
      Paint.StrokeWidth := 2.0;
      Paint.Color := SkColor(RGB(40, 74, 51), 200);
      ACanvas.DrawLine(PointF(W * 0.42, H - 430), PointF(W * 0.42, H - 240), Paint);
      ACanvas.DrawLine(PointF(W * 0.42, H - 380), PointF(W * 0.28, H - 395), Paint);
      ACanvas.DrawLine(PointF(W * 0.42, H - 380), PointF(W * 0.56, H - 395), Paint);
      ACanvas.DrawLine(PointF(W * 0.42, H - 340), PointF(W * 0.25, H - 350), Paint);
      ACanvas.DrawLine(PointF(W * 0.42, H - 340), PointF(W * 0.59, H - 350), Paint);

      // Side leaf
      PB := TSkPathBuilder.Create;
      PB.MoveTo(W * 0.74, H - 305);
      PB.CubicTo(W * 0.50, H - 320, W * 0.52, H - 220, W * 0.74, H - 190);
      PB.CubicTo(W * 0.94, H - 220, W * 0.92, H - 320, W * 0.74, H - 305);
      PB.Close;
      Shader := TSkShader.MakeGradientLinear(
        PointF(W * 0.74, H - 305), PointF(W * 0.74, H - 190),
        SkColor(RGB(106, 160, 120), 255), SkColor(RGB(49, 84, 58), 255));
      Paint := TSkPaint.Create(TSkPaintStyle.Fill);
      Paint.AntiAlias := True;
      Paint.Shader := Shader;
      ACanvas.DrawPath(PB.Detach, Paint);
    end);
end;

procedure TfrmLogin.PaintForm(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    var
      Paint: ISkPaint;
    begin
      ACanvas.Clear(SkColor(RGB(237, 242, 236)));

      Paint := TSkPaint.Create(TSkPaintStyle.Stroke);
      Paint.AntiAlias := True;
      Paint.Color := SkColor(RGB(182, 200, 188), 200);
      Paint.StrokeWidth := 1.0;

      // Leaf divider
      ACanvas.DrawLine(PointF(W * 0.18, 158), PointF(W * 0.42, 158), Paint);
      ACanvas.DrawLine(PointF(W * 0.58, 158), PointF(W * 0.82, 158), Paint);
      SkDrawSvg(ACanvas, SvgForGlyph(G_LEAF),
        RectF((W - 22) / 2, 147, (W + 22) / 2, 169), RGB(64, 99, 83), 255);

      // "Or" divider
      ACanvas.DrawLine(PointF(W * 0.18, 482), PointF(W * 0.42, 482), Paint);
      ACanvas.DrawLine(PointF(W * 0.58, 482), PointF(W * 0.82, 482), Paint);
    end);
end;

procedure TfrmLogin.PaintUserCont(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
  BClr: TColor;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;
  if FUserFocused then BClr := RGB(53, 86, 72) else BClr := RGB(178, 205, 189);

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 10, RGB(227, 233, 224), 255);
      SkDrawRoundRectBorder(ACanvas, RectF(0, 0, W, H), 10, BClr, 255, 1.2);
    end);
end;

procedure TfrmLogin.PaintPassCont(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
  BClr: TColor;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;
  if FPasswordFocused then BClr := RGB(53, 86, 72) else BClr := RGB(178, 205, 189);

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 10, RGB(227, 233, 224), 255);
      SkDrawRoundRectBorder(ACanvas, RectF(0, 0, W, H), 10, BClr, 255, 1.2);
    end);
end;

// ---------------------------------------------------------------------------
// Icon OnDraw handlers (Skia)
// ---------------------------------------------------------------------------

procedure TfrmLogin.DrawBtnClose(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      if FCloseHover then
        SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 6, RGB(75, 9, 201), 255);
      SkDrawSvg(ACanvas, SvgForGlyph(G_CLOSE),
        RectF(0, 0, W, H), RGB(100, 130, 115), 255);
    end);
end;

procedure TfrmLogin.DrawBtnMin(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      if FMinHover then
        SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 6, RGB(132, 202, 209), 255);
      SkDrawSvg(ACanvas, SvgForGlyph(G_MINIMIZE),
        RectF(0, 0, W, H), RGB(100, 130, 115), 255);
    end);
end;

procedure TfrmLogin.DrawUserIcon(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 8, RGB(53, 74, 69), 255);
      SkDrawSvg(ACanvas, SvgForGlyph(G_USER),
        RectF(0, 0, W, H), clWhite, 255);
    end);
end;

procedure TfrmLogin.DrawPassIcon(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      SkFillRoundRect(ACanvas, RectF(0, 0, W, H), 8, RGB(53, 74, 69), 255);
      SkDrawSvg(ACanvas, SvgForGlyph(G_LOCK),
        RectF(0, 0, W, H), clWhite, 255);
    end);
end;

procedure TfrmLogin.DrawToggle(Sender: TObject; Canvas: TCanvas; Rect: TRect);
var
  W, H: Integer;
  G: string;
begin
  W := Rect.Width; H := Rect.Height;
  if (W <= 0) or (H <= 0) then Exit;

  if FShowPassword then G := SvgForGlyph(G_EYE_OFF)
  else G := SvgForGlyph(G_EYE);

  SkiaDrawToCanvas(Canvas, W, H,
    procedure(const ACanvas: ISkCanvas)
    begin
      SkDrawSvg(ACanvas, G, RectF(0, 0, W, H), RGB(53, 86, 72), 255);
    end);
end;

procedure TfrmLogin.svgCloseMouseEnter(Sender: TObject);
begin
  FCloseHover := True;
  svgBtnClose.Invalidate;
end;

procedure TfrmLogin.svgCloseMouseLeave(Sender: TObject);
begin
  FCloseHover := False;
  svgBtnClose.Invalidate;
end;

procedure TfrmLogin.svgMinMouseEnter(Sender: TObject);
begin
  FMinHover := True;
  svgBtnMin.Invalidate;
end;

procedure TfrmLogin.svgMinMouseLeave(Sender: TObject);
begin
  FMinHover := False;
  svgBtnMin.Invalidate;
end;

// ---------------------------------------------------------------------------
// Control events
// ---------------------------------------------------------------------------

procedure TfrmLogin.pnlTogglePasswordClick(Sender: TObject);
begin
  FShowPassword := not FShowPassword;
  if FShowPassword then edtPassword.PasswordChar := #0
  else edtPassword.PasswordChar := '*';
  svgToggle.Invalidate;
end;

procedure TfrmLogin.lblForgotPasswordClick(Sender: TObject);
begin
  ShowAvertissement(
    #1610#1585#1580#1609 + ' ' + #1575#1604#1578#1608#1575#1589#1604 + ' ' +
    #1605#1593 + ' ' + #1605#1587#1572#1608#1604 + ' ' + #1575#1604#1606#1592#1575#1605);
end;

procedure TfrmLogin.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmLogin.btnMinimizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  if Trim(edtUser.Text) = '' then
  begin
    ShowAvertissement(
      #1575#1604#1585#1580#1575#1569 + ' ' + #1573#1583#1582#1575#1604 + ' ' + #1575#1587#1605 + ' ' + #1575#1604#1605#1587#1578#1582#1583#1605);
    edtUser.SetFocus;
    Exit;
  end;
  if Trim(edtPassword.Text) = '' then
  begin
    ShowAvertissement(
      #1575#1604#1585#1580#1575#1569 + ' ' + #1573#1583#1582#1575#1604 + ' ' + #1603#1604#1605#1577 + ' ' + #1575#1604#1605#1585#1608#1585);
    edtPassword.SetFocus;
    Exit;
  end;

  ShowLoadingOverlay(#1580#1575#1585#1610 + ' ' + #1575#1604#1578#1581#1602#1602 + '...');
  try
    try
      if not dmMain.Connecter then
      begin
        HideLoadingOverlay;
        ShowErreur(#1601#1588#1604 + ' ' + #1575#1604#1575#1578#1589#1575#1604 + ' ' + #1576#1602#1575#1593#1583#1577 + ' ' + #1575#1604#1576#1610#1575#1606#1575#1578);
        Exit;
      end;
      if dmMain.Authentifier(Trim(edtUser.Text), Trim(edtPassword.Text)) then
      begin
        SaveUserIfRemembered;
        FLoginOK := True;
        ModalResult := mrOk;
      end
      else
      begin
        HideLoadingOverlay;
        ShowErreur(
          #1575#1587#1605 + ' ' + #1575#1604#1605#1587#1578#1582#1583#1605 + ' ' + #1571#1608 + ' ' +
          #1603#1604#1605#1577 + ' ' + #1575#1604#1605#1585#1608#1585 + ' ' + #1594#1610#1585 + ' ' + #1589#1581#1610#1581#1577);
        edtPassword.SelectAll;
        edtPassword.SetFocus;
      end;
    except
      on E: Exception do
      begin
        HideLoadingOverlay;
        ShowErreur('Erreur: ' + E.Message);
      end;
    end;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmLogin.btnConfigClick(Sender: TObject);
begin
  AfficherConfigConnexion;
end;

procedure TfrmLogin.btnTestConnClick(Sender: TObject);
begin
  if Assigned(GCfgSrv) then
    dmMain.FDConnection1.Params.Values['Server'] := GCfgSrv.Text;
  if Assigned(GCfgDb) then
    dmMain.FDConnection1.Params.Values['Database'] := GCfgDb.Text;
  if Assigned(GCfgUsr) then
    dmMain.FDConnection1.Params.Values['User_Name'] := GCfgUsr.Text;
  if Assigned(GCfgPwd) then
    dmMain.FDConnection1.Params.Values['Password'] := GCfgPwd.Text;
  if Assigned(GCfgWin) then
  begin
    if GCfgWin.Checked then
      dmMain.FDConnection1.Params.Values['OSAuthent'] := 'Yes'
    else
      dmMain.FDConnection1.Params.Values['OSAuthent'] := 'No';
  end;

  ShowLoadingOverlay(#1580#1575#1585#1610 + ' ' + #1575#1604#1575#1582#1578#1576#1575#1585 + '...');
  try
    try
      if dmMain.Connecter then
      begin
        HideLoadingOverlay;
        ShowSucces(#1578#1605 + ' ' + #1575#1604#1575#1578#1589#1575#1604 + ' ' + #1576#1606#1580#1575#1581);
        dmMain.Deconnecter;
      end
      else
      begin
        HideLoadingOverlay;
        ShowErreur(#1601#1588#1604 + ' ' + #1575#1604#1575#1578#1589#1575#1604);
      end;
    except
      on E: Exception do begin HideLoadingOverlay; ShowErreur(E.Message); end;
    end;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmLogin.AfficherConfigConnexion;
var
  Dlg: TForm;
  btnSave, btnTest, btnCancel: TButton;
  lblS, lblD, lblU, lblP: TLabel;
  Ini: TIniFile;
  IniPath: string;
  Y: Integer;
begin
  IniPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  Dlg := TForm.Create(Self);
  try
    Dlg.Caption := #1573#1593#1583#1575#1583#1575#1578 + ' ' + #1575#1604#1575#1578#1589#1575#1604;
    Dlg.Width := 420; Dlg.Height := 380;
    Dlg.Position := poScreenCenter;
    Dlg.BorderStyle := bsDialog;
    Dlg.BiDiMode := bdRightToLeft;
    Dlg.Font.Name := FONT_MAIN;
    Dlg.Font.Size := FONT_SIZE_BODY;
    Dlg.Color := CLR_BG_SECONDARY;
    Y := 20;

    lblS := TLabel.Create(Dlg); lblS.Parent := Dlg;
    lblS.Left := 20; lblS.Top := Y;
    lblS.Caption := ':' + #1575#1604#1582#1575#1583#1605;
    AppliquerThemeLabel(lblS, False, False); Inc(Y, 24);

    GCfgSrv := TEdit.Create(Dlg); GCfgSrv.Parent := Dlg;
    GCfgSrv.Left := 20; GCfgSrv.Top := Y; GCfgSrv.Width := 370;
    GCfgSrv.Text := 'localhost'; AppliquerThemeEdit(GCfgSrv); Inc(Y, 46);

    lblD := TLabel.Create(Dlg); lblD.Parent := Dlg;
    lblD.Left := 20; lblD.Top := Y;
    lblD.Caption := ':' + #1602#1575#1593#1583#1577 + ' ' + #1575#1604#1576#1610#1575#1606#1575#1578;
    AppliquerThemeLabel(lblD, False, False); Inc(Y, 24);

    GCfgDb := TEdit.Create(Dlg); GCfgDb.Parent := Dlg;
    GCfgDb.Left := 20; GCfgDb.Top := Y; GCfgDb.Width := 370;
    GCfgDb.Text := 'GestionFichesTechniques';
    AppliquerThemeEdit(GCfgDb); Inc(Y, 46);

    GCfgWin := TCheckBox.Create(Dlg); GCfgWin.Parent := Dlg;
    GCfgWin.Left := 20; GCfgWin.Top := Y; GCfgWin.Width := 370;
    GCfgWin.Caption := #1605#1589#1575#1583#1602#1577 + ' ' + #1608#1610#1606#1583#1608#1586;
    GCfgWin.Font.Color := CLR_TEXT_MAIN;
    GCfgWin.Checked := True; Inc(Y, 34);

    lblU := TLabel.Create(Dlg); lblU.Parent := Dlg;
    lblU.Left := 20; lblU.Top := Y; lblU.Caption := 'User:';
    AppliquerThemeLabel(lblU, False, False);
    lblP := TLabel.Create(Dlg); lblP.Parent := Dlg;
    lblP.Left := 210; lblP.Top := Y; lblP.Caption := 'Pass:';
    AppliquerThemeLabel(lblP, False, False); Inc(Y, 24);

    GCfgUsr := TEdit.Create(Dlg); GCfgUsr.Parent := Dlg;
    GCfgUsr.Left := 20; GCfgUsr.Top := Y; GCfgUsr.Width := 170;
    GCfgUsr.Text := 'sa'; AppliquerThemeEdit(GCfgUsr);

    GCfgPwd := TEdit.Create(Dlg); GCfgPwd.Parent := Dlg;
    GCfgPwd.Left := 210; GCfgPwd.Top := Y; GCfgPwd.Width := 170;
    GCfgPwd.PasswordChar := '*'; AppliquerThemeEdit(GCfgPwd); Inc(Y, 56);

    if FileExists(IniPath) then
    begin
      Ini := TIniFile.Create(IniPath);
      try
        GCfgSrv.Text := Ini.ReadString('Database', 'Server', 'localhost');
        GCfgDb.Text  := Ini.ReadString('Database', 'Database', 'GestionFichesTechniques');
        GCfgWin.Checked := Ini.ReadBool('Database', 'WindowsAuth', True);
        GCfgUsr.Text := Ini.ReadString('Database', 'User', 'sa');
        GCfgPwd.Text := Ini.ReadString('Database', 'Password', '');
      finally Ini.Free; end;
    end;

    btnTest := TButton.Create(Dlg); btnTest.Parent := Dlg;
    btnTest.Left := 20; btnTest.Top := Y; btnTest.Width := 110;
    btnTest.Caption := #1575#1582#1578#1576#1575#1585 + ' ' + #1575#1604#1575#1578#1589#1575#1604;
    AppliquerThemeBouton(btnTest, bsSecondary);
    btnTest.OnClick := btnTestConnClick;

    btnSave := TButton.Create(Dlg); btnSave.Parent := Dlg;
    btnSave.Left := 150; btnSave.Top := Y; btnSave.Width := 110;
    btnSave.Caption := #1581#1601#1592;
    AppliquerThemeBouton(btnSave, bsPrimary);
    btnSave.ModalResult := mrOk;

    btnCancel := TButton.Create(Dlg); btnCancel.Parent := Dlg;
    btnCancel.Left := 280; btnCancel.Top := Y; btnCancel.Width := 110;
    btnCancel.Caption := #1573#1604#1594#1575#1569;
    AppliquerThemeBouton(btnCancel, bsGhost);
    btnCancel.ModalResult := mrCancel;

    if Dlg.ShowModal = mrOk then
    begin
      ShowLoadingOverlay(#1581#1601#1592 + '...');
      try
        Ini := TIniFile.Create(IniPath);
        try
          Ini.WriteString('Database', 'Server',      GCfgSrv.Text);
          Ini.WriteString('Database', 'Database',    GCfgDb.Text);
          Ini.WriteBool  ('Database', 'WindowsAuth', GCfgWin.Checked);
          Ini.WriteString('Database', 'User',        GCfgUsr.Text);
          Ini.WriteString('Database', 'Password',    GCfgPwd.Text);
        finally Ini.Free; end;
        dmMain.FDConnection1.Params.Values['Server']    := GCfgSrv.Text;
        dmMain.FDConnection1.Params.Values['Database']  := GCfgDb.Text;
        dmMain.FDConnection1.Params.Values['User_Name'] := GCfgUsr.Text;
        dmMain.FDConnection1.Params.Values['Password']  := GCfgPwd.Text;
        if GCfgWin.Checked then
          dmMain.FDConnection1.Params.Values['OSAuthent'] := 'Yes'
        else
          dmMain.FDConnection1.Params.Values['OSAuthent'] := 'No';
      finally HideLoadingOverlay; end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmLogin.FormKeyHandler(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and not (ssShift in Shift) then
  begin
    Key := 0;
    btnLoginClick(nil);
  end;
end;

initialization

end.
