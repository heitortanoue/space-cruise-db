import psycopg2
from config import config
from termcolor import colored

params = config()

# connect to the PostgreSQL server
conn = psycopg2.connect(**params)
cur = conn.cursor()

"""
Função para inserir uma pessoa no sistema.
"""
def inserir_pessoa(cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie):
  try:
    query = "INSERT INTO PESSOA (cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    values = (cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie)
    cur.execute(query, values)
    conn.commit()
    print(colored("Pessoa inserida com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir pessoa: ", "red"))
    print(colored(e, "red"));

""""
Função para inserir um passageiro no sistema.
"""
def inserir_passageiro(cpi):
  try:
    query = "INSERT INTO PASSAGEIRO (cpi) VALUES (%s)"
    values = (cpi,)
    cur.execute(query, values)
    conn.commit()
    print(colored("Passageiro inserido com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir passageiro: ", "red"))
    print(colored(e, "red"))

"""
Função para inserir um funcionário no sistema.
"""
def inserir_funcionario(cpi, num_funcional, cargo, salario):
  try:
    query = "INSERT INTO FUNCIONARIO (cpi, num_funcional, cargo, salario) VALUES (%s, %s, %s, %s)"
    values = (cpi, num_funcional, cargo, salario)
    cur.execute(query, values)
    conn.commit()
    print(colored("Funcionario inserido com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir funcionario: ", "red"))
    print(colored(e, "red"))

"""
Função para inserir uma reserva no sistema.
"""
def inserir_hospedagem(quarto_reserva, passageiro):
  try:
    query = "INSERT INTO HOSPEDAGEM (quarto_reserva, passageiro) VALUES (%s, %s)"
    values = (quarto_reserva, passageiro)
    cur.execute(query, values)
    conn.commit()
    print(colored("Hospedagem inserida com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir hospedagem: ", "red"))
    print(colored(e, "red"))

"""
Função para inserir uma reserva no sistema.
"""
def inserir_produtos(cod_barras, nome, valor):
  try:
    query = "INSERT INTO PRODUTOS (cod_barras, nome, valor) VALUES (%s, %s, %s)"
    values = (cod_barras, nome, valor)
    cur.execute(query, values)
    conn.commit()
    print(colored("Produto inserido com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir produto: ", "red"))
    print(colored(e, "red"))

"""
Função para inserir um serviço no sistema.
"""
def inserir_servicos(cod_barras, nome, valor):
  try:
    query = "INSERT INTO SERVICOS (cod_barras, nome, valor) VALUES (%s, %s, %s)"
    values = (cod_barras, nome, valor)
    cur.execute(query, values)
    conn.commit()
    print(colored("Servico inserido com sucesso!", "green"))
  except Exception as e:
    # ROLLBACK
    conn.rollback()
    print(colored("Erro ao inserir servico: ", "red"))
    print(colored(e, "red"))
