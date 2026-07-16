object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Controle de Lotes de Aves'
  ClientHeight = 460
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSaude: TPanel
    Left = 0
    Top = 0
    Width = 860
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Nenhum lote selecionado'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
  end
  object grdLotes: TDBGrid
    Left = 0
    Top = 48
    Width = 860
    Height = 371
    Align = alClient
    DataSource = dsLotes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawColumnCell = grdLotesDrawColumnCell
    OnDblClick = grdLotesDblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'O_ID_LOTE'
        Title.Caption = 'C'#243'digo'
        Width = 55
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_DESCRICAO'
        Title.Caption = 'Descri'#231#227'o'
        Width = 280
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_DATA_ENTRADA'
        Title.Caption = 'Entrada'
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_QUANTIDADE_INICIAL'
        Title.Caption = 'Qtde inicial'
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_PESO_MEDIO_GERAL'
        Title.Caption = 'Peso m'#233'dio geral'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_MORTALIDADE_ACUMULADA'
        Title.Caption = 'Mortas'
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'O_PERCENTUAL_MORTALIDADE'
        Title.Caption = 'Mortalidade %'
        Width = 100
        Visible = True
      end>
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 419
    Width = 860
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnAtualizar: TButton
      Left = 8
      Top = 8
      Width = 90
      Height = 25
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = btnAtualizarClick
    end
    object btnLancamentos: TButton
      Left = 104
      Top = 8
      Width = 120
      Height = 25
      Caption = 'Lan'#231'amentos...'
      TabOrder = 1
      OnClick = btnLancamentosClick
    end
  end
  object dsLotes: TDataSource
    DataSet = dmPrincipal.qryLotes
    OnDataChange = dsLotesDataChange
    Left = 792
    Top = 104
  end
end
