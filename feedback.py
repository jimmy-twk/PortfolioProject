import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# File path 
data = pd.read_csv(r'D:\Projects\Customer Feedback Project\sentiment-analysis.csv')

#print(data.columns)
#print(data.dtypes)
#print(data.info())
#print(data)

# Drop NA values and duplicate rows
data = data.dropna()
# Check for duplicate rows
repeat_row = data.duplicated()
#print(repeat_row)
# Drop duplicate rows
data = data.drop_duplicates()

# Convert data to DataFrame using pd.DataFrame
df = pd.DataFrame(columns = ['Text', 'Sentiment', 'Source','Date/Time', 'User ID', 'Location', 'Confidence Score'])
for i in data.index:
    a = data.iloc[i,0].split(",")
    df.loc[len(df)] = a

# Format User ID column by remove @
df['User ID'] = df['User ID'].str.replace('@','')

# Separate Date and Time to different columns
df['Date/Time'] = pd.to_datetime(df['Date/Time'])
df['Date'] = df['Date/Time'].dt.date 
df['Time'] = df['Date/Time'].dt.time 

# Output total number of feedback - Pie Chart
senti = df['Sentiment'].value_counts()
fig = plt.figure(figsize=(14,6))
plt.pie(senti, labels = df['Sentiment'].unique(), autopct = '%1.1f%%')

# Output number of feedback based on different platforms - Bar plot
source = df[['Source']]
feedback_source = source.groupby('Source').agg({'Source':['count']}).reset_index()
feedback_source.columns = ['source_type','feedback_count_source']
sorted_feedback_source = feedback_source.sort_values(by = 'feedback_count_source', ascending= False,ignore_index= True)
fig = plt.figure(figsize=(14,6))
sns.barplot(y = 'source_type', x = 'feedback_count_source', data =sorted_feedback_source)

# Output number of feedback based on different cities - Bar plot
location = df[['Location']]
feedback_location = location.groupby('Location').agg({'Location':['count']}).reset_index()
feedback_location.columns = ['city','feedback_count_location']
sorted_feedback_location = feedback_location.sort_values(by = ['feedback_count_location','city'], ascending= True, ignore_index= True)
fig = plt.figure(figsize=(14,6))
sns.barplot(y = 'feedback_count_location', x = 'city', data =sorted_feedback_location)

# Output number of positive and negative feedback based on from different cities - Table
location_senti = df[['Location','Sentiment']]
feedback_loc_sen = location_senti.groupby(['Location','Sentiment']).agg({'Sentiment':['count']}).unstack(fill_value=0)
feedback_loc_sen.columns = ['Negative','Positive']

plt.show()