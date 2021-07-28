SELECT
    SUBSTRING(sqltext.text, (querystats.statement_start_offset / 2) + 1,
                (CASE querystats.statement_end_offset
                    WHEN -1 THEN DATALENGTH(sqltext.text)
                    ELSE querystats.statement_end_offset
                END - querystats.statement_start_offset) / 2 + 1) AS sqltext,
sum(querystats.execution_count)
FROM sys.dm_exec_query_stats as querystats
CROSS APPLY sys.dm_exec_text_query_plan
    (querystats.plan_handle, querystats.statement_start_offset, querystats.statement_end_offset)
    as textplan
CROSS APPLY sys.dm_exec_sql_text(querystats.sql_handle) AS sqltext
WHERE
    textplan.query_plan like '{%table_name%}'
group by SUBSTRING(sqltext.text, (querystats.statement_start_offset / 2) + 1,
                (CASE querystats.statement_end_offset
                    WHEN -1 THEN DATALENGTH(sqltext.text)
                    ELSE querystats.statement_end_offset
                END - querystats.statement_start_offset) / 2 + 1)
order by sum(querystats.execution_count) desc
OPTION (RECOMPILE);
GO