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
    p.CPI,
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
    p.CPI,
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
    f.NUM_FUNCIONAL,
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
    c.CPI,
    c.FORMACAO,
    c.LICENCA
FROM
    CAPITAO c
    JOIN LICENCAS_PERMITIDAS lp ON c.LICENCA = lp.LICENCA
    LEFT JOIN VIAGEM v ON c.CPI = v.CPI_CAPITAO
    AND v.DATA = '{{DATA_DA_VIAGEM}}'
WHERE
    v.CPI_CAPITAO IS NULL
    AND lp.NOME_MODELO = '{{MODELO_NAVE}}';


-- Gastos por itinerário
SELECT
    itin.NOME AS Nome_Itinerario,
    COALESCE(prod.Soma_Produtos, 0) AS Soma_Produtos,
    COALESCE(serv.Soma_Servicos, 0) AS Soma_Servicos,
    COALESCE(hosp.Soma_Hospedagem, 0) AS Soma_Hospedagem,
    COALESCE(prod.Soma_Produtos, 0) + COALESCE(serv.Soma_Servicos, 0) + COALESCE(hosp.Soma_Hospedagem, 0) AS Soma_Total
FROM
    ITINERARIO itin
LEFT JOIN (
    SELECT
        viag.ITINERARIO,
        SUM(prod.VALOR * comp.QUANTIDADE) AS Soma_Produtos
    FROM
        VIAGEM viag
    JOIN QUARTO_RESERVA qres ON viag.NAVE = qres.NAVE_VIAGEM AND viag.DATA = qres.DATA_VIAGEM
    JOIN RESERVAS res ON qres.ID = res.QUARTO_RESERVA
    JOIN COMPRA comp ON res.QUARTO_RESERVA = comp.QUARTO_RESERVA
    JOIN PRODUTOS prod ON comp.COD_BARRAS = prod.COD_BARRAS
    GROUP BY
        viag.ITINERARIO
) prod ON itin.NOME = prod.ITINERARIO
LEFT JOIN (
    SELECT
        viag.ITINERARIO,
        SUM(serv.VALOR) AS Soma_Servicos
    FROM
        VIAGEM viag
    JOIN QUARTO_RESERVA qres ON viag.NAVE = qres.NAVE_VIAGEM AND viag.DATA = qres.DATA_VIAGEM
    JOIN RESERVAS res ON qres.ID = res.QUARTO_RESERVA
    JOIN CONTRATACAO_SERVICO contr ON res.QUARTO_RESERVA = contr.QUARTO_RESERVA
    JOIN SERVICO_PRESTADO serpre ON contr.FUNCIONARIO = serpre.FUNCIONARIO_COMUM AND contr.HORARIO = serpre.HORARIO
    JOIN SERVICOS serv ON serpre.COD_SERVICO = serv.COD_BARRAS
    GROUP BY
        viag.ITINERARIO
) serv ON itin.NOME = serv.ITINERARIO
LEFT JOIN (
    SELECT
        viag.ITINERARIO,
        SUM(qres.VALOR) AS Soma_Hospedagem
    FROM
        VIAGEM viag
    JOIN QUARTO_RESERVA qres ON viag.NAVE = qres.NAVE_VIAGEM AND viag.DATA = qres.DATA_VIAGEM
    GROUP BY
        viag.ITINERARIO
) hosp ON itin.NOME = hosp.ITINERARIO
ORDER BY
    itin.NOME;

-- Gastos por passageiro, considerando todas as viagens/reservas
SELECT
    pess.NOME AS Passageiro,
    COALESCE(prod.Soma_Produtos, 0) AS Soma_Produtos,
    COALESCE(serv.Soma_Servicos, 0) AS Soma_Servicos,
    COALESCE(hosp.Soma_Hospedagem, 0) AS Soma_Hospedagem,
    COALESCE(prod.Soma_Produtos, 0) + COALESCE(serv.Soma_Servicos, 0) + COALESCE(hosp.Soma_Hospedagem, 0) AS Soma_Total
FROM
    PASSAGEIRO pass
JOIN PESSOA pess ON pass.CPI = pess.CPI
LEFT JOIN (
    SELECT
        hosp.PASSAGEIRO,
        SUM(prod.VALOR * comp.QUANTIDADE) AS Soma_Produtos
    FROM
        HOSPEDAGEM hosp
    JOIN RESERVAS res ON hosp.QUARTO_RESERVA = res.QUARTO_RESERVA
    JOIN COMPRA comp ON res.QUARTO_RESERVA = comp.QUARTO_RESERVA
    JOIN PRODUTOS prod ON comp.COD_BARRAS = prod.COD_BARRAS
    GROUP BY
        hosp.PASSAGEIRO
) prod ON pass.CPI = prod.PASSAGEIRO
LEFT JOIN (
    SELECT
        hosp.PASSAGEIRO,
        SUM(serv.VALOR) AS Soma_Servicos
    FROM
        HOSPEDAGEM hosp
    JOIN RESERVAS res ON hosp.QUARTO_RESERVA = res.QUARTO_RESERVA
    JOIN CONTRATACAO_SERVICO contr ON res.QUARTO_RESERVA = contr.QUARTO_RESERVA
    JOIN SERVICO_PRESTADO serpre ON contr.FUNCIONARIO = serpre.FUNCIONARIO_COMUM AND contr.HORARIO = serpre.HORARIO
    JOIN SERVICOS serv ON serpre.COD_SERVICO = serv.COD_BARRAS
    GROUP BY
        hosp.PASSAGEIRO
) serv ON pass.CPI = serv.PASSAGEIRO
LEFT JOIN (
    SELECT
        hosp.PASSAGEIRO,
        SUM(qres.VALOR) AS Soma_Hospedagem
    FROM
        HOSPEDAGEM hosp
    JOIN QUARTO_RESERVA qres ON hosp.QUARTO_RESERVA = qres.ID
    GROUP BY
        hosp.PASSAGEIRO
) hosp ON pass.CPI = hosp.PASSAGEIRO
ORDER BY
    Soma_Total DESC;

-- Gastos por planeta de origem
SELECT
    pess.PLANETA_ORIGEM AS Planeta,
    COALESCE(SUM(prod.VALOR * comp.QUANTIDADE), 0) AS Soma_Produtos,
    COALESCE(SUM(serv.VALOR), 0) AS Soma_Servicos,
    COALESCE(SUM(qres.VALOR), 0) AS Soma_Hospedagem,
    COALESCE(SUM(prod.VALOR * comp.QUANTIDADE), 0) + COALESCE(SUM(serv.VALOR), 0) + COALESCE(SUM(qres.VALOR), 0) AS Soma_Total
FROM
    PESSOA pess
LEFT JOIN RESERVAS res ON pess.CPI = res.PESSOA
LEFT JOIN QUARTO_RESERVA qres ON res.QUARTO_RESERVA = qres.ID
LEFT JOIN COMPRA comp ON res.QUARTO_RESERVA = comp.QUARTO_RESERVA
LEFT JOIN PRODUTOS prod ON comp.COD_BARRAS = prod.COD_BARRAS
LEFT JOIN CONTRATACAO_SERVICO contr ON res.QUARTO_RESERVA = contr.QUARTO_RESERVA
LEFT JOIN SERVICO_PRESTADO serpre ON contr.FUNCIONARIO = serpre.FUNCIONARIO_COMUM AND contr.HORARIO = serpre.HORARIO
LEFT JOIN SERVICOS serv ON serpre.COD_SERVICO = serv.COD_BARRAS
GROUP BY
    pess.PLANETA_ORIGEM
ORDER BY
    Soma_Total DESC;
