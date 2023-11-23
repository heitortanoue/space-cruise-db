-- Insert into PESSOA
INSERT INTO PESSOA (CPI, NOME, TIPO, SENHA, PLANETA_ORIGEM, DATA_NASCIMENTO, ESPECIE) 
VALUES ('123.456.789-AB', 'Heitor', 'PASSAGEIRO', 'heitor-123-456', 'Earth', '2000-09-12', 'Human');
INSERT INTO PESSOA (CPI, NOME, TIPO, SENHA, PLANETA_ORIGEM, DATA_NASCIMENTO, ESPECIE) 
VALUES ('123.456.789-YZ', 'Wall-e', 'PASSAGEIRO', 'password-robot-123', 'XKCD-II', '3023-10-11', 'Robot');
INSERT INTO PESSOA (CPI, NOME, TIPO, SENHA, PLANETA_ORIGEM, DATA_NASCIMENTO, ESPECIE) 
VALUES ('123.456.789-AA', 'John Doe', 'FUNCIONARIO', 'password123', 'Earth', '1980-01-01', 'Human');
INSERT INTO PESSOA (CPI, NOME, TIPO, SENHA, PLANETA_ORIGEM, DATA_NASCIMENTO, ESPECIE) 
VALUES ('111.111.111-AA', 'Pedrinho', 'FUNCIONARIO', 'adminadmin123312', 'Marte', '2023-09-07', 'Alien');
INSERT INTO PESSOA (CPI, NOME, TIPO, SENHA, PLANETA_ORIGEM, DATA_NASCIMENTO, ESPECIE) 
VALUES ('123.456.789-AC', 'Billy Joe', 'FUNCIONARIO', 'best-captain', 'Earth', '1980-02-13', 'Human');

-- Insert into PASSAGEIRO
INSERT INTO PASSAGEIRO (CPI) 
VALUES ('123.456.789-AB');
INSERT INTO PASSAGEIRO (CPI) 
VALUES ('123.456.789-YZ');

-- Insert into RESTRICOES_ALIMENTARES
INSERT INTO RESTRICOES_ALIMENTARES (CPI, RESTRICAO) 
VALUES ('123.456.789-AB', 'Gluten');
INSERT INTO RESTRICOES_ALIMENTARES (CPI, RESTRICAO) 
VALUES ('123.456.789-YZ', 'Lactose');
INSERT INTO RESTRICOES_ALIMENTARES (CPI, RESTRICAO) 
VALUES ('111.111.111-AA', 'Gatos');

-- Insert into FUNCIONARIO
INSERT INTO FUNCIONARIO (CPI, NUM_FUNCIONAL, CARGO, SALARIO) 
VALUES ('123.456.789-AB', '123456789', 'COMUM', 5000.00);
INSERT INTO FUNCIONARIO (CPI, NUM_FUNCIONAL, CARGO, SALARIO) 
VALUES ('111.111.111-AA', '111111111', 'CAPITAO', 51000.00);
INSERT INTO FUNCIONARIO (CPI, NUM_FUNCIONAL, CARGO, SALARIO) 
VALUES ('123.456.789-AC', '222222222', 'COMISSARIO', 10000.00);

-- Insert into COMUM
INSERT INTO COMUM (CPI, PROFISSAO_ESP, TURNO) 
VALUES ('123.456.789-AB', 'Engineer', 'MANHA');

-- Insert into CAPITAO
INSERT INTO CAPITAO (CPI, FORMACAO, LICENCA) 
VALUES ('111.111.111-AA', 'Aeronautics', 'A');

-- Insert into COMISSARIO
INSERT INTO COMISSARIO (CPI, CAPACITACAO) 
VALUES ('123.456.789-AC', 'First Aid');

-- Insert into MODELO_NAVE
INSERT INTO MODELO_NAVE (NOME, TAMANHO, TRIPULANTES_NECESSARIOS, CAPACIDADE_CARGA, CAPACIDADE_COMBUSTIVEL, TIPO_COMBUSTIVEL) 
VALUES ('Model X', 'GRANDE', 5, 10000, 5000, 'Fusion');
INSERT INTO MODELO_NAVE (NOME, TAMANHO, TRIPULANTES_NECESSARIOS, CAPACIDADE_CARGA, CAPACIDADE_COMBUSTIVEL, TIPO_COMBUSTIVEL) 
VALUES ('Model X2', 'MEDIO', 3, 5000, 4000, 'Eletrico');

-- Insert into LICENCAS_PERMITIDAS
INSERT INTO LICENCAS_PERMITIDAS (NOME_MODELO, LICENCA) 
VALUES ('Model X', 'A');
INSERT INTO LICENCAS_PERMITIDAS (NOME_MODELO, LICENCA) 
VALUES ('Model X2', 'B');

-- Insert into NAVE
INSERT INTO NAVE (NUMERO_SERIE, MODELO_NAVE) 
VALUES ('12345678', 'Model X');
INSERT INTO NAVE (NUMERO_SERIE, MODELO_NAVE) 
VALUES ('12345677', 'Model X2');

-- Insert into QUARTO
INSERT INTO QUARTO (MODELO_NAVE, NUMERO, VAGAS) 
VALUES ('Model X', 1, 2);
INSERT INTO QUARTO (MODELO_NAVE, NUMERO, VAGAS) 
VALUES ('Model X', 2, 3);
INSERT INTO QUARTO (MODELO_NAVE, NUMERO, VAGAS) 
VALUES ('Model X2', 1, 3);
INSERT INTO QUARTO (MODELO_NAVE, NUMERO, VAGAS) 
VALUES ('Model X2', 3, 5);

-- Insert into VIAGEM
INSERT INTO VIAGEM (NAVE, DATA, CPI_CAPITAO, ITINERARIO, DURACAO) 
VALUES ('12345678', '2022-01-01', '111.111.111-AA', 'Earth to Mars', '03:00:00');
INSERT INTO VIAGEM (NAVE, DATA, CPI_CAPITAO, ITINERARIO, DURACAO) 
VALUES ('11111111', '2024-11-11', '111.111.111-AA', 'Earth to Mercury', '51:00:00');

-- Insert into QUARTO_RESERVA
INSERT INTO QUARTO_RESERVA (ID, NAVE_VIAGEM, DATA_VIAGEM, MODELO_NAVE_QUARTO, NUMERO_QUARTO, VALOR, DISPONIBILIDADE)
OVERRIDING SYSTEM VALUE -- tem que botar isso pra aceitar o ID
VALUES (1, '12345678', '2022-01-01', 'Model X', 1, 100.0, '1');

-- Insert into RESERVAS
INSERT INTO RESERVAS (QUARTO_RESERVA, PESSOA) 
VALUES (1, '123.456.789-AB');

-- Insert into HOSPEDAGEM
INSERT INTO HOSPEDAGEM (QUARTO_RESERVA, PASSAGEIRO) 
VALUES (1, '123.456.789-AB');

-- Insert into ITINERARIO
INSERT INTO ITINERARIO (NOME, ROTA) 
VALUES ('Earth to Mars', 'Earth, Mars');

-- Insert into PARADA
INSERT INTO PARADA (NOME, TIPO) 
VALUES ('Earth', 'PLANETA');

-- Insert into PARADAS_ITINERARIO
INSERT INTO PARADAS_ITINERARIO (NOME_ITINERARIO, NOME_PARADA, ORDEM, DURACAO) 
VALUES ('Earth to Mars', 'Earth', 1, '01:00:00');

-- Insert into ESTRELA
INSERT INTO ESTRELA (NOME, GALAXIA, CATEGORIA) 
VALUES ('Sun', 'Milky Way', 'GIGANTE VERMELHA ');

-- Insert into PLANETA
INSERT INTO PLANETA (NOME, GOVERNO, NOME_ESTRELA, NOME_GALAXIA) 
VALUES ('Earth', 'REPUBLICA', 'Sun', 'Milky Way');

-- Insert into PONTO_PARADA
INSERT INTO PONTO_PARADA (NOME, PLANETA) 
VALUES ('Earth', 'Earth');

-- Insert into CARACTERISTICAS_PONTO_PARADA
INSERT INTO CARACTERISTICAS_PONTO_PARADA (NOME_PONTO, CARACTERISTICA) 
VALUES ('Earth', 'Safe');

-- Insert into PRODUTOS
INSERT INTO PRODUTOS (COD_BARRAS, NOME, VALOR) 
VALUES ('1 123456 123456', 'Space Food', 10.0);

-- Insert into PRODUTOS_ITINERARIO
INSERT INTO PRODUTOS_ITINERARIO (NOME_ITINERARIO, COD_BARRAS_PRODUTO) 
VALUES ('Earth to Mars', '1 123456 123456');

-- Insert into COMPRA
INSERT INTO COMPRA (QUARTO_RESERVA, COD_BARRAS, QUANTIDADE) 
VALUES (1, '1 123456 123456', 1);

-- Insert into SERVICOS
INSERT INTO SERVICOS (COD_BARRAS, NOME, VALOR) 
VALUES ('1 123456 123456', 'Cleaning', 20.0);

-- Insert into SERVICOS_ITINERARIO
INSERT INTO SERVICOS_ITINERARIO (NOME_ITINERARIO, COD_BARRAS_SERVICO) 
VALUES ('Earth to Mars', '1 123456 123456');

-- Insert into SERVICO_PRESTADO
INSERT INTO SERVICO_PRESTADO (FUNCIONARIO_COMUM, HORARIO, COD_SERVICO, DURACAO) 
VALUES ('123.456.789-AB', '08:00:00', '1 123456 123456', '00:30:00');

-- Insert into CONSTRATACAO_SERVICO
INSERT INTO CONSTRATACAO_SERVICO (QUARTO_RESERVA, FUNCIONARIO, HORARIO) 
VALUES (1, '123.456.789-AB', '08:00:00');