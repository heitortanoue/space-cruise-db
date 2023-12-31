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

-- Funcionários comuns que ganham mais que a média de seu cargo
SELECT
    f.NUM_FUNCIONAL,
    p.NOME,
    f.SALARIO,
    C .PROFISSAO_ESP,
    MEDIA_CARGO.MEDIA_SALARIAL AS MEDIA_SALARIAL_CARGO
FROM
    COMUM C
    JOIN PESSOA p ON C .CPI = p.CPI
    JOIN FUNCIONARIO f ON p.CPI = f.CPI
    INNER JOIN (
        SELECT
            C .PROFISSAO_ESP,
            AVG(f.SALARIO) AS MEDIA_SALARIAL
        FROM
            FUNCIONARIO f
            JOIN COMUM C ON f.CPI = C .CPI
        GROUP BY
            C .PROFISSAO_ESP
    ) AS MEDIA_CARGO ON C .PROFISSAO_ESP = MEDIA_CARGO.PROFISSAO_ESP
WHERE
    f.SALARIO > MEDIA_CARGO.MEDIA_SALARIAL;

-- Passageiros que viajaram em todas as viagens de um itinerário (DIVISÃO RELACIONAL)
SELECT
    p.CPI AS CPI,
    p.NOME AS Passageiro
FROM
    pessoa p
    JOIN passageiro pa ON p.CPI = pa.CPI
WHERE
    NOT EXISTS (
        (
            SELECT
                v.NAVE,
                v.DATA
            FROM
                viagem v
            WHERE
                v.ITINERARIO = {{ITINERARIO}}
        )
        EXCEPT
            (
                SELECT
                    qr.NAVE_VIAGEM,
                    qr.DATA_VIAGEM
                FROM
                    quarto_reserva qr
                    JOIN hospedagem h ON qr.ID = h.QUARTO_RESERVA
                WHERE
                    h.PASSAGEIRO = p.CPI
            )
    ) -- Capitães disponíveis para pilotar uma viagem
SELECT
    C .CPI,
    C .FORMACAO,
    C .LICENCA
FROM
    CAPITAO C
    JOIN LICENCAS_PERMITIDAS lp ON C .LICENCA = lp.LICENCA
    LEFT JOIN VIAGEM v ON C .CPI = v.CPI_CAPITAO
    AND v.DATA = {{DATA_DA_VIAGEM}}
WHERE
    v.CPI_CAPITAO IS NULL
    AND lp.NOME_MODELO = {{MODELO_NAVE}};

-- Próximas viagens que realizam um determinado itinerário
SELECT
    v.NAVE,
    v.DATA,
    v.CPI_CAPITAO,
    v.ITINERARIO,
    v.DURACAO
FROM
    VIAGEM v
WHERE
    v.ITINERARIO = {{ITINERARIO}}
    AND v.DATA >= CURRENT_DATE
ORDER BY
    v.DATA ASC;

-- Gastos por itinerário
SELECT
    itin.NOME AS Nome_Itinerario,
    COALESCE(SUM(prod.VALOR * comp.QUANTIDADE), 0) AS Soma_Produtos,
    COALESCE(SUM(serv.VALOR), 0) AS Soma_Servicos,
    COALESCE(SUM(qres.VALOR), 0) AS Soma_Hospedagem,
    COALESCE(SUM(prod.VALOR * comp.QUANTIDADE), 0) + COALESCE(SUM(serv.VALOR), 0) + COALESCE(SUM(qres.VALOR), 0) AS Soma_Total
FROM
    ITINERARIO itin
    LEFT JOIN VIAGEM viag ON itin.NOME = viag.ITINERARIO
    LEFT JOIN QUARTO_RESERVA qres ON viag.NAVE = qres.NAVE_VIAGEM
    AND viag.DATA = qres.DATA_VIAGEM
    LEFT JOIN COMPRA comp ON comp.QUARTO_RESERVA = qres.ID
    LEFT JOIN PRODUTOS prod ON comp.COD_BARRAS = prod.COD_BARRAS
    LEFT JOIN (
        CONTRATACAO_SERVICO contr
        JOIN SERVICO_PRESTADO serpre ON contr.FUNCIONARIO = serpre.FUNCIONARIO_COMUM
        AND contr.HORARIO = serpre.HORARIO
        JOIN SERVICOS serv ON serpre.COD_SERVICO = serv.COD_BARRAS
    ) ON qres.ID = contr.QUARTO_RESERVA
GROUP BY
    itin.NOME
ORDER BY
    itin.NOME;