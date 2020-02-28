use TSQL2012
go

set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

WITH C1 AS
(
  SELECT username, starttime AS ts, +1 AS type
  FROM dbo.Sessions

  UNION ALL

  SELECT username, endtime, -1
  FROM dbo.Sessions
),
C2 AS
(
  SELECT *,
  SUM(type) OVER(PARTITION BY username ORDER BY ts, type
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cnt
  FROM C1
),
ET AS
(
  SELECT A.username, A.ts AS endtime, 
	ROW_NUMBER() OVER(PARTITION BY username ORDER BY ts) AS rownum FROM C2 A 
  WHERE cnt = (SELECT MAX(cnt) FROM C2 B WHERE A.username = B.username AND A.type = -1) - 1
),
ST AS
(
  SELECT A.username, A.ts AS starttime, 
	ROW_NUMBER() OVER(PARTITION BY username ORDER BY ts) AS rownum FROM C2 A 
  WHERE cnt = (SELECT MAX(cnt) FROM C2 B WHERE A.username = B.username)
)
SELECT S.username, S.starttime, E.endtime
FROM ET E, ST S
WHERE E.username = S.username AND E.rownum = S.rownum