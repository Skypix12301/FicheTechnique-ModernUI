object frmDashboard_v3: TfrmDashboard_v3
  Left = 0
  Top = 0
  Caption = 'Syst'#232'me de Gestion des Fiches Techniques'
  ClientHeight = 720
  ClientWidth = 1180
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 1180
    Height = 720
    Align = alClient
    BevelOuter = bvNone
    Color = 16316668
    ParentBackground = False
    TabOrder = 0
    object pnlSidebar: TPanel
      Left = 0
      Top = 0
      Width = 240
      Height = 720
      Align = alLeft
      BevelOuter = bvNone
      Color = 1972778
      ParentBackground = False
      TabOrder = 0
      object pnlBrandHeader: TPanel
        Left = 0
        Top = 0
        Width = 240
        Height = 70
        Align = alTop
        BevelOuter = bvNone
        Color = 1381653
        ParentBackground = False
        TabOrder = 0
        object lblBrandTitle: TLabel
          Left = 16
          Top = 16
          Width = 143
          Height = 19
          Caption = 'Fiches Techniques'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblBrandSub: TLabel
          Left = 16
          Top = 38
          Width = 104
          Height = 15
          Caption = 'Services Techniques'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 15456453
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object btnNavDashboard: TSpeedButton
        Left = 12
        Top = 86
        Width = 216
        Height = 42
        Caption = '  Tableau de bord'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btnNavFiches: TSpeedButton
        Left = 12
        Top = 134
        Width = 216
        Height = 42
        Caption = '  Liste des Fiches'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12632256
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnNavProjets: TSpeedButton
        Left = 12
        Top = 182
        Width = 216
        Height = 42
        Caption = '  Projets & March'#233's'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12632256
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnNavCatalogue: TSpeedButton
        Left = 12
        Top = 230
        Width = 216
        Height = 42
        Caption = '  Bordereau des Prix'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12632256
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnToggleLangue: TSpeedButton
        Left = 12
        Top = 660
        Width = 216
        Height = 36
        Caption = 'Fran'#231'ais / '#1575#1604#1593#1585#1576#1610#1574
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15456453
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btnToggleLangueClick
      end
    end
    object pnlMainContent: TPanel
      Left = 240
      Top = 0
      Width = 940
      Height = 720
      Align = alClient
      BevelOuter = bvNone
      Color = 16316668
      ParentBackground = False
      TabOrder = 1
      object pnlExecutiveBanner: TPanel
        AlignWithMargins = True
        Left = 12
        Top = 12
        Width = 916
        Height = 110
        Margins.Left = 12
        Margins.Top = 12
        Margins.Right = 12
        Margins.Bottom = 8
        Align = alTop
        BevelOuter = bvNone
        Color = 1972778
        ParentBackground = False
        TabOrder = 0
        object lblBannerTitle: TLabel
          Left = 20
          Top = 18
          Width = 373
          Height = 21
          Caption = 'Direction des Travaux et de l'#39'Urbanisme'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblBannerSubTitle: TLabel
          Left = 20
          Top = 44
          Width = 420
          Height = 15
          Caption = 'Suivi budg'#233'taire et validation des devis estimatifs - Wilaya / Commune'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 12632256
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblTotalGlobalTTC: TLabel
          Left = 20
          Top = 70
          Width = 148
          Height = 25
          Caption = '0.00 '#1583'.'#1580' (TTC)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 4437318
          Font.Height = -19
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnNouvelleFiche: TSpeedButton
          Left = 720
          Top = 32
          Width = 176
          Height = 46
          Caption = '+ Nouvelle Fiche'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = btnNouvelleFicheClick
        end
      end
      object pnlKpiContainer: TPanel
        AlignWithMargins = True
        Left = 12
        Top = 133
        Width = 916
        Height = 90
        Margins.Left = 12
        Margins.Top = 3
        Margins.Right = 12
        Margins.Bottom = 8
        Align = alTop
        BevelOuter = bvNone
        Color = 16316668
        ParentBackground = False
        TabOrder = 1
        object pnlCardTotalFiches: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 220
          Height = 90
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 8
          Margins.Bottom = 0
          Align = alLeft
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object lblKpiTotalFichesCount: TLabel
            Left = 16
            Top = 36
            Width = 31
            Height = 32
            Caption = '24'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 1972778
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblKpiTotalFichesTitle: TLabel
            Left = 16
            Top = 14
            Width = 63
            Height = 15
            Caption = 'Total Fiches'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 6579307
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object pnlCardValidees: TPanel
          AlignWithMargins = True
          Left = 228
          Top = 0
          Width = 220
          Height = 90
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 8
          Margins.Bottom = 0
          Align = alLeft
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 1
          object lblKpiValideesCount: TLabel
            Left = 16
            Top = 36
            Width = 31
            Height = 32
            Caption = '18'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3046706
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblKpiValideesTitle: TLabel
            Left = 16
            Top = 14
            Width = 47
            Height = 15
            Caption = 'Valid'#233'es'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 6579307
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object pnlCardEnEtude: TPanel
          AlignWithMargins = True
          Left = 456
          Top = 0
          Width = 220
          Height = 90
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 8
          Margins.Bottom = 0
          Align = alLeft
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 2
          object lblKpiEnEtudeCount: TLabel
            Left = 16
            Top = 36
            Width = 16
            Height = 32
            Caption = '6'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 35607
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblKpiEnEtudeTitle: TLabel
            Left = 16
            Top = 14
            Width = 84
            Height = 15
            Caption = 'En Attente / '#201'tude'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 6579307
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object pnlCardProjets: TPanel
          AlignWithMargins = True
          Left = 684
          Top = 0
          Width = 224
          Height = 90
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alClient
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 3
          object lblKpiProjetsCount: TLabel
            Left = 16
            Top = 36
            Width = 16
            Height = 32
            Caption = '8'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 10040115
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblKpiProjetsTitle: TLabel
            Left = 16
            Top = 14
            Width = 73
            Height = 15
            Caption = 'Projets Actifs'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 6579307
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
      object pnlTableToolbar: TPanel
        AlignWithMargins = True
        Left = 12
        Top = 234
        Width = 916
        Height = 48
        Margins.Left = 12
        Margins.Top = 3
        Margins.Right = 12
        Margins.Bottom = 6
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        object edtSearchFiche: TEdit
          Left = 12
          Top = 10
          Width = 260
          Height = 28
          TabOrder = 0
          TextHint = 'Rechercher par num'#233'ro ou d'#233'signation...'
          OnChange = edtSearchFicheChange
        end
        object btnFilterTous: TSpeedButton
          Left = 285
          Top = 10
          Width = 70
          Height = 28
          Caption = 'Tous'
          Flat = True
          OnClick = btnFilterTousClick
        end
        object btnFilterValidees: TSpeedButton
          Left = 360
          Top = 10
          Width = 80
          Height = 28
          Caption = 'Valid'#233'es'
          Flat = True
          OnClick = btnFilterValideesClick
        end
        object btnFilterEnEtude: TSpeedButton
          Left = 445
          Top = 10
          Width = 80
          Height = 28
          Caption = 'En '#201'tude'
          Flat = True
          OnClick = btnFilterEnEtudeClick
        end
        object btnExportCSV: TSpeedButton
          Left = 820
          Top = 10
          Width = 84
          Height = 28
          Caption = 'Export CSV'
          Flat = True
          OnClick = btnExportCSVClick
        end
      end
      object pnlGridCard: TPanel
        AlignWithMargins = True
        Left = 12
        Top = 291
        Width = 916
        Height = 417
        Margins.Left = 12
        Margins.Top = 3
        Margins.Right = 12
        Margins.Bottom = 12
        Align = alClient
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        object dbgFiches: TDBGrid
          Left = 0
          Top = 0
          Width = 916
          Height = 417
          Align = alClient
          BorderStyle = bsNone
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDrawColumnCell = dbgFichesDrawColumnCell
        end
      end
    end
  end
end
