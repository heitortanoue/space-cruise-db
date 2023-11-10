#!/usr/bin/python

import psycopg2
from config import config

def create_tables():
    conn = None
    try:
        params = config()
        
        # connect to the PostgreSQL server
        conn = psycopg2.connect(**params)
        cur = conn.cursor()

        # create tables from esquema.sql
        cur.execute(open("esquema.sql", "r").read())
        
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
    create_tables()
