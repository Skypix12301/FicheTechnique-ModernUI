unit uGraphicsGDIP;

{
  ==========================================================================
  uGraphicsGDIP.pas - Infrastructure de rendu GDI+ (sans dépendance externe)
  ==========================================================================
  Fournit des helpers réutilisables pour un rendu vectoriel de qualité :
  - Conversion TColor -> ARGB (GPColor)
  - Chemins à coins arrondis (BuildRoundRectPath)
  - Ombres douces multi-couches (DrawSoftShadow)
  - Remplissages plein / dégradé à coins arrondis
  - Dessin de texte haute qualité (anti-alias + ClearType)
  - Panneau "verre" (glass) léger

  L'initialisation GDI+ est gérée automatiquement par Winapi.GDIPOBJ
  (sections initialization/finalization de l'unité VCL).
  ==========================================================================
}

interface

uses
  Winapi.Windows, System.Types, System.Math, System.UITypes,
  Vcl.Graphics,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  TFontStyleGP = (fgRegular, fgBold, fgItalic, fgBoldItalic);
  TTextAlignGP = (taLeftGP, taCenterGP, taRightGP);

// Conversion couleur VCL (BGR) -> ARGB GDI+
function GPColor(C: TColor; Alpha: Byte = 255): ARGB;
function LightenColor(C: TColor; Amount: Integer): TColor;
function DarkenColor(C: TColor; Amount: Integer): TColor;
function BlendColor(C1, C2: TColor; Ratio: Single): TColor;

// Chemins
procedure BuildRoundRectPath(APath: TGPGraphicsPath; const R: TGPRectF;
  Radius: Single);

// Remplissages
procedure FillRoundRect(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Color: TColor; Alpha: Byte = 255);
procedure DrawRoundRectBorder(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Color: TColor; Alpha: Byte = 255; PenWidth: Single = 1.0);
procedure FillGradientRoundRect(G: TGPGraphics; const R: TGPRectF;
  Radius: Single; ColorTop, ColorBottom: TColor; Alpha: Byte = 255);

// Ombre douce (multi-couches, dégradé d'alpha)
procedure DrawSoftShadow(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Layers: Integer; ShadowColor: TColor; MaxAlpha: Byte;
  OffsetX: Single = 0; OffsetY: Single = 3);

// Reflet supérieur (effet 3D léger)
procedure DrawTopSheen(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Alpha: Byte = 40);

// Texte
procedure DrawTextGP(G: TGPGraphics; const AText: string; const R: TGPRectF;
  const FontName: string; FontSize: Single; Style: TFontStyleGP;
  Color: TColor; HAlign: TTextAlignGP; VCenter: Boolean = True;
  Alpha: Byte = 255);

// Configuration standard d'un contexte GDI+ (qualité maximale)
procedure SetupHighQuality(G: TGPGraphics);

implementation

function GPColor(C: TColor; Alpha: Byte): ARGB;
var
  RGBv: Longint;
begin
  RGBv := ColorToRGB(C);
  Result := MakeColor(Alpha, GetRValue(RGBv), GetGValue(RGBv), GetBValue(RGBv));
end;

function ClampByte(V: Integer): Byte;
begin
  if V < 0 then Result := 0
  else if V > 255 then Result := 255
  else Result := V;
end;

function LightenColor(C: TColor; Amount: Integer): TColor;
var
  RGBv: Longint;
begin
  RGBv := ColorToRGB(C);
  Result := RGB(
    ClampByte(GetRValue(RGBv) + Amount),
    ClampByte(GetGValue(RGBv) + Amount),
    ClampByte(GetBValue(RGBv) + Amount));
end;

function DarkenColor(C: TColor; Amount: Integer): TColor;
begin
  Result := LightenColor(C, -Amount);
end;

function BlendColor(C1, C2: TColor; Ratio: Single): TColor;
var
  R1, R2: Longint;
begin
  if Ratio < 0 then Ratio := 0 else if Ratio > 1 then Ratio := 1;
  R1 := ColorToRGB(C1);
  R2 := ColorToRGB(C2);
  Result := RGB(
    Round(GetRValue(R1) + (GetRValue(R2) - GetRValue(R1)) * Ratio),
    Round(GetGValue(R1) + (GetGValue(R2) - GetGValue(R1)) * Ratio),
    Round(GetBValue(R1) + (GetBValue(R2) - GetBValue(R1)) * Ratio));
end;

procedure BuildRoundRectPath(APath: TGPGraphicsPath; const R: TGPRectF;
  Radius: Single);
var
  d: Single;
begin
  APath.Reset;
  if Radius <= 0.5 then
  begin
    APath.AddRectangle(R);
    Exit;
  end;
  d := Radius * 2;
  if d > R.Width then d := R.Width;
  if d > R.Height then d := R.Height;

  APath.AddArc(R.X, R.Y, d, d, 180, 90);
  APath.AddArc(R.X + R.Width - d, R.Y, d, d, 270, 90);
  APath.AddArc(R.X + R.Width - d, R.Y + R.Height - d, d, d, 0, 90);
  APath.AddArc(R.X, R.Y + R.Height - d, d, d, 90, 90);
  APath.CloseFigure;
end;

procedure FillRoundRect(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Color: TColor; Alpha: Byte);
var
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
begin
  Path := TGPGraphicsPath.Create;
  try
    BuildRoundRectPath(Path, R, Radius);
    Brush := TGPSolidBrush.Create(GPColor(Color, Alpha));
    try
      G.FillPath(Brush, Path);
    finally
      Brush.Free;
    end;
  finally
    Path.Free;
  end;
end;

procedure DrawRoundRectBorder(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Color: TColor; Alpha: Byte; PenWidth: Single);
var
  Path: TGPGraphicsPath;
  Pen: TGPPen;
begin
  Path := TGPGraphicsPath.Create;
  try
    BuildRoundRectPath(Path, R, Radius);
    Pen := TGPPen.Create(GPColor(Color, Alpha), PenWidth);
    try
      G.DrawPath(Pen, Path);
    finally
      Pen.Free;
    end;
  finally
    Path.Free;
  end;
end;

procedure FillGradientRoundRect(G: TGPGraphics; const R: TGPRectF;
  Radius: Single; ColorTop, ColorBottom: TColor; Alpha: Byte);
var
  Path: TGPGraphicsPath;
  Brush: TGPLinearGradientBrush;
  GR: TGPRectF;
begin
  Path := TGPGraphicsPath.Create;
  try
    BuildRoundRectPath(Path, R, Radius);
    // Léger débordement pour éviter les artefacts de bordure du dégradé
    GR := MakeRect(R.X, R.Y - 1, R.Width, R.Height + 2);
    Brush := TGPLinearGradientBrush.Create(GR,
      GPColor(ColorTop, Alpha), GPColor(ColorBottom, Alpha), 90.0);
    try
      G.FillPath(Brush, Path);
    finally
      Brush.Free;
    end;
  finally
    Path.Free;
  end;
end;

procedure DrawSoftShadow(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Layers: Integer; ShadowColor: TColor; MaxAlpha: Byte; OffsetX, OffsetY: Single);
var
  i: Integer;
  sr: TGPRectF;
  Path: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  a: Byte;
  grow: Single;
begin
  if Layers < 1 then Layers := 1;
  for i := Layers downto 1 do
  begin
    grow := i * 1.6;
    sr := MakeRect(R.X - grow + OffsetX, R.Y - grow + OffsetY,
      R.Width + grow * 2, R.Height + grow * 2);
    // Les couches externes sont plus transparentes -> effet de flou
    a := Round(MaxAlpha * (1.0 - (i - 1) / Layers) / Layers * 2.2);
    if a = 0 then a := 1;
    Path := TGPGraphicsPath.Create;
    try
      BuildRoundRectPath(Path, sr, Radius + grow);
      Brush := TGPSolidBrush.Create(GPColor(ShadowColor, a));
      try
        G.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;
    finally
      Path.Free;
    end;
  end;
end;

procedure DrawTopSheen(G: TGPGraphics; const R: TGPRectF; Radius: Single;
  Alpha: Byte);
var
  Path: TGPGraphicsPath;
  Brush: TGPLinearGradientBrush;
  SheenR: TGPRectF;
begin
  SheenR := MakeRect(R.X, R.Y, R.Width, R.Height * 0.45);
  Path := TGPGraphicsPath.Create;
  try
    BuildRoundRectPath(Path, R, Radius);
    Brush := TGPLinearGradientBrush.Create(
      MakeRect(SheenR.X, SheenR.Y - 1, SheenR.Width, SheenR.Height + 2),
      MakeColor(Alpha, 255, 255, 255),
      MakeColor(0, 255, 255, 255), 90.0);
    try
      G.SetClip(Path);
      G.FillRectangle(Brush, SheenR);
      G.ResetClip;
    finally
      Brush.Free;
    end;
  finally
    Path.Free;
  end;
end;

procedure DrawTextGP(G: TGPGraphics; const AText: string; const R: TGPRectF;
  const FontName: string; FontSize: Single; Style: TFontStyleGP;
  Color: TColor; HAlign: TTextAlignGP; VCenter: Boolean; Alpha: Byte);
var
  Family: TGPFontFamily;
  Font: TGPFont;
  Fmt: TGPStringFormat;
  Brush: TGPSolidBrush;
  GpStyle: Integer;
begin
  case Style of
    fgBold: GpStyle := FontStyleBold;
    fgItalic: GpStyle := FontStyleItalic;
    fgBoldItalic: GpStyle := FontStyleBold or FontStyleItalic;
  else
    GpStyle := FontStyleRegular;
  end;

  Family := TGPFontFamily.Create(FontName);
  try
    if Family.GetLastStatus <> Ok then
    begin
      Family.Free;
      Family := TGPFontFamily.Create('Segoe UI');
    end;
    Font := TGPFont.Create(Family, FontSize, GpStyle, UnitPixel);
    try
      Fmt := TGPStringFormat.Create;
      try
        case HAlign of
          taCenterGP: Fmt.SetAlignment(StringAlignmentCenter);
          taRightGP: Fmt.SetAlignment(StringAlignmentFar);
        else
          Fmt.SetAlignment(StringAlignmentNear);
        end;
        if VCenter then
          Fmt.SetLineAlignment(StringAlignmentCenter)
        else
          Fmt.SetLineAlignment(StringAlignmentNear);
        Fmt.SetFormatFlags(StringFormatFlagsNoWrap);

        Brush := TGPSolidBrush.Create(GPColor(Color, Alpha));
        try
          G.DrawString(AText, -1, Font, R, Fmt, Brush);
        finally
          Brush.Free;
        end;
      finally
        Fmt.Free;
      end;
    finally
      Font.Free;
    end;
  finally
    Family.Free;
  end;
end;

procedure SetupHighQuality(G: TGPGraphics);
begin
  G.SetSmoothingMode(SmoothingModeAntiAlias);
  G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
  G.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  G.SetInterpolationMode(InterpolationModeHighQualityBicubic);
end;

end.
