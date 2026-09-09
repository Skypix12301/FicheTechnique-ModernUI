unit uDashboard_v3;

{
  ==========================================================================
  uDashboard_v3.pas - Tableau de bord ModernUI v3
  ==========================================================================
  - TAdvPanel stat cards defined in DFM (POSViande pattern)
  - Labels inside each card for title, value, metadata
  - Colors applied from theme in FormCreate
  - Grille des fiches recentes : lignes alternees + badge de statut
  ==========================================================================
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client,
  AdvPanel,
  uModernTheme, uDataModule_v3, uUtils_v3;

type
  TfrmDashboard = class(TForm)
    pnlTitle: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    pnlStats: TPanel;
    pnlCard1: TAdvPanel;
    lblCard1Title: TLabel;
    lblCard1Value: TLabel;
    lblCard1Meta: TLabel;
    pnlCard2: TAdvPanel;
    lblCard2Title: TLabel;
    lblCard2Value: TLabel;
    lblCard2Meta: TLabel;
    pnlCard3: TAdvPanel;
    lblCard3Title: TLabel;
    lblCard3Value: TLabel;
    lblCard3Meta: TLabel;
    pnlCard4: TAdvPanel;
    lblCard4Title: TLabel;
    lblCard4Value: TLabel;
    lblCard4Meta: TLabel;
    pnlGrid: TPanel;
    lblGridTitle: TLabel;
    btnRefresh: TButton;
    gridRecent: TDBGrid;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure gridRecentDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    procedure ChargerStatistiques;
    procedure ChargerFichesRecentes;
    procedure ApplyModernLayout;
  public
    { Public declarations }
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}


procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  AppliquerThemeFormulaire(Self);

  pnlTitle.Color := CLR_BG_MAIN;
  pnlTitle.BevelOuter := bvNone;
  pnlStats.Color := CLR_BG_MAIN;
  pnlStats.BevelOuter := bvNone;
  pnlGrid.Color := CLR_BG_MAIN;
  pnlGrid.BevelOuter := bvNone;

  AppliquerThemeLabel(lblTitle, True, False);
  AppliquerThemeLabel(lblSubtitle, False, True);
  AppliquerThemeLabel(lblGridTitle, True, False);

  AppliquerThemeGrille(gridRecent);
  AppliquerThemeBouton(btnRefresh, bsSecondary);

  GVEnsureDecorPanel(Self, pnlTitle, 'pnlTitleBand',
    0, 0, pnlTitle.Width, 4,
    CLR_PRIMARY, CLR_PRIMARY, [akLeft, akTop, akRight]);

  { Card 1 - Blue (Fiches Actives) }
  GVApplyCardStyle(pnlCard1, CLR_BG_SECONDARY, CLR_STAT_BLUE);
  GVApplyLabelStyle(lblCard1Title, ActiveTheme.TextSecondary,
    FONT_SIZE_BODY, False);
  GVApplyLabelStyle(lblCard1Value, CLR_STAT_BLUE, 18, True, FONT_BOLD);
  GVApplyLabelStyle(lblCard1Meta, ActiveTheme.TextSecondary,
    FONT_SIZE_SMALL, False);

  { Card 2 - Orange (En Attente) }
  GVApplyCardStyle(pnlCard2, CLR_BG_SECONDARY, CLR_STAT_ORANGE);
  GVApplyLabelStyle(lblCard2Title, ActiveTheme.TextSecondary,
    FONT_SIZE_BODY, False);
  GVApplyLabelStyle(lblCard2Value, CLR_STAT_ORANGE, 18, True, FONT_BOLD);
  GVApplyLabelStyle(lblCard2Meta, ActiveTheme.TextSecondary,
    FONT_SIZE_SMALL, False);

  { Card 3 - Green (Projets) }
  GVApplyCardStyle(pnlCard3, CLR_BG_SECONDARY, CLR_STAT_GREEN);
  GVApplyLabelStyle(lblCard3Title, ActiveTheme.TextSecondary,
    FONT_SIZE_BODY, False);
  GVApplyLabelStyle(lblCard3Value, CLR_STAT_GREEN, 18, True, FONT_BOLD);
  GVApplyLabelStyle(lblCard3Meta, ActiveTheme.TextSecondary,
    FONT_SIZE_SMALL, False);

  { Card 4 - Purple (Stock Alertes) }
  GVApplyCardStyle(pnlCard4, CLR_BG_SECONDARY, CLR_STAT_PURPLE);
  GVApplyLabelStyle(lblCard4Title, ActiveTheme.TextSecondary,
    FONT_SIZE_BODY, False);
  GVApplyLabelStyle(lblCard4Value, CLR_STAT_PURPLE, 18, True, FONT_BOLD);
  GVApplyLabelStyle(lblCard4Meta, ActiveTheme.TextSecondary,
    FONT_SIZE_SMALL, False);

  ChargerStatistiques;
  ChargerFichesRecentes;
end;

procedure TfrmDashboard.FormResize(Sender: TObject);
var
  Gap, CardsPerRow, TopCardW, CardH: Integer;
  I: Integer;
  Cards: array[0..3] of TAdvPanel;
begin
  if ClientWidth <= 0 then Exit;

  Gap := 16;

  if ClientWidth < 600 then
    CardsPerRow := 1
  else if ClientWidth < 900 then
    CardsPerRow := 2
  else
    CardsPerRow := 4;

  TopCardW := (ClientWidth - Gap * (CardsPerRow + 1)) div CardsPerRow;
  CardH := 112;

  Cards[0] := pnlCard1;
  Cards[1] := pnlCard2;
  Cards[2] := pnlCard3;
  Cards[3] := pnlCard4;

  for I := 0 to 3 do
  begin
    Cards[I].SetBounds(
      Gap + (TopCardW + Gap) * (I mod CardsPerRow),
      Gap + (CardH + Gap) * (I div CardsPerRow),
      TopCardW,
      CardH);
  end;

  pnlGrid.SetBounds(Gap, Cards[3].Top + CardH + Gap,
    ClientWidth - Gap * 2, ClientHeight - Cards[3].Top - CardH - Gap * 2 - 10);
end;

procedure TfrmDashboard.ChargerStatistiques;
var
  Q, QA: TFDQuery;
  SDraft, SOk: string;
begin
  ShowLoadingOverlay(#1575#1583#1575#1585' '#1575#1604#1576#1591#1575#1602#1575#1578'...');
  try
    SDraft := #1605#1587#1608#1583#1577;
    SOk := #1605#1589#1575#1583#1602 + Chr(32) + #1593#1604#1610#1607;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := dmMain.FDConnection1;
      Q.SQL.Text :=
        'SELECT ' +
        '(SELECT COUNT(*) FROM FichesTechniques) AS CTotal, ' +
        '(SELECT COUNT(*) FROM FichesTechniques WHERE Statut = :P1 OR Statut = :P2) AS CEnAttente, ' +
        '(SELECT COUNT(*) FROM FichesTechniques WHERE Statut = :P3 OR Statut = :P4) AS CValidee';
      Q.ParamByName('P1').AsString := 'Brouillon';
      Q.ParamByName('P2').AsString := SDraft;
      Q.ParamByName('P3').AsString := 'Validee';
      Q.ParamByName('P4').AsString := SOk;
      Q.Open;
      lblCard1Value.Caption := IntToStr(Q.FieldByName('CTotal').AsInteger);
      lblCard2Value.Caption := IntToStr(Q.FieldByName('CEnAttente').AsInteger);
      lblCard3Value.Caption := IntToStr(Q.FieldByName('CValidee').AsInteger);
    finally
      Q.Free;
    end;

    { Alertes stock : table optionnelle, ignoree si absente }
    lblCard4Value.Caption := '--';
    QA := TFDQuery.Create(nil);
    try
      QA.Connection := dmMain.FDConnection1;
      QA.SQL.Text := 'SELECT COUNT(*) FROM StockAlertes';
      QA.Open;
      lblCard4Value.Caption := IntToStr(QA.Fields[0].AsInteger);
    except
      lblCard4Value.Caption := '--';
    end;
    if Assigned(QA) then
      QA.Free;
  finally
    HideLoadingOverlay;
  end;
end;

procedure TfrmDashboard.ChargerFichesRecentes;
begin
  with dmMain.qryFiches do
  begin
    Close;
    SQL.Text :=
      'SELECT TOP 50 * FROM FichesTechniques ORDER BY DateCreation DESC';
    Open;
  end;
  gridRecent.DataSource := dmMain.dsFiches;
end;

procedure TfrmDashboard.gridRecentDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Statut: string;
begin
  if SameText(Column.FieldName, 'Statut') then
  begin
    if gdSelected in State then
      gridRecent.Canvas.Brush.Color := CLR_GRID_SELECTED
    else if gridRecent.DataSource.DataSet.RecNo mod 2 = 0 then
      gridRecent.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridRecent.Canvas.Brush.Color := CLR_BG_SECONDARY;
    gridRecent.Canvas.FillRect(Rect);

    Statut := Column.Field.AsString;
    DrawStatusBadge(gridRecent.Canvas, Rect, Statut, StatutColor(Statut));
    Exit;
  end;

  if not (gdSelected in State) then
  begin
    if gridRecent.DataSource.DataSet.RecNo mod 2 = 0 then
      gridRecent.Canvas.Brush.Color := CLR_GRID_ALT
    else
      gridRecent.Canvas.Brush.Color := CLR_BG_SECONDARY;
  end;
  gridRecent.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmDashboard.btnRefreshClick(Sender: TObject);
begin
  ChargerStatistiques;
  ChargerFichesRecentes;
end;

procedure TfrmDashboard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmDashboard.ApplyModernLayout;
const
  Margin = 12;
  Gap = 16;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  pnlTitle.SetBounds(0, 0, ClientWidth, pnlTitle.Height);
  pnlStats.SetBounds(0, pnlTitle.Height, ClientWidth, pnlStats.Height);

  pnlGrid.SetBounds(Margin, pnlTitle.Height + pnlStats.Height + Gap,
    ClientWidth - Margin * 2,
    ClientHeight - pnlTitle.Height - pnlStats.Height - Gap * 2 - Margin);
end;

end.
