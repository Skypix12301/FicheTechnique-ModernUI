unit uDataModule_v3;

{==============================================================================}
{ DataModule Centralisé FireDAC & SQLite / PostgreSQL / MySQL - Delphi VCL     }
{ Gestion : Connexion base de données, transactions ACID, schémas de tables,    }
{ requêtes paramétrées pour Projets, Fiches Techniques, Lots et Devis BTPH     }
{ Compatible Delphi XE8, 10.x, 11 Alexandria, 12 Athens                        }
{==============================================================================}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdmMain_v3 = class(TDataModule)
    { Composants Moteurs & Connexion }
    FDConnection: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;

    { Requêtes pour la gestion des Projets }
    qryProjets: TFDQuery;
    dsProjets: TDataSource;

    { Requêtes pour la gestion des Fiches Techniques }
    qryFiches: TFDQuery;
    dsFiches: TDataSource;

    { Requêtes pour les Lots de travaux }
    qryLots: TFDQuery;
    dsLots: TDataSource;

    { Requêtes pour les Lignes d'articles et devis quantitatif / estimatif }
    qryLignesDevis: TFDQuery;
    dsLignesDevis: TDataSource;

    { Requêtes pour le Bordereau des Prix Unitaires (Catalogue) }
    qryCatalogue: TFDQuery;
    dsCatalogue: TDataSource;

    { Requêtes d'agrégation et statistiques pour le Tableau de Bord }
    qryStatsGlobales: TFDQuery;

    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FDatabasePath: string;
    procedure ConfigurerConnexionLocale;
    procedure InitialiserTablesEtIndex;
    procedure SeedDonneesInitiales;
  public
    procedure OuvrirToutesLesTables;
    procedure FermerToutesLesTables;
    function ExecuterSQLTransaction(const SQLCommands: array of string): Boolean;
    function ObtenirNouveauNumeroFiche(Annee: Integer): string;
  end;

var
  dmMain_v3: TdmMain_v3;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmMain_v3.DataModuleCreate(Sender: TObject);
begin
  ConfigurerConnexionLocale;
  InitialiserTablesEtIndex;
  SeedDonneesInitiales;
  OuvrirToutesLesTables;
end;

procedure TdmMain_v3.DataModuleDestroy(Sender: TObject);
begin
  FermerToutesLesTables;
  if FDConnection.Connected then
    FDConnection.Connected := False;
end;

procedure TdmMain_v3.ConfigurerConnexionLocale;
begin
  // Emplacement du fichier SQLite dans le dossier Application ou AppData
  FDatabasePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'btph_projets_v3.db');

  FDConnection.Connected := False;
  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=SQLite');
  FDConnection.Params.Add('Database=' + FDatabasePath);
  FDConnection.Params.Add('LockingMode=Normal');
  FDConnection.Params.Add('Synchronous=Normal');
  FDConnection.Params.Add('JournalMode=WAL'); // Mode WAL haute performance
  FDConnection.Params.Add('ForeignKeys=On');   // Intégrité référentielle active
  FDConnection.LoginPrompt := False;

  try
    FDConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Erreur de connexion à la base de données BTPH : ' + E.Message);
  end;
end;

procedure TdmMain_v3.InitialiserTablesEtIndex;
begin
  FDConnection.StartTransaction;
  try
    // 1. Table des Projets (PCD, PSD, Budget communal...)
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS PROJETS (' +
      '  ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  CODE_PROJET VARCHAR(30) UNIQUE NOT NULL, ' +
      '  INTITULE VARCHAR(255) NOT NULL, ' +
      '  PROGRAMME VARCHAR(60) DEFAULT ''PCD'', ' +
      '  LOCALISATION VARCHAR(150), ' +
      '  ANNEE_BUDGETAIRE INTEGER, ' +
      '  AUTORISATION_ENGAGEMENT DOUBLE DEFAULT 0, ' +
      '  STATUT VARCHAR(30) DEFAULT ''En cours'', ' +
      '  DATE_CREATION DATE ' +
      ');'
    );

    // 2. Table des Fiches Techniques
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS FICHES_TECHNIQUES (' +
      '  ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  NUMERO_FICHE VARCHAR(30) UNIQUE NOT NULL, ' +
      '  PROJET_ID INTEGER REFERENCES PROJETS(ID) ON DELETE CASCADE, ' +
      '  DATE_FICHE DATE, ' +
      '  OBJET_OPERATION VARCHAR(255) NOT NULL, ' +
      '  LOCALISATION VARCHAR(150), ' +
      '  INGENIEUR_RESPONSABLE VARCHAR(100), ' +
      '  STATUT VARCHAR(30) DEFAULT ''Etude'', ' +
      '  TAUX_TVA DOUBLE DEFAULT 19.0, ' +
      '  TAUX_REMISE DOUBLE DEFAULT 0.0, ' +
      '  MONTANT_TOTAL_HT DOUBLE DEFAULT 0.0, ' +
      '  MONTANT_TVA DOUBLE DEFAULT 0.0, ' +
      '  MONTANT_TOTAL_TTC DOUBLE DEFAULT 0.0, ' +
      '  DATE_MODIFICATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP ' +
      ');'
    );

    // 3. Table des Lots de Travaux par Fiche
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS LOTS_TRAVAUX (' +
      '  ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  FICHE_ID INTEGER REFERENCES FICHES_TECHNIQUES(ID) ON DELETE CASCADE, ' +
      '  NUMERO_LOT INTEGER NOT NULL, ' +
      '  DESIGNATION_LOT VARCHAR(150) NOT NULL, ' +
      '  MONTANT_LOT_HT DOUBLE DEFAULT 0.0 ' +
      ');'
    );

    // 4. Table des Lignes de Devis Quantitatif et Estimatif
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS LIGNES_DEVIS (' +
      '  ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  LOT_ID INTEGER REFERENCES LOTS_TRAVAUX(ID) ON DELETE CASCADE, ' +
      '  NUMERO_PRIX INTEGER NOT NULL, ' +
      '  CODE_ARTICLE VARCHAR(30), ' +
      '  DESIGNATION_ARTICLE TEXT NOT NULL, ' +
      '  UNITE VARCHAR(15) DEFAULT ''U'', ' +
      '  QUANTITE DOUBLE DEFAULT 1.0, ' +
      '  PRIX_UNITAIRE DOUBLE DEFAULT 0.0, ' +
      '  MONTANT_HT DOUBLE DEFAULT 0.0, ' +
      '  OBSERVATIONS VARCHAR(200) ' +
      ');'
    );

    // 5. Table du Bordereau des Prix Unitaires (Catalogue)
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS CATALOGUE_PRIX (' +
      '  ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  CATEGORIE_NOM VARCHAR(60) NOT NULL, ' +
      '  CODE_ARTICLE VARCHAR(30) UNIQUE NOT NULL, ' +
      '  DESIGNATION TEXT NOT NULL, ' +
      '  UNITE VARCHAR(15) NOT NULL, ' +
      '  PRIX_UNITAIRE DOUBLE NOT NULL, ' +
      '  OBSERVATIONS VARCHAR(255), ' +
      '  DATE_MAJ DATE ' +
      ');'
    );

    // 6. Index pour optimiser les performances de jointures et recherches
    FDConnection.ExecSQL('CREATE INDEX IF NOT EXISTS IDX_FICHE_PROJET ON FICHES_TECHNIQUES(PROJET_ID);');
    FDConnection.ExecSQL('CREATE INDEX IF NOT EXISTS IDX_LOT_FICHE ON LOTS_TRAVAUX(FICHE_ID);');
    FDConnection.ExecSQL('CREATE INDEX IF NOT EXISTS IDX_LIGNE_LOT ON LIGNES_DEVIS(LOT_ID);');
    FDConnection.ExecSQL('CREATE INDEX IF NOT EXISTS IDX_CAT_CODE ON CATALOGUE_PRIX(CODE_ARTICLE);');

    FDConnection.Commit;
  except
    FDConnection.Rollback;
    raise;
  end;
end;

procedure TdmMain_v3.SeedDonneesInitiales;
var
  CountProjets: Integer;
begin
  // Vérifier si la base contient déjà des données
  CountProjets := FDConnection.ExecSQLScalar('SELECT COUNT(*) FROM PROJETS');
  if CountProjets > 0 then Exit;

  FDConnection.StartTransaction;
  try
    // Insérer un projet type
    FDConnection.ExecSQL(
      'INSERT INTO PROJETS (CODE_PROJET, INTITULE, PROGRAMME, LOCALISATION, ANNEE_BUDGETAIRE, AUTORISATION_ENGAGEMENT, STATUT, DATE_CREATION) ' +
      'VALUES (''PRJ-2026-001'', ''Aménagement urbain et VRD centre-ville'', ''PCD'', ''Chef-lieu de Commune'', 2026, 45000000.0, ''En cours'', ''2026-01-15'');'
    );

    // Insérer une fiche technique de démonstration
    FDConnection.ExecSQL(
      'INSERT INTO FICHES_TECHNIQUES (NUMERO_FICHE, PROJET_ID, DATE_FICHE, OBJET_OPERATION, LOCALISATION, INGENIEUR_RESPONSABLE, STATUT, TAUX_TVA, TAUX_REMISE, MONTANT_TOTAL_HT, MONTANT_TVA, MONTANT_TOTAL_TTC) ' +
      'VALUES (''FT-01/2026'', 1, ''2026-02-01'', ''Travaux de réfection de voirie, trottoirs et éclairage'', ''Secteur Ouest'', ''Ing. Benali'', ''Validé'', 19.0, 0.0, 5747500.0, 1092025.0, 6839525.0);'
    );

    // Insérer les lots
    FDConnection.ExecSQL('INSERT INTO LOTS_TRAVAUX (FICHE_ID, NUMERO_LOT, DESIGNATION_LOT, MONTANT_LOT_HT) VALUES (1, 1, ''Lot 01 : Terrassement & Déblais'', 631000.0);');
    FDConnection.ExecSQL('INSERT INTO LOTS_TRAVAUX (FICHE_ID, NUMERO_LOT, DESIGNATION_LOT, MONTANT_LOT_HT) VALUES (1, 2, ''Lot 02 : Gros Œuvres & Béton'', 4725000.0);');
    FDConnection.ExecSQL('INSERT INTO LOTS_TRAVAUX (FICHE_ID, NUMERO_LOT, DESIGNATION_LOT, MONTANT_LOT_HT) VALUES (1, 3, ''Lot 03 : Maçonnerie & Enduits'', 391500.0);');

    // Insérer des lignes de devis
    FDConnection.ExecSQL('INSERT INTO LIGNES_DEVIS (LOT_ID, NUMERO_PRIX, CODE_ARTICLE, DESIGNATION_ARTICLE, UNITE, QUANTITE, PRIX_UNITAIRE, MONTANT_HT) VALUES (1, 1, ''TER-001'', ''Décapage terre végétale ep 20cm'', ''M²'', 1250, 180, 225000);');
    FDConnection.ExecSQL('INSERT INTO LIGNES_DEVIS (LOT_ID, NUMERO_PRIX, CODE_ARTICLE, DESIGNATION_ARTICLE, UNITE, QUANTITE, PRIX_UNITAIRE, MONTANT_HT) VALUES (1, 2, ''TER-002'', ''Fouilles en rigoles dans terrain ordinaire'', ''M³'', 340, 850, 289000);');
    FDConnection.ExecSQL('INSERT INTO LIGNES_DEVIS (LOT_ID, NUMERO_PRIX, CODE_ARTICLE, DESIGNATION_ARTICLE, UNITE, QUANTITE, PRIX_UNITAIRE, MONTANT_HT) VALUES (1, 3, ''TER-003'', ''Remblais d''''apport compacté'', ''M³'', 180, 650, 117000);');

    FDConnection.Commit;
  except
    FDConnection.Rollback;
    raise;
  end;
end;

procedure TdmMain_v3.OuvrirToutesLesTables;
begin
  try
    qryProjets.SQL.Text := 'SELECT * FROM PROJETS ORDER BY ID DESC';
    qryProjets.Open;

    qryFiches.SQL.Text := 'SELECT * FROM FICHES_TECHNIQUES ORDER BY ID DESC';
    qryFiches.Open;

    qryLots.SQL.Text := 'SELECT * FROM LOTS_TRAVAUX ORDER BY NUMERO_LOT ASC';
    qryLots.Open;

    qryLignesDevis.SQL.Text := 'SELECT * FROM LIGNES_DEVIS ORDER BY NUMERO_PRIX ASC';
    qryLignesDevis.Open;

    qryCatalogue.SQL.Text := 'SELECT * FROM CATALOGUE_PRIX ORDER BY CATEGORIE_NOM, CODE_ARTICLE ASC';
    qryCatalogue.Open;
  except
    on E: Exception do
      // Tolérance si certaines tables s'ouvrent à la demande
  end;
end;

procedure TdmMain_v3.FermerToutesLesTables;
begin
  if qryLignesDevis.Active then qryLignesDevis.Close;
  if qryLots.Active then qryLots.Close;
  if qryFiches.Active then qryFiches.Close;
  if qryProjets.Active then qryProjets.Close;
  if qryCatalogue.Active then qryCatalogue.Close;
end;

function TdmMain_v3.ExecuterSQLTransaction(const SQLCommands: array of string): Boolean;
var
  Cmd: string;
begin
  Result := False;
  FDConnection.StartTransaction;
  try
    for Cmd in SQLCommands do
    begin
      if Trim(Cmd) <> '' then
        FDConnection.ExecSQL(Cmd);
    end;
    FDConnection.Commit;
    Result := True;
  except
    FDConnection.Rollback;
    raise;
  end;
end;

function TdmMain_v3.ObtenirNouveauNumeroFiche(Annee: Integer): string;
var
  DernierId: Integer;
begin
  DernierId := FDConnection.ExecSQLScalar(
    'SELECT COALESCE(MAX(ID), 0) + 1 FROM FICHES_TECHNIQUES'
  );
  Result := Format('FT-%0.2d/%d', [DernierId, Annee]);
end;

end.
