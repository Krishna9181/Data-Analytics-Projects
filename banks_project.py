import pandas as pd 
import numpy as np 
from bs4 import BeautifulSoup
import requests
import sqlite3
from datetime import datetime

url = 'https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks'
table_attribs = ['Name', 'MC_USD_Billion']
csv_path = './Largest_banks_data.csv'
table_name = 'Largest_banks' 
db_name = 'Banks.db' 

def log_progress(message):
    timestamp_format = '%Y-%h-%d-%H:%M:%S'
    now = datetime.now()
    timestamp = now.strftime(timestamp_format)
    with open("./code_log.txt","a") as f:
        f.write(timestamp + ':' + message + '\n')

def extract(url, table_attribs):
    page = requests.get(url).text
    data = BeautifulSoup(page, 'html.parser')
    df = pd.DataFrame(columns = table_attribs)
    tables = data.find_all('tbody')
    rows = tables[0].find_all('tr')
    for row in rows:
        if row.find('td') is not None:
            col = row.find_all('td')
            data_dict = {'Name' : col[1].find_all('a')[1]['title'], 'MC_USD_Billion': col[2].contents[0][:-1}
            df1 = pd.DataFrame(data_dict, index = [0])
            df = pd.concat([df,df1], ignore_index = True)
    return df


def transform(df):
    df['MC_USD_Billion'] = pd.to_numeric(df['MC_USD_Billion'],errors = 'coerce')
    df['MC_INR_Billion'] = [np.round(x*82.95,2)for x in df['MC_USD_Billion']]
    df['MC_GBP_Billion'] = [np.round(x*0.8,2)for x in df['MC_USD_Billion']]
    df['MC_EUR_Billion'] = [np.round(x*0.93,2) for x in df['MC_USD_Billion']]
    return df


def load_to_csv(df, csv_path):
    df.to_csv(csv_path)

def load_to_db(df, conn, table_name):
    df.to_sql(table_name, conn, if_exists = 'replace', index = False)

def run_query(query_statement, conn):
    query_output = pd.read_sql(query_statement, conn)
    return query_output



log_progress('Preliminaries complete. Initiating ETL process')
df = extract(url,table_attribs)
log_progress('Data extraction complete. Initiating Transformation process')
df = transform(df)
#print(df)
log_progress('Data transformation complete. Initiating loading process')
load_to_csv(df, csv_path)
log_progress('Data saved to CSV file')
conn = sqlite3.connect(db_name)
log_progress('SQL Connection initiated.')
load_to_db(df, conn, table_name)
log_progress('Data loaded to Database as table. Running the query')
#query_statement = f"SELECT * FROM {table_name}"
#query_statement = f"SELECT AVG(MC_GBP_Billion) FROM {table_name}"
query_statement = f"SELECT Name from Largest_banks LIMIT 5"
query_output = run_query(query_statement, conn)
print(query_output)
log_progress("Process Terminated")
conn.close()
