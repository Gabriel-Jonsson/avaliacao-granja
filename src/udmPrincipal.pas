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
      procedure FormataCampo(AField: TField; const AFormato: string);
      procedure AddParam(AParams: TFDParams; const ANome: string;
         ATipo: TFieldType; ADirecao: TParamType; ATamanho: Integer = 0);
      procedure PreparaProcedures;
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
   PreparaProcedures;
end;

procedure TdmPrincipal.CarregaConfiguracao;
var
   Ini: TIniFile;
begin
   Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
   try
      FDConnection.Params.DriverID := 'FB';
      FDConnection.Params.Add('Protocol=TCPIP');
      FDConnection.Params.Add('Server=' +
         Ini.ReadString('banco', 'servidor', 'localhost'));
      FDConnection.Params.Add('Port=' +
         Ini.ReadString('banco', 'porta', '3050'));
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

procedure TdmPrincipal.AddParam(AParams: TFDParams; const ANome: string;
   ATipo: TFieldType; ADirecao: TParamType; ATamanho: Integer);
var
   P: TFDParam;
begin
   P := AParams.Add;
   P.Name := ANome;
   P.DataType := ATipo;
   P.ParamType := ADirecao;
   if ATamanho > 0 then
      P.Size := ATamanho;
end;

procedure TdmPrincipal.PreparaProcedures;
begin
   AddParam(spInserePesagem.Params, 'I_ID_LOTE', ftInteger, ptInput);
   AddParam(spInserePesagem.Params, 'I_DATA_PESAGEM', ftDate, ptInput);
   AddParam(spInserePesagem.Params, 'I_PESO_MEDIO', ftFloat, ptInput);
   AddParam(spInserePesagem.Params, 'I_QUANTIDADE_PESADA', ftInteger, ptInput);
   AddParam(spInserePesagem.Params, 'O_ID_PESAGEM', ftInteger, ptOutput);
   AddParam(spInserePesagem.Params, 'O_PESO_MEDIO_GERAL', ftFloat, ptOutput);

   AddParam(spInsereMortalidade.Params, 'I_ID_LOTE', ftInteger, ptInput);
   AddParam(spInsereMortalidade.Params, 'I_DATA_MORTALIDADE', ftDate, ptInput);
   AddParam(spInsereMortalidade.Params, 'I_QUANTIDADE_MORTA', ftInteger, ptInput);
   AddParam(spInsereMortalidade.Params, 'I_OBSERVACAO', ftString, ptInput, 255);
   AddParam(spInsereMortalidade.Params, 'O_ID_MORTALIDADE', ftInteger, ptOutput);
   AddParam(spInsereMortalidade.Params, 'O_MORTALIDADE_ACUMULADA', ftInteger, ptOutput);
   AddParam(spInsereMortalidade.Params, 'O_PERCENTUAL_MORTALIDADE', ftFloat, ptOutput);
end;

procedure TdmPrincipal.FormataCampo(AField: TField; const AFormato: string);
begin
   if AField is TBCDField then
      begin
         TBCDField(AField).Currency := False;
         TBCDField(AField).DisplayFormat := AFormato;
      end
   else
      if AField is TFMTBCDField then
      begin
         TFMTBCDField(AField).Currency := False;
         TFMTBCDField(AField).DisplayFormat := AFormato;
      end
   else
      if AField is TFloatField then
      TFloatField(AField).DisplayFormat := AFormato;
end;

procedure TdmPrincipal.AbreLotes;
begin
   qryLotes.Close;
   qryLotes.Open;
   FormataCampo(qryLotes.FieldByName('O_PESO_MEDIO_GERAL'), '0.00');
   FormataCampo(qryLotes.FieldByName('O_PERCENTUAL_MORTALIDADE'), '0.00');
end;

procedure TdmPrincipal.AbrePesagens(AIdLote: Integer);
begin
   qryPesagens.Close;
   qryPesagens.ParamByName('ID_LOTE').AsInteger := AIdLote;
   qryPesagens.Open;
   FormataCampo(qryPesagens.FieldByName('O_PESO_MEDIO'), '0.00');
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

