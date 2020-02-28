set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

select	*
from	dbo.Hotel3D  h
where	not exists
(	 select	*
	from	dbo.Hotel3D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price
	  and   h1.rating >=  h.rating
	  and	( h1.distance < h.distance or h1.price < h.price or h1.rating >  h.rating)
)