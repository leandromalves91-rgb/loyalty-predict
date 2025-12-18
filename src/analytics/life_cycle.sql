-- curiosa -> idade < 7
-- fiel -> recência < 7 e anterior < 15
-- turista -> 7 <= rececência <= 14
-- desencantado -> 14 <= recência <= 28
-- zumbi -> recência > 28
-- recomquistado -> recência < 7 e 14 <= recência anterior <= 28
-- reborn -> recência < 7 e 14 <= recência anterior > 28

WITH tb_daily AS (
    SELECT
        DISTINCT
            idCliente,
            substr(DtCriacao, 0, 11) AS dtDia
    FROM transacoes
    WHERE DtCriacao < '{date}'
),

tb_idade AS (
    SELECT 
        IdCliente,
        -- min(dtDia) AS dtPrimTransacao,
        CAST(max(julianday('{date}') - julianday(dtDia)) AS int) AS qtdeDiasPrimTransacao,
        -- max(dtDia) AS dtUltTransacao,
        CAST(min(julianday('{date}') - julianday(dtDia)) AS int) AS qtdeDiasUltTransacao
    FROM tb_daily
    GROUP BY idCliente

),

tb_rn AS (
    SELECT  *,
            row_number() OVER (PARTITION BY idCliente ORDER BY dtDia DESC) AS rnDia

    from tb_daily
),

tb_penultima_ativacao AS (
    SELECT  *, 
            CAST(julianday('{date}') - julianday(dtDia) AS INT) AS qtdeDiasPenultimaTransacao
    FROM tb_rn
    WHERE rnDia = 2
),

tb_life_cycle AS (
    SELECT  t1.*,
            t2.qtdeDiasPenultimaTransacao,
            CASE
                WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
                WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao <= 14 THEN '02-FIEL'
                WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
                WHEN qtdeDiasUltTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
                WHEN qtdeDiasUltTransacao > 28 THEN '05-ZUMBI'
                WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
                WHEN qtdeDiasUltTransacao <= 14 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao > 28 THEN '02-REBORN'
            END AS descLifeCycle

    FROM tb_idade AS t1

    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.idCliente = t2.idCliente
),

tb_freq_valor AS (
    SELECT  idCliente,
            COUNT(DISTINCT substr(DtCriacao,0,11)) as qtdeFreq,
            sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) as qtdePontosPos
            -- sum(abs(QtdePontos)) as qtdePontosAbs
    FROM transacoes

    WHERE DtCriacao < '{date}'
    AND DtCriacao >= date('{date}', '-28 day')

    GROUP BY idCliente

    ORDER BY qtdeFreq DESC

),

tb_cluster AS (
        SELECT  *,
                CASE
                        WHEN qtdeFreq <= 10 AND qtdePontosPos >= 1500 THEN '10-HYPERS'
                        WHEN qtdeFreq > 10 AND qtdePontosPos >= 1500 THEN '20-EFICIENTES'
                        WHEN qtdeFreq <= 10 AND qtdePontosPos >= 750 THEN '02-INDECISO'
                        WHEN qtdeFreq > 10 AND qtdePontosPos >= 750 THEN '12-ESFORCADO'
                        WHEN qtdeFreq < 5 THEN '00-LURKERS'
                        WHEN qtdeFreq <= 10 THEN '01-PREGUICOSOS'
                        WHEN qtdeFreq > 10 THEN '11-POTENCIAL'
                END AS cluster



        FROM tb_freq_valor

)

SELECT  date('{date}', '-1 day') AS dtRef,
        t1.*,
        t2.qtdeFreq,
        t2.qtdePontosPos,
        t2.cluster

FROM tb_life_cycle AS t1

LEFT JOIN tb_cluster AS t2
ON t1.idCliente = t2.idCliente
