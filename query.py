#!/usr/bin/python

import psycopg2
from config import config

def query_data():
    conn = None
    try:
        params = config()
        
        # connect to the PostgreSQL server
        conn = psycopg2.connect(**params)
        cur = conn.cursor()

        # query from consultas.sql
        cur.execute(open("./sql/consultas.sql", "r").read())

        rows = cur.fetchall()
        print("Number of rows: ", cur.rowcount)
        for row in rows:
            print(row)
        
        # close communication with the PostgreSQL database server
        cur.close()

        # commit the changes
        conn.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    finally:
        if conn is not None:
          conn.close()

if __name__ == '__main__':
    query_data()
