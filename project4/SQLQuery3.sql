set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
go

with sub1 as (
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 0 and 300000)
) and (h.id between 0 and 300000)

union all

select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 300000 and 600000)
) and (h.id between 300000 and 600000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 600000 and 900000)
) and (h.id between 600000 and 900000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 900000 and 1200000)
) and (h.id between 900000 and 1200000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 1200000 and 1500000)
) and (h.id between 1200000 and 1500000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 1500000 and 1800000)
) and (h.id between 1500000 and 1800000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 1800000 and 2100000)
) and (h.id between 1800000 and 2100000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 2100000 and 2400000)
) and (h.id between 2100000 and 2400000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 2400000 and 2700000)
) and (h.id between 2400000 and 2700000)
union all
select	*
from	dbo.Hotel2D  h
where	not exists
(	 select	*
	from	dbo.Hotel2D h1
	where	h1.distance <= h.distance 
	  and	h1.price <= h.price 
	  and	( h1.distance < h.distance or h1.price < h.price )
	  and   (h1.id between 2700000 and 3000000)
) and (h.id between 2700000 and 3000000)
)
select * from sub1 s
where not exists (
	select * from sub1 s1
	where s1.distance <= s.distance
	  and	s1.price <= s.price 
	  and	( s1.distance < s.distance or s1.price < s.price )
)
