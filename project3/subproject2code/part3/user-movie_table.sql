use bigdata


/*
create table movieIdIndex(indentity int,movieId int)

insert into movieIdIndex(indentity,movieId)
select ROW_NUMBER() OVER(ORDER BY movieId ASC) AS indentity,movieId
from movies

select * from movieIdIndex
*/

/*
create table user_movie(userID int,indentity int,rating float)

insert into user_movie(userID,indentity,rating)
select userId,movieIdIndex.indentity,rating
from ratings,movieIdIndex
where ratings.movieId=movieIdIndex.movieId

select top 10 * from user_movie
*/

create table user_rating(
    userId int,
    TagedAvgScore float,
    NoTagedAvgScore float
)

insert into user_rating
select S1.userId,S1.avgscore as TagedAvgScore,S2.avgscore as NoTagedAvgScore
from user_rating_diff as S1,user_rating_diff as S2
where S1.userId=S2.userId and S1.taged<S2.taged
order by S1.userId

select avg(TagedAvgScore) as TagedAvg, avg(NoTagedAvgScore) as NoTagedAvg
from user_rating
