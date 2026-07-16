unit uEntidades;

{ Entidades de negocio do modulo. Sem dependencia de banco ou VCL:
  quem conversa com o Firebird e o datamodule, quem pinta cor e a tela. }

interface

uses
   System.SysUtils;

type
   TFaixaSaude = (fsVerde, fsAmarelo, fsVermelho);

   TEntidade = class
   private
      FId: Integer;
   public
      property Id: Integer read FId write FId;
   end;

   TLoteAves = class(TEntidade)
   private
      FDescricao: string;
      FDataEntrada: TDate;
      FQuantidadeInicial: Integer;
      FPesoMedioGeral: Double;
      FMortalidadeAcumulada: Integer;
      FPercentualMortalidade: Double;
   public
      { chamada com o retorno da SP_INSERE_MORTALIDADE - os dois valores
        andam sempre juntos, por isso nao tem setter individual }
      procedure AtualizaMortalidade(AAcumulada: Integer; APercentual: Double);

      { unica implementacao da regra 5%/10% do sistema. A versao de classe
        existe para a tela classificar qualquer linha do grid sem precisar
        montar um objeto por registro }
      class function ClassificaSaude(APercentual: Double): TFaixaSaude;
      function FaixaSaude: TFaixaSaude;

      { pre-validacao de tela. A regra oficial esta nas procedures;
        aqui e so para avisar o usuario antes do round-trip ao banco }
      function PodePesar(AQuantidade: Integer): Boolean;
      function PodeLancarMortalidade(AQuantidade: Integer): Boolean;

      property Descricao: string read FDescricao write FDescricao;
      property DataEntrada: TDate read FDataEntrada write FDataEntrada;
      property QuantidadeInicial: Integer read FQuantidadeInicial write FQuantidadeInicial;
      property PesoMedioGeral: Double read FPesoMedioGeral write FPesoMedioGeral;
      property MortalidadeAcumulada: Integer read FMortalidadeAcumulada;
      property PercentualMortalidade: Double read FPercentualMortalidade;
   end;

   TPesagem = class(TEntidade)
   private
      FIdLote: Integer;
      FDataPesagem: TDate;
      FPesoMedio: Double;
      FQuantidadePesada: Integer;
   public
      property IdLote: Integer read FIdLote write FIdLote;
      property DataPesagem: TDate read FDataPesagem write FDataPesagem;
      property PesoMedio: Double read FPesoMedio write FPesoMedio;
      property QuantidadePesada: Integer read FQuantidadePesada write FQuantidadePesada;
   end;

   TMortalidade = class(TEntidade)
   private
      FIdLote: Integer;
      FDataMortalidade: TDate;
      FQuantidadeMorta: Integer;
      FObservacao: string;
   public
      property IdLote: Integer read FIdLote write FIdLote;
      property DataMortalidade: TDate read FDataMortalidade write FDataMortalidade;
      property QuantidadeMorta: Integer read FQuantidadeMorta write FQuantidadeMorta;
      property Observacao: string read FObservacao write FObservacao;
   end;

implementation

procedure TLoteAves.AtualizaMortalidade(AAcumulada: Integer; APercentual: Double);
begin
   FMortalidadeAcumulada := AAcumulada;
   FPercentualMortalidade := APercentual;
end;

class function TLoteAves.ClassificaSaude(APercentual: Double): TFaixaSaude;
begin
   if APercentual < 5 then
      Result := fsVerde
   else
      if APercentual <= 10 then
      Result := fsAmarelo
   else
      Result := fsVermelho;
end;

function TLoteAves.FaixaSaude: TFaixaSaude;
begin
   Result := ClassificaSaude(FPercentualMortalidade);
end;

function TLoteAves.PodePesar(AQuantidade: Integer): Boolean;
begin
   Result := (AQuantidade > 0) and (AQuantidade <= FQuantidadeInicial);
end;

function TLoteAves.PodeLancarMortalidade(AQuantidade: Integer): Boolean;
begin
   Result := (AQuantidade > 0) and
      (FMortalidadeAcumulada + AQuantidade <= FQuantidadeInicial);
end;

end.

