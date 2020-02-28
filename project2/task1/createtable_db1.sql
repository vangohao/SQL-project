use master
if exists(select * from sys.databases where name='db1') 
	drop database db1
create database db1
go
use db1
go
create table PS(Parent nvarchar(50),Son nvarchar(50));
go
BULK insert dbo.PS
from 'C:/Dropbox/sql/shixi2/xingshiqiyuan.txt'  
WITH (   
FIELDTERMINATOR = ',',   
ROWTERMINATOR = '\n'
)
GO
CREATE FUNCTION derives
(
	@param1 nvarchar(50)
)
RETURNS @returntable TABLE
(
	xing nvarchar(50),
	lvl int
)
AS
BEGIN
	with Components(Ancestor, Derives, lvl) as
		(select Parent, Son, 1
		from 	PS
		where Parent = @param1
		union all
		select	C.Ancestor, A.Son, C.lvl + 1
		from	PS A, Components C
		where	A.Parent = C.Derives
		)
	INSERT @returntable
	SELECT Derives, lvl from Components
	RETURN
END
go
CREATE FUNCTION ancestors
(
	@param1 nvarchar(50)
)
RETURNS @returntable TABLE
(
	xing nvarchar(50)
)
AS
BEGIN
	with Components(Ancestor, Derives) as
		(select Parent, Son
		from 	PS
		where Son = @param1
		union all
		select	A.Parent, C.Derives
		from	PS A, Components C
		where	A.Son = C.Ancestor
		)
	INSERT @returntable
	SELECT Ancestor from Components
	RETURN
END
go