use master
if exists(select * from sys.databases where name='db3') 
	drop database db3
create database db3
go
use db3
create table SP(
IndexDate date, 
OpenPrice money, 
HighPrice money,
LowPrice money,
ClosePrice money,
Volume real,
AdjClose money);
create table SP_O(
t1 varchar(20),
t2 varchar(20),
t3 varchar(20),
t4 varchar(20),
t5 varchar(20),
t6 varchar(20),
t7 varchar(20)
);
go
use db3
bulk insert dbo.SP_O
from 'C:\\Dropbox\\sql\\shixi2\\sp500.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
);
go
insert into SP
select convert(date,t1),convert(money,t2),convert(money,t3),convert(money,t4),convert(money,t5),convert(real,t6),convert(money,t7)
from SP_O
go
-- 计算威廉指标
select top 10 *, 
(((max(HighPrice) over (order by IndexDate rows between 13 preceding and 0 following)) 
 - ClosePrice)
 /((max(HighPrice) over (order by IndexDate rows between 13 preceding and 0 following))
 -(min(LowPrice) over (order by IndexDate rows between 13 preceding and 0 following)))
 * (-100))
 as "W%R"
from SP
go
-- 识别长上影线
select *, 'yes'
from SP
where ((HighPrice - OpenPrice)/OpenPrice > 0.02) and
		((OpenPrice=ClosePrice) or (OpenPrice<>ClosePrice and ((HighPrice-(case when OpenPrice > ClosePrice then OpenPrice else ClosePrice end))
	/(case when OpenPrice > ClosePrice then OpenPrice - ClosePrice else ClosePrice - OpenPrice end) > 7))) 