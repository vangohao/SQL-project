use db_wky

/*
create table players_playoffs_career(ilkid nvarchar(20), firstname nvarchar(20), lastname nvarchar(20), leag nvarchar(20), gp int, minutes int, pts int, dreb int, oreb int, reb int, arbs int, stl int, tlk int, turnover int, pf int, fga int, fgm int, fta int, ptm int, tpa int, tpm int)

BULK insert players_playoffs_career
FROM 'usr/local/spark/basketball_dataset/player_playoffs_career.csv'
WITH (FIELDTERMINATOR = '', ROWTERMINATOR = '\n', FORMAT= 'CSV')
*/

/*
create table players(ilkid nvarchar(20), firstname nvarchar(20), lastname nvarchar(20), position nvarchar(20), firstseason int, lastseason int, h_feet int, h_inches int, weight int, collage nvarchar(20), birthdate nvarchar(20))

BULK insert players
FROM 'usr/local/spark/basketball_dataset/player.csv'
WITH (FIELDTERMINATOR = '', ROWTERMINATOR = '\n', FORMAT= 'CSV')
*/

/*
create table players_regular_season(ilkid nvarchar(20), year int, firstname nvarchar(20), lastname nvarchar(20), team nvarchar(20), leag nvarchar(20), gp int, minutes int, pts int, dreb int, oreb int, reb int, arbs int, stl int, tlk int, turnover int, pf int, fga int, fgm int, fta int, ptm int, tpa int, tpm int)

BULK insert players_playoffs_career
FROM 'usr/local/spark/basketball_dataset/player_regular_season.csv'
WITH (FIELDTERMINATOR = '', ROWTERMINATOR = '\n', FORMAT= 'CSV')
*/

/*
create table players_playoffs(ilkid nvarchar(20), year int, firstname nvarchar(20), lastname nvarchar(20), team nvarchar(20), leag nvarchar(20), gp int, minutes int, pts int, dreb int, oreb int, reb int, arbs int, stl int, tlk int, turnover int, pf int, fga int, fgm int, fta int, ptm int, tpa int, tpm int)

BULK insert players_playoffs_career
FROM 'usr/local/spark/basketball_dataset/player_playoffs.csv'
WITH (FIELDTERMINATOR = '', ROWTERMINATOR = '\n', FORMAT= 'CSV')
*/

/*
create table players_career(ilkid nvarchar(20), firstname nvarchar(20), lastname nvarchar(20), leag nvarchar(20), gp int, minutes int, pts int, dreb int, oreb int, reb int, arbs int, stl int, tlk int, turnover int, pf int, fga int, fgm int, fta int, ptm int, tpa int, tpm int)

BULK insert players_playoffs_career
FROM 'usr/local/spark/basketball_dataset/player_career.csv'
WITH (FIELDTERMINATOR = '', ROWTERMINATOR = '\n', FORMAT= 'CSV')
*/

