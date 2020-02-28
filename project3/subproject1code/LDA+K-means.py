# 使用LDA有监督降维到2维，绘制散点图。使用kmeans进行聚类。
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA

X = StandardScaler().fit_transform(num)
lda = LDA(n_components=2)

Target_LDA = tmp
delete_list = []
for i in range(len(num)):
    if num[i][1] <= 5:
        delete_list.append(i)

Target_LDA = np.delete(Target_LDA, delete_list, axis=0)
XD = np.delete(X, delete_list, axis=0)

X_LDA_2D = lda.fit_transform(X, Target_LDA)

fig = plt.figure()
ax1 = fig.add_subplot(111)
# 设置标题
ax1.set_title('Linear Discriminant Analysis (LDA)')
# 设置X轴标签
plt.xlabel('First Principal Component')
# 设置Y轴标签
plt.ylabel('Second Principal Component')
# 画散点图
ax1.scatter(X_LDA_2D[:, 0], X_LDA_2D[:, 1], c=Target_LDA, cmap='jet', marker='o')
# 设置图标
# 显示所画的图
plt.show()

from sklearn.cluster import KMeans # KMeans clustering

kmeans = KMeans(n_clusters=3)

X_clustered = kmeans.fit_predict(X_LDA_2D)

fig = plt.figure()
ax1 = fig.add_subplot(111)
#设置标题
ax1.set_title('KMeans Clustering (LDA)')
#设置X轴标签
plt.xlabel('First Principal Component')
#设置Y轴标签
plt.ylabel('Second Principal Component')
#画散点图
ax1.scatter(X_LDA_2D[:,0],X_LDA_2D[:,1],c = X_clustered, cmap='jet', marker = 'o')
#显示所画的图
plt.show()