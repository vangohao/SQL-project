set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
)

