use db1;
select distinct *
from dbo.ancestors(N'Ìï')
go
select distinct *
from dbo.derives(N'Ìï')
order by xing
go