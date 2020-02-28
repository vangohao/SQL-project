from sklearn.linear_model import  LinearRegression
from sklearn.model_selection import train_test_split
from sklearn import linear_model,datasets,metrics
import pandas as pd
file = pd.read_csv('player_career.csv')
data = file.drop([2236])
num = data.values
import numpy as np

index = []
for i in range(len(num[0])):
    try:
        tmp = float(num[0][i])
    except:
        index.append(i)

num = np.delete(num, index, axis=1)
#print(num.shape)


y = num[:,2]
x = num[:,3:]

X_train,X_test,y_train,y_test=train_test_split(x,y,test_size=0.1,random_state=1)

LR = LinearRegression()
# 对训练数据进行拟合训练
LR.fit(X_train, y_train)
# 输出参数,分别是截距（intercept_）和权重参数(coef_）
print('LR.intercept:\n',LR.intercept_)
print('LR.coef:\n',LR.coef_)
# 计算确定系数R^2,取值范[0,1],值越大,说明模拟的拟合度越好，对模型的解释能力越强
print('R^2:\n',LR.score(X_test,y_test))
# 根据测试数据计算预测值y_predict
y_predict=LR.predict(X_test)
# MSE为均方误差，用测试数据来验证，MSE为预测数据和测试数据误差平方和的均值
print ("MSE:",metrics.mean_squared_error(y_test,y_predict))
# RMSE为均方根无误差
print('RMSE:',np.sqrt(metrics.mean_squared_error(y_test,y_predict)))

plt.scatter(y_test,y_predict,c='b',alpha=0.5,marker='*')
plt.xlabel('y_test')
plt.ylabel('y_predict')
plt.plot([y_test.min(),y_test.max()],[y_test.min(),y_test.max()],'k--',lw=4)   ### 画出y=x这条线
plt.show()