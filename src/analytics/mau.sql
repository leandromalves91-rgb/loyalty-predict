/*
Cada ponto conta quantos usuários distintos tiveram nos últimos 28 dias em relação àquele ponto
28 dias = 4 de cada dia da semana
*/

with tb_daily AS (
    SELECT  DISTINCT
        date(substr(DtCriacao, 0, 11)) AS DtDia,
        idCliente

    FROM transacoes
    ORDER BY DtDia

),

tb_distintic_day AS (
    SELECT 
        DISTINCT DtDia AS dtRef

    FROM tb_daily

)

SELECT  t1.dtRef,
        count(DISTINCT IdCliente) AS MAU,
        count(DISTINCT t2.dtDia) AS qtdeDias

FROM tb_distintic_day AS t1

LEFT JOIN tb_daily AS t2
ON t2.DtDia <= t1.dtRef
AND julianday(t1.dtRef) - julianday(t2.DtDia) < 28

GROUP BY t1.dtRef
ORDER BY t1.dtRef ASC



