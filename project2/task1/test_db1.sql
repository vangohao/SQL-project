use db1;
select distinct *
from dbo.ancestors(N'��')
go
select distinct *
from dbo.derives(N'��')
order by xing
go