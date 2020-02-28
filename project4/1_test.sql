use MovieLen
go
set   statistics IO on
set   statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
create clustered index clu_in_movies
on dbo.movies(movieId)
drop index clu_in_movies on dbo.movies

create clustered index clu_in_ratings
on dbo.ratings(movieId) 
drop index clu_in_ratings on dbo.ratings

create clustered index clu_in_links
on dbo.links(movieId)
drop index clu_in_links on dbo.links

create clustered index clu_in_tags
on dbo.tags(movieId)
drop index clu_in_tags on dbo.tags
go

select movieId, avg(rating)
from dbo.ratings
group by movieId

with ratingcnt as (
	select movieId, count(1) as num
	from dbo.ratings 
	group by movieId
	having count(1) > 500
)
create index clu_in_ratings
on dbo.ratings(movieId) where movieId in (select movieId from ratingcnt)
drop index clu_in_ratings_avg on dbo.ratings
