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
        cur.execute(open("./sql/esquema.sql", "r").read())

        # Execute the query to count all tables
        cur.execute("SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'")

        # Fetch the result
        count = cur.fetchone()[0]

        # Print the count of tables
        print(f"Created {count} tables:")

        # Execute the query to list all tables names
        cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
        names = cur.fetchall()
        print(names)
        
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
