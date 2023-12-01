--PESSOAS--

--PRECISA VER COMO FAZ O TIPO--
CREATE TABLE PESSOA (
    CPI CHAR(14) NOT NULL,                          -------formato eh "123.456.789-AZ"
    NOME VARCHAR(64) NOT NULL,
    TIPO VARCHAR(11) NOT NULL,
    SENHA VARCHAR(24) NOT NULL,
    PLANETA_ORIGEM VARCHAR(64),
    DATA_NASCIMENTO DATE NOT NULL,
    ESPECIE VARCHAR(16) NOT NULL,
    
    CONSTRAINT PK_PESSOA PRIMARY KEY(CPI),
    CONSTRAINT UN_PESSOA UNIQUE(nome, senha),
    CONSTRAINT CK_PESSOA CHECK(CPI ~ '[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[A-Z]{2}'),
    CONSTRAINT CK_PESSOA_TIPO CHECK(
        TIPO IN(
            'PASSAGEIRO',
            'FUNCIONARIO'
        )
    )
);

CREATE TABLE PASSAGEIRO (
    CPI CHAR(14) NOT NULL,

    CONSTRAINT PK_PASS PRIMARY KEY(CPI),
    CONSTRAINT FK_PASS FOREIGN KEY(CPI) REFERENCES pessoa(CPI)
);

CREATE TABLE RESTRICOES_ALIMENTARES (
    CPI CHAR(14) NOT NULL,
    RESTRICAO VARCHAR(16) NOT NULL,

    CONSTRAINT PK_RESTRICOES PRIMARY KEY(CPI, RESTRICAO),
    CONSTRAINT FK_RESTRICOES FOREIGN KEY(CPI) REFERENCES passageiro(CPI)
);

CREATE TABLE FUNCIONARIO (
    CPI CHAR(14) NOT NULL,
    NUM_FUNCIONAL CHAR(9) NOT NULL,
    CARGO VARCHAR(16) NOT NULL,
    SALARIO FLOAT NOT NULL,

    CONSTRAINT PK_FUNC PRIMARY KEY(CPI),
    CONSTRAINT FK_FUNC FOREIGN KEY(CPI) REFERENCES pessoa(CPI),
    CONSTRAINT UN_FUNC UNIQUE(NUM_FUNCIONAL),
    CONSTRAINT CK_FUNC_CARGO CHECK(
        CARGO IN(
            'COMUM',
            'CAPITAO',
            'COMISSARIO'
        )
    )
);

CREATE TABLE COMUM (
    CPI CHAR(14) NOT NULL,
    PROFISSAO_ESP VARCHAR(24) NOT NULL,
    TURNO VARCHAR(5) NOT NULL,

    CONSTRAINT PK_COMUM PRIMARY KEY(CPI),
    CONSTRAINT FK_COMUM FOREIGN KEY(CPI) REFERENCES funcionario(CPI),
    CONSTRAINT CK_COMUM_TURNO CHECK(
        TURNO IN(
            'MANHA',
            'TARDE',
            'NOITE'
        )
    )
);

CREATE TABLE CAPITAO (
    CPI CHAR(14) NOT NULL,
    FORMACAO VARCHAR(24),
    LICENCA CHAR(1) NOT NULL,

    CONSTRAINT PK_CAPITAO PRIMARY KEY(CPI),
    CONSTRAINT FK_CAPITAO FOREIGN KEY(CPI) REFERENCES funcionario(CPI),
    CONSTRAINT CK_CAPITAO_LICENCA CHECK(
        LICENCA IN(
            'A',
            'B',
            'C'
        )
    )
);

CREATE TABLE COMISSARIO (
    CPI CHAR(14) NOT NULL,
    CAPACITACAO VARCHAR(32),

    CONSTRAINT PK_COMISSARIO PRIMARY KEY(CPI),
    CONSTRAINT FK_COMISSARIO FOREIGN KEY(CPI) REFERENCES funcionario(CPI)
);


--NAVE--

CREATE TABLE MODELO_NAVE (
    NOME VARCHAR(24) NOT NULL,
    TAMANHO VARCHAR(8) NOT NULL,
    TRIPULANTES_NECESSARIOS INTEGER NOT NULL,
    CAPACIDADE_CARGA INTEGER NOT NULL,
    CAPACIDADE_COMBUSTIVEL INTEGER NOT NULL,
    TIPO_COMBUSTIVEL VARCHAR(24) NOT NULL,
    
    CONSTRAINT PK_MODELO_NAVE PRIMARY KEY(NOME),
    CONSTRAINT CK_MODELO_NAVE_TAMANHO CHECK(
        TAMANHO IN(
            'PEQUENO',
            'MEDIO',
            'GRANDE'
        )
    )
);

CREATE TABLE LICENCAS_PERMITIDAS (
    NOME_MODELO VARCHAR(16) NOT NULL,
    LICENCA CHAR(1) NOT NULL,

    CONSTRAINT PK_LICENCAS PRIMARY KEY(NOME_MODELO, LICENCA),
    CONSTRAINT FK_LICENCAS FOREIGN KEY(NOME_MODELO) REFERENCES modelo_nave(NOME),
    CONSTRAINT CK_LICENCAS CHECK(
        LICENCA IN(
            'A',
            'B',
            'C'
        )
    )
);

CREATE TABLE NAVE (
    NUMERO_SERIE CHAR(8) NOT NULL,
    MODELO_NAVE VARCHAR(24) NOT NULL,
    
    CONSTRAINT PK_NAVE PRIMARY KEY(NUMERO_SERIE),
    CONSTRAINT FK_NAVE FOREIGN KEY(MODELO_NAVE) REFERENCES modelo_nave(NOME)
);

CREATE TABLE QUARTO (
    MODELO_NAVE VARCHAR(16) NOT NULL,
    NUMERO INTEGER NOT NULL,
    VAGAS INTEGER NOT NULL,

    CONSTRAINT PK_QUARTO PRIMARY KEY(MODELO_NAVE, NUMERO),
    CONSTRAINT UN_QUARTO UNIQUE (MODELO_NAVE, NUMERO),
    CONSTRAINT FK_QUARTO FOREIGN KEY(MODELO_NAVE) REFERENCES modelo_nave(NOME)
);

CREATE TABLE ITINERARIO (
    NOME VARCHAR(32) NOT NULL,
    ROTA VARCHAR(320) NOT NULL,           --idealmente o maximo sao 10 pontos de paradas

    CONSTRAINT PK_ITINERARIO PRIMARY KEY(NOME)
);

CREATE TABLE VIAGEM (
    NAVE CHAR(8) NOT NULL,
    DATA DATE NOT NULL,
    CPI_CAPITAO CHAR(14) NOT NULL,
    ITINERARIO VARCHAR(32) NOT NULL,
    DURACAO TIME NOT NULL,                   ----formato eh "00:00:00"

    CONSTRAINT PK_VIAGEM PRIMARY KEY(NAVE, DATA),
    CONSTRAINT FK_VIAGEM FOREIGN KEY(NAVE) REFERENCES nave(NUMERO_SERIE),
    CONSTRAINT FK_VIAGEM_ITINERARIO FOREIGN KEY(ITINERARIO) REFERENCES itinerario(NOME),
    CONSTRAINT FK_VIAGEM_CAPITAO FOREIGN KEY(CPI_CAPITAO) REFERENCES capitao(CPI)
);

--RESERVAS--

CREATE TABLE QUARTO_RESERVA (
    ID INTEGER GENERATED ALWAYS AS IDENTITY,
    NAVE_VIAGEM CHAR(8) NOT NULL,
    DATA_VIAGEM DATE NOT NULL,
    MODELO_NAVE_QUARTO VARCHAR(24) NOT NULL,
    NUMERO_QUARTO INTEGER NOT NULL,
    VALOR FLOAT NOT NULL,
    DISPONIBILIDADE CHAR(1) DEFAULT '1',

    CONSTRAINT PK_QUARTO_RESERVA PRIMARY KEY(ID),
    CONSTRAINT FK_QUARTO_RESERVA_VIAGEM FOREIGN KEY(NAVE_VIAGEM, DATA_VIAGEM) REFERENCES viagem(NAVE, DATA),
    CONSTRAINT UN_QUARTO_RESERVA UNIQUE(NAVE_VIAGEM, DATA_VIAGEM, MODELO_NAVE_QUARTO, NUMERO_QUARTO),
    CONSTRAINT FK_QUARTO_RESERVA_QUARTO FOREIGN KEY(MODELO_NAVE_QUARTO, NUMERO_QUARTO) REFERENCES quarto(MODELO_NAVE, NUMERO)
);

CREATE
OR REPLACE FUNCTION verificar_disponibilidade_quarto() RETURNS TRIGGER AS $$ BEGIN
    -- Verifica se a disponibilidade do quarto para a reserva é 1
    IF NOT EXISTS (
        SELECT
            1
        FROM
            quarto_reserva
        WHERE
            id = NEW .quarto_reserva
            AND disponibilidade = '1'
    ) THEN RAISE
    EXCEPTION
        'Nao e possível reservar este quarto, pois ele nao esta disponivel.';

END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION alterar_disponibilidade_quarto() RETURNS TRIGGER AS $$ BEGIN
    -- Atualiza a disponibilidade para '0' (indisponível) assim que uma reserva é feita
    UPDATE
        quarto_reserva
    SET
        disponibilidade = '0'
    WHERE
        id = NEW .quarto_reserva;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TABLE RESERVAS (
    QUARTO_RESERVA INTEGER NOT NULL,
    PESSOA CHAR(14) NOT NULL,

    CONSTRAINT PK_RESERVA PRIMARY KEY(QUARTO_RESERVA),
    CONSTRAINT FK_RESERVA_QUARTO FOREIGN KEY(QUARTO_RESERVA) REFERENCES quarto_reserva(ID),
    CONSTRAINT FK_RESERVA_PESSOA FOREIGN KEY(PESSOA) REFERENCES pessoa(CPI)
);

CREATE TABLE HOSPEDAGEM (
    QUARTO_RESERVA INTEGER NOT NULL,
    PASSAGEIRO CHAR(14) NOT NULL,

    CONSTRAINT PK_HOSPEDAGEM PRIMARY KEY(QUARTO_RESERVA, PASSAGEIRO),
    CONSTRAINT FK_HOSPEDAGEM_QUARTO FOREIGN KEY(QUARTO_RESERVA) REFERENCES reservas(ID),
    CONSTRAINT FK_HOSPEDAGEM_PASSAGEIRO FOREIGN KEY(PASSAGEIRO) REFERENCES passageiro(CPI)
);


--ITINERARIOS--

CREATE TABLE PARADA (
    NOME VARCHAR(16) NOT NULL,
    TIPO VARCHAR(15) NOT NULL,

    CONSTRAINT PK_PARADA PRIMARY KEY(NOME),
    CONSTRAINT CK_PARADA CHECK(
        TIPO IN(
            'PONTO DE PARADA',
            'PLANETA'
        )
    )
);

CREATE TABLE PARADAS_ITINERARIO (
    NOME_ITINERARIO VARCHAR(24) NOT NULL,
    NOME_PARADA VARCHAR(16) NOT NULL,
    ORDEM INTEGER NOT NULL,
    DURACAO TIME NOT NULL,       ----- formato eh "00:00:00"

    CONSTRAINT PK_PARADAS_ITINERARIO PRIMARY KEY(NOME_ITINERARIO, NOME_PARADA),
    CONSTRAINT FK_PARADAS_ITINERARIO FOREIGN KEY(NOME_PARADA) REFERENCES parada(NOME),
    CONSTRAINT FK_PARADAS_ITINERARIO_ITINERARIO FOREIGN KEY(NOME_ITINERARIO) REFERENCES itinerario(NOME),
    CONSTRAINT UN_PARADAS_ITINERARIO UNIQUE(NOME_ITINERARIO, ORDEM)
);

CREATE OR REPLACE FUNCTION ADICIONAR_PARADA_ROTA_ITINERARIO()
RETURNS TRIGGER AS $$
DECLARE
    rota_atual VARCHAR(320);
BEGIN
    -- Recupera a rota atual do itinerário relacionado
    SELECT ROTA INTO rota_atual FROM ITINERARIO
    WHERE NOME = NEW.NOME_ITINERARIO;

    -- Verifica se a rota já possui alguma parada
    IF rota_atual IS NOT NULL AND LENGTH(rota_atual) > 0 THEN
        -- Concatena a nova parada à rota existente
        rota_atual := rota_atual || ', ' || NEW.NOME_PARADA;
    ELSE
        -- Define a rota com a primeira parada
        rota_atual := NEW.NOME_PARADA;
    END IF;

    -- Atualiza a rota no itinerário
    UPDATE ITINERARIO
    SET ROTA = rota_atual
    WHERE NOME = NEW.NOME_ITINERARIO;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE ESTRELA (
    NOME VARCHAR(12) NOT NULL,
    GALAXIA VARCHAR(12) NOT NULL,
    CATEGORIA VARCHAR(16) NOT NULL,

    CONSTRAINT PK_ESTRELA PRIMARY KEY(NOME, GALAXIA),
    CONSTRAINT CK_ESTRELA_CATEGORIA CHECK(
        CATEGORIA IN(
            'ANA BRANCA',
            'ANA AMARELA',
            'ANA VERMELHA',
            'GIGANTE VERMELHA',
            'GIGANTE AZUL'
        )
    )
);

CREATE TABLE PLANETA (
    NOME VARCHAR(24) NOT NULL,
    GOVERNO VARCHAR(12),
    NOME_ESTRELA VARCHAR(12) NOT NULL,
    NOME_GALAXIA VARCHAR(12) NOT NULL,

    CONSTRAINT PK_PLANETA PRIMARY KEY(NOME),
    CONSTRAINT FK_PLANETA FOREIGN KEY(NOME) REFERENCES parada(NOME),
    CONSTRAINT FK_PLANETA_ESTRELA FOREIGN KEY(NOME_ESTRELA, NOME_GALAXIA) REFERENCES estrela(NOME, GALAXIA),
    CONSTRAINT CK_PLANETA_GOVERNO CHECK(
        GOVERNO IN(
            'REPUBLICA',
            'MONARQUIA',
            'DITADURA',
            'OLIGARQUIA',
            'TEOCRACIA',
            'IMPERIO'
        )
    )
);

CREATE TABLE PONTO_PARADA (
    NOME VARCHAR(32) NOT NULL,
    PLANETA VARCHAR(24) NOT NULL,

    CONSTRAINT PK_PONTO_PARADA PRIMARY KEY(NOME),
    CONSTRAINT FK_PONTO_PARADA FOREIGN KEY(PLANETA) REFERENCES planeta(NOME),
    CONSTRAINT FK_PONTO_PARADA_NOME FOREIGN KEY(NOME) REFERENCES parada(NOME)
);

CREATE TABLE CARACTERISTICAS_PONTO_PARADA (
    NOME_PONTO VARCHAR(32) NOT NULL,
    CARACTERISTICA VARCHAR(12) NOT NULL,

    CONSTRAINT PK_CARACTERISTICA PRIMARY KEY(NOME_PONTO, CARACTERISTICA),
    CONSTRAINT FK_CARACTERISTICA FOREIGN KEY(NOME_PONTO) REFERENCES ponto_parada(NOME)
);

--PRODUTOS--

CREATE TABLE PRODUTOS (
    COD_BARRAS CHAR(13) NOT NULL,
    NOME VARCHAR(24) NOT NULL,
    VALOR FLOAT NOT NULL,

    CONSTRAINT PK_PRODUTOS PRIMARY KEY(COD_BARRAS),
    CONSTRAINT CH_PRODUTOS_COD_BARRAS CHECK(COD_BARRAS ~ '[0-9]{1}\ [0-9]{6}\ [0-9]{6}')
);

CREATE TABLE PRODUTOS_ITINERARIO (
    NOME_ITINERARIO VARCHAR(24) NOT NULL,
    COD_BARRAS_PRODUTO CHAR(13) NOT NULL,

    CONSTRAINT PK_PRODUTOS_ITINERARIO PRIMARY KEY(NOME_ITINERARIO, COD_BARRAS_PRODUTO),
    CONSTRAINT FK_PRODUTOS_ITINERARIO_ITI FOREIGN KEY(NOME_ITINERARIO) REFERENCES itinerario(NOME),
    CONSTRAINT FK_PRODUTOS_ITINERARIO_PRO FOREIGN KEY(COD_BARRAS_PRODUTO) REFERENCES produtos(COD_BARRAS),
    CONSTRAINT CH_PRODUTOS_ITI_COD_BARRAS CHECK(COD_BARRAS_PRODUTO ~'[0-9]{1}\ [0-9]{6}\ [0-9]{6}')
);

CREATE TABLE COMPRA (
    QUARTO_RESERVA INTEGER NOT NULL,
    COD_BARRAS CHAR(13) NOT NULL,
    QUANTIDADE INTEGER NOT NULL,

    CONSTRAINT PK_COMPRA PRIMARY KEY(QUARTO_RESERVA, COD_BARRAS),
    CONSTRAINT FK_COMPRA_QUARTO FOREIGN KEY(QUARTO_RESERVA) REFERENCES reservas(QUARTO_RESERVA),
    CONSTRAINT FK_COMPRA_PRODUTO FOREIGN KEY(COD_BARRAS) REFERENCES produtos(COD_BARRAS),
    CONSTRAINT CH_COMPRA_COD_BARRAS CHECK(COD_BARRAS ~ '[0-9]{1}\ [0-9]{6}\ [0-9]{6}')
);

--SERVICOS--

CREATE TABLE AUXILIA_COMISSARIO (
    CPI_COMISSARIO CHAR(14) NOT NULL,
    NAVE_VIAGEM CHAR(8) NOT NULL,
    DATA_VIAGEM DATE NOT NULL,          -----formato eh "YYYY-MM-DD"

    CONSTRAINT PK_AUXILIA_COMISSARIO PRIMARY KEY(CPI_COMISSARIO, NAVE_VIAGEM, DATA_VIAGEM),
    CONSTRAINT FK_AUXILIA_COMISSARIO_COMUM FOREIGN KEY(CPI_COMISSARIO) REFERENCES comissario(CPI),
    CONSTRAINT FK_AUXILIA_COMISSARIO_VIAGEM FOREIGN KEY(NAVE_VIAGEM, DATA_VIAGEM) REFERENCES viagem(NAVE, DATA)
);

CREATE TABLE TRABALHO_COMUM (
    CPI_COMUM CHAR(14) NOT NULL,
    NAVE_VIAGEM CHAR(8) NOT NULL,
    DATA_VIAGEM DATE NOT NULL,

    CONSTRAINT PK_TRABALHO_COMUM PRIMARY KEY(CPI_COMUM, NAVE_VIAGEM, DATA_VIAGEM),
    CONSTRAINT FK_TRABALHO_COMUM_COMUM FOREIGN KEY(CPI_COMUM) REFERENCES comum(CPI),
    CONSTRAINT FK_TRABALHO_COMUM_VIAGEM FOREIGN KEY(NAVE_VIAGEM, DATA_VIAGEM) REFERENCES viagem(NAVE, DATA)
);

CREATE TABLE SERVICOS (
    COD_BARRAS CHAR(13) NOT NULL,
    NOME VARCHAR(24) NOT NULL,
    VALOR FLOAT NOT NULL,

    CONSTRAINT PK_SERVICOS PRIMARY KEY(COD_BARRAS),
    CONSTRAINT CH_SERVICOS_COD_BARRAS CHECK(COD_BARRAS ~ '[0-9]{1}\ [0-9]{6}\ [0-9]{6}')
);

CREATE TABLE SERVICOS_ITINERARIO (
    NOME_ITINERARIO VARCHAR(24) NOT NULL,
    COD_BARRAS_SERVICO CHAR(13) NOT NULL,

    CONSTRAINT PK_SERVICOS_ITINERARIO PRIMARY KEY(NOME_ITINERARIO, COD_BARRAS_SERVICO),
    CONSTRAINT FK_SERVICOS_ITINERARIO_ITI FOREIGN KEY(NOME_ITINERARIO) REFERENCES itinerario(NOME),
    CONSTRAINT FK_SERVICOS_ITINERARIO_COD FOREIGN KEY(COD_BARRAS_SERVICO) REFERENCES servicos(COD_BARRAS),
    CONSTRAINT CH_SERVICOS_ITI_COD_BARRAS CHECK(COD_BARRAS_SERVICO ~ '[0-9]{1}\ [0-9]{6}\ [0-9]{6}')
);

CREATE TABLE SERVICO_PRESTADO (
    FUNCIONARIO_COMUM CHAR(14) NOT NULL,
    HORARIO TIME NOT NULL,                      ----formato eh "00:00:00"
    COD_SERVICO CHAR(13) NOT NULL,
    DURACAO TIME NOT NULL,                       ----formato eh "00:00:00"

    CONSTRAINT PK_SERVICO_PRESTADO PRIMARY KEY(FUNCIONARIO_COMUM, HORARIO),
    CONSTRAINT FK_SERVICO_PRESTADO_FUNC FOREIGN KEY(FUNCIONARIO_COMUM) REFERENCES comum(CPI),
    CONSTRAINT FK_SERVICO_PRESTADO_COD FOREIGN KEY(COD_SERVICO) REFERENCES servicos(COD_BARRAS)
);

CREATE TABLE CONTRATACAO_SERVICO (
    QUARTO_RESERVA INTEGER NOT NULL,
    FUNCIONARIO CHAR(14) NOT NULL,
    HORARIO TIME NOT NULL,               ----formato eh "00:00:00"

    CONSTRAINT PK_CONTRATACAO_SERVICO PRIMARY KEY(QUARTO_RESERVA, FUNCIONARIO, HORARIO),
    CONSTRAINT FK_CONTRATACAO_SERVICO_QUARTO FOREIGN KEY(QUARTO_RESERVA) REFERENCES reservas(QUARTO_RESERVA),
    CONSTRAINT FK_CONTRATACAO_SERVICO_SERVICO FOREIGN KEY(FUNCIONARIO, HORARIO) REFERENCES servico_prestado(FUNCIONARIO_COMUM, HORARIO)
);
