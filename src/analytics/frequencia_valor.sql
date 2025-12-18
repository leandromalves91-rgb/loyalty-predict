
WITH tb_freq_valor AS (
    SELECT  idCliente,
            COUNT(DISTINCT substr(DtCriacao,0,11)) as qtdeFreq,
            sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) as qtdePontosPos
            -- sum(abs(QtdePontos)) as qtdePontosAbs
    FROM transacoes

    WHERE DtCriacao < '2025-09-01'
    AND DtCriacao >= date('2025-09-01', '-28 day')

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

SELECT  *

FROM tb_cluster

