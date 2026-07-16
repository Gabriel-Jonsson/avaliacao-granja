object frmLote: TfrmLote
  Left = 0
  Top = 0
  Caption = 'Lan'#231'amentos do Lote'
  ClientHeight = 440
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgcLancamentos: TPageControl
    Left = 0
    Top = 0
    Width = 720
    Height = 440
    ActivePage = tabPesagens
    Align = alClient
    TabOrder = 0
    object tabPesagens: TTabSheet
      Caption = 'Pesagens'
      object grdPesagens: TDBGrid
        Left = 0
        Top = 0
        Width = 712
        Height = 336
        Align = alClient
        DataSource = dsPesagens
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'O_ID_PESAGEM'
            Title.Caption = 'C'#243'digo'
            Width = 55
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_DATA_PESAGEM'
            Title.Caption = 'Data'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_PESO_MEDIO'
            Title.Caption = 'Peso m'#233'dio (kg)'
            Width = 110
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_QUANTIDADE_PESADA'
            Title.Caption = 'Qtde pesada'
            Width = 90
            Visible = True
          end>
      end
      object pnlPesagem: TPanel
        Left = 0
        Top = 336
        Width = 712
        Height = 76
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object lblDataPesagem: TLabel
          Left = 8
          Top = 8
          Width = 26
          Height = 13
          Caption = 'Data'
        end
        object lblPesoMedio: TLabel
          Left = 128
          Top = 8
          Width = 78
          Height = 13
          Caption = 'Peso m'#233'dio (kg)'
        end
        object lblQtdePesada: TLabel
          Left = 248
          Top = 8
          Width = 62
          Height = 13
          Caption = 'Qtde pesada'
        end
        object dtpDataPesagem: TDateTimePicker
          Left = 8
          Top = 27
          Width = 105
          Height = 21
          Date = 45000.000000000000000000
          Time = 0.000000000000000000
          TabOrder = 0
        end
        object edtPesoMedio: TEdit
          Left = 128
          Top = 27
          Width = 105
          Height = 21
          TabOrder = 1
        end
        object edtQtdePesada: TEdit
          Left = 248
          Top = 27
          Width = 105
          Height = 21
          TabOrder = 2
        end
        object btnLancarPesagem: TButton
          Left = 376
          Top = 25
          Width = 130
          Height = 25
          Caption = 'Lan'#231'ar pesagem'
          TabOrder = 3
          OnClick = btnLancarPesagemClick
        end
      end
    end
    object tabMortalidades: TTabSheet
      Caption = 'Mortalidades'
      ImageIndex = 1
      object grdMortalidades: TDBGrid
        Left = 0
        Top = 0
        Width = 712
        Height = 336
        Align = alClient
        DataSource = dsMortalidades
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'O_ID_MORTALIDADE'
            Title.Caption = 'C'#243'digo'
            Width = 55
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_DATA_MORTALIDADE'
            Title.Caption = 'Data'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_QUANTIDADE_MORTA'
            Title.Caption = 'Qtde morta'
            Width = 80
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'O_OBSERVACAO'
            Title.Caption = 'Observa'#231#227'o'
            Width = 340
            Visible = True
          end>
      end
      object pnlMortalidade: TPanel
        Left = 0
        Top = 336
        Width = 712
        Height = 76
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object lblDataMortalidade: TLabel
          Left = 8
          Top = 8
          Width = 26
          Height = 13
          Caption = 'Data'
        end
        object lblQtdeMorta: TLabel
          Left = 128
          Top = 8
          Width = 56
          Height = 13
          Caption = 'Qtde morta'
        end
        object lblObservacao: TLabel
          Left = 248
          Top = 8
          Width = 58
          Height = 13
          Caption = 'Observa'#231#227'o'
        end
        object dtpDataMortalidade: TDateTimePicker
          Left = 8
          Top = 27
          Width = 105
          Height = 21
          Date = 45000.000000000000000000
          Time = 0.000000000000000000
          TabOrder = 0
        end
        object edtQtdeMorta: TEdit
          Left = 128
          Top = 27
          Width = 105
          Height = 21
          TabOrder = 1
        end
        object edtObservacao: TEdit
          Left = 248
          Top = 27
          Width = 289
          Height = 21
          MaxLength = 255
          TabOrder = 2
        end
        object btnLancarMortalidade: TButton
          Left = 552
          Top = 25
          Width = 140
          Height = 25
          Caption = 'Lan'#231'ar mortalidade'
          TabOrder = 3
          OnClick = btnLancarMortalidadeClick
        end
      end
    end
  end
  object dsPesagens: TDataSource
    DataSet = dmPrincipal.qryPesagens
    Left = 640
    Top = 48
  end
  object dsMortalidades: TDataSource
    DataSet = dmPrincipal.qryMortalidades
    Left = 640
    Top = 104
  end
end
