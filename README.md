# procTransacoes

Processamento de transações bancárias em COBOL utilizando arquivos sequenciais.

## Descrição

O programa realiza o processamento de transações bancárias a partir de dois arquivos de entrada:

* **clientes.txt**: cadastro de clientes e seus respectivos saldos.
* **transac.txt**: lista de transações (créditos e débitos).

Durante a execução, o sistema atualiza os saldos dos clientes, gera um arquivo de saída com os dados processados e registra eventuais inconsistências em um arquivo de erros.

## Estrutura do Projeto

```text
procTransacoes/
├── COBOL/
│   ├── bookcli.cpy
│   ├── bookerro.cpy
│   ├── booktrx.cpy
│   └── proj5.cbl
│
├── JCL/
│   ├── compcob.jcl
│   └── proctrx.jcl
│
├── Dados/
│   ├── Entrada/
│   │   ├── clientes.txt
│   │   └── transac.txt
│   │
│   └── Saida/
│       ├── cliout.txt
│       └── erros.txt
│
├── Prints/
│   ├── 1.png
│   ├── 2.png
│   └── 3.png
│
└── README.md
```

## Arquivos

### COBOL

| Arquivo        | Descrição                                                         |
| -------------- | ----------------------------------------------------------------- |
| `proj5.cbl`    | Programa principal responsável pelo processamento das transações. |
| `bookcli.cpy`  | Copybook contendo o layout do arquivo de clientes.                |
| `booktrx.cpy`  | Copybook contendo o layout do arquivo de transações.              |
| `bookerro.cpy` | Copybook contendo o layout do arquivo de erros.                   |

### JCL

| Arquivo       | Descrição                                                               |
| ------------- | ----------------------------------------------------------------------- |
| `compcob.jcl` | Compila o programa COBOL.                                               |
| `proctrx.jcl` | Executa o programa utilizando os arquivos de entrada e saída definidos. |

### Dados

| Arquivo        | Descrição                                                      |
| -------------- | -------------------------------------------------------------- |
| `clientes.txt` | Arquivo de entrada contendo os clientes cadastrados.           |
| `transac.txt`  | Arquivo de entrada contendo as transações a serem processadas. |
| `cliout.txt`   | Arquivo de saída contendo os clientes com saldos atualizados.  |
| `erros.txt`    | Arquivo contendo erros encontrados durante o processamento.    |

## Regras de Processamento

O programa processa os registros dos arquivos de clientes e transações em ordem crescente de identificador.

### Créditos (`C`)

* O valor da transação é adicionado ao saldo do cliente.
* O total de créditos do cliente é acumulado para fins estatísticos.

### Débitos (`D`)

* O valor é descontado do saldo do cliente.
* Caso o saldo seja insuficiente, a transação é rejeitada e registrada no arquivo de erros.

### Situações de Erro

As seguintes ocorrências são registradas em `erros.txt`:

* Cliente não encontrado.
* Tipo de transação inválido.
* Valor da transação igual a zero.
* Saldo insuficiente para débito.

## Estatísticas Geradas

Ao final da execução, o programa exibe:

* Quantidade de clientes processados.
* Quantidade de transações processadas.
* Total de créditos processados.
* Total de débitos processados.
* Quantidade de erros encontrados.

## Como Executar

### 1. Compilar o programa

Submeter o JCL:

```text
COMPCOB
```

ou executar o conteúdo de:

```text
JCL/compcob.jcl
```

### 2. Executar o programa

Submeter o JCL:

```text
PROCTRX
```

ou executar o conteúdo de:

```text
JCL/proctrx.jcl
```

### 3. Consultar os resultados

Após a execução, verificar:

```text
cliout.txt
erros.txt
sysout
```

## Ambiente Utilizado

* MVS 3.8J (TK5)
* x3270

## Autor

Tobias Saueressig

