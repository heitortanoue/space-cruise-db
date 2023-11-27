import psycopg2
from psycopg2 import sql
from termcolor import colored

from config import config

def connect_to_db():
    """ Estabelece conexão com o banco de dados. """
    try:
        params = config()  # substitua pela sua função de configuração
        conn = psycopg2.connect(**params)
        return conn
    except Exception as e:
        print(colored(f"Erro ao conectar ao banco de dados: {e}", "red"))
        return None

def get_table_status(cursor):
    """ Retorna o status das tabelas no banco de dados. """
    cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
    tables = cursor.fetchall()

    status = []
    for table in tables:
        table_name = table[0]
        cursor.execute(sql.SQL("SELECT COUNT(*) FROM {}").format(sql.Identifier(table_name)))
        count = cursor.fetchone()[0]
        status.append((table_name, count))

    return status

def print_db_status():
    """ Imprime o status da base de dados e das tabelas. """
    conn = connect_to_db()
    if conn:
        cur = conn.cursor()
        try:
            # Obter e imprimir o status das tabelas
            table_status = get_table_status(cur)
            print(colored("Status das Tabelas:", "yellow"))
            for table, count in table_status:
                print(colored(f"{table}: ", "cyan"), end=""), print(f"{count} tuplas")

            # Adicione aqui mais verificações de status se necessário

        except Exception as e:
            print(colored(f"Erro ao obter status do banco de dados: {e}", "red"))
        finally:
            cur.close()
            conn.close()
    else:
        print(colored("Falha ao conectar ao banco de dados.", "red"))

if __name__ == "__main__":
    print_db_status()
