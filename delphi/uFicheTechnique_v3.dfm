object frmFicheTechnique_v3: TfrmFicheTechnique_v3
  Left = 0
  Top = 0
  Caption = #201'diteur de Fiche Technique & Devis Estimatif'
  ClientHeight = 780
  ClientWidth = 1120
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
    Width = 1120
    Height = 780
    Align = alClient
    BevelOuter = bvNone
    Color = 16316668
    ParentBackground = False
    TabOrder = 0
    object pnlTopActionBar: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 1100
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
        Top = 16
        Width = 265
        Height = 21
        Caption = 'Fiche Technique & Devis Estimatif'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblFicheStatusBadge: TLabel
        Left = 295
        Top = 16
        Width = 100
        Height = 22
        Alignment = taCenter
        AutoSize = False
        Caption = #1602#1610#1583' '#1575#1604#1583#1585#1575#1587#1574' ('#201'tude)'
        Color = 16775137
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11692544
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
      end
      object btnEnregistrer: TSpeedButton
        Left = 670
        Top = 10
        Width = 100
        Height = 34
        Caption = 'Enregistrer'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnEnregistrerClick
      end
      object btnValiderFiche: TSpeedButton
        Left = 776
        Top = 10
        Width = 110
        Height = 34
        Caption = 'Valider (F2)'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnValiderFicheClick
      end
      object btnImprimerA4: TSpeedButton
        Left = 892
        Top = 10
        Width = 110
        Height = 34
        Caption = 'Imprimer A4'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14380837
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnImprimerA4Click
      end
      object btnFermer: TSpeedButton
        Left = 1008
        Top = 10
        Width = 80
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
    object pnlHeaderCard: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 73
      Width = 1100
      Height = 98
      Margins.Left = 10
      Margins.Top = 3
      Margins.Right = 10
      Margins.Bottom = 6
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblNumeroFiche: TLabel
        Left = 16
        Top = 12
        Width = 47
        Height = 15
        Caption = 'N'#176' Fiche :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDateFiche: TLabel
        Left = 180
        Top = 12
        Width = 31
        Height = 15
        Caption = 'Date :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblProjet: TLabel
        Left = 320
        Top = 12
        Width = 38
        Height = 15
        Caption = 'Projet :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTauxTVA: TLabel
        Left = 770
        Top = 12
        Width = 55
        Height = 15
        Caption = 'Taux TVA :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTauxRemise: TLabel
        Left = 880
        Top = 12
        Width = 63
        Height = 15
        Caption = 'Remise % :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblOperation: TLabel
        Left = 16
        Top = 52
        Width = 60
        Height = 15
        Caption = 'Op'#233'ration :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edtNumeroFiche: TEdit
        Left = 72
        Top = 8
        Width = 96
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14380837
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        Text = 'FT-01/2026'
      end
      object dtpDateFiche: TDateTimePicker
        Left = 216
        Top = 8
        Width = 94
        Height = 24
        Date = 45914.000000000000000000
        Time = 0.500000000000000000
        TabOrder = 1
      end
      object cbbProjets: TComboBox
        Left = 366
        Top = 8
        Width = 390
        Height = 23
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 2
        Text = 'PCD - Am'#233'nagement urbain centre-ville'
        Items.Strings = (
          'PCD - Am'#233'nagement urbain centre-ville'
          'PSD - R'#233'fection des voies et trottoirs'
          'Budget Communal - '#201'cole primaire')
      end
      object cbbTauxTVA: TComboBox
        Left = 830
        Top = 8
        Width = 44
        Height = 23
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 3
        Text = '19%'
        OnChange = cbbTauxTVAChange
        Items.Strings = (
          '19%'
          '9%'
          '0%')
      end
      object edtTauxRemise: TEdit
        Left = 948
        Top = 8
        Width = 48
        Height = 24
        TabOrder = 4
        Text = '0.00'
        OnChange = edtTauxRemiseChange
      end
      object edtOperation: TEdit
        Left = 84
        Top = 48
        Width = 998
        Height = 24
        TabOrder = 5
        Text = 'Travaux d'#39'am'#233'nagement ext'#233'rieur, voirie et trottoirs au chef-lieu de commune'
      end
    end
    object pnlLotsAndGridCard: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 180
      Width = 1100
      Height = 440
      Margins.Left = 10
      Margins.Top = 3
      Margins.Right = 10
      Margins.Bottom = 6
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object pnlLotsTabBar: TPanel
        Left = 0
        Top = 0
        Width = 1100
        Height = 44
        Align = alTop
        BevelOuter = bvNone
        Color = 16316668
        ParentBackground = False
        TabOrder = 0
        object lblLotsTitle: TLabel
          Left = 12
          Top = 13
          Width = 59
          Height = 15
          Caption = 'Lot d'#39#233'tude :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1972778
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblMontantLotEnCours: TLabel
          Left = 760
          Top = 13
          Width = 220
          Height = 17
          Alignment = taRightJustify
          Caption = 'Sous-total Lot : 0.00 '#1583'.'#1580
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14380837
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnAjouterLot: TSpeedButton
          Left = 416
          Top = 8
          Width = 90
          Height = 28
          Caption = '+ Nv. Lot'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3046706
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = btnAjouterLotClick
        end
        object btnSupprimerLot: TSpeedButton
          Left = 512
          Top = 8
          Width = 86
          Height = 28
          Caption = '- Suppr. Lot'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3553510
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          OnClick = btnSupprimerLotClick
        end
        object cbbLotsSelector: TComboBox
          Left = 82
          Top = 9
          Width = 328
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbbLotsSelectorChange
        end
      end
      object pnlGridToolbar: TPanel
        Left = 0
        Top = 44
        Width = 1100
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object btnAjouterLigne: TSpeedButton
          Left = 12
          Top = 6
          Width = 120
          Height = 28
          Caption = '+ Ajouter Article'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 14380837
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = btnAjouterLigneClick
        end
        object btnSupprimerLigne: TSpeedButton
          Left = 138
          Top = 6
          Width = 104
          Height = 28
          Caption = 'Supprimer (Suppr)'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3553510
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          OnClick = btnSupprimerLigneClick
        end
        object btnCalculerTotaux: TSpeedButton
          Left = 248
          Top = 6
          Width = 116
          Height = 28
          Caption = 'Recalculer Totaux'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1972778
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = btnCalculerTotauxClick
        end
        object lblNombreLignes: TLabel
          Left = 980
          Top = 12
          Width = 90
          Height = 15
          Alignment = taRightJustify
          Caption = '3 article(s)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6579307
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object dbgLignesDevis: TDBGrid
        Left = 0
        Top = 84
        Width = 1100
        Height = 356
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsLignesDevis
        DrawingStyle = gdsClassic
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnColExit = dbgLignesDevisColExit
        OnDrawColumnCell = dbgLignesDevisDrawColumnCell
        Columns = <
          item
            Expanded = False
            FieldName = 'NUMERO_PRIX'
            Title.Alignment = taCenter
            Title.Caption = 'N'#176' Prix'
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CODE_ARTICLE'
            Title.Caption = 'Code Article'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DESIGNATION'
            Title.Caption = 'D'#233'signation des Travaux / Fournitures'
            Width = 430
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
            FieldName = 'QUANTITE'
            Title.Alignment = taRightJustify
            Title.Caption = 'Quantit'#233
            Width = 75
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PRIX_UNITAIRE'
            Title.Alignment = taRightJustify
            Title.Caption = 'P.U (DZD)'
            Width = 95
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MONTANT_HT'
            ReadOnly = True
            Title.Alignment = taRightJustify
            Title.Caption = 'Montant HT (DZD)'
            Width = 120
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'OBSERVATIONS'
            Title.Caption = 'Observations'
            Width = 130
            Visible = True
          end>
      end
    end
    object pnlFinancialCard: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 629
      Width = 1100
      Height = 141
      Margins.Left = 10
      Margins.Top = 3
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblTotalHTLabel: TLabel
        Left = 760
        Top = 14
        Width = 100
        Height = 15
        Caption = 'Total Global HT :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalHTValue: TLabel
        Left = 910
        Top = 14
        Width = 160
        Height = 17
        Alignment = taRightJustify
        Caption = '0.00 '#1583'.'#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblRemiseLabel: TLabel
        Left = 760
        Top = 38
        Width = 84
        Height = 15
        Caption = 'Remise '#233'vent. :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblRemiseValue: TLabel
        Left = 910
        Top = 38
        Width = 160
        Height = 15
        Alignment = taRightJustify
        Caption = '- 0.00 '#1583'.'#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3553510
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTVALabel: TLabel
        Left = 760
        Top = 60
        Width = 82
        Height = 15
        Caption = 'TVA Factur'#233'e :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTVAValue: TLabel
        Left = 910
        Top = 60
        Width = 160
        Height = 15
        Alignment = taRightJustify
        Caption = '0.00 '#1583'.'#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 35607
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalTTCLabel: TLabel
        Left = 760
        Top = 88
        Width = 109
        Height = 19
        Caption = 'TOTAL TTC (DZD) :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblTotalTTCValue: TLabel
        Left = 880
        Top = 86
        Width = 190
        Height = 25
        Alignment = taRightJustify
        Caption = '0.00 '#1583'.'#1580
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblArreteEnToutesLettres: TLabel
        Left = 16
        Top = 10
        Width = 230
        Height = 15
        Caption = 'Arr'#234't'#233' en toutes lettres (Conformit'#233' l'#233'gale) :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object memArreteToutesLettres: TMemo
        Left = 16
        Top = 30
        Width = 710
        Height = 94
        Color = 16316668
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1972778
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsItalic]
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object dsLignesDevis: TDataSource
    DataSet = mtLignesDevis
    Left = 48
    Top = 320
  end
  object mtLignesDevis: TFDMemTable
    OnCalcFields = mtLignesDevisCalcFields
    AfterPost = mtLignesDevisAfterPost
    AfterDelete = mtLignesDevisAfterDelete
    Left = 128
    Top = 320
  end
end
