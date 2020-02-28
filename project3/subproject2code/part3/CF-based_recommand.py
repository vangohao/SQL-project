import MySQLdb

db = MySQLdb.connect("47.106.14.88", "root", "#define0true", "bigdata", charset='unicode' )
cursor = db.cursor()
sql = " SELECT * \
        from user_movie"
cursor.execute(sql)
df = cursor.fetchall()
n_users = 944
n_items = 1683

from sklearn import model_selection
train_data, test_data = model_selection.train_test_split(df, test_size=0.25)

train_data_matrix = np.zeros((n_users, n_items))
for i in range(len(train_data)):
    row = int(train_data.iloc[[i]]['user_id'])
    col = int(train_data.iloc[[i]]['movie_id'])
    train_data_matrix[row][col] = int(train_data.iloc[[i]]['rating'])

test_data_matrix = np.zeros((n_users, n_items))
for i in range(len(test_data)):
    row = int(test_data.iloc[[i]]['user_id'])
    col = int(test_data.iloc[[i]]['movie_id'])
    test_data_matrix[row][col] = int(test_data.iloc[[i]]['rating'])

import math
from sklearn.metrics.pairwise import cosine_similarity
#计算余弦相似度

#user_similarity = np.zeros((n_users, n_users))
user_similarity = cosine_similarity(train_data_matrix)


#item_similarity = np.zeros((n_items, n_items))
item_similarity = cosine_similarity(train_data_matrix.transpose())

for i in range(n_users):
    user_similarity[i][i] = 0.0
for i in range(n_items):
    item_similarity[i][i] = 0.0


# 实现的是KNN思想，取k=3,即打分取3个的平均值
def predict(ratings, similarity, type='user'):
    prediction = np.zeros((n_users, n_items))
    if type == 'user':
        for i in range(1, n_users):
            ind = np.argsort(user_similarity[i])
            # print(ind)
            index1 = ind[-1]
            index2 = ind[-2]
            index3 = ind[-3]
            for j in range(1, n_items):
                if train_data_matrix[i][j] == 0:
                    prediction[i][j] = (train_data_matrix[index1][j] + train_data_matrix[index2][j] +
                                        train_data_matrix[index3][j]) / 3

    elif type == 'item':
        for i in range(1, n_items):
            ind = np.argsort(item_similarity[i])
            index1 = ind[-1]
            index2 = ind[-2]
            index3 = ind[-3]
            for j in range(1, n_users):
                if train_data_matrix[j][i] == 0:
                    prediction[j][i] = (train_data_matrix[j][index1] + train_data_matrix[j][index2] +
                                        train_data_matrix[j][index3]) / 3

    return prediction


item_prediction = predict(train_data_matrix, item_similarity, type='item')
user_prediction = predict(train_data_matrix, user_similarity, type='user')

from sklearn.metrics import mean_squared_error
from math import sqrt
def rmse(prediction, ground_truth):
    prediction = prediction[ground_truth.nonzero()].flatten()
    ground_truth = ground_truth[ground_truth.nonzero()].flatten()
    return sqrt(mean_squared_error(prediction, ground_truth))

print('User-based CF RMSE: ' + str(rmse(user_prediction, test_data_matrix)))
print('Item-based CF RMSE: ' + str(rmse(item_prediction, test_data_matrix)))