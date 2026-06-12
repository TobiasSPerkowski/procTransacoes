       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROJ5.
      *-----------------------------------------------------
       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT CLIENTES ASSIGN TO UT-S-ARQCLI.
           SELECT TRANSAC  ASSIGN TO UT-S-ARQTRX.
           SELECT SAIDA    ASSIGN TO UT-S-ARQSAI.
           SELECT ERROS    ASSIGN TO UT-S-ARQERR.
      *-----------------------------------------------------
       DATA DIVISION.

       FILE SECTION.

       FD  CLIENTES
           LABEL  RECORDS ARE STANDARD
           RECORD CONTAINS 44 CHARACTERS
           BLOCK  CONTAINS  0 RECORDS
           DATA   RECORD IS CLIENTES.
           01 REG-CLIENTES COPY BOOKCLI.
       FD  TRANSAC
           LABEL  RECORDS ARE STANDARD
           RECORD CONTAINS 20 CHARACTERS
           BLOCK  CONTAINS  0 RECORDS
           DATA   RECORD IS TRANSAC.
           01 REG-TRANSAC COPY BOOKTRX.
       FD  SAIDA
           LABEL  RECORDS ARE STANDARD
           RECORD CONTAINS 44 CHARACTERS
           BLOCK  CONTAINS  0 RECORDS
           DATA   RECORD IS SAIDA.
           01 REG-SAIDA PIC X(44).
       FD  ERROS
           LABEL  RECORDS ARE STANDARD
           RECORD CONTAINS 45 CHARACTERS
           BLOCK  CONTAINS  0 RECORDS
           DATA   RECORD IS ERROS.
           01 REG-ERRO COPY BOOKERRO.

       WORKING-STORAGE SECTION.

       01  FS-CLIENTES   PIC X     VALUE 'N'.
       01  FS-TRANSAC    PIC X     VALUE 'N'.
       01  WS-CLI-CRED   PIC 9(09) VALUE ZEROS.
       01  WS-CLI-DEB    PIC 9(09) VALUE ZEROS.
       01  WS-NUM-CLI    PIC 9(06) VALUE ZEROS.
       01  WS-NUM-TRX    PIC 9(06) VALUE ZEROS.
       01  WS-NUM-CRED   PIC 9(06) VALUE ZEROS.
       01  WS-NUM-DEB    PIC 9(06) VALUE ZEROS.
       01  WS-NUM-ERR    PIC 9(06) VALUE ZEROS.
      *-----------------------------------------------------
       PROCEDURE DIVISION.

       0001-PRINCIPAL.
           PERFORM 0100-INICIAR.
           PERFORM 0400-PROCESSAR UNTIL FS-CLIENTES = 'F'
                                  OR    FS-TRANSAC = 'F'.
           IF FS-CLIENTES = 'F'
               PERFORM 0700-TRANSAC-RESTANTES
               UNTIL FS-TRANSAC = 'F'
           ELSE
               PERFORM 0600-CLIENTES-RESTANTES
               UNTIL FS-CLIENTES = 'F'.

           PERFORM 0500-FINALIZAR.
           STOP RUN.

       0100-INICIAR.
           OPEN INPUT CLIENTES
                INPUT TRANSAC
                OUTPUT SAIDA
                OUTPUT ERROS.
           PERFORM 0200-LER-CLIENTE.
           IF FS-CLIENTES = 'F'
               DISPLAY 'NENHUM CLIENTE REGISTRADO'.
           PERFORM 0300-LER-TRANSAC.
           IF FS-TRANSAC = 'F'
               DISPLAY 'NENHUMA TRANSACAO REGISTRADA'.

       0200-LER-CLIENTE.
           IF FS-CLIENTES NOT = 'F'
               READ CLIENTES
                   AT END MOVE 'F' TO FS-CLIENTES.

       0300-LER-TRANSAC.
           IF FS-TRANSAC NOT = 'F'
               READ TRANSAC
                   AT END MOVE 'F' TO FS-TRANSAC.

       0400-PROCESSAR.
           IF CLI-ID = TRX-CLI-ID
               PERFORM 0800-PROCESSAR-TRANSAC
               PERFORM 0300-LER-TRANSAC
           ELSE
               IF CLI-ID < TRX-CLI-ID
                   PERFORM 0900-GRAVAR-CLIENTE
                   PERFORM 0200-LER-CLIENTE
               ELSE
                   PERFORM 1000-CLIENTE-INEXISTENTE
                   PERFORM 0300-LER-TRANSAC.

       0500-FINALIZAR.
           DISPLAY ' '
           DISPLAY '*****************************'
           DISPLAY 'ESTATISTICAS DE PROCESSAMENTO'
           DISPLAY '*****************************'
           DISPLAY ' CLIENTES PROCESSADOS...: ' WS-NUM-CLI
           DISPLAY ' TRANSACOES PROCESSADAS.: ' WS-NUM-TRX
           DISPLAY ' CREDITOS PROCESSADOS...: ' WS-NUM-CRED
           DISPLAY ' DEBITOS PROCESSADOS....: ' WS-NUM-DEB
           DISPLAY ' ERROS ENCONTRADOS......: ' WS-NUM-ERR
           DISPLAY ' '
           DISPLAY 'FIM DO PROCESSAMENTO'
           CLOSE CLIENTES
                 TRANSAC
                 SAIDA
                 ERROS.

       0600-CLIENTES-RESTANTES.
           PERFORM 0900-GRAVAR-CLIENTE.
           PERFORM 0200-LER-CLIENTE.

       0700-TRANSAC-RESTANTES.
           IF TRX-CLI-ID = CLI-ID
               PERFORM 0800-PROCESSAR-TRANSAC
           ELSE
               PERFORM 1000-CLIENTE-INEXISTENTE.
           PERFORM 0300-LER-TRANSAC.

       0800-PROCESSAR-TRANSAC.
           IF TRX-VALOR = 0
               PERFORM 1200-VALOR-INVALIDO
           ELSE
               IF TRX-TIPO = 'C'
                   ADD TRX-VALOR TO CLI-SALDO
                   ADD TRX-VALOR TO WS-CLI-CRED
                   ADD 1 TO WS-NUM-CRED
               ELSE
                   IF TRX-TIPO = 'D'
                       IF CLI-SALDO - TRX-VALOR < 0
                           PERFORM 1300-SALDO-INSUFICIENTE
                       ELSE
                           SUBTRACT TRX-VALOR FROM CLI-SALDO
                           ADD TRX-VALOR TO WS-CLI-DEB
                       ADD 1 TO WS-NUM-DEB
                   ELSE
                       PERFORM 1100-TIPO-INVALIDO.
           ADD 1 TO WS-NUM-TRX.

       0900-GRAVAR-CLIENTE.
           DISPLAY ' '
           DISPLAY 'CLIENTE: ' CLI-ID
           DISPLAY 'TOTAL CREDITOS: ' WS-CLI-CRED
           DISPLAY 'TOTAL DEBITOS: ' WS-CLI-DEB
           MOVE REG-CLIENTES TO REG-SAIDA
           WRITE REG-SAIDA
           MOVE ZEROS TO WS-CLI-CRED
           MOVE ZEROS TO WS-CLI-DEB
           ADD 1 TO WS-NUM-CLI.

       1000-CLIENTE-INEXISTENTE.
           MOVE 'ERRO: CLIENTE NAO ENCONTRADO ------- ID '
                TO ERR-TEXTO
           MOVE TRX-CLI-ID TO ERR-ID
           WRITE REG-ERRO
           ADD 1 TO WS-NUM-TRX
           ADD 1 TO WS-NUM-ERR.

       1100-TIPO-INVALIDO.
           MOVE 'ERRO: TIPO DE TRANSACAO INVALIDO --- ID '
                TO ERR-TEXTO
           MOVE TRX-CLI-ID TO ERR-ID
           WRITE REG-ERRO
           ADD 1 TO WS-NUM-ERR.

       1200-VALOR-INVALIDO.
           MOVE 'ERRO: VALOR DE TRANSACAO INVALIDO -- ID '
                TO ERR-TEXTO
           MOVE TRX-CLI-ID TO ERR-ID
           WRITE REG-ERRO
           ADD 1 TO WS-NUM-ERR.

       1300-SALDO-INSUFICIENTE.
           MOVE 'ERRO: SALDO INSUFICIENTE ----------- ID '
                TO ERR-TEXTO
           MOVE TRX-CLI-ID TO ERR-ID
           WRITE REG-ERRO
           ADD 1 TO WS-NUM-ERR.

