#!/usr/bin/python

import psycopg2
from termcolor import colored
from config import config

def insert_data():
    conn = None
    try:
        params = config()

        # connect to the PostgreSQL server
        conn = psycopg2.connect(**params)
        cur = conn.cursor()

        # execute the INSERT statement
        cur.execute(open("./sql/dados.sql", "r", encoding='utf-8').read())

        # close communication with the PostgreSQL database server
        cur.close()

        # commit the changes to the database
        conn.commit()

        print(colored("Dados inseridos com sucesso.", 'green'))
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
          conn.close()


if __name__ == '__main__':
    insert_data()
