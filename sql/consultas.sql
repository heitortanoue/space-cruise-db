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

-- Verificação de quartos dísponíveis para uma data
SELECT
    qr.MODELO_NAVE_QUARTO AS MODELO_NAVE,
    v.ITINERARIO,
    qr.NUMERO_QUARTO
FROM
    QUARTO_RESERVA qr
    JOIN VIAGEM v ON qr.NAVE_VIAGEM = v.NAVE
        AND qr.DATA_VIAGEM = v.DATA
WHERE
    qr.DATA_VIAGEM = '{{DATA_VIAGEM}}'
    AND qr.DISPONIBILIDADE = '1';

-- Lista de passageiros para uma viagem
SELECT
    p.NOME AS Passageiro
FROM
    VIAGEM v
    JOIN QUARTO_RESERVA qr ON v.NAVE = qr.NAVE_VIAGEM
        AND v.DATA = qr.DATA_VIAGEM
    JOIN HOSPEDAGEM h ON qr.ID = h.QUARTO_RESERVA
    JOIN PESSOA p ON h.PASSAGEIRO = p.CPI
WHERE
    v.NAVE = '{{NUMERO_SERIE_NAVE}}'
    AND v.DATA = '{{DATA_DA_VIAGEM}}';

-- Restrições alimentares dos passageiros
SELECT
    p.NOME AS Passageiro,
    ra.RESTRICAO
FROM
    HOSPEDAGEM h
    JOIN PESSOA p ON h.PASSAGEIRO = p.CPI
    JOIN RESTRICOES_ALIMENTARES ra ON p.CPI = ra.CPI
WHERE
    h.QUARTO_RESERVA IN (
        SELECT
            ID
        FROM
            QUARTO_RESERVA
        WHERE
            NAVE_VIAGEM = '{{NUMERO_SERIE_NAVE}}'
            AND DATA_VIAGEM = '{{DATA_DA_VIAGEM}}'
    );

-- Relatório de vendas de produtos por itinerário
SELECT
    i.NOME AS Itinerario,
    SUM(p.VALOR * c.QUANTIDADE) AS Vendas_Totais
FROM
    ITINERARIO i
    JOIN PRODUTOS_ITINERARIO pi ON i.NOME = pi.NOME_ITINERARIO
    JOIN PRODUTOS p ON pi.COD_BARRAS_PRODUTO = p.COD_BARRAS
    JOIN COMPRA c ON p.COD_BARRAS = c.COD_BARRAS
GROUP BY
    i.NOME;

-- Produtos mais vendidos em viagens que passam por um planeta
SELECT
    PR.nome,
    SUM(C .quantidade) AS total_vendido
FROM
    compra AS C
    JOIN produtos AS PR ON C .cod_barras = PR.cod_barras
WHERE
    C.quarto_reserva IN (
        SELECT
            QR.id
        FROM
            quarto_reserva AS QR
            JOIN viagem AS V ON QR.nave_viagem = V.nave
            AND QR.data_viagem = V.data
            JOIN itinerario AS I ON V.itinerario = I.nome
            JOIN paradas_itinerario AS PI ON I.nome = PI.nome_itinerario
            JOIN parada AS P ON PI.nome_parada = P.nome
        WHERE
            P.tipo = 'PLANETA'
            AND P.nome = '{{PLANETA}}'
    )
GROUP BY
    PR.nome
ORDER BY
    total_vendido DESC;

-- Capacidade e ocupação das naves
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

-- Funcionários comuns que ganham mais que a média de seu cargo
SELECT
    p.CPI,
    p.NOME,
    f.SALARIO,
    c.PROFISSAO_ESP,
    MEDIA_CARGO.MEDIA_SALARIAL AS MEDIA_SALARIAL_CARGO
FROM
    COMUM c
    JOIN PESSOA p ON c.CPI = p.CPI
    JOIN FUNCIONARIO f ON p.CPI = f.CPI
    INNER JOIN (
        SELECT
            c.PROFISSAO_ESP,
            AVG(f.SALARIO) AS MEDIA_SALARIAL
        FROM
            FUNCIONARIO f JOIN COMUM c ON f.CPI = c.CPI
        GROUP BY
            c.PROFISSAO_ESP
    ) AS MEDIA_CARGO ON c.PROFISSAO_ESP = MEDIA_CARGO.PROFISSAO_ESP
WHERE
    f.SALARIO > MEDIA_CARGO.MEDIA_SALARIAL;

-- Passageiros que nunca viajaram em uma rota (divisão relacional)
SELECT
    pe.NOME
FROM
    PASSAGEIRO pa
    JOIN PESSOA pe ON pa.CPI = pe.CPI
WHERE
    pa.CPI NOT IN (
        SELECT
            h.PASSAGEIRO
        FROM
            HOSPEDAGEM h
            JOIN QUARTO_RESERVA qr ON h.QUARTO_RESERVA = qr.ID
            JOIN VIAGEM v ON QR.nave_viagem = v.NAVE
            AND qr.DATA_VIAGEM = v.DATA
        WHERE
            v.ITINERARIO = '{{ROTA}}'
    );

-- Capitães disponíveis para pilotar uma viagem
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