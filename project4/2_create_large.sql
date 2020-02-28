SET NOCOUNT ON;
USE TSQL2013;

IF OBJECT_ID(N'dbo.GetNums', N'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO

IF OBJECT_ID('dbo.Sessions') IS NOT NULL DROP TABLE dbo.Sessions;
IF OBJECT_ID('dbo.Users') IS NOT NULL DROP TABLE dbo.Users;

CREATE TABLE dbo.Users
(
  username  VARCHAR(14)  NOT NULL,
  CONSTRAINT PK_Users PRIMARY KEY(username)
);
GO

INSERT INTO dbo.Users(username) VALUES('User1'), ('User2'), ('User3');

CREATE TABLE dbo.Sessions
(
  id        INT          NOT NULL IDENTITY(1, 1),
  username  VARCHAR(14)  NOT NULL,
  starttime DATETIME2(3) NOT NULL,
  endtime   DATETIME2(3) NOT NULL,
  CONSTRAINT PK_Sessions PRIMARY KEY(id),
  CONSTRAINT CHK_endtime_gteq_starttime
    CHECK (endtime >= starttime)
);
GO

INSERT INTO dbo.Sessions(username, starttime, endtime) VALUES
  ('User1', '20121201 08:00:00.000', '20121201 08:30:00.000'),
  ('User1', '20121201 08:30:00.000', '20121201 09:00:00.000'),
  ('User1', '20121201 09:00:00.000', '20121201 09:30:00.000'),
  ('User1', '20121201 10:00:00.000', '20121201 11:00:00.000'),
  ('User1', '20121201 10:30:00.000', '20121201 12:00:00.000'),
  ('User1', '20121201 11:30:00.000', '20121201 12:30:00.000'),
  ('User2', '20121201 08:00:00.000', '20121201 10:30:00.000'),
  ('User2', '20121201 08:30:00.000', '20121201 10:00:00.000'),
  ('User2', '20121201 09:00:00.000', '20121201 09:30:00.000'),
  ('User2', '20121201 11:00:00.000', '20121201 11:30:00.000'),
  ('User2', '20121201 11:32:00.000', '20121201 12:00:00.000'),
  ('User2', '20121201 12:04:00.000', '20121201 12:30:00.000'),
  ('User3', '20121201 08:00:00.000', '20121201 09:00:00.000'),
  ('User3', '20121201 08:00:00.000', '20121201 08:30:00.000'),
  ('User3', '20121201 08:30:00.000', '20121201 09:00:00.000'),
  ('User3', '20121201 09:30:00.000', '20121201 09:30:00.000');
GO

-- desired results
/*
username  starttime               endtime
--------- ----------------------- -----------------------
User1     2012-12-01 08:00:00.000 2012-12-01 09:30:00.000
User1     2012-12-01 10:00:00.000 2012-12-01 12:30:00.000
User2     2012-12-01 08:00:00.000 2012-12-01 10:30:00.000
User2     2012-12-01 11:00:00.000 2012-12-01 11:30:00.000
User2     2012-12-01 11:32:00.000 2012-12-01 12:00:00.000
User2     2012-12-01 12:04:00.000 2012-12-01 12:30:00.000
User3     2012-12-01 08:00:00.000 2012-12-01 09:00:00.000
User3     2012-12-01 09:30:00.000 2012-12-01 09:30:00.000
*/

-- Large Set of Sample Data
-- 2,000 users, 5,000,000 intervals
DECLARE 
  @num_users          AS INT          = 200,
  @intervals_per_user AS INT          = 500,
  @start_period       AS DATETIME2(3) = '20120101',
  @end_period         AS DATETIME2(3) = '20120107',
  @max_duration_in_ms AS INT  = 3600000; -- 60 minutes
  
TRUNCATE TABLE dbo.Sessions;
TRUNCATE TABLE dbo.Users;

INSERT INTO dbo.Users(username)
  SELECT 'User' + RIGHT('000000000' + CAST(U.n AS VARCHAR(10)), 10) AS username
  FROM dbo.GetNums(1, @num_users) AS U;

WITH C AS
(
  SELECT 'User' + RIGHT('000000000' + CAST(U.n AS VARCHAR(10)), 10) AS username,
      DATEADD(ms, ABS(CHECKSUM(NEWID())) % 86400000,
        DATEADD(day, ABS(CHECKSUM(NEWID())) % DATEDIFF(day, @start_period, @end_period), @start_period)) AS starttime
  FROM dbo.GetNums(1, @num_users) AS U
    CROSS JOIN dbo.GetNums(1, @intervals_per_user) AS I
)
INSERT INTO dbo.Sessions WITH (TABLOCK) (username, starttime, endtime)
  SELECT username, starttime,
    DATEADD(ms, ABS(CHECKSUM(NEWID())) % (@max_duration_in_ms + 1), starttime) AS endtime
  FROM C;
GO