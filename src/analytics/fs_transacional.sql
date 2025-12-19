WITH tb_transacao AS (
    SELECT  *,
            substr(DtCriacao,0,11) AS dtDia,
            cast(substr(DtCriacao,12,2) AS Int) AS dtHora
    FROM transacoes 
    WHERE DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (
    SELECT  IdCliente,

            max(julianday(date('2025-10-01', '-1 day')) - julianday(DtCriacao)) AS idadeDias,

            count(DISTINCT dtDia) AS qtdeAtivacaoVida,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day')  THEN dtDia END) AS qtdeAtivacaoD7,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,

            count(DISTINCT IdTransacao) AS qtdeTransacaoVida,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day')  THEN IdTransacao END) AS qtdeTransacaoD7,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,

            sum(qtdePontos) AS saldoVida,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day')  THEN qtdePontos ELSE 0 END) AS saldoD7,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,

            sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day')  AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD7,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD14,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD28,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD56,

            sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-7 day')  AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD7,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD14,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD28,
            SUM(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD56,

            count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
            count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
            count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) AS qtdeTransacaoNoite,

            1. * count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoManha,
            1. * count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoTarde,
            1. * count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoNoite
            
    FROM tb_transacao
    GROUP BY IdCliente
),

tb_agg_calc AS (
    SELECT  *,
            COALESCE(1. * qtdeAtivacaoVida / qtdeTransacaoVida,0) AS QtdeTransacaoVida,
            COALESCE(1. * qtdeAtivacaoD7 / qtdeTransacaoD7,0) AS QtdeTransacaoD7,
            COALESCE(1. * qtdeAtivacaoD14 / qtdeTransacaoD14,0) AS QtdeTransacaoD14,
            COALESCE(1. * qtdeAtivacaoD28 / qtdeTransacaoD28,0) AS QtdeTransacaoD28,
            COALESCE(1. * qtdeAtivacaoD56 / qtdeTransacaoD56,0) AS QtdeTransacaoD56,
            COALESCE(1. *  qtdeAtivacaoD28 / 28,0) AS pctAtivacaoMAU
    FROM tb_agg_transacao
),

tb_horas_dia AS (
    SELECT  IdCliente,
            dtDia,
            24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao

    FROM tb_transacao
    GROUP BY IdCliente, dtDia
),

tb_hora_cliente AS (
    SELECT  IdCliente,
            sum(duracao) AS qtdeHorasVida,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
            sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56

    FROM tb_horas_dia

    GROUP BY IdCliente

),

tb_lag_dia AS (
    SELECT  IdCliente,
            dtDia,
            LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lagDia

    FROM tb_horas_dia
),

tb_intervalo_dias AS (

    SELECT  IdCliente,
            avg(julianday(dtDia) - julianday(lagDia)) AS avgIntervaloDiasVida,
            avg(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN julianday(dtDia) - julianday(lagDia) END) AS avgIntervaloD28

    FROM tb_lag_dia
    GROUP By IdCliente
),

tb_share_produtos AS (
    SELECT  
            idCliente,
            1. * COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChatMessage,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeAirflowLover,
            1. * COUNT(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRLover,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeResgatarPonei,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeListadePresenca,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdePresencaStreak,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeTrocadePontso,
            1. * COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeReembolsoStreamElements,
            1. * COUNT(CASE WHEN DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRPG,
            1. * COUNT(CASE WHEN DescCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChurnModel

    FROM tb_transacao as t1

    LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos AS t3
    ON t2.IdProduto = t3.IdProduto

    GROUP BY IdCliente
),

tb_join AS (
    SELECT  t1.*,
            t2.qtdeHorasVida,
            t2.qtdeHorasD7,
            t2.qtdeHorasD14,
            t2.qtdeHorasD28,
            t2.qtdeHorasD56,
            t3.avgIntervaloDiasVida,
            t3.avgIntervaloD28,
            t4.qtdeChatMessage,
            t4.qtdeAirflowLover,
            t4.qtdeRLover,
            t4.qtdeResgatarPonei,
            t4.qtdeListadePresenca,
            t4.qtdePresencaStreak,
            t4.qtdeTrocadePontso,
            t4.qtdeReembolsoStreamElements,
            t4.qtdeRPG,
            t4.qtdeChurnModel

    FROM tb_agg_calc AS t1

    LEFT JOIN tb_hora_cliente AS t2
    ON t1.IdCliente = t2.IdCliente

    LEFT JOIN tb_intervalo_dias AS t3
    ON t1.IdCliente = t3.IdCliente

    LEFT JOIN tb_share_produtos AS t4
    ON t1.IdCliente = t4.IdCliente
)

SELECT  date('2025-10-01', '-1 day') AS dtRef,
        *
FROM tb_join