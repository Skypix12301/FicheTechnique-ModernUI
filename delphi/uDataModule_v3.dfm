object dmMain_v3: TdmMain_v3
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 460
  Width = 620
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'LockingMode=Normal'
      'Synchronous=Normal'
      'JournalMode=WAL'
      'ForeignKeys=On')
    LoginPrompt = False
    Left = 56
    Top = 32
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 160
    Top = 32
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 272
    Top = 32
  end
  object qryProjets: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM PROJETS ORDER BY ID DESC')
    Left = 56
    Top = 120
  end
  object dsProjets: TDataSource
    DataSet = qryProjets
    Left = 144
    Top = 120
  end
  object qryFiches: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM FICHES_TECHNIQUES ORDER BY ID DESC')
    Left = 56
    Top = 192
  end
  object dsFiches: TDataSource
    DataSet = qryFiches
    Left = 144
    Top = 192
  end
  object qryLots: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM LOTS_TRAVAUX ORDER BY NUMERO_LOT ASC')
    Left = 56
    Top = 264
  end
  object dsLots: TDataSource
    DataSet = qryLots
    Left = 144
    Top = 264
  end
  object qryLignesDevis: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM LIGNES_DEVIS ORDER BY NUMERO_PRIX ASC')
    Left = 56
    Top = 336
  end
  object dsLignesDevis: TDataSource
    DataSet = qryLignesDevis
    Left = 144
    Top = 336
  end
  object qryCatalogue: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM CATALOGUE_PRIX ORDER BY CATEGORIE_NOM, CODE_ARTICLE ASC')
    Left = 280
    Top = 120
  end
  object dsCatalogue: TDataSource
    DataSet = qryCatalogue
    Left = 368
    Top = 120
  end
  object qryStatsGlobales: TFDQuery
    Connection = FDConnection
    Left = 280
    Top = 192
  end
end
