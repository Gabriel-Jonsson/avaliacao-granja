object dmPrincipal: TdmPrincipal
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  Height = 240
  Width = 320
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB')
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 168
    Top = 32
  end
  object qryLotes: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM SP_LISTA_LOTES')
    Left = 48
    Top = 104
  end
  object qryPesagens: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM SP_LISTA_PESAGENS(:ID_LOTE)')
    Left = 168
    Top = 104
    ParamData = <
      item
        Name = 'ID_LOTE'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object qryMortalidades: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM SP_LISTA_MORTALIDADES(:ID_LOTE)')
    Left = 264
    Top = 104
    ParamData = <
      item
        Name = 'ID_LOTE'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object spInserePesagem: TFDStoredProc
    Connection = FDConnection
    StoredProcName = 'SP_INSERE_PESAGEM'
    Left = 48
    Top = 176
  end
  object spInsereMortalidade: TFDStoredProc
    Connection = FDConnection
    StoredProcName = 'SP_INSERE_MORTALIDADE'
    Left = 168
    Top = 176
  end
end
