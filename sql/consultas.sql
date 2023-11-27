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

-- Consultar as próximas viagens que precisam de tripulantes / capitão
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
    qr.DATA_VIAGEM = '{{DATA_VIAGEM}}'
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
    v.NAVE = '{{NUMERO_SERIE_NAVE}}'
    AND v.DATA = '{{DATA_DA_VIAGEM}}';

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
            NAVE_VIAGEM = '{{NUMERO_SERIE_NAVE}}'
            AND DATA_VIAGEM = '{{DATA_DA_VIAGEM}}'
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
    h.PASSAGEIRO = '{{CPI_DO_PASSAGEIRO}}';

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
    AND v.DATA = '{{DATA_DA_VIAGEM}}'
WHERE
    v.CPI_CAPITAO IS NULL
    AND lp.NOME_MODELO = '{{MODELO_NAVE}}';

-- Comissários Disponíveis para uma Viagem
SELECT
    C.*
FROM
    COMISSARIO C
WHERE
    NOT EXISTS (
        SELECT
            *
        FROM
            VIAGEM v
        WHERE
            v.DATA = '{{DATA_DA_VIAGEM}}'
            AND v.CPI_COMISSARIO = C .CPI
    );

-- Consultar funcionários por profissão
SELECT
    f.NUM_FUNCIONAL,
    p.NOME,
    f.CARGO,
    f.SALARIO
FROM
    FUNCIONARIO f
    JOIN PESSOA p ON f.CPI = p.CPI
WHERE
    f.CARGO = '{{PROFISSAO}}';

-- Consultar reservas recentes
SELECT
    r.QUARTO_RESERVA,
    r.DATA_RESERVA,
    r.DATA_VIAGEM,
    r.PESSOA,
    r.PAGAMENTO,
    r.VALOR,
    r.PAGO,
    r.CANCELADO
FROM
    RESERVAS r
WHERE
    r.DATA_RESERVA > CURRENT_DATE - 30;

-- Tripulação necessária para uma viagem com um modelo de nave
SELECT
    m.NOME AS modelo_nave,
    m.TRIPULANTES_NECESSARIOS,
    COUNT(C .CPI) AS tripulantes_alocados
FROM
    MODELO_NAVE m
    LEFT JOIN FUNCIONARIO C ON m.NOME = C .CARGO
WHERE
    m.NOME = '{{MODELO_NAVE}}'
GROUP BY
    m.NOME,
    m.TRIPULANTES_NECESSARIOS;

-- Ganhos/lucro de cada itinerário
SELECT
    i.NOME AS itinerario,
    SUM(p.VALOR * C .QUANTIDADE) AS ganhos
FROM
    ITINERARIO i
    JOIN PRODUTOS_ITINERARIO pi ON i.NOME = pi.NOME_ITINERARIO
    JOIN PRODUTOS p ON pi.COD_BARRAS_PRODUTO = p.COD_BARRAS
    JOIN COMPRA C ON p.COD_BARRAS = C .COD_BARRAS
GROUP BY
    i.NOME;

-- Lista de passageiros em cada quarto em uma viagem
SELECT
    v.NAVE,
    v.DATA,
    q.MODELO_NAVE,
    q.NUMERO,
    p.NOME AS passageiro
FROM
    VIAGEM v
    JOIN QUARTO_RESERVA qr ON v.NAVE = qr.NAVE_VIAGEM
    AND v.DATA = qr.DATA_VIAGEM
    JOIN QUARTO q ON qr.MODELO_NAVE_QUARTO = q.MODELO_NAVE
    AND qr.NUMERO_QUARTO = q.NUMERO
    JOIN HOSPEDAGEM h ON qr.ID = h.QUARTO_RESERVA
    JOIN RESERVAS r ON h.QUARTO_RESERVA = r.QUARTO_RESERVA
    JOIN PESSOA p ON r.PESSOA = p.CPI
WHERE
    v.NAVE = '{{NUMERO_SERIE_NAVE}}'
    AND v.DATA = '{{DATA_DA_VIAGEM}}';

-- Balanço de despesas de um passageiro em uma viagem
SELECT
    v.NAVE,
    v.DATA,
    p.NOME AS passageiro,
    SUM(p.VALOR * C .QUANTIDADE) AS despesas
FROM
    VIAGEM v
    JOIN QUARTO_RESERVA qr ON v.NAVE = qr.NAVE_VIAGEM
    AND v.DATA = qr.DATA_VIAGEM
    JOIN QUARTO q ON qr.MODELO_NAVE_QUARTO = q.MODELO_NAVE
    AND qr.NUMERO_QUARTO = q.NUMERO
    JOIN HOSPEDAGEM h ON qr.ID = h.QUARTO_RESERVA
    JOIN RESERVAS r ON h.QUARTO_RESERVA = r.QUARTO_RESERVA
    JOIN PESSOA p ON r.PESSOA = p.CPI
    JOIN COMPRA C ON p.CPI = C .CPI
    JOIN PRODUTOS pr ON C .COD_BARRAS = pr.COD_BARRAS
GROUP BY
    v.NAVE,
    v.DATA,
    p.NOME;

-- Soma dos gastos de todos os passageiros a partir de seu planeta origem
SELECT
    p.PLANETA_ORIGEM,
    SUM(p.VALOR * C .QUANTIDADE) AS gastos
FROM
    PESSOA p
    JOIN COMPRA C ON p.CPI = C .CPI
    JOIN PRODUTOS pr ON C .COD_BARRAS = pr.COD_BARRAS
GROUP BY
    p.PLANETA_ORIGEM;

-- Serviços disponíveis com funcionário e turno para uma viagem
SELECT
    v.NAVE,
    v.DATA,
    s.NOME AS servico,
    f.CARGO,
    f.NUM_FUNCIONAL,
    t.TURNO
FROM
    VIAGEM v
    JOIN SERVICOS s ON v.NAVE = s.NAVE_VIAGEM
    AND v.DATA = s.DATA_VIAGEM
    JOIN FUNCIONARIO f ON s.CARGO_FUNCIONARIO = f.CARGO
    JOIN TURNO t ON s.TURNO_FUNCIONARIO = t.TURNO
WHERE
    v.NAVE = '{{NUMERO_SERIE_NAVE}}'
    AND v.DATA = '{{DATA_DA_VIAGEM}}';

-- Próximas viagens disponíveis de um itinerário
SELECT
    i.NOME AS itinerario,
    v.NAVE,
    v.DATA
FROM
    ITINERARIO i
    JOIN VIAGEM v ON i.NOME = v.ITINERARIO
WHERE
    v.DATA > CURRENT_DATE;