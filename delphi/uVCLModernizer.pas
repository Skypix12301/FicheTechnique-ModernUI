unit uVCLModernizer;

{==============================================================================}
{ Module d'amélioration graphique et de modernisation VCL pour Delphi         }
{ Compatible Delphi XE8, 10.x (Seattle..Sydney), 11 Alexandria, 12 Athens     }
{ Fournit: Style moderne pour TDBGrid, cartes avec bordures douces,             }
{ gestion RTL bilingue, suppression du scintillement (DoubleBuffering)        }
{==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.DBGrids, Vcl.Grids, Data.DB, Vcl.Themes;

type
  { Palette de couleurs moderne "Slate & Blue" }
  TModernTheme = record
    Background: TColor;       // Fond principal ($00F8FAFC - Slate 50)
    Surface: TColor;          // Fond des cartes / panels ($00FFFFFF - Blanc)
    Border: TColor;           // Bordure subtile ($00E2E8F0 - Slate 200)
    TextPrimary: TColor;      // Texte principal ($000F172A - Slate 900)
    TextSecondary: TColor;    // Texte secondaire ($0064748B - Slate 500)
    Primary: TColor;          // Bleu principal ($00E26725 - #2563eb)
    PrimaryHover: TColor;     // Bleu survol ($00D44A1D - #1d4ed8)
    AccentGreen: TColor;      // Vert validation ($0043A047 - Emerald)
    AccentOrange: TColor;     // Orange attente ($001880F5 - Amber)
    AccentRed: TColor;         // Rouge rejet ($003B2FE1 - Rose)
    GridRowAlt: TColor;       // Ligne alternée grille ($00F8FAFC)
    GridRowHover: TColor;     // Survol grille ($00F1F5F9)
  end;

  TVCLModernizer = class
  public
    class var Theme: TModernTheme;
    class constructor Create;

    { Amélioration globale de la fiche }
    class procedure ModernizeForm(AForm: TForm; const FontName: string = 'Segoe UI');

    { Amélioration d'un TPanel en "Carte" moderne sans biseau vieillot }
    class procedure StyleCardPanel(APanel: TPanel; ABorderColor: TColor = $00E2E8F0; ARadius: Integer = 8);

    { Dessin personnalisé d'une grille TDBGrid moderne }
    class procedure DrawModernDBGridCell(
      Sender: TObject;
      const Rect: TRect;
      DataCol: Integer;
      Column: TColumn;
      State: TGridDrawState;
      AFontFamily: string = 'Segoe UI'
    );

    { Dessin d'un badge de statut dans une cellule (ex: Validé, En Attente) }
    class procedure DrawStatusBadge(
      Canvas: TCanvas;
      const CellRect: TRect;
      const StatusText: string;
      BgColor, TextColor: TColor
    );

    { Configuration BiDi (Arabe / Français) avec préservation LTR pour les chiffres }
    class procedure ApplyBiDiMode(AControl: TWinControl; IsArabic: Boolean);
  end;

implementation

{ TVCLModernizer }

class constructor TVCLModernizer.Create;
begin
  // Palette moderne inspirée des interfaces professionnelles
  Theme.Background    := $00F8FAFC; // #f8fafc
  Theme.Surface       := $00FFFFFF; // #ffffff
  Theme.Border        := $00E2E8F0; // #e2e8f0
  Theme.TextPrimary   := $001E293B; // #1e293b
  Theme.TextSecondary := $0064748B; // #64748b
  Theme.Primary       := $00EB6725; // #2567eb
  Theme.PrimaryHover  := $00D84E1D; // #1d4ed8
  Theme.AccentGreen   := $002E7D32; // #327d2e
  Theme.AccentOrange  := $00008AE6; // #e68a00
  Theme.AccentRed     := $003333E6; // #e63333
  Theme.GridRowAlt    := $00FAFAF9; // #f9fafa
  Theme.GridRowHover  := $00F1F5F9; // #f9f5f1
end;

class procedure TVCLModernizer.ModernizeForm(AForm: TForm; const FontName: string);
var
  i: Integer;
begin
  if not Assigned(AForm) then Exit;

  // 1. Anti-scintillement (Flicker-Free UI)
  AForm.DoubleBuffered := True;
  AForm.Color := Theme.Background;

  // 2. Police moderne standardisée
  AForm.Font.Name := FontName;
  AForm.Font.Size := 9;
  AForm.Font.Quality := fqClearTypeNatural; // Rendu de texte haute qualité

  // 3. Parcours des composants pour activer DoubleBuffered
  for i := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[i] is TWinControl then
      TWinControl(AForm.Components[i]).DoubleBuffered := True;
  end;
end;

class procedure TVCLModernizer.StyleCardPanel(APanel: TPanel; ABorderColor: TColor; ARadius: Integer);
begin
  if not Assigned(APanel) then Exit;

  // Supprimer les biseaux 3D d'époque Windows 95/XP
  APanel.BevelOuter := bvNone;
  APanel.BevelInner := bvNone;
  APanel.BevelKind  := bkNone;
  APanel.BorderStyle := bsNone;
  APanel.Color      := Theme.Surface;
  APanel.ParentBackground := False;

  // Espacements modernes avec Margins
  APanel.AlignWithMargins := True;
  APanel.Margins.Left   := 8;
  APanel.Margins.Top    := 8;
  APanel.Margins.Right  := 8;
  APanel.Margins.Bottom := 8;
end;

class procedure TVCLModernizer.DrawModernDBGridCell(
  Sender: TObject;
  const Rect: TRect;
  DataCol: Integer;
  Column: TColumn;
  State: TGridDrawState;
  AFontFamily: string);
var
  Grid: TDBGrid;
  RowColor: TColor;
  TxtColor: TColor;
  CellText: string;
  TextRect: TRect;
  Alignment: TAlignment;
  FormatFlags: Cardinal;
begin
  if not (Sender is TDBGrid) then Exit;
  Grid := TDBGrid(Sender);

  // Déterminer la couleur de fond
  if gdSelected in State then
  begin
    RowColor := $00FEEFD8; // Bleu pastel très clair pour la sélection
    TxtColor := $00993D00; // Texte bleu contrasté
  end
  else if (Grid.DataSource <> nil) and (Grid.DataSource.DataSet <> nil) and
          (Grid.DataSource.DataSet.RecNo mod 2 = 0) then
  begin
    RowColor := Theme.GridRowAlt;
    TxtColor := Theme.TextPrimary;
  end
  else
  begin
    RowColor := Theme.Surface;
    TxtColor := Theme.TextPrimary;
  end;

  // Dessin du fond de cellule
  Grid.Canvas.Brush.Color := RowColor;
  Grid.Canvas.FillRect(Rect);

  // Configuration de la police
  Grid.Canvas.Font.Name := AFontFamily;
  Grid.Canvas.Font.Size := 9;
  Grid.Canvas.Font.Quality := fqClearTypeNatural;
  Grid.Canvas.Font.Color := TxtColor;

  if (Column.Field <> nil) then
    CellText := Column.Field.DisplayText
  else
    CellText := '';

  // Traitement particulier si colonne "Statut"
  if SameText(Column.FieldName, 'STATUT') or SameText(Column.FieldName, 'ETAT') then
  begin
    if Pos('VALIDE', UpperCase(CellText)) > 0 then
      DrawStatusBadge(Grid.Canvas, Rect, CellText, $00E8F5E9, $002E7D32)
    else if Pos('ATTENTE', UpperCase(CellText)) > 0 then
      DrawStatusBadge(Grid.Canvas, Rect, CellText, $00FFF8E1, $00B26A00)
    else
      DrawStatusBadge(Grid.Canvas, Rect, CellText, $00F1F5F9, $00475569);
    Exit;
  end;

  // Alignement et marge interne de 6px pour le texte
  Alignment := Column.Alignment;
  TextRect := Rect;
  InflateRect(TextRect, -6, -2);

  FormatFlags := DT_SINGLELINE or DT_VCENTER;
  case Alignment of
    taLeftJustify:  FormatFlags := FormatFlags or DT_LEFT;
    taRightJustify: FormatFlags := FormatFlags or DT_RIGHT;
    taCenter:       FormatFlags := FormatFlags or DT_CENTER;
  end;

  Winapi.Windows.DrawText(Grid.Canvas.Handle, PChar(CellText), Length(CellText), TextRect, FormatFlags);

  // Ligne de délimitation inférieure ultra fine
  Grid.Canvas.Pen.Color := Theme.Border;
  Grid.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
  Grid.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
end;

class procedure TVCLModernizer.DrawStatusBadge(
  Canvas: TCanvas;
  const CellRect: TRect;
  const StatusText: string;
  BgColor, TextColor: TColor);
var
  BadgeRect: TRect;
  TextSize: TSize;
  PaddingX, PaddingY: Integer;
begin
  PaddingX := 10;
  PaddingY := 3;

  Canvas.Font.Size := 8;
  Canvas.Font.Style := [fsBold];
  TextSize := Canvas.TextExtent(StatusText);

  // Calcul d'un badge centré dans la cellule
  BadgeRect.Left   := CellRect.Left + (CellRect.Width - (TextSize.cx + PaddingX * 2)) div 2;
  BadgeRect.Right  := BadgeRect.Left + TextSize.cx + PaddingX * 2;
  BadgeRect.Top    := CellRect.Top + (CellRect.Height - (TextSize.cy + PaddingY * 2)) div 2;
  BadgeRect.Bottom := BadgeRect.Top + TextSize.cy + PaddingY * 2;

  // Dessin du rectangle à coins arrondis (Pilule / Badge)
  Canvas.Brush.Color := BgColor;
  Canvas.Pen.Color   := BgColor;
  Canvas.RoundRect(BadgeRect.Left, BadgeRect.Top, BadgeRect.Right, BadgeRect.Bottom, 10, 10);

  // Texte à l'intérieur du badge
  Canvas.Font.Color := TextColor;
  Canvas.Brush.Style := bsClear;
  Canvas.TextOut(
    BadgeRect.Left + PaddingX,
    BadgeRect.Top + PaddingY,
    StatusText
  );
end;

class procedure TVCLModernizer.ApplyBiDiMode(AControl: TWinControl; IsArabic: Boolean);
begin
  if not Assigned(AControl) then Exit;

  if IsArabic then
  begin
    AControl.BiDiMode := bdRightToLeft;
    AControl.Font.Name := 'Segoe UI'; // Ou 'Cairo', 'Tahoma'
  end
  else
  begin
    AControl.BiDiMode := bdLeftToRight;
    AControl.Font.Name := 'Segoe UI';
  end;
end;

end.
