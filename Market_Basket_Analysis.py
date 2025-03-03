import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
# %matplotlib inline
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder

df = pd.read_csv("OnlineRetail.csv")



df.dropna(inplace=True)

# Removing duplicate values
df.drop_duplicates(inplace = True)


# Removing negative values
df = df[df.Quantity > 0]
df = df[df['Country'] == 'United Kingdom']

# Splitting the date column
df[['date', 'time']] = df['InvoiceDate'].str.split(' ', expand=True)


"""# Market Basket Recommender - Association Rules"""



# Top 10 recommended products for a given item

basket = df.groupby(['InvoiceNo', 'StockCode'])['Quantity'].sum().unstack().reset_index().fillna(0).set_index('InvoiceNo')
basket.head(10)

# Encoding to know whether an invoice has a bought product
def encode_u(x):
    if x < 1:
        return 0
    else:
        return 1

basket = basket.applymap(encode_u)
basket = basket.astype(bool)
basket.head(10)



from mlxtend.frequent_patterns import apriori,association_rules
def RecommendItems(CurItemOfInterest, CustomerID, Country, time, date):
    # Assuming 'basket' is your dataframe containing transactions with items encoded as 1 or 0
    recommendation_ids = []
    # df of item passed
    if CurItemOfInterest == '21777':
        recommendation_ids = ['21777']
        return recommendation_ids
    else:
        item_of_interest = basket.loc[basket[CurItemOfInterest] == 1]
        
        # Check if there are any transactions containing the item of interest
        if item_of_interest.empty:
            print(f"No transactions found for item {CurItemOfInterest}.")
            return []
        
        # Applying apriori algorithm on item df
        frequent_itemsets = apriori(item_of_interest, min_support=0.15, use_colnames=True)
        
        # Check if there are any frequent itemsets
        if frequent_itemsets.empty:
            print(f"No frequent itemsets found for item {CurItemOfInterest}.")
            return []
        
        # Storing association rules
        rules = association_rules(frequent_itemsets, metric="lift", min_threshold=1)
        
        # Sorting on lift and support
        rules = rules.sort_values(['lift', 'support'], ascending=False).reset_index(drop=True)
        
        #print('Items frequently bought together with {0}:'.format(CurItemOfInterest))
        
        # Returning top 10 items with highest lift and support
        top_recommendations = rules['consequents'].head(10).tolist()

        # Extracting individual item IDs from the list of recommendations and removing duplicates
        recommendation_ids = list(set(item for sublist in top_recommendations for item in sublist))
        
        return recommendation_ids
