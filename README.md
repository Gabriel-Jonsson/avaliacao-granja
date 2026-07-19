# Controle de Pesagem e Mortalidade de Aves

Projeto da avaliação prática de Desenvolvedor Delphi. Tela principal com a lista
de lotes e indicador de saúde (verde/amarelo/vermelho pela mortalidade acumulada),
e uma tela de lançamentos com abas de pesagem e mortalidade. Todo o acesso ao banco
é feito por stored procedures, não tem SQL de tabela na aplicação.

Usei Firebird 4.0 no lugar do Oracle, como o enunciado permite. É o banco que uso
no dia a dia, então preferi entregar bem no que domino. Os conceitos pedidos têm
equivalente direto:

| Oracle (enunciado) | Firebird (implementado) |
|---|---|
| NUMBER / VARCHAR2 | INTEGER, NUMERIC(10,2) / VARCHAR |
| PK com IDENTITY | IDENTITY (por isso precisa de FB 3.0+) |
| RAISE_APPLICATION_ERROR | EXCEPTION nomeada |
| parâmetro OUT | RETURNS da procedure |
| function com SYS_REFCURSOR | procedure selecionável (SUSPEND) |
| SELECT ... FOR UPDATE | SELECT ... WITH LOCK |

## Como rodar

Precisa de Delphi 10.3+ e um servidor Firebird 3.0 ou superior (desenvolvi no 4.0.2).

Primeiro o banco - rodar os scripts nessa ordem:

```
cd /d <pasta onde o repositorio foi clonado>
set ISQL="C:\Program Files\Firebird\Firebird_4_0\isql.exe"

mkdir C:\dados
%ISQL% -i sql\00_cria_banco.sql
%ISQL% -u SYSDBA -p masterkey localhost:C:\dados\granja.fdb -i sql\01_ddl.sql
%ISQL% -u SYSDBA -p masterkey localhost:C:\dados\granja.fdb -i sql\02_procedures.sql
%ISQL% -u SYSDBA -p masterkey localhost:C:\dados\granja.fdb -i sql\03_consultas.sql
%ISQL% -u SYSDBA -p masterkey localhost:C:\dados\granja.fdb -i sql\99_dados_teste.sql
```

O script 00 assume senha masterkey e cria o banco em C:\dados\granja.fdb (ajuste no
próprio script se for diferente). A mensagem "Use CONNECT or CREATE DATABASE" que
aparece nele é normal, o banco é criado na sequência. O 99 é opcional, carrega 4
lotes de exemplo, um em cada faixa do indicador. Tem também o sql\90_testes.sql,
que exercita as validações das procedures - os 4 "Statement failed" que ele mostra
são os testes de erro passando.

Depois é abrir src\AvaliacaoGranja.dproj no Delphi e compilar (Win32). A conexão lê
um config.ini na pasta do executável (copie o config.exemplo.ini e ajuste). Sem o
arquivo, valem os padrões: localhost, porta 3050, C:\dados\granja.fdb, SYSDBA/masterkey.

Se o app não conectar reclamando de fbclient.dll, copie o fbclient.dll 32-bit do
Firebird para a pasta do executável. O exe é 32-bit, então precisa do client
32-bit - em instalação 64-bit ele só existe se a opção foi marcada no instalador
(fica na subpasta WOW64). O mesmo vale para máquina com mais de um Firebird
instalado (comum onde roda ERP legado): com a DLL na pasta do exe, o FireDAC não
arrisca carregar um client antigo do PATH. A conexão já força Protocol=TCPIP pelo
mesmo motivo - o attach local do FireDAC pode cair no servidor errado quando
existem dois.

## Estrutura

```
sql/
  00_cria_banco.sql     criacao do banco
  01_ddl.sql            tabelas e constraints
  02_procedures.sql     excecoes + procedures de insercao
  03_consultas.sql      procedures selecionaveis usadas pelas telas
  90_testes.sql         teste das validacoes
  99_dados_teste.sql    dados de exemplo
src/
  uEntidades.pas        classes de dominio (Lote, Pesagem, Mortalidade)
  udmPrincipal.pas      conexao e chamada das procedures
  ufrmPrincipal.pas     grid de lotes + indicador
  ufrmLote.pas          abas de lancamento
```

## Algumas decisões que valem explicar

O peso médio geral do lote é um campo que o requisito manda a procedure atualizar,
mas que não existe na estrutura de tabelas do enunciado - então criei a coluna
PESO_MEDIO_GERAL na TAB_LOTE_AVES. O valor é a média ponderada pela quantidade
pesada, recalculada inteira a cada lançamento, o que deixa a operação idempotente.

A SP_INSERE_MORTALIDADE devolve a acumulada e o percentual como parâmetros de
saída, e a tela usa esse retorno para atualizar o indicador na hora, sem consulta
extra. A regra das faixas (verde < 5%, amarelo de 5 a 10%, vermelho acima) fica num
único lugar, TLoteAves.ClassificaSaude, usada tanto pelo painel quanto pelo grid.

As procedures de inserção travam a linha do lote (WITH LOCK) antes de validar, para
duas sessões simultâneas não estourarem juntas a quantidade inicial. Dá pra ver
funcionando abrindo o exe duas vezes no mesmo lote. As telas também validam antes
de chamar o banco, mas só como pré-checagem - a validação que vale é a da procedure.

A validação da pesagem segue o enunciado (quantidade pesada limitada à quantidade
inicial). Em produção o teto mais correto seria a quantidade de aves vivas, já que
ave morta não é pesada - mantive a regra literal e deixo a observação registrada.

Não tem edição nem exclusão de lançamentos porque o enunciado pede lançamento e
inserção, e porque registro operacional desse tipo em produção se corrige por
estorno, não por update/delete. Nenhuma procedure faz COMMIT - transação é
controlada pela aplicação.
