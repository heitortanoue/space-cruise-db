#!/usr/bin/python

import psycopg2
from termcolor import colored
from config import config

def create_tables():
    conn = None
    try:
        params = config()

        # connect to the PostgreSQL server
        conn = psycopg2.connect(**params)
        cur = conn.cursor()

        print(colored("ATENÇÃO: Todas as tabelas serão apagadas e recriadas.", "red"))
        input("Pressione ENTER para confirmar...")

        # drop All tables
        cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
        tables = cur.fetchall()
        for table in tables:
            cur.execute(f"DROP TABLE {table[0]} CASCADE")
        print(colored("Todas as tabelas foram apagadas.", 'green'))

        # create tables from esquema.sql
        cur.execute(open("./sql/esquema.sql", "r").read())

        # Execute the query to count all tables
        cur.execute("SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'")

        # Fetch the result
        count = cur.fetchone()[0]

        # Print the count of tables
        print(colored(f"O banco de dados foi recriado com {count} tabelas:", 'green'))

        # Execute the query to list all tables names
        cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
        names = cur.fetchall()
        str_names = ""
        for name in names:
            str_names += name[0] + ", "
        print(str_names[:-2])

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
