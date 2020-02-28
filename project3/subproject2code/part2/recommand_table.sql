use bigdata

/*
create table recommand_tab(userId int, genre nvarchar(200), avg_rating float)

insert into recommand_tab(userId,genre,avg_rating)
select ratingsTime.userId as userId,genre_movie.genres as genre,avg(rating) as avg_rating
from genre_movie inner join ratingsTime on genre_movie.movieID=ratingsTime.movieId
group by ratingsTime.userId,genre_movie.genres
order by userId,avg_rating DESC

SELECT * from recommand_tab
order by userId,avg_rating DESC
*/

/*create table best_movies_genres(genres nvarchar(200), title nvarchar(200), avg_score float)

insert into best_movies_genres(genres, title, avg_score)
select g1.genres as genres, top.title as title, top.avg_score as avg_score
from (select distinct genres from genre_movie) as g1 cross apply(
    select g1.genres, m.title, avg(r.rating) as avg_score
    from movies as m, ratings as r, genre_movie as g2
    where g1.genres = g2.genres and m.movieId = r.movieId and m.movieId = g2.movieID and m.movieId in(
        select movieID
        from ratings
        group by movieID
    )
    group by g2.genres, m.title
    order by g2.genres, avg_score
) as top
order by g1.genres
*/