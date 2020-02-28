import os
import MySQLdb

db = MySQLdb.connect("47.106.14.88", "root", "#define0true", "bigdata", charset='unicode' )
cursor = db.cursor()
sql = " SELECT * \
        from best_movies_genres"
cursor.execute(sql)
best_movies_genres = cursor.fetchall()
# structure: [0]-genres, [1]-title, [2]avg_score
# the data part is too big, so use the small-data instead


sql = " SELECT * from recommand_tab\
        order by userId,avg_rating DESC"
cursor.execute(sql)
recommand_tab = cursor.fetchall()
# structure: [0]-userId, [1]-genre, [2]-avg_rating

str = input("Please input the UserId:")
sql = " select title\
        from ratings\
        where userId = " + str
# the rating table has already been added a column "title", so just get it
cursor.execute(sql)
movies = cursor.fetchall()

num = 0
result = []
# all genres and movies are sorted, so just use it
for row1 in recommand_tab:
	if num >= 10:
		break
	if row1[0] == (int)(str):
		# recommand this genre
		cur_genre = row1[1]
		for row2 in best_movies_genres:
			if num >= 10:
				break
			if row2[0] == cur_genre:
				# try to recommand this movie
				if row2[1] not in movies:
					# this movie is not seen by this user
					result.append(row2[1])
					num += 1

print("Recommanded movies are:")
print(result)