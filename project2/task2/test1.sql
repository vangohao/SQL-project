use db2
--insert into Ord Values
--(1,'T1','read','A'),
--(2,'T2','write','A'),
--(3,'T1','write','A');

insert into Ord Values
(1,'T1','read','A'),
(2,'T2','write','A'),
(3,'T3','read','A'),
(4,'T1','write','A'),
(5,'T3','write','A');

declare @a int, @b int
exec @a = ConflictSer
if(@a=1) 
	select N'当前调度不是冲突可串行化的' as result;
else 
	select N'当前调度是冲突可串行化的' as result;
exec @b = ViewSer
if(@b=1)
	select N'当前调度不是视图可串行化的' as result;
else
	select N'当前调度是视图可串行化的' as result;
go
use master
go