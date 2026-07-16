unit ufrmPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
   Vcl.ExtCtrls, Data.DB, uEntidades;

type
   TfrmPrincipal = class(TForm)
      pnlSaude: TPanel;
      grdLotes: TDBGrid;
      pnlRodape: TPanel;
      btnAtualizar: TButton;
      btnLancamentos: TButton;
      dsLotes: TDataSource;
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure dsLotesDataChange(Sender: TObject; Field: TField);
      procedure btnAtualizarClick(Sender: TObject);
      procedure grdLotesDrawColumnCell(Sender: TObject; const Rect: TRect;
         DataCol: Integer; Column: TColumn; State: TGridDrawState);
      procedure grdLotesDblClick(Sender: TObject);
      procedure btnLancamentosClick(Sender: TObject);
   private
      FLote: TLoteAves;
      procedure CarregaLoteSelecionado;
      procedure AtualizaIndicador;
      function CorDaFaixa(AFaixa: TFaixaSaude): TColor;
   end;

var
   frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
   udmPrincipal, ufrmLote;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   FLote := TLoteAves.Create;
   dmPrincipal.AbreLotes;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
   FLote.Free;
end;

procedure TfrmPrincipal.dsLotesDataChange(Sender: TObject; Field: TField);
begin
   CarregaLoteSelecionado;
   AtualizaIndicador;
end;

procedure TfrmPrincipal.CarregaLoteSelecionado;
begin
   if dmPrincipal.qryLotes.IsEmpty then
      begin
         FLote.Id := 0;
         Exit;
      end;

   FLote.Id := dmPrincipal.qryLotes.FieldByName('O_ID_LOTE').AsInteger;
   FLote.Descricao := dmPrincipal.qryLotes.FieldByName('O_DESCRICAO').AsString;
   FLote.DataEntrada := dmPrincipal.qryLotes.FieldByName('O_DATA_ENTRADA').AsDateTime;
   FLote.QuantidadeInicial := dmPrincipal.qryLotes.FieldByName('O_QUANTIDADE_INICIAL').AsInteger;
   FLote.PesoMedioGeral := dmPrincipal.qryLotes.FieldByName('O_PESO_MEDIO_GERAL').AsFloat;
   FLote.AtualizaMortalidade(
      dmPrincipal.qryLotes.FieldByName('O_MORTALIDADE_ACUMULADA').AsInteger,
      dmPrincipal.qryLotes.FieldByName('O_PERCENTUAL_MORTALIDADE').AsFloat);
end;

procedure TfrmPrincipal.AtualizaIndicador;
begin
   if FLote.Id = 0 then
      begin
         pnlSaude.Color := clBtnFace;
         pnlSaude.Font.Color := clWindowText;
         pnlSaude.Caption := 'Nenhum lote selecionado';
         Exit;
      end;

   pnlSaude.Color := CorDaFaixa(FLote.FaixaSaude);
   if FLote.FaixaSaude = fsAmarelo then
      pnlSaude.Font.Color := clBlack
   else
      pnlSaude.Font.Color := clWhite;
   pnlSaude.Caption := Format('%s  -  mortalidade acumulada: %d de %d aves (%.2f%%)',
      [FLote.Descricao, FLote.MortalidadeAcumulada, FLote.QuantidadeInicial,
         FLote.PercentualMortalidade]);
end;

function TfrmPrincipal.CorDaFaixa(AFaixa: TFaixaSaude): TColor;
begin
   case AFaixa of
      fsVerde: Result := TColor($0050AF4C);
      fsAmarelo: Result := TColor($0007C1FF);
      else
         Result := TColor($003643F4);
   end;
end;

procedure TfrmPrincipal.grdLotesDrawColumnCell(Sender: TObject; const Rect: TRect;
   DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   if SameText(Column.FieldName, 'O_PERCENTUAL_MORTALIDADE') then
      begin
         grdLotes.Canvas.Brush.Color :=
            CorDaFaixa(TLoteAves.ClassificaSaude(Column.Field.AsFloat));
         if TLoteAves.ClassificaSaude(Column.Field.AsFloat) = fsAmarelo then
            grdLotes.Canvas.Font.Color := clBlack
         else
            grdLotes.Canvas.Font.Color := clWhite;
      end;
   grdLotes.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmPrincipal.btnAtualizarClick(Sender: TObject);
begin
   dmPrincipal.AbreLotes;
end;

procedure TfrmPrincipal.grdLotesDblClick(Sender: TObject);
var
   Frm: TfrmLote;
begin
   if FLote.Id = 0 then
      Exit;

   Frm := TfrmLote.Create(Self);
   try
      Frm.Lote := FLote;
      Frm.ShowModal;
   finally
      Frm.Free;
   end;

   dmPrincipal.AbreLotes;
   dmPrincipal.qryLotes.Locate('O_ID_LOTE', FLote.Id, []);
end;

procedure TfrmPrincipal.btnLancamentosClick(Sender: TObject);
begin
   grdLotesDblClick(Sender);
end;

end.

