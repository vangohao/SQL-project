from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

X = StandardScaler().fit_transform(num)

Target_2d = tmp
delete_list = []
for i in range(len(num)):
    if num[i][1] <= 5:
        delete_list.append(i)

Target_2d = np.delete(Target_2d, delete_list, axis=0)
X = np.delete(X, delete_list, axis=0)

n_components = 2
pca = PCA(n_components=2)
pca.fit(X)
X_2d = pca.transform(X)

# print(X_2d[0])
fig = plt.figure()
ax1 = fig.add_subplot(111)
# 设置标题
ax1.set_title('Principal Component Analysis (PCA)')
# 设置X轴标签
plt.xlabel('First Principal Component')
# 设置Y轴标签
plt.ylabel('Second Principal Component')

ax1.scatter(X_2d[:, 0], X_2d[:, 1], c=Target_2d, cmap='jet', marker='o')
for i in range(0, 2041):
    ax1.annotate((X_2d[i, 0], X_2d[i, 1]))

from sklearn.cluster import KMeans # KMeans clustering

kmeans = KMeans(n_clusters=3)

X_clustered = kmeans.fit_predict(X_2d)

fig = plt.figure()
ax1 = fig.add_subplot(111)
#设置标题
ax1.set_title('KMeans Clustering (PCA)')
#设置X轴标签
plt.xlabel('First Principal Component')
#设置Y轴标签
plt.ylabel('Second Principal Component')
#画散点图
ax1.scatter(X_2d[:,0],X_2d[:,1],c = X_clustered, cmap='jet', marker = 'o')
#显示所画的图
plt.show()