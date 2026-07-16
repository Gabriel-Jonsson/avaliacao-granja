unit ufrmLote;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Data.DB,
  uEntidades;

type
  TfrmLote = class(TForm)
    pgcLancamentos: TPageControl;
    tabPesagens: TTabSheet;
    tabMortalidades: TTabSheet;
    grdPesagens: TDBGrid;
    dsPesagens: TDataSource;
    grdMortalidades: TDBGrid;
    dsMortalidades: TDataSource;
    pnlPesagem: TPanel;
    lblDataPesagem: TLabel;
    dtpDataPesagem: TDateTimePicker;
    lblPesoMedio: TLabel;
    edtPesoMedio: TEdit;
    lblQtdePesada: TLabel;
    edtQtdePesada: TEdit;
    btnLancarPesagem: TButton;
    pnlMortalidade: TPanel;
    lblDataMortalidade: TLabel;
    dtpDataMortalidade: TDateTimePicker;
    lblQtdeMorta: TLabel;
    edtQtdeMorta: TEdit;
    lblObservacao: TLabel;
    edtObservacao: TEdit;
    btnLancarMortalidade: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnLancarPesagemClick(Sender: TObject);
    procedure btnLancarMortalidadeClick(Sender: TObject);
  private
    FLote: TLoteAves;   // referencia; quem gerencia a vida do objeto e a tela principal
    procedure AtualizaTitulo;
  public
    property Lote: TLoteAves read FLote write FLote;
  end;

var
  frmLote: TfrmLote;

implementation

{$R *.dfm}

uses
  udmPrincipal;

procedure TfrmLote.FormShow(Sender: TObject);
begin
  dtpDataPesagem.Date := Date;
  dtpDataMortalidade.Date := Date;
  dmPrincipal.AbrePesagens(FLote.Id);
  dmPrincipal.AbreMortalidades(FLote.Id);
  AtualizaTitulo;
end;

procedure TfrmLote.AtualizaTitulo;
begin
  Caption := Format('Lote %d - %s  (mortalidade %.2f%%)',
    [FLote.Id, FLote.Descricao, FLote.PercentualMortalidade]);
end;

procedure TfrmLote.btnLancarPesagemClick(Sender: TObject);
var
  Pesagem: TPesagem;
  Qtde: Integer;
  Peso: Double;
begin
  Qtde := StrToIntDef(edtQtdePesada.Text, 0);
  Peso := StrToFloatDef(edtPesoMedio.Text, 0);

  { pre-validacao de tela (feedback rapido). A validacao que vale e a da
    procedure - se outro usuario alterou o lote nesse meio tempo, ela barra. }
  if Peso <= 0 then
  begin
    ShowMessage('Informe um peso medio maior que zero.');
    edtPesoMedio.SetFocus;
    Exit;
  end;

  if not FLote.PodePesar(Qtde) then
  begin
    ShowMessage(Format('Quantidade pesada invalida: deve ser maior que zero ' +
      'e no maximo a quantidade inicial do lote (%d).', [FLote.QuantidadeInicial]));
    edtQtdePesada.SetFocus;
    Exit;
  end;

  Pesagem := TPesagem.Create;
  try
    Pesagem.IdLote := FLote.Id;
    Pesagem.DataPesagem := dtpDataPesagem.Date;
    Pesagem.PesoMedio := Peso;
    Pesagem.QuantidadePesada := Qtde;
    FLote.PesoMedioGeral := dmPrincipal.InserePesagem(Pesagem);
  finally
    Pesagem.Free;
  end;

  dmPrincipal.AbrePesagens(FLote.Id);
  edtPesoMedio.Clear;
  edtQtdePesada.Clear;
  edtPesoMedio.SetFocus;
end;

procedure TfrmLote.btnLancarMortalidadeClick(Sender: TObject);
var
  Mortalidade: TMortalidade;
  Qtde: Integer;
begin
  Qtde := StrToIntDef(edtQtdeMorta.Text, 0);

  if not FLote.PodeLancarMortalidade(Qtde) then
  begin
    ShowMessage(Format('Quantidade invalida: somada as %d mortes ja registradas, ' +
      'nao pode passar da quantidade inicial do lote (%d).',
      [FLote.MortalidadeAcumulada, FLote.QuantidadeInicial]));
    edtQtdeMorta.SetFocus;
    Exit;
  end;

  Mortalidade := TMortalidade.Create;
  try
    Mortalidade.IdLote := FLote.Id;
    Mortalidade.DataMortalidade := dtpDataMortalidade.Date;
    Mortalidade.QuantidadeMorta := Qtde;
    Mortalidade.Observacao := Trim(edtObservacao.Text);
    { a procedure devolve acumulada e percentual e o datamodule ja
      atualiza o objeto do lote - o titulo reflete na hora }
    dmPrincipal.InsereMortalidade(Mortalidade, FLote);
  finally
    Mortalidade.Free;
  end;

  dmPrincipal.AbreMortalidades(FLote.Id);
  AtualizaTitulo;
  edtQtdeMorta.Clear;
  edtObservacao.Clear;
  edtQtdeMorta.SetFocus;
end;

end.
