object frmCatalogue_v3: TfrmCatalogue_v3
  Left = 0
  Top = 0
  Caption = 'Bordereau des Prix Unitaires (BPU) & Catalogue d'#39'Articles'
  ClientHeight = 720
  ClientWidth = 1140
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object pnlRoot: TPanel
    Left = 0
    Top = 0
    Width = 1140
    Height = 720
    Align = alClient
    BevelOuter = bvNone
    Color = 16316668
    ParentBackground = False
    TabOrder = 0
    object pnlTopActionBar: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 1120
      Height = 54
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 6
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblFormTitle: TLabel
        Left = 16
        Top = 10
        Width = 272
        Height = 21
        Caption = 'Bordereau des Prix Unitaires (BPU)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblFormSubtitle: TLabel
        Left = 16
        Top = 32
        Width = 330
        Height = 14
        Caption = 'R'#233'f'#233'rentiel des prix standard BTPH pour devis & fiches techniques'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnInsererDansDevis: TSpeedButton
        Left = 560
        Top = 10
        Width = 160
        Height = 34
        Caption = 'Ins'#233'rer dans le Devis'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
        OnClick = btnInsererDansDevisClick
      end
      object btnNouveauPrix: TSpeedButton
        Left = 730
        Top = 10
        Width = 110
        Height = 34
        Caption = '+ Nouveau Prix'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14380837
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnNouveauPrixClick
      end
      object btnModifierPrix: TSpeedButton
        Left = 846
        Top = 10
        Width = 90
        Height = 34
        Caption = 'Modifier'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = btnModifierPrixClick
      end
      object btnSupprimerPrix: TSpeedButton
        Left = 942
        Top = 10
        Width = 96
        Height = 34
        Caption = 'Supprimer'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3553510
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = btnSupprimerPrixClick
      end
      object btnFermer: TSpeedButton
        Left = 1044
        Top = 10
        Width = 66
        Height = 34
        Caption = 'Fermer'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = btnFermerClick
      end
    end
    object pnlFilterCard: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 73
      Width = 1120
      Height = 56
      Margins.Left = 10
      Margins.Top = 3
      Margins.Right = 10
      Margins.Bottom = 6
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblRecherche: TLabel
        Left = 16
        Top = 18
        Width = 64
        Height = 15
        Caption = 'Recherche :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCategorie: TLabel
        Left = 410
        Top = 18
        Width = 60
        Height = 15
        Caption = 'Cat'#233'gorie :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCompteurArticles: TLabel
        Left = 940
        Top = 18
        Width = 150
        Height = 15
        Alignment = taRightJustify
        Caption = '20 article(s) trouv'#233'(s)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object edtSearchText: TEdit
        Left = 88
        Top = 14
        Width = 290
        Height = 24
        TabOrder = 0
        OnChange = edtSearchTextChange
      end
      object cbbCategories: TComboBox
        Left = 480
        Top = 14
        Width = 240
        Height = 23
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = 'Toutes les cat'#233'gories'
        OnChange = cbbCategoriesChange
        Items.Strings = (
          'Toutes les cat'#233'gories'
          'Terrassements'
          'Gros '#338'uvres'
          'Ma'#231'onnerie'
          'VRD & Voirie'
          #201'lectricit'#233)
      end
    end
    object pnlGridCard: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 138
      Width = 740
      Height = 572
      Margins.Left = 10
      Margins.Top = 3
      Margins.Right = 5
      Margins.Bottom = 10
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object dbgCatalogue: TDBGrid
        Left = 0
        Top = 0
        Width = 740
        Height = 572
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsCatalogue
        DrawingStyle = gdsClassic
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDblClick = dbgCatalogueDblClick
        OnDrawColumnCell = dbgCatalogueDrawColumnCell
        Columns = <
          item
            Expanded = False
            FieldName = 'CODE_ARTICLE'
            Title.Caption = 'Code'
            Width = 85
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DESIGNATION'
            Title.Caption = 'D'#233'signation des Travaux'
            Width = 330
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CATEGORIE_NOM'
            Title.Caption = 'Cat'#233'gorie'
            Width = 110
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'UNITE'
            Title.Alignment = taCenter
            Title.Caption = 'Unit'#233
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PRIX_UNITAIRE'
            Title.Alignment = taRightJustify
            Title.Caption = 'P.U (DZD)'
            Width = 110
            Visible = True
          end>
      end
    end
    object pnlDetailCard: TPanel
      AlignWithMargins = True
      Left = 758
      Top = 138
      Width = 372
      Height = 572
      Margins.Left = 3
      Margins.Top = 3
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alRight
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblDetailTitle: TLabel
        Left = 16
        Top = 14
        Width = 146
        Height = 17
        Caption = 'Fiche Article du Bordereau'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDetailCode: TLabel
        Left = 16
        Top = 48
        Width = 73
        Height = 15
        Caption = 'Code Article :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDetailCategorie: TLabel
        Left = 16
        Top = 102
        Width = 57
        Height = 15
        Caption = 'Cat'#233'gorie :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDetailDesignation: TLabel
        Left = 16
        Top = 158
        Width = 140
        Height = 15
        Caption = 'D'#233'signation des Travaux :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDetailUnite: TLabel
        Left = 16
        Top = 278
        Width = 34
        Height = 15
        Caption = 'Unit'#233' :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDetailPU: TLabel
        Left = 150
        Top = 278
        Width = 99
        Height = 15
        Caption = 'Prix Unitaire H.T. :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDetailDZD: TLabel
        Left = 325
        Top = 300
        Width = 24
        Height = 15
        Caption = #1583'.'#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14380837
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDetailObservations: TLabel
        Left = 16
        Top = 338
        Width = 74
        Height = 15
        Caption = 'Sp'#233'cifications :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtDetailCode: TEdit
        Left = 16
        Top = 68
        Width = 330
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14380837
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
      end
      object cbbDetailCategorie: TComboBox
        Left = 16
        Top = 122
        Width = 330
        Height = 23
        Style = csDropDownList
        TabOrder = 1
        Items.Strings = (
          'Terrassements'
          'Gros '#338'uvres'
          'Ma'#231'onnerie'
          'VRD & Voirie'
          #201'lectricit'#233)
      end
      object memDetailDesignation: TMemo
        Left = 16
        Top = 178
        Width = 330
        Height = 88
        ScrollBars = ssVertical
        TabOrder = 2
      end
      object cbbDetailUnite: TComboBox
        Left = 16
        Top = 298
        Width = 110
        Height = 23
        TabOrder = 3
        Items.Strings = (
          'M'#178
          'M'#179
          'ML'
          'KG'
          'T'
          'U'
          'FF'
          'ENS')
      end
      object edtDetailPU: TEdit
        Left = 150
        Top = 298
        Width = 168
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
      end
      object memDetailObservations: TMemo
        Left = 16
        Top = 358
        Width = 330
        Height = 90
        ScrollBars = ssVertical
        TabOrder = 5
      end
      object btnSauvegarderDetail: TSpeedButton
        Left = 16
        Top = 470
        Width = 160
        Height = 34
        Caption = 'Valider Article'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnSauvegarderDetailClick
      end
      object btnAnnulerDetail: TSpeedButton
        Left = 186
        Top = 470
        Width = 160
        Height = 34
        Caption = 'R'#233'initialiser'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = btnAnnulerDetailClick
      end
    end
  end
  object dsCatalogue: TDataSource
    DataSet = mtCatalogue
    OnDataChange = dsCatalogueDataChange
    Left = 72
    Top = 360
  end
  object mtCatalogue: TFDMemTable
    Left = 152
    Top = 360
  end
end
