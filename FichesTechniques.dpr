program FichesTechniques;

{
  ==========================================================================
  FichesTechniques.dpr - Programme principal v3 (ModernUI)
  ==========================================================================
}

uses
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Themes,
  Vcl.Styles,
  System.SysUtils,
  uModernTheme in 'uModernTheme.pas',
  uSkiaTheme in 'uSkiaTheme.pas',
  uIconsSVG in 'uIconsSVG.pas',
  uUtils_v3 in 'uUtils_v3.pas',
  uDataModule_v3 in 'uDataModule_v3.pas' {dmMain: TDataModule},
  uLogin_v3 in 'uLogin_v3.pas' {frmLogin},
  uMain_v3 in 'uMain_v3.pas' {frmMain},
  uDashboard_v3 in 'uDashboard_v3.pas' {frmDashboard},
  uListeFiches_v3 in 'uListeFiches_v3.pas' {frmListeFiches},
  uFicheTechnique_v3 in 'uFicheTechnique_v3.pas' {frmFicheTechnique},
  uProjets_v3 in 'uProjets_v3.pas' {frmProjets},
  uCatalogue_v3 in 'uCatalogue_v3.pas' {frmCatalogue},
  uParametres_v3 in 'uParametres_v3.pas' {frmParametres};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'إدارة البطاقات التقنية - Modern UI';

  // Style VCL intégré neutre : le rendu custom GDI+ gère l'apparence,
  // ce style garde les dialogues natifs cohérents (sans fichier .vsf externe).
  TStyleManager.TrySetStyle('Windows', False);

  // Charger le thème (clair/sombre) depuis config.ini
  InitTheme;

  // Créer le DataModule en premier
  Application.CreateForm(TdmMain, dmMain);

  // Afficher le formulaire de login
  frmLogin := TfrmLogin.Create(Application);
  try
    if frmLogin.ShowModal = mrOk then
    begin
      Application.CreateForm(TfrmMain, frmMain);
      frmMain.ApresConnexion;
      Application.Run;
    end
    else
    begin
      Application.Terminate;
    end;
  finally
    frmLogin.Free;
  end;
end.