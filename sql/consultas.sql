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


-- Passageiros que viajaram em todas as viagens de um itinerário (DIVISÃO RELACIONAL)
SELECT
    p.CPI AS CPI,
    p.NOME AS Passageiro
FROM
    pessoa p
JOIN passageiro pa
ON p.CPI = pa.CPI
WHERE NOT EXISTS (
    (
        SELECT v.NAVE, v.DATA FROM viagem v
        WHERE v.ITINERARIO = {{ITINERARIO}}
    )
    EXCEPT (
        SELECT qr.NAVE_VIAGEM, qr.DATA_VIAGEM
        FROM quarto_reserva qr
        JOIN hospedagem h ON qr.ID = h.QUARTO_RESERVA
        WHERE h.PASSAGEIRO = p.CPI
    )
)



-- Capitães disponíveis para pilotar uma viagem
SELECT
    c.CPI,
    c.FORMACAO,
    c.LICENCA
FROM
    CAPITAO c
    JOIN LICENCAS_PERMITIDAS lp ON c.LICENCA = lp.LICENCA
    LEFT JOIN VIAGEM v ON c.CPI = v.CPI_CAPITAO
    AND v.DATA = {{DATA_DA_VIAGEM}}
WHERE
    v.CPI_CAPITAO IS NULL
    AND lp.NOME_MODELO = {{MODELO_NAVE}};


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

-- Gastos por passageiro, considerando todas as reservas feitas por ele
SELECT
    p.NOME AS Passageiro,
    p.CPI AS CPI,
    COALESCE(sp.Soma_Produtos, 0) AS "Soma Produtos",
    COALESCE(ss.Soma_Servicos, 0) AS "Soma Serviços",
    COALESCE(sh.Soma_Hospedagem, 0) AS "Soma Hospedagem",
    COALESCE(sp.Soma_Produtos, 0) + COALESCE(ss.Soma_Servicos, 0) + COALESCE(sh.Soma_Hospedagem, 0) AS "Soma Total"
FROM
    PASSAGEIRO pa
INNER JOIN
    PESSOA p ON pa.CPI = p.CPI
LEFT JOIN
    (SELECT
         r.PESSOA,
         SUM(pr.VALOR * c.QUANTIDADE) AS Soma_Produtos
     FROM
         COMPRA c
     INNER JOIN
         RESERVAS r ON c.QUARTO_RESERVA = r.QUARTO_RESERVA
     INNER JOIN
         PRODUTOS pr ON c.COD_BARRAS = pr.COD_BARRAS
     GROUP BY
         r.PESSOA) sp ON p.CPI = sp.PESSOA
LEFT JOIN
    (SELECT
         r.PESSOA,
         SUM(s.VALOR) AS Soma_Servicos
     FROM
         CONTRATACAO_SERVICO cs
     INNER JOIN
         RESERVAS r ON cs.QUARTO_RESERVA = r.QUARTO_RESERVA
     INNER JOIN
         SERVICO_PRESTADO sp ON cs.FUNCIONARIO = sp.FUNCIONARIO_COMUM AND cs.HORARIO = sp.HORARIO
     INNER JOIN
         SERVICOS s ON sp.COD_SERVICO = s.COD_BARRAS
     GROUP BY
         r.PESSOA) ss ON p.CPI = ss.PESSOA
LEFT JOIN
    (SELECT
         r.PESSOA,
         SUM(qr.VALOR) AS Soma_Hospedagem
     FROM
         RESERVAS r
     INNER JOIN
         QUARTO_RESERVA qr ON r.QUARTO_RESERVA = qr.ID
     GROUP BY
         r.PESSOA) sh ON p.CPI = sh.PESSOA;


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

-- Serviços disponíveis para uma viagem
SELECT
    p.NOME AS Nome_Funcionario,
    s.NOME AS Nome_Servico,
    sp.HORARIO,
    s.VALOR AS Valor_Servico
FROM
    SERVICO_PRESTADO sp
INNER JOIN
    COMUM c ON sp.FUNCIONARIO_COMUM = c.CPI
INNER JOIN
    FUNCIONARIO f ON c.CPI = f.CPI
INNER JOIN
    PESSOA p ON f.CPI = p.CPI
INNER JOIN
    SERVICOS s ON sp.COD_SERVICO = s.COD_BARRAS
LEFT JOIN
    CONTRATACAO_SERVICO cs ON sp.FUNCIONARIO_COMUM = cs.FUNCIONARIO AND sp.HORARIO = cs.HORARIO
WHERE
    cs.FUNCIONARIO IS NULL
    AND sp.HORARIO > CURRENT_TIME
    AND EXISTS (
        SELECT 1
        FROM TRABALHO_COMUM tc
        WHERE tc.CPI_COMUM = sp.FUNCIONARIO_COMUM
        AND tc.NAVE_VIAGEM = {{Nave Viagem}}
        AND sp.HORARIO > CURRENT_TIME
    );

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
    v.ITINERARIO = {{Itinerário desejado}}
    AND v.DATA >= CURRENT_DATE
ORDER BY
    v.DATA ASC;