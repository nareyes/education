##%% IMPORT MODULES
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix

#%% IMPORT DATA
my_df = pd.read_csv('data/sample_data_classification.csv')
my_df.head()

#%% SPLIT DATA
X = my_df.drop(['output'], axis = 1)
y = my_df['output']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, stratify = y)

#%% INSTANTIATE MODEL OBJECT
clf = LogisticRegression()

#%% TRAIN MODEL
clf.fit(X_train, y_train)

#%% ASSESS MODEL ACCURACY
y_pred = clf.predict(X_test)
y_pred_prob = clf.predict_proba(X_test)
accuracy_score(y_test, y_pred)

#%% CONFUSION MATRIX
# create confusion matrix
conf_matrix = confusion_matrix(y_test, y_pred)

# plot confusion matrix
plt.style.use('seaborn-poster')
plt.matshow(conf_matrix, cmap = 'coolwarm')
plt.gca().xaxis.tick_bottom()
plt.title('Confusion Matrix')
plt.ylabel('Actual Class')
plt.xlabel('Predicted Class')

for (i, j), corr_value in np.ndenumerate(conf_matrix):
    plt.text(j, i, corr_value, ha = 'center', va = 'center', fontsize = 20)

plt.show()