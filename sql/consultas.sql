-- SELECT ...

-- Consulta de itinerário de viagem
SELECT
    i.NOME AS Itinerario,
    p.NOME AS Parada,
    pi.ORDEM,
    pi.DURACAO
FROM
    ITINERARIO i
    JOIN PARADAS_ITINERARIO pi ON i.NOME = pi.NOME_ITINERARIO
    JOIN PARADA p ON pi.NOME_PARADA = p.NOME
ORDER BY
    i.NOME,
    pi.ORDEM;

-- Consultar AS próximas viagens que precisam de tripulantes / capitão
SELECT
    v.NAVE,
    v.DATA,
    m.TRIPULANTES_NECESSARIOS,
    COUNT(f.CPI) AS Tripulantes_Alocados
FROM
    VIAGEM v
    JOIN NAVE n ON v.NAVE = n.NUMERO_SERIE
    JOIN MODELO_NAVE m ON n.MODELO_NAVE = m.NOME
    LEFT JOIN FUNCIONARIO f ON v.CPI_CAPITAO = f.CPI
WHERE
    v.DATA > CURRENT_DATE
GROUP BY
    v.NAVE,
    v.DATA,
    m.TRIPULANTES_NECESSARIOS
HAVING
    COUNT(f.CPI) < m.TRIPULANTES_NECESSARIOS;

-- Verificação de disponibilidade de quarto em naves
SELECT
    q.MODELO_NAVE,
    q.NUMERO,
    qr.DISPONIBILIDADE
FROM
    QUARTO_RESERVA qr
    JOIN QUARTO q ON qr.MODELO_NAVE_QUARTO = q.MODELO_NAVE
    AND qr.NUMERO_QUARTO = q.NUMERO
WHERE
    qr.DATA_VIAGEM = 'data_especifica'
    AND qr.DISPONIBILIDADE = '1';

-- Lista de passageiros por viagem
SELECT
    v.NAVE,
    v.DATA,
    p.NOME AS Passageiro
FROM
    HOSPEDAGEM h
    JOIN RESERVAS r ON h.QUARTO_RESERVA = r.QUARTO_RESERVA
    JOIN PESSOA p ON r.PESSOA = p.CPI
    JOIN VIAGEM v ON h.QUARTO_RESERVA = v.NAVE
WHERE
    v.NAVE = 'numero_serie_nave'
    AND v.DATA = 'data_especifica';

-- Restrições alimentares dos passageiros
SELECT
    p.NOME AS Passageiro,
    ra.RESTRICAO
FROM
    RESERVAS r
    JOIN PESSOA p ON r.PESSOA = p.CPI
    JOIN RESTRICOES_ALIMENTARES ra ON p.CPI = ra.CPI
WHERE
    r.QUARTO_RESERVA IN (
        SELECT
            ID
        FROM
            QUARTO_RESERVA
        WHERE
            NAVE_VIAGEM = 'numero_serie_nave'
            AND DATA_VIAGEM = 'data_especifica'
    );

-- Relatório de vendas de produtos e serviços
SELECT
    i.NOME AS Itinerario,
    SUM(p.VALOR * C .QUANTIDADE) AS Vendas_Totais
FROM
    ITINERARIO i
    JOIN PRODUTOS_ITINERARIO pi ON i.NOME = pi.NOME_ITINERARIO
    JOIN PRODUTOS p ON pi.COD_BARRAS_PRODUTO = p.COD_BARRAS
    JOIN COMPRA C ON p.COD_BARRAS = C .COD_BARRAS
GROUP BY
    i.NOME;

-- Consulta de funcionários e cargos
SELECT
    f.NUM_FUNCIONAL,
    p.NOME,
    f.CARGO,
    f.SALARIO
FROM
    FUNCIONARIO f
    JOIN PESSOA p ON f.CPI = p.CPI;

-- Capacidade e Ocupação das Naves
SELECT
    m.NOME AS modelo_nave,
    SUM(q.VAGAS) AS capacidade_total,
    COUNT(h.PASSAGEIRO) AS ocupacao_atual
FROM
    MODELO_NAVE m
    JOIN QUARTO q ON m.NOME = q.MODELO_NAVE
    JOIN QUARTO_RESERVA qr ON q.MODELO_NAVE = qr.MODELO_NAVE_QUARTO
    AND q.NUMERO = qr.NUMERO_QUARTO
    LEFT JOIN HOSPEDAGEM h ON qr.ID = h.QUARTO_RESERVA
GROUP BY
    m.NOME;

-- Histórico de Viagens de um Passageiro
SELECT
    v.NAVE,
    v.DATA,
    v.ITINERARIO
FROM
    VIAGEM v
    JOIN HOSPEDAGEM h ON v.NAVE = h.QUARTO_RESERVA
WHERE
    h.PASSAGEIRO = 'CPI_DO_PASSAGEIRO';

-- Licenças de Voo Necessárias por Modelo de Nave
SELECT
    mn.NOME AS modelo_nave,
    lp.LICENCA
FROM
    MODELO_NAVE mn
    JOIN LICENCAS_PERMITIDAS lp ON mn.NOME = lp.NOME_MODELO;

-- Capitães Disponíveis para Pilotar uma Viagem
SELECT
    C .CPI,
    C .FORMACAO,
    C .LICENCA
FROM
    CAPITAO C
    JOIN LICENCAS_PERMITIDAS lp ON C .LICENCA = lp.LICENCA
    LEFT JOIN VIAGEM v ON C .CPI = v.CPI_CAPITAO
    AND v.DATA = 'DATA_DA_VIAGEM'
WHERE
    v.CPI_CAPITAO IS NULL
    AND lp.NOME_MODELO = 'MODELO_NAVE';