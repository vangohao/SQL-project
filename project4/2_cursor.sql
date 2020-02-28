use TSQL2012
go

set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

DECLARE
  @username AS varchar(10), 
  @prevusername AS varchar (10),
  @ts AS datetime,
  @tmps AS datetime,
  @type AS int,
  @concurrent AS int,
  @flag AS int, 
  @mx AS int;

DECLARE @usernamesMx TABLE
(
  username varchar (10) NOT NULL,
  starttime datetime NOT NULL,
  endtime datetime NOT NULL
);

DECLARE sessions_cur CURSOR FAST_FORWARD FOR
  SELECT username, starttime AS ts, +1 AS type
  FROM dbo.Sessions
  
  UNION ALL
  
  SELECT username, endtime, -1
  FROM dbo.Sessions
  
  ORDER BY username, ts, type;

OPEN sessions_cur;

FETCH NEXT FROM sessions_cur
  INTO @username, @ts, @type;

SET @prevusername = @username;
SET @concurrent = 0;
SET @mx = 0;
SET @flag = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @username <> @prevusername
  BEGIN
    SET @concurrent = 0;
    SET @mx = 0;
	SET @flag = 0;
    SET @prevusername = @username;
  END

  SET @concurrent = @concurrent + @type;
  IF @concurrent > @mx 
  BEGIN
	SET @mx = @concurrent;
	DELETE FROM @usernamesMx WHERE username = @username
	SET @flag = 1;
	SET @tmps = @ts;
  END
  ELSE IF @concurrent = @mx
  BEGIN
	SET @flag = 1;
	SET @tmps = @ts;
  END
  ELSE IF @flag = 1
  BEGIN
	SET @flag = 0;
	INSERT INTO @usernamesMx VALUES(@username, @tmps, @ts);
  END
  
  FETCH NEXT FROM sessions_cur
    INTO @username, @ts, @type;
END

CLOSE sessions_cur;

DEALLOCATE sessions_cur;

SELECT * FROM @usernamesMx;
GO