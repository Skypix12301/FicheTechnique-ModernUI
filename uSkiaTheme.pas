unit uSkiaTheme;

{
  ==========================================================================
  uSkiaTheme.pas - Infrastructure de rendu Skia4Delphi (sans GDI+)
  ==========================================================================
  Remplace uGraphicsGDIP pour le dessin vectoriel haute qualité via
  System.Skia. Fournit des helpers équivalents aux anciens helpers GDI+ :
  - Conversion TColor -> TAlphaColor (SkColor)
  - Coins arrondis (SkRoundRect / Fill / Border)
  - Dégradé vertical à coins arrondis (SkFillGradientRoundRect)
  - Ombre douce via blur mask filter (SkDrawSoftShadow)
  - Helpers de couleurs (BlendColor / LightenColor / DarkenColor)
  - Rendu sur TCanvas VCL via TBitmap.SkiaDraw (SkiaDrawToCanvas)

  Utilisation typique (FormPaint) :
    SkiaDrawToCanvas(Canvas, ClientWidth, ClientHeight,
      procedure(const ACanvas: ISkCanvas)
      begin
        ACanvas.Clear(SkColor(CLR_BG_MAIN));
        SkFillRoundRect(ACanvas, R, Radius, ActiveTheme.Surface, 255);
      end);
  ==========================================================================
}

interface

uses
  Winapi.Windows, System.Types, System.Math, System.UITypes,
  Vcl.Graphics,
  System.Skia, Vcl.Skia;

// Conversion couleur VCL (BGR) -> ARGB Skia
function SkColor(C: TColor; Alpha: Byte = 255): TAlphaColor;

// Helpers de couleurs (équivalents uGraphicsGDIP)
function LightenColor(C: TColor; Amount: Integer): TColor;
function DarkenColor(C: TColor; Amount: Integer): TColor;
function BlendColor(C1, C2: TColor; Ratio: Single): TColor;

// Coins arrondis (ISkRoundRect prêt à l'emploi)
function SkRoundRect(const R: TRectF; Radius: Single): ISkRoundRect;

// Remplissages
procedure SkFillRoundRect(ACanvas: ISkCanvas; const R: TRectF; Radius: Single;
  Color: TColor; Alpha: Byte = 255);
procedure SkDrawRoundRectBorder(ACanvas: ISkCanvas; const R: TRectF;
  Radius: Single; Color: TColor; Alpha: Byte = 255; PenWidth: Single = 1.0);
procedure SkFillGradientRoundRect(ACanvas: ISkCanvas; const R: TRectF;
  Radius: Single; ColorTop, ColorBottom: TColor; Alpha: Byte = 255);

// Ombre douce (blur mask filter)
procedure SkDrawSoftShadow(ACanvas: ISkCanvas; const R: TRectF; Radius: Single;
  ShadowColor: TColor; MaxAlpha: Byte;
  OffsetX: Single = 0; OffsetY: Single = 3; Sigma: Single = 6);

// Rendu Skia sur un TCanvas VCL (via TBitmap offscreen)
procedure SkiaDrawToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer;
  const AProc: TSkDrawProc);

implementation

function SkColor(C: TColor; Alpha: Byte): TAlphaColor;
var
  RGBv: Longint;
begin
  RGBv := ColorToRGB(C);
  Result := TAlphaColor((TAlphaColor(Alpha) shl 24) or
    (TAlphaColor(GetRValue(RGBv)) shl 16) or
    (TAlphaColor(GetGValue(RGBv)) shl 8) or
    TAlphaColor(GetBValue(RGBv)));
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

function SkRoundRect(const R: TRectF; Radius: Single): ISkRoundRect;
var
  RR: ISkRoundRect;
begin
  RR := TSkRoundRect.Create(R, Radius, Radius);
  Result := RR;
end;

procedure SkFillRoundRect(ACanvas: ISkCanvas; const R: TRectF; Radius: Single;
  Color: TColor; Alpha: Byte);
var
  Paint: ISkPaint;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Paint.Color := SkColor(Color, Alpha);
  ACanvas.DrawRoundRect(R, Radius, Radius, Paint);
end;

procedure SkDrawRoundRectBorder(ACanvas: ISkCanvas; const R: TRectF;
  Radius: Single; Color: TColor; Alpha: Byte; PenWidth: Single);
var
  Paint: ISkPaint;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Stroke);
  Paint.AntiAlias := True;
  Paint.Color := SkColor(Color, Alpha);
  Paint.StrokeWidth := PenWidth;
  ACanvas.DrawRoundRect(R, Radius, Radius, Paint);
end;

procedure SkFillGradientRoundRect(ACanvas: ISkCanvas; const R: TRectF;
  Radius: Single; ColorTop, ColorBottom: TColor; Alpha: Byte);
var
  Paint: ISkPaint;
  Shader: ISkShader;
begin
  Shader := TSkShader.MakeGradientLinear(
    PointF(R.Left, R.Top), PointF(R.Left, R.Bottom),
    SkColor(ColorTop, Alpha), SkColor(ColorBottom, Alpha));
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Paint.Shader := Shader;
  ACanvas.DrawRoundRect(SkRoundRect(R, Radius), Paint);
end;

procedure SkDrawSoftShadow(ACanvas: ISkCanvas; const R: TRectF; Radius: Single;
  ShadowColor: TColor; MaxAlpha: Byte; OffsetX, OffsetY, Sigma: Single);
var
  Paint: ISkPaint;
  SR: TRectF;
begin
  Paint := TSkPaint.Create(TSkPaintStyle.Fill);
  Paint.AntiAlias := True;
  Paint.Color := SkColor(ShadowColor, MaxAlpha);
  Paint.MaskFilter := TSkMaskFilter.MakeBlur(TSkBlurStyle.Normal, Sigma);
  SR := RectF(R.Left + OffsetX, R.Top + OffsetY, R.Right + OffsetX, R.Bottom + OffsetY);
  ACanvas.DrawRoundRect(SR, Radius, Radius, Paint);
end;

procedure SkiaDrawToCanvas(ACanvas: TCanvas; AWidth, AHeight: Integer;
  const AProc: TSkDrawProc);
var
  Bmp: TBitmap;
begin
  if (AWidth <= 0) or (AHeight <= 0) then Exit;
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(AWidth, AHeight);
    Bmp.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
        if Assigned(AProc) then
          AProc(ACanvas);
      end);
    ACanvas.Draw(0, 0, Bmp);
  finally
    Bmp.Free;
  end;
end;

end.
