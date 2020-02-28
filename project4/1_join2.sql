use MovieLen
go
set   statistics IO on
set   statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
create clustered index clu_in_movies
on dbo.movies(movieId)
drop index clu_in_movies on dbo.movies

create index clu_in_ratings
on dbo.ratings(movieId, userId) include(rating) 

create index clu_in_tags
on dbo.tags(movieId, userId) include(tag)
drop index clu_in_ratings on dbo.ratings

create clustered index clu_in_links
on dbo.links(movieId)
drop index clu_in_links on dbo.links


drop index clu_in_tags on dbo.tags
go

select R.userId, R.movieId, R.rating, T.tag
from dbo.ratings R inner join dbo.tags T on R.movieId = T.movieId and R.userId = T.userId