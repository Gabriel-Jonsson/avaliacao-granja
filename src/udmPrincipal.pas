unit udmPrincipal;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uEntidades, FireDAC.Phys.IBBase;

type
  TdmPrincipal = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    qryLotes: TFDQuery;
    qryPesagens: TFDQuery;
    qryMortalidades: TFDQuery;
    spInserePesagem: TFDStoredProc;
    spInsereMortalidade: TFDStoredProc;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure CarregaConfiguracao;
  public
    procedure AbreLotes;
    procedure AbrePesagens(AIdLote: Integer);
    procedure AbreMortalidades(AIdLote: Integer);
    function InserePesagem(APesagem: TPesagem): Double;
    procedure InsereMortalidade(AMortalidade: TMortalidade; ALote: TLoteAves);
  end;

var
  dmPrincipal: TdmPrincipal;

implementation

{$R *.dfm}

procedure TdmPrincipal.DataModuleCreate(Sender: TObject);
begin
  CarregaConfiguracao;
  FDConnection.Connected := True;
end;

procedure TdmPrincipal.CarregaConfiguracao;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  try
    FDConnection.Params.DriverID := 'FB';
    { o default do FireDAC e Protocol=Local (XNET) - com mais de um Firebird
      na maquina o attach local pode cair no servidor errado. TCP explicito,
      com host e arquivo em parametros separados (o FireDAC nao aceita o
      formato host:arquivo do isql no Database). }
    FDConnection.Params.Add('Protocol=TCPIP');
    FDConnection.Params.Add('Server=' +
      Ini.ReadString('banco', 'servidor', 'localhost'));
    FDConnection.Params.Add('Port=' +
      Ini.ReadString('banco', 'porta', '3040'));
    FDConnection.Params.Database :=
      Ini.ReadString('banco', 'database', 'C:\dados\granja.fdb');
    FDConnection.Params.UserName :=
      Ini.ReadString('banco', 'usuario', 'SYSDBA');
    FDConnection.Params.Password :=
      Ini.ReadString('banco', 'senha', 'masterkey');
    FDConnection.Params.Add('CharacterSet=UTF8');
  finally
    Ini.Free;
  end;
end;

procedure TdmPrincipal.AbreLotes;
begin
  qryLotes.Close;
  qryLotes.Open;
end;

procedure TdmPrincipal.AbrePesagens(AIdLote: Integer);
begin
  qryPesagens.Close;
  qryPesagens.ParamByName('ID_LOTE').AsInteger := AIdLote;
  qryPesagens.Open;
end;

procedure TdmPrincipal.AbreMortalidades(AIdLote: Integer);
begin
  qryMortalidades.Close;
  qryMortalidades.ParamByName('ID_LOTE').AsInteger := AIdLote;
  qryMortalidades.Open;
end;

function TdmPrincipal.InserePesagem(APesagem: TPesagem): Double;
begin
  spInserePesagem.ParamByName('I_ID_LOTE').AsInteger := APesagem.IdLote;
  spInserePesagem.ParamByName('I_DATA_PESAGEM').AsDate := APesagem.DataPesagem;
  spInserePesagem.ParamByName('I_PESO_MEDIO').AsFloat := APesagem.PesoMedio;
  spInserePesagem.ParamByName('I_QUANTIDADE_PESADA').AsInteger := APesagem.QuantidadePesada;
  spInserePesagem.ExecProc;

  APesagem.Id := spInserePesagem.ParamByName('O_ID_PESAGEM').AsInteger;
  Result := spInserePesagem.ParamByName('O_PESO_MEDIO_GERAL').AsFloat;
end;

procedure TdmPrincipal.InsereMortalidade(AMortalidade: TMortalidade; ALote: TLoteAves);
begin
  spInsereMortalidade.ParamByName('I_ID_LOTE').AsInteger := AMortalidade.IdLote;
  spInsereMortalidade.ParamByName('I_DATA_MORTALIDADE').AsDate := AMortalidade.DataMortalidade;
  spInsereMortalidade.ParamByName('I_QUANTIDADE_MORTA').AsInteger := AMortalidade.QuantidadeMorta;
  spInsereMortalidade.ParamByName('I_OBSERVACAO').AsString := AMortalidade.Observacao;
  spInsereMortalidade.ExecProc;

  AMortalidade.Id := spInsereMortalidade.ParamByName('O_ID_MORTALIDADE').AsInteger;
  ALote.AtualizaMortalidade(
    spInsereMortalidade.ParamByName('O_MORTALIDADE_ACUMULADA').AsInteger,
    spInsereMortalidade.ParamByName('O_PERCENTUAL_MORTALIDADE').AsFloat);
end;

end.
