unit uDataModule_v3;

{
  ==========================================================================
  uDataModule_v3.pas - Module de données v3
  ==========================================================================
  Copie fidèle de uDataModule.pas original avec :
  - Mêmes composants (FDConnection, FDQuery, StoredProcs, DataSources)
  - Mêmes méthodes CRUD (Projets, Fiches, Lots, Lignes, Catalogue, Paramètres)
  - Référence au thème moderne (uModernTheme)
  - Aucune modification fonctionnelle — compatibilité totale avec la BDD
  ==========================================================================
}

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.UI, System.IniFiles, FireDAC.Phys.ODBCBase, System.Hash;

type
  TdmMain = class(TDataModule)
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    qryProjets: TFDQuery;
    qryFiches: TFDQuery;
    qryLotsFiches: TFDQuery;
    qryLignesFiches: TFDQuery;
    qryTypesProjets: TFDQuery;
    qryUnites: TFDQuery;
    qryCatalogue: TFDQuery;
    qryParametres: TFDQuery;
    qryUtilisateurs: TFDQuery;
    qryGeneral: TFDQuery;
    qryTotauxLots: TFDQuery;
    dsProjets: TDataSource;
    dsFiches: TDataSource;
    dsLotsFiches: TDataSource;
    dsLignesFiches: TDataSource;
    dsTypesProjets: TDataSource;
    dsUnites: TDataSource;
    dsCatalogue: TDataSource;
    dsParametres: TDataSource;
    spCreerFicheVide: TFDStoredProc;
    spAjouterLotFiche: TFDStoredProc;
    spCalculerTotaux: TFDStoredProc;
    spDupliquerFiche: TFDStoredProc;
    spGenererNumero: TFDStoredProc;
    procedure DataModuleCreate(Sender: TObject);
  private
    FUtilisateurID: Integer;
    FNomUtilisateur: string;
    FNomComplet: string;
    FRole: string;
    FLastError: string;
    procedure ChargerParametresConnexion;
  public
    // --- Connexion ---
    function Connecter: Boolean;
    procedure Deconnecter;

    // --- Authentification ---
    function Authentifier(const ALogin, AMotDePasse: string): Boolean;

    // --- Projets ---
    procedure ChargerProjets;
    function AjouterProjet(TypeProjetID: Integer; const Code, Nom, Wilaya,
      Daira, Commune, MaitreOuvrage: string): Integer;
    procedure ModifierProjet(ProjetID: Integer; const Nom, Wilaya,
      Daira, Commune, MaitreOuvrage: string);
    procedure SupprimerProjet(ProjetID: Integer);

    // --- Fiches Techniques ---
    procedure ChargerFiches(ProjetID: Integer = 0; const Statut: string = '');
    function CreerFicheVide(ProjetID: Integer; const NumeroFiche, Operation: string): Integer;
    function CreerFicheDepuisTemplate(TemplateID, ProjetID: Integer;
      const NumeroFiche, Operation: string): Integer;
    procedure ModifierFiche(FicheID: Integer; const Operation: string; TauxTVA: Double);
    procedure SupprimerFiche(FicheID: Integer);
    procedure ValiderFiche(FicheID: Integer);
    function DupliquerFiche(FicheIDSource: Integer; const NouveauNumero: string): Integer;
    function GenererNumeroFiche(ProjetID: Integer): string;

    // --- Lots ---
    procedure ChargerLotsFiche(FicheID: Integer);
    function AjouterLot(FicheID: Integer; const CodeLot, NomLot: string): Integer;
    procedure SupprimerLot(LotFicheID: Integer);
    procedure RenommerLot(LotFicheID: Integer; const NouveauNom: string);

    // --- Lignes ---
    procedure ChargerLignesLot(LotFicheID: Integer);
    function AjouterLigne(FicheID, LotFicheID: Integer; const NumeroLigne,
      Designation: string; UniteID: Integer; Quantite, PrixUnitaire: Double): Integer;
    procedure ModifierLigne(LigneID: Integer; const Designation: string;
      UniteID: Integer; Quantite, PrixUnitaire: Double);
    procedure SupprimerLigne(LigneID: Integer);

    // --- Catalogue ---
    procedure ChargerCatalogue(TypeProjetID: Integer = 0);

    // --- Paramètres ---
    function GetParametre(const Cle: string): string;
    procedure SetParametre(const Cle, Valeur: string);

    // --- Utilitaires ---
    procedure RecalculerTotaux(FicheID: Integer);
    procedure ChargerTotauxParLot(FicheID: Integer);

    // --- Propriétés ---
    property LastError: string read FLastError;
    property UtilisateurID: Integer read FUtilisateurID;
    property NomUtilisateur: string read FNomUtilisateur;
    property NomComplet: string read FNomComplet;
    property Role: string read FRole;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  FUtilisateurID := 0;
  FNomUtilisateur := '';
  FNomComplet := '';
  FRole := '';
  ChargerParametresConnexion;
end;

procedure TdmMain.ChargerParametresConnexion;
var
  Ini: TIniFile;
  IniPath: string;
begin
  IniPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  if FileExists(IniPath) then
  begin
    Ini := TIniFile.Create(IniPath);
    try
      FDConnection1.Params.Values['Server'] :=
        Ini.ReadString('Database', 'Server', 'localhost');
      FDConnection1.Params.Values['Database'] :=
        Ini.ReadString('Database', 'Database', 'GestionFichesTechniques');
      FDConnection1.Params.Values['User_Name'] :=
        Ini.ReadString('Database', 'User', 'sa');
      FDConnection1.Params.Values['Password'] :=
        Ini.ReadString('Database', 'Password', '');

      if Ini.ReadBool('Database', 'WindowsAuth', True) then
        FDConnection1.Params.Values['OSAuthent'] := 'Yes'
      else
        FDConnection1.Params.Values['OSAuthent'] := 'No';
    finally
      Ini.Free;
    end;
  end;
end;

function TdmMain.Connecter: Boolean;
begin
  Result := False;
  try
    FDConnection1.Connected := True;
    Result := True;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      Result := False;
    end;
  end;
end;

procedure TdmMain.Deconnecter;
begin
  FDConnection1.Connected := False;
end;

function TdmMain.Authentifier(const ALogin, AMotDePasse: string): Boolean;
var
  StoredHash, Salt, LegacyPwd: string;
  HasCols, Ok: Boolean;
  G: TGUID;
begin
  Result := False;
  FLastError := '';
  try
    qryGeneral.Close;
    HasCols := True;
    try
      qryGeneral.SQL.Text :=
        'SELECT UtilisateurID, NomComplet, Role, MotDePasse, PasswordHash, Salt ' +
        'FROM Utilisateurs WHERE NomUtilisateur = :Login AND Actif = 1';
      qryGeneral.ParamByName('Login').AsString := ALogin;
      qryGeneral.Open;
    except
      HasCols := False;
      qryGeneral.Close;
      qryGeneral.SQL.Text :=
        'SELECT UtilisateurID, NomComplet, Role, MotDePasse ' +
        'FROM Utilisateurs WHERE NomUtilisateur = :Login AND Actif = 1';
      qryGeneral.ParamByName('Login').AsString := ALogin;
      qryGeneral.Open;
    end;

    if qryGeneral.IsEmpty then
    begin
      qryGeneral.Close;
      Exit;
    end;

    FUtilisateurID := qryGeneral.FieldByName('UtilisateurID').AsInteger;
    FNomUtilisateur := ALogin;
    FNomComplet := qryGeneral.FieldByName('NomComplet').AsString;
    FRole := qryGeneral.FieldByName('Role').AsString;
    if HasCols then
    begin
      StoredHash := qryGeneral.FieldByName('PasswordHash').AsString;
      Salt := qryGeneral.FieldByName('Salt').AsString;
    end
    else
    begin
      StoredHash := '';
      Salt := '';
    end;
    if StoredHash = '' then
      LegacyPwd := qryGeneral.FieldByName('MotDePasse').AsString
    else
      LegacyPwd := '';
    qryGeneral.Close;

    Ok := False;
    if StoredHash <> '' then
      Ok := SameText(THashSHA2.GetHashString(Salt + AMotDePasse, SHA256), StoredHash)
    else if LegacyPwd = AMotDePasse then
    begin
      CreateGUID(G);
      Salt := Copy(GUIDToString(G), 2, 36);
      Salt := StringReplace(Salt, '-', '', [rfReplaceAll]);
      StoredHash := THashSHA2.GetHashString(Salt + AMotDePasse, SHA256);
      if HasCols then
      begin
        qryGeneral.SQL.Text :=
          'UPDATE Utilisateurs SET PasswordHash = :H, Salt = :S WHERE UtilisateurID = :ID';
        qryGeneral.ParamByName('H').AsString := StoredHash;
        qryGeneral.ParamByName('S').AsString := Salt;
        qryGeneral.ParamByName('ID').AsInteger := FUtilisateurID;
        qryGeneral.ExecSQL;
      end;
      Ok := True;
    end;

    if not Ok then
      Exit;

    qryGeneral.SQL.Text :=
      'UPDATE Utilisateurs SET DerniereConnexion = GETDATE() WHERE UtilisateurID = :ID';
    qryGeneral.ParamByName('ID').AsInteger := FUtilisateurID;
    qryGeneral.ExecSQL;
    Result := True;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      Result := False;
    end;
  end;
end;

// === PROJETS ===

procedure TdmMain.ChargerProjets;
begin
  qryProjets.Close;
  qryProjets.Open;
end;

function TdmMain.AjouterProjet(TypeProjetID: Integer; const Code, Nom,
  Wilaya, Daira, Commune, MaitreOuvrage: string): Integer;
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'INSERT INTO Projets (TypeProjetID, CodeProjet, NomProjet, Wilaya, Daira, ' +
    'Commune, MaitreOuvrage, UtilisateurCreation) ' +
    'VALUES (:TypeID, :Code, :Nom, :Wilaya, :Daira, :Commune, :MO, :User); ' +
    'SELECT SCOPE_IDENTITY() AS NewID';
  qryGeneral.ParamByName('TypeID').AsInteger := TypeProjetID;
  qryGeneral.ParamByName('Code').AsString := Code;
  qryGeneral.ParamByName('Nom').AsString := Nom;
  qryGeneral.ParamByName('Wilaya').AsString := Wilaya;
  qryGeneral.ParamByName('Daira').AsString := Daira;
  qryGeneral.ParamByName('Commune').AsString := Commune;
  qryGeneral.ParamByName('MO').AsString := MaitreOuvrage;
  qryGeneral.ParamByName('User').AsString := FNomUtilisateur;
  qryGeneral.Open;
  Result := qryGeneral.FieldByName('NewID').AsInteger;
  qryGeneral.Close;
end;

procedure TdmMain.ModifierProjet(ProjetID: Integer; const Nom, Wilaya,
  Daira, Commune, MaitreOuvrage: string);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE Projets SET NomProjet = :Nom, Wilaya = :Wilaya, Daira = :Daira, ' +
    'Commune = :Commune, MaitreOuvrage = :MO, DateModification = GETDATE(), ' +
    'UtilisateurModification = :User WHERE ProjetID = :ID';
  qryGeneral.ParamByName('Nom').AsString := Nom;
  qryGeneral.ParamByName('Wilaya').AsString := Wilaya;
  qryGeneral.ParamByName('Daira').AsString := Daira;
  qryGeneral.ParamByName('Commune').AsString := Commune;
  qryGeneral.ParamByName('MO').AsString := MaitreOuvrage;
  qryGeneral.ParamByName('User').AsString := FNomUtilisateur;
  qryGeneral.ParamByName('ID').AsInteger := ProjetID;
  qryGeneral.ExecSQL;
end;

procedure TdmMain.SupprimerProjet(ProjetID: Integer);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text := 'DELETE FROM Projets WHERE ProjetID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := ProjetID;
  qryGeneral.ExecSQL;
end;

// === FICHES TECHNIQUES ===

procedure TdmMain.ChargerFiches(ProjetID: Integer; const Statut: string);
var
  SQL: string;
begin
  SQL := 'SELECT * FROM Vue_FichesResume WHERE 1=1';
  if ProjetID > 0 then
    SQL := SQL + ' AND ProjetID = ' + IntToStr(ProjetID);
  if Statut <> '' then
    SQL := SQL + ' AND Statut = ''' + Statut + '''';
  SQL := SQL + ' ORDER BY DateCreation DESC';

  qryFiches.Close;
  qryFiches.SQL.Text := SQL;
  qryFiches.Open;
end;

function TdmMain.CreerFicheVide(ProjetID: Integer;
  const NumeroFiche, Operation: string): Integer;
begin
  spCreerFicheVide.Prepare;
  spCreerFicheVide.ParamByName('@ProjetID').AsInteger := ProjetID;
  spCreerFicheVide.ParamByName('@NumeroFiche').AsString := NumeroFiche;
  spCreerFicheVide.ParamByName('@Operation').AsString := Operation;
  spCreerFicheVide.ParamByName('@UtilisateurCreation').AsString := FNomUtilisateur;
  spCreerFicheVide.ExecProc;
  Result := spCreerFicheVide.ParamByName('@NouveauFicheID').AsInteger;
end;

function TdmMain.CreerFicheDepuisTemplate(TemplateID, ProjetID: Integer;
  const NumeroFiche, Operation: string): Integer;
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'DECLARE @FicheID INT; ' +
    'EXEC sp_CreerFicheDepuisTemplate :TemplateID, :ProjetID, :NumFiche, ' +
    ':Operation, :User, @FicheID OUTPUT; ' +
    'SELECT @FicheID AS NewID';
  qryGeneral.ParamByName('TemplateID').AsInteger := TemplateID;
  qryGeneral.ParamByName('ProjetID').AsInteger := ProjetID;
  qryGeneral.ParamByName('NumFiche').AsString := NumeroFiche;
  qryGeneral.ParamByName('Operation').AsString := Operation;
  qryGeneral.ParamByName('User').AsString := FNomUtilisateur;
  qryGeneral.Open;
  Result := qryGeneral.FieldByName('NewID').AsInteger;
  qryGeneral.Close;
end;

procedure TdmMain.ModifierFiche(FicheID: Integer; const Operation: string;
  TauxTVA: Double);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE FichesTechniques SET Operation = :Op, TauxTVA = :TVA, ' +
    'DateModification = GETDATE(), UtilisateurModification = :User ' +
    'WHERE FicheID = :ID';
  qryGeneral.ParamByName('Op').AsString := Operation;
  qryGeneral.ParamByName('TVA').AsFloat := TauxTVA;
  qryGeneral.ParamByName('User').AsString := FNomUtilisateur;
  qryGeneral.ParamByName('ID').AsInteger := FicheID;
  qryGeneral.ExecSQL;
end;

procedure TdmMain.SupprimerFiche(FicheID: Integer);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text := 'DELETE FROM FichesTechniques WHERE FicheID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := FicheID;
  qryGeneral.ExecSQL;
end;

procedure TdmMain.ValiderFiche(FicheID: Integer);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE FichesTechniques SET Statut = :Statut, ' +
    'DateValidation = GETDATE(), UtilisateurValidation = :User ' +
    'WHERE FicheID = :ID';
  qryGeneral.ParamByName('Statut').AsString := #1605#1589#1575#1583#1602' '#1593#1604#1610#1607;
  qryGeneral.ParamByName('User').AsString := FNomUtilisateur;
  qryGeneral.ParamByName('ID').AsInteger := FicheID;
  qryGeneral.ExecSQL;
end;

function TdmMain.DupliquerFiche(FicheIDSource: Integer;
  const NouveauNumero: string): Integer;
begin
  spDupliquerFiche.Prepare;
  spDupliquerFiche.ParamByName('@FicheIDSource').AsInteger := FicheIDSource;
  spDupliquerFiche.ParamByName('@NouveauNumeroFiche').AsString := NouveauNumero;
  spDupliquerFiche.ParamByName('@UtilisateurCreation').AsString := FNomUtilisateur;
  spDupliquerFiche.ExecProc;
  Result := spDupliquerFiche.ParamByName('@NouveauFicheID').AsInteger;
end;

function TdmMain.GenererNumeroFiche(ProjetID: Integer): string;
begin
  spGenererNumero.Prepare;
  spGenererNumero.ParamByName('@ProjetID').AsInteger := ProjetID;
  spGenererNumero.ExecProc;
  Result := spGenererNumero.ParamByName('@NouveauNumero').AsString;
end;

// === LOTS ===

procedure TdmMain.ChargerLotsFiche(FicheID: Integer);
begin
  qryLotsFiches.Close;
  qryLotsFiches.ParamByName('FicheID').AsInteger := FicheID;
  qryLotsFiches.Open;
end;

function TdmMain.AjouterLot(FicheID: Integer;
  const CodeLot, NomLot: string): Integer;
begin
  spAjouterLotFiche.Prepare;
  spAjouterLotFiche.ParamByName('@FicheID').AsInteger := FicheID;
  spAjouterLotFiche.ParamByName('@CodeLot').AsString := CodeLot;
  spAjouterLotFiche.ParamByName('@NomLot').AsString := NomLot;
  spAjouterLotFiche.ExecProc;
  Result := spAjouterLotFiche.ParamByName('@NouveauLotFicheID').AsInteger;
end;

procedure TdmMain.SupprimerLot(LotFicheID: Integer);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text := 'DELETE FROM LotsFiches WHERE LotFicheID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := LotFicheID;
  qryGeneral.ExecSQL;
end;

procedure TdmMain.RenommerLot(LotFicheID: Integer; const NouveauNom: string);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE LotsFiches SET NomLot = :Nom WHERE LotFicheID = :ID';
  qryGeneral.ParamByName('Nom').AsString := NouveauNom;
  qryGeneral.ParamByName('ID').AsInteger := LotFicheID;
  qryGeneral.ExecSQL;
end;

// === LIGNES ===

procedure TdmMain.ChargerLignesLot(LotFicheID: Integer);
begin
  qryLignesFiches.Close;
  qryLignesFiches.ParamByName('LotFicheID').AsInteger := LotFicheID;
  qryLignesFiches.Open;
end;

function TdmMain.AjouterLigne(FicheID, LotFicheID: Integer;
  const NumeroLigne, Designation: string; UniteID: Integer;
  Quantite, PrixUnitaire: Double): Integer;
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'INSERT INTO LignesFiches (FicheID, LotFicheID, NumeroLigne, Designation, ' +
    'UniteID, Quantite, PrixUnitaire) ' +
    'VALUES (:FicheID, :LotID, :NumLigne, :Design, :UniteID, :Qte, :PU); ' +
    'SELECT SCOPE_IDENTITY() AS NewID';
  qryGeneral.ParamByName('FicheID').AsInteger := FicheID;
  qryGeneral.ParamByName('LotID').AsInteger := LotFicheID;
  qryGeneral.ParamByName('NumLigne').AsString := NumeroLigne;
  qryGeneral.ParamByName('Design').AsString := Designation;
  qryGeneral.ParamByName('UniteID').AsInteger := UniteID;
  qryGeneral.ParamByName('Qte').AsFloat := Quantite;
  qryGeneral.ParamByName('PU').AsFloat := PrixUnitaire;
  qryGeneral.Open;
  Result := qryGeneral.FieldByName('NewID').AsInteger;
  qryGeneral.Close;
end;

procedure TdmMain.ModifierLigne(LigneID: Integer; const Designation: string;
  UniteID: Integer; Quantite, PrixUnitaire: Double);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE LignesFiches SET Designation = :Design, UniteID = :UniteID, ' +
    'Quantite = :Qte, PrixUnitaire = :PU, DateModification = GETDATE() ' +
    'WHERE LigneID = :ID';
  qryGeneral.ParamByName('Design').AsString := Designation;
  qryGeneral.ParamByName('UniteID').AsInteger := UniteID;
  qryGeneral.ParamByName('Qte').AsFloat := Quantite;
  qryGeneral.ParamByName('PU').AsFloat := PrixUnitaire;
  qryGeneral.ParamByName('ID').AsInteger := LigneID;
  qryGeneral.ExecSQL;
end;

procedure TdmMain.SupprimerLigne(LigneID: Integer);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text := 'DELETE FROM LignesFiches WHERE LigneID = :ID';
  qryGeneral.ParamByName('ID').AsInteger := LigneID;
  qryGeneral.ExecSQL;
end;

// === CATALOGUE ===

procedure TdmMain.ChargerCatalogue(TypeProjetID: Integer);
var
  SQL: string;
begin
  SQL := 'SELECT * FROM Vue_CatalogueArticlesDetail WHERE Actif = 1';
  if TypeProjetID > 0 then
    SQL := SQL + ' AND TypeProjetID = ' + IntToStr(TypeProjetID);
  SQL := SQL + ' ORDER BY CodeArticle';

  qryCatalogue.Close;
  qryCatalogue.SQL.Text := SQL;
  qryCatalogue.Open;
end;

// === PARAMETRES ===

function TdmMain.GetParametre(const Cle: string): string;
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'SELECT ValeurParametre FROM Parametres WHERE CleParametre = :Cle';
  qryGeneral.ParamByName('Cle').AsString := Cle;
  qryGeneral.Open;
  if not qryGeneral.IsEmpty then
    Result := qryGeneral.FieldByName('ValeurParametre').AsString
  else
    Result := '';
  qryGeneral.Close;
end;

procedure TdmMain.SetParametre(const Cle, Valeur: string);
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text :=
    'UPDATE Parametres SET ValeurParametre = :Val, DateModification = GETDATE() ' +
    'WHERE CleParametre = :Cle';
  qryGeneral.ParamByName('Val').AsString := Valeur;
  qryGeneral.ParamByName('Cle').AsString := Cle;
  qryGeneral.ExecSQL;
  if qryGeneral.RowsAffected = 0 then
  begin
    qryGeneral.Close;
    qryGeneral.SQL.Text :=
      'INSERT INTO Parametres (CleParametre, ValeurParametre) VALUES (:Cle2, :Val2)';
    qryGeneral.ParamByName('Cle2').AsString := Cle;
    qryGeneral.ParamByName('Val2').AsString := Valeur;
    qryGeneral.ExecSQL;
  end;
end;

// === UTILITAIRES ===

procedure TdmMain.RecalculerTotaux(FicheID: Integer);
begin
  spCalculerTotaux.Prepare;
  spCalculerTotaux.ParamByName('@FicheID').AsInteger := FicheID;
  spCalculerTotaux.ExecProc;
end;

procedure TdmMain.ChargerTotauxParLot(FicheID: Integer);
begin
  qryTotauxLots.Close;
  qryTotauxLots.ParamByName('FicheID').AsInteger := FicheID;
  qryTotauxLots.Open;
end;

end.
