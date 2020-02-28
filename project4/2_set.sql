use TSQL2012
go

set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

WITH TimePoints AS 
(
  SELECT username, starttime AS ts FROM dbo.Sessions
),
Counts AS
(
  SELECT username, ts,
    (SELECT COUNT(*)
     FROM dbo.Sessions AS S
     WHERE P.username = S.username
       AND P.ts >= S.starttime
       AND P.ts < S.endtime) AS concurrent
  FROM TimePoints AS P
),
ETimePoints AS 
(
  SELECT username, endtime AS ets FROM dbo.Sessions
),
ECounts AS
(
  SELECT username, ets,
    (SELECT COUNT(*)
     FROM dbo.Sessions AS S
     WHERE P.username = S.username
       AND P.ets > S.starttime
       AND P.ets <= S.endtime) AS concurrent
  FROM ETimePoints AS P
),
Maxsess AS
(      
	SELECT username, MAX(concurrent) AS mx
	FROM Counts
	GROUP BY username
),
Maxsts AS
(
	SELECT S.username, ts
	FROM Counts S, Maxsess M
	WHERE S.username = M.username AND S.concurrent = M.mx
),
Maxets AS
(
	SELECT E.username, ets
	FROM ECounts E, Maxsess M
	WHERE E.username = M.username AND E.concurrent = M.mx
)
SELECT distinct username, ts AS starttime,
	(
	SELECT MIN(ets) FROM Maxets AS E
	WHERE E.username = S.username
		AND ets > ts) AS endtime
FROM Maxsts AS S
