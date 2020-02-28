use db_wky

/*1
create table movies(movieId INT,title NVARCHAR(500),genres NVARCHAR(1000))
BULK INSERT movies
FROM '/usr/local/spark/wky/movies_unicode.csv'
WITH(FIELDTERMINATOR=',',ROWTERMINATOR='\n',FORMAT='CSV')

SELECT title FROM movies
*/

/*2

create table genre_movie(movieID INT,genres VARCHAR(50))

insert into genre_movie(movieID,genres)
SELECT movieId,value
FROM movies
CROSS APPLY STRING_SPLIT(genres,'|')

select * from genre_movie
order by genres
*/

/*3
create table movieTitlePubDate(movieId int,title NVARCHAR(500),pub_date int)


insert into movieTitlePubDate(movieId,title,pub_date)
Select movieId  , Substring(title, 1 ,LEN(title)-6) as title,
cast(Substring(title, LEN(title)-4, 4) as int) as  pub_date
from movies
*/

/* 4
create table ratings(userId int,movieId int,rating float,timestamp_ bigint)

bulk insert ratings
FROM '/usr/local/spark/ratings.csv'
WITH(FIELDTERMINATOR=',',ROWTERMINATOR='\n',FORMAT='CSV')
 
SELECT * FROM ratings
*/

/*5

create table ratingsTime(userId int, movieId int, rating float, time_ date)

insert into ratingsTime(userId,movieId,rating,time_)
select userId, movieId, rating, dateadd(second,timestamp_,{d'1970-01-01'}) as time_
from ratings
*/

/*6
create table tags(userId int,movieId int,tag nvarchar(300),timestamp_ bigint)

bulk insert tags
FROM '/usr/local/spark/wky/tags_unicode.csv'
WITH(FIELDTERMINATOR=',',ROWTERMINATOR='\n',FORMAT='CSV',DATAFILETYPE = 'widechar')
SELECT * FROM tags
*/

/*7
create table tagsTime(userId int, movieId int, tag nvarchar(300), time_ date)

insert into tagsTime(userId,movieId,tag,time_)
select userId, movieId, tag, dateadd(second,timestamp_,{d'1970-01-01'}) as time_
from tags

select * from tagsTime
order by userId
*/
