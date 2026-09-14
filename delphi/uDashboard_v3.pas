unit uDashboard_v3;

{==============================================================================}
{ Fenêtre principale modernisée - Dashboard & Suivi des Fiches Techniques      }
{ Architecture VCL Moderne : TSplitView, Cards, Anti-Flicker, TDBGrid stylé    }
{ Compatible Delphi XE8, 10 Seattle..Sydney, 11 Alexandria, 12 Athens          }
{==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.DBGrids, Vcl.Grids,
  Vcl.WinXCtrls, Data.DB, uBaseForm, uVCLModernizer;

type
  TfrmDashboard_v3 = class(TfrmBase)
    { Conteneurs principaux }
    pnlBackground: TPanel;
    pnlSidebar: TPanel;
    pnlMainContent: TPanel;
    pnlHeaderBar: TPanel;

    { Bannière récapitulative & actions rapides }
    pnlExecutiveBanner: TPanel;
    lblBannerTitle: TLabel;
    lblBannerSubTitle: TLabel;
    lblTotalGlobalTTC: TLabel;
    lblTotalGlobalHT: TLabel;
    lblTotalGlobalTVA: TLabel;
    btnNouvelleFiche: TSpeedButton;
    btnProjets: TSpeedButton;

    { 4 Cartes d'indicateurs (KPIs) }
    pnlKpiContainer: TPanel;
    pnlCardTotalFiches: TPanel;
    pnlCardValidees: TPanel;
    pnlCardEnEtude: TPanel;
    pnlCardProjets: TPanel;

    lblKpiTotalFichesCount: TLabel;
    lblKpiTotalFichesTitle: TLabel;
    lblKpiValideesCount: TLabel;
    lblKpiValideesTitle: TLabel;
    lblKpiEnEtudeCount: TLabel;
    lblKpiEnEtudeTitle: TLabel;
    lblKpiProjetsCount: TLabel;
    lblKpiProjetsTitle: TLabel;

    { Barre d'outils et de recherche du tableau }
    pnlTableToolbar: TPanel;
    edtSearchFiche: TEdit;
    btnFilterTous: TSpeedButton;
    btnFilterValidees: TSpeedButton;
    btnFilterEnEtude: TSpeedButton;
    btnExportCSV: TSpeedButton;
    cbbProjetFilter: TComboBox;

    { Grille moderne des fiches techniques }
    pnlGridCard: TPanel;
    dbgFiches: TDBGrid;

    { Barre de navigation latérale (Sidebar) }
    pnlBrandHeader: TPanel;
    lblBrandTitle: TLabel;
    lblBrandSub: TLabel;
    btnNavDashboard: TSpeedButton;
    btnNavFiches: TSpeedButton;
    btnNavCatalogue: TSpeedButton;
    btnNavProjets: TSpeedButton;
    btnNavParametres: TSpeedButton;
    btnToggleLangue: TSpeedButton;

    { Événements }
    procedure FormCreate(Sender: TObject);
    procedure dbgFichesDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnNouvelleFicheClick(Sender: TObject);
    procedure edtSearchFicheChange(Sender: TObject);
    procedure btnFilterTousClick(Sender: TObject);
    procedure btnFilterValideesClick(Sender: TObject);
    procedure btnFilterEnEtudeClick(Sender: TObject);
    procedure btnExportCSVClick(Sender: TObject);
    procedure btnToggleLangueClick(Sender: TObject);
  private
    FCurrentLang: string;
    procedure InitCardPanels;
    procedure RefreshDashboardKPIs;
    procedure FilterGrid(const AStatus: string);
  protected
    procedure SetupModernUI; override;
  public
  end;

var
  frmDashboard_v3: TfrmDashboard_v3;

implementation

{$R *.dfm}

procedure TfrmDashboard_v3.FormCreate(Sender: TObject);
begin
  inherited;
  FCurrentLang := 'AR';
  InitCardPanels;
  RefreshDashboardKPIs;
end;

procedure TfrmDashboard_v3.SetupModernUI;
begin
  inherited;
  // Modernisation globale de la fiche (Anti-Flicker + police Segoe UI)
  TVCLModernizer.ModernizeForm(Self, 'Segoe UI');
end;

procedure TfrmDashboard_v3.InitCardPanels;
begin
  // Stylisation sans biseau des cartes et de la grille
  ApplyCardStyle(pnlCardTotalFiches);
  ApplyCardStyle(pnlCardValidees);
  ApplyCardStyle(pnlCardEnEtude);
  ApplyCardStyle(pnlCardProjets);
  ApplyCardStyle(pnlGridCard);
  ApplyCardStyle(pnlTableToolbar);

  // Configuration visuelle du TDBGrid pour le confort de lecture
  dbgFiches.BorderStyle := bsNone;
  dbgFiches.DrawingStyle := gdsClassic;
  dbgFiches.Options := [dgTitles, dgIndicator, dgColumnResize, dgRowSelect, dgAlwaysShowSelection];
end;

procedure TfrmDashboard_v3.RefreshDashboardKPIs;
begin
  // Exemple de mise à jour des métriques depuis le DataModule
  {
  lblTotalGlobalTTC.Caption := FormatFloat('#,##0.00 "دج"', dmData.QryStatsTOTAL_TTC.AsFloat);
  lblKpiTotalFichesCount.Caption := IntToStr(dmData.QryStatsCOUNT_FICHES.AsInteger);
  lblKpiValideesCount.Caption    := IntToStr(dmData.QryStatsCOUNT_VALIDEES.AsInteger);
  lblKpiEnEtudeCount.Caption     := IntToStr(dmData.QryStatsCOUNT_EN_ETUDE.AsInteger);
  lblKpiProjetsCount.Caption     := IntToStr(dmData.QryStatsCOUNT_PROJETS.AsInteger);
  }
end;

procedure TfrmDashboard_v3.dbgFichesDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  // Utilisation du moteur de dessin moderne pour la grille
  TVCLModernizer.DrawModernDBGridCell(Sender, Rect, DataCol, Column, State, 'Segoe UI');
end;

procedure TfrmDashboard_v3.btnNouvelleFicheClick(Sender: TObject);
begin
  // Ouverture du formulaire de saisie de la fiche technique
  // frmFicheTechnique_v3.ShowModal;
end;

procedure TfrmDashboard_v3.edtSearchFicheChange(Sender: TObject);
begin
  // Filtrage dynamique en cours de frappe
  if dbgFiches.DataSource <> nil then
  begin
    if Trim(edtSearchFiche.Text) <> '' then
    begin
      dbgFiches.DataSource.DataSet.Filter :=
        Format('(NUMERO_FICHE LIKE ''%%%s%%'') OR (OPERATION LIKE ''%%%s%%'')',
        [edtSearchFiche.Text, edtSearchFiche.Text]);
      dbgFiches.DataSource.DataSet.Filtered := True;
    end
    else
      dbgFiches.DataSource.DataSet.Filtered := False;
  end;
end;

procedure TfrmDashboard_v3.btnFilterTousClick(Sender: TObject);
begin
  FilterGrid('');
end;

procedure TfrmDashboard_v3.btnFilterValideesClick(Sender: TObject);
begin
  FilterGrid('مصادق عليه');
end;

procedure TfrmDashboard_v3.btnFilterEnEtudeClick(Sender: TObject);
begin
  FilterGrid('قيد الدراسة');
end;

procedure TfrmDashboard_v3.FilterGrid(const AStatus: string);
begin
  if dbgFiches.DataSource = nil then Exit;

  if AStatus = '' then
    dbgFiches.DataSource.DataSet.Filtered := False
  else
  begin
    dbgFiches.DataSource.DataSet.Filter := Format('STATUT = ''%s''', [AStatus]);
    dbgFiches.DataSource.DataSet.Filtered := True;
  end;
end;

procedure TfrmDashboard_v3.btnExportCSVClick(Sender: TObject);
var
  CSVList: TStringList;
  RowStr: string;
  i: Integer;
begin
  // Export direct des données de la grille en CSV avec BOM UTF-8
  if (dbgFiches.DataSource = nil) or (dbgFiches.DataSource.DataSet = nil) then Exit;

  CSVList := TStringList.Create;
  try
    // En-tête
    RowStr := 'N_Fiche;Projet;Operation;Date;Montant_TTC;Statut';
    CSVList.Add(RowStr);

    dbgFiches.DataSource.DataSet.DisableControls;
    try
      dbgFiches.DataSource.DataSet.First;
      while not dbgFiches.DataSource.DataSet.Eof do
      begin
        RowStr := Format('"%s";"%s";"%s";"%s";"%f";"%s"', [
          dbgFiches.DataSource.DataSet.FieldByName('NUMERO_FICHE').AsString,
          dbgFiches.DataSource.DataSet.FieldByName('NOM_PROJET').AsString,
          dbgFiches.DataSource.DataSet.FieldByName('OPERATION').AsString,
          dbgFiches.DataSource.DataSet.FieldByName('DATE_FICHE').AsString,
          dbgFiches.DataSource.DataSet.FieldByName('MONTANT_TTC').AsFloat,
          dbgFiches.DataSource.DataSet.FieldByName('STATUT').AsString
        ]);
        CSVList.Add(RowStr);
        dbgFiches.DataSource.DataSet.Next;
      end;
    finally
      dbgFiches.DataSource.DataSet.EnableControls;
    end;

    CSVList.SaveToFile(ExtractFilePath(Application.ExeName) + 'export_fiches.csv', TEncoding.UTF8);
    ShowMessage('Export CSV réalisé avec succès dans : export_fiches.csv');
  finally
    CSVList.Free;
  end;
end;

procedure TfrmDashboard_v3.btnToggleLangueClick(Sender: TObject);
begin
  if FCurrentLang = 'AR' then
    FCurrentLang := 'FR'
  else
    FCurrentLang := 'AR';

  SwitchLanguage(FCurrentLang);
end;

end.
