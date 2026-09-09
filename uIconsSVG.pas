unit uIconsSVG;

{
  ==========================================================================
  uIconsSVG.pas - Icônes SVG rendues par Skia (teintables), avec cache
  ==========================================================================
  - Fournit une source SVG monochrome (style Feather) pour chaque glyphe
    Segoe MDL2 utilisé par l'application (mapping par codepoint).
  - Rasterise le SVG via Skia (TSkSvgBrush + TSkSurface), le teinte via
    OverrideColor, puis expose un TGPBitmap (PNG -> alpha correct) mis en
    cache par (svg, taille, couleur) pour composition dans les Paint GDI+.
  Dépend de sk4d.dll (fournie avec RAD Studio), déployée à côté de l'exe.
  ==========================================================================
}

interface

uses
  Winapi.Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Vcl.Graphics, System.UITypes, System.Types, System.Skia, Vcl.Skia;

const
  G_HOME     = #$E80F;
  G_LIST     = #$E8FD;
  G_ADD      = #$E710;
  G_FOLDER   = #$E8B7;
  G_LIBRARY  = #$E8F1;
  G_SETTINGS = #$E713;
  G_POWER    = #$E7E8;
  G_SAVE     = #$E74E;
  G_ACCEPT   = #$E73E;
  G_PRINT    = #$E749;
  G_CANCEL   = #$E711;
  G_EDIT     = #$E70F;
  G_DELETE   = #$E74D;
  G_SEARCH   = #$E721;
  G_COPY     = #$E8C8;
  G_INFO     = #$E946;
  G_WARNING  = #$E7BA;
  G_ERROR    = #$EA39;
  G_USER     = #$E77B;
  G_MONEY    = #$E1D6;
  G_DOC      = #$E8A5;
  G_LOCK     = #$E785;
  G_EYE      = #$E890;
  G_EYE_OFF  = #$ED1A;
  G_LEAF     = #$E9A1;
  G_DB_GEAR  = #$E9A2;
  G_ARROW_RIGHT = #$E72A;
  G_ARROW_LEFT  = #$E72B;
  G_MINIMIZE = #$E921;
  G_CLOSE    = #$E8BB;
  G_CHECK    = #$E73E;

// Renvoie la source SVG associée au glyphe MDL2 (codepoint), ou '' si aucune.
function SvgForGlyph(const Glyph: string): string;

// Dessine l'icône SVG (teintée en Color) centrée dans R sur le contexte BG.
procedure DrawSvgIcon(BG: TGPGraphics; const Svg: string; const R: TGPRectF;
  Color: TColor);

// Dessine une icône SVG directement sur un canvas Skia
procedure SkDrawSvg(ACanvas: ISkCanvas; const ASvg: string; const R: TRectF;
  Color: TColor; Alpha: Byte = 255);

implementation

uses
  System.SysUtils, System.Classes, System.Math,
  System.Generics.Collections, Winapi.ActiveX,
  uGraphicsGDIP;

{ ------------------------------------------------------------------------ }
{ Sources SVG (viewBox 24x24, tracé "stroke" recoloré à l'exécution)        }
{ ------------------------------------------------------------------------ }

const
  // Contenus internes (paths/formes Feather - licence MIT)
  P_HOME     = '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>' +
               '<path d="M9 22V12h6v10"/>';
  P_LIST     = '<line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/>' +
               '<line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/>' +
               '<line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>';
  P_ADD      = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
  P_FOLDER   = '<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>';
  P_LIBRARY  = '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>' +
               '<path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>';
  P_SETTINGS = '<circle cx="12" cy="12" r="3"/>' +
               '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06' +
               'a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09' +
               'A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83' +
               'l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09' +
               'A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83' +
               'l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09' +
               'a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83' +
               'l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09' +
               'a1.65 1.65 0 0 0-1.51 1z"/>';
  P_POWER    = '<path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/>';
  P_SAVE     = '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>' +
               '<polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>';
  P_ACCEPT   = '<polyline points="20 6 9 17 4 12"/>';
  P_PRINT    = '<polyline points="6 9 6 2 18 2 18 9"/>' +
               '<path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>' +
               '<rect x="6" y="14" width="12" height="8"/>';
  P_CANCEL   = '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
  P_EDIT     = '<path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"/>';
  P_DELETE   = '<polyline points="3 6 5 6 21 6"/>' +
               '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>' +
               '<line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/>';
  P_SEARCH   = '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
  P_COPY     = '<rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>' +
               '<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>';
  P_INFO     = '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/>' +
               '<line x1="12" y1="8" x2="12.01" y2="8"/>';
  P_WARNING  = '<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86' +
               'a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/>' +
               '<line x1="12" y1="17" x2="12.01" y2="17"/>';
  P_ERROR    = '<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/>' +
               '<line x1="9" y1="9" x2="15" y2="15"/>';
  P_USER     = '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>';
  P_MONEY    = '<line x1="12" y1="1" x2="12" y2="23"/>' +
               '<path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>';
  P_DOC      = '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>' +
               '<polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/>' +
               '<line x1="16" y1="17" x2="8" y2="17"/><line x1="10" y1="9" x2="8" y2="9"/>';
  P_LOCK     = '<rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>' +
               '<path d="M7 11V7a5 5 0 0 1 10 0v4"/>';
  P_EYE      = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
               '<circle cx="12" cy="12" r="3"/>';
  P_EYE_OFF  = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>' +
               '<line x1="1" y1="1" x2="23" y2="23"/>';
  P_MINIMIZE = '<line x1="5" y1="12" x2="19" y2="12"/>';
  P_CLOSE    = '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
  P_LEAF     = '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10z"/>' +
               '<path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/>';
  P_DB_GEAR  = '<ellipse cx="12" cy="5" rx="9" ry="3"/>' +
               '<path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/>' +
               '<circle cx="18" cy="19" r="2.2"/>';
  P_ARROW_RIGHT = '<line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>';
  P_ARROW_LEFT  = '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
  P_CHECK    = '<polyline points="20 6 9 17 4 12"/>';

var
  FCache: TDictionary<string, TGPBitmap>;
  FCACHE_MAX_SIZE: Integer;

function WrapSvg(const Inner: string): string;
begin
  Result := '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" ' +
    'stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
    Inner + '</svg>';
end;

function SvgForGlyph(const Glyph: string): string;
begin
  if Glyph = G_HOME then Result := WrapSvg(P_HOME)
  else if Glyph = G_LIST then Result := WrapSvg(P_LIST)
  else if Glyph = G_ADD then Result := WrapSvg(P_ADD)
  else if Glyph = G_FOLDER then Result := WrapSvg(P_FOLDER)
  else if Glyph = G_LIBRARY then Result := WrapSvg(P_LIBRARY)
  else if Glyph = G_SETTINGS then Result := WrapSvg(P_SETTINGS)
  else if Glyph = G_POWER then Result := WrapSvg(P_POWER)
  else if Glyph = G_SAVE then Result := WrapSvg(P_SAVE)
  else if Glyph = G_ACCEPT then Result := WrapSvg(P_ACCEPT)
  else if Glyph = G_PRINT then Result := WrapSvg(P_PRINT)
  else if Glyph = G_CANCEL then Result := WrapSvg(P_CANCEL)
  else if Glyph = G_EDIT then Result := WrapSvg(P_EDIT)
  else if Glyph = G_DELETE then Result := WrapSvg(P_DELETE)
  else if Glyph = G_SEARCH then Result := WrapSvg(P_SEARCH)
  else if Glyph = G_COPY then Result := WrapSvg(P_COPY)
  else if Glyph = G_INFO then Result := WrapSvg(P_INFO)
  else if Glyph = G_WARNING then Result := WrapSvg(P_WARNING)
  else if Glyph = G_ERROR then Result := WrapSvg(P_ERROR)
  else if Glyph = G_USER then Result := WrapSvg(P_USER)
  else if Glyph = G_MONEY then Result := WrapSvg(P_MONEY)
  else if Glyph = G_DOC then Result := WrapSvg(P_DOC)
  else if Glyph = G_LOCK then Result := WrapSvg(P_LOCK)
  else if Glyph = G_EYE then Result := WrapSvg(P_EYE)
  else if Glyph = G_EYE_OFF then Result := WrapSvg(P_EYE_OFF)
  else if Glyph = G_MINIMIZE then Result := WrapSvg(P_MINIMIZE)
  else if Glyph = G_CLOSE then Result := WrapSvg(P_CLOSE)
  else if Glyph = G_LEAF then Result := WrapSvg(P_LEAF)
  else if Glyph = G_DB_GEAR then Result := WrapSvg(P_DB_GEAR)
  else if Glyph = G_ARROW_RIGHT then Result := WrapSvg(P_ARROW_RIGHT)
  else if Glyph = G_ARROW_LEFT then Result := WrapSvg(P_ARROW_LEFT)
  else if Glyph = G_CHECK then Result := WrapSvg(P_CHECK)
  else Result := '';
end;

function ColorToAlphaColor(C: TColor; Alpha: Byte = 255): TAlphaColor;
var
  RGB: Longint;
begin
  RGB := ColorToRGB(C);
  Result := (TAlphaColor(Alpha) shl 24) or
    (TAlphaColor(GetRValue(RGB)) shl 16) or
    (TAlphaColor(GetGValue(RGB)) shl 8) or
    (TAlphaColor(GetBValue(RGB)));
end;

procedure SkDrawSvg(ACanvas: ISkCanvas; const ASvg: string; const R: TRectF;
  Color: TColor; Alpha: Byte = 255);
var
  Brush: TSkSvgBrush;
begin
  if (ACanvas = nil) or (ASvg = '') then Exit;
  Brush := TSkSvgBrush.Create;
  try
    Brush.WrapMode := TSkSvgWrapMode.Fit;
    Brush.Source := ASvg;
    Brush.OverrideColor := ColorToAlphaColor(Color, Alpha);
    Brush.Render(ACanvas, R, 1.0);
  finally
    Brush.Free;
  end;
end;

// Rasterise le SVG teinté dans un TGPBitmap indépendant (via PNG en mémoire).
function RenderSvgToGPBitmap(const Svg: string; Size: Integer;
  Color: TColor): TGPBitmap;
var
  Surface: ISkSurface;
  Image: ISkImage;
  Brush: TSkSvgBrush;
  Bytes: TBytes;
  Stream: TMemoryStream;
  Adapter: IStream;
  Tmp: TGPBitmap;
  G: TGPGraphics;
begin
  Result := nil;
  Surface := TSkSurface.MakeRaster(Size, Size);
  if Surface = nil then Exit;
  Surface.Canvas.Clear(TAlphaColors.Null);

  Brush := TSkSvgBrush.Create;
  try
    Brush.WrapMode := TSkSvgWrapMode.Fit;
    Brush.Source := Svg;
    Brush.OverrideColor := ColorToAlphaColor(Color);
    Brush.Render(Surface.Canvas, RectF(0, 0, Size, Size), 1.0);
  finally
    Brush.Free;
  end;

  Image := Surface.MakeImageSnapshot;
  if Image = nil then Exit;
  Bytes := Image.Encode(TSkEncodedImageFormat.PNG, 100);
  if Length(Bytes) = 0 then Exit;

  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Bytes[0], Length(Bytes));
    Stream.Position := 0;
    Adapter := TStreamAdapter.Create(Stream, soOwned);
    Tmp := TGPBitmap.Create(Adapter);
    try
      // Copie indépendante : découple le résultat du flux (libéré ensuite).
      Result := TGPBitmap.Create(Size, Size, PixelFormat32bppARGB);
      G := TGPGraphics.Create(Result);
      try
        SetupHighQuality(G);
        G.DrawImage(Tmp, MakeRect(0.0, 0.0, Size, Size));
      finally
        G.Free;
      end;
    finally
      Tmp.Free;
    end;
  except
    // Stream appartient à l'adaptateur (soOwned) si créé ; sinon libéré ici.
    if Adapter = nil then
      Stream.Free;
    FreeAndNil(Result);
    raise;
  end;
end;

function GetSvgIcon(const Svg: string; Size: Integer; Color: TColor): TGPBitmap;
var
  Key: string;
  Pair: TPair<string, TGPBitmap>;
begin
  if (Svg = '') or (Size <= 0) then Exit(nil);
  Key := Svg + '|' + IntToStr(Size) + '|' + IntToHex(ColorToRGB(Color), 6);
  if FCache.TryGetValue(Key, Result) then Exit;
  Result := nil;
  try
    Result := RenderSvgToGPBitmap(Svg, Size, Color);
  except
    Result := nil;
  end;
  if Result <> nil then
  begin
    if FCache.Count >= FCACHE_MAX_SIZE then
    begin
      for Pair in FCache do
      begin
        FCache.Remove(Pair.Key);
        Pair.Value.Free;
        Break;
      end;
    end;
    FCache.Add(Key, Result);
  end;
end;

procedure DrawSvgIcon(BG: TGPGraphics; const Svg: string; const R: TGPRectF;
  Color: TColor);
var
  S: Integer;
  Bmp: TGPBitmap;
  X, Y: Single;
begin
  S := Round(Min(R.Width, R.Height));
  if S <= 0 then Exit;
  Bmp := GetSvgIcon(Svg, S, Color);
  if Bmp = nil then Exit;
  X := R.X + (R.Width - S) / 2;
  Y := R.Y + (R.Height - S) / 2;
  BG.DrawImage(Bmp, MakeRect(X, Y, S, S));
end;

procedure FreeCache;
var
  Bmp: TGPBitmap;
begin
  for Bmp in FCache.Values do
    Bmp.Free;
  FCache.Free;
end;

initialization
  FCACHE_MAX_SIZE := 50;
  FCache := TDictionary<string, TGPBitmap>.Create;

finalization
  FreeCache;

end.
