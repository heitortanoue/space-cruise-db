import psycopg2
from config import config

params = config()

# connect to the PostgreSQL server
conn = psycopg2.connect(**params)
cur = conn.cursor()

def inserir_pessoa(cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie):
  try:
    query = "INSERT INTO PESSOA (cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    values = (cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie)
    cur.execute(query, values)
    conn.commit()
    print("Pessoa inserida com sucesso!")
  except Exception as e:
    print("Erro ao inserir pessoa: ", e)

def inserir_passageiro(cpi):
  try:
    query = "INSERT INTO PASSAGEIRO (cpi) VALUES (%s)"
    values = (cpi,)
    cur.execute(query, values)
    conn.commit()
    print("Passageiro inserido com sucesso!")
  except Exception as e:
    print("Erro ao inserir passageiro: ", e)


def inserir_funcionario(cpi, num_funcional, cargo, salario):
  try:
    query = "INSERT INTO FUNCIONARIO (cpi, num_funcional, cargo, salario) VALUES (%s, %s, %s, %s)"
    values = (cpi, num_funcional, cargo, salario)
    cur.execute(query, values)
    conn.commit()
    print("Funcionario inserido com sucesso!")
  except Exception as e:
    print("Erro ao inserir funcionario: ", e)

def inserir_hospedagem(quarto_reserva, passageiro):
  try:
    query = "INSERT INTO HOSPEDAGEM (quarto_reserva, passageiro) VALUES (%s, %s)"
    values = (quarto_reserva, passageiro)
    cur.execute(query, values)
    conn.commit()
    print("Hospedagem inserida com sucesso!")
  except Exception as e:
    print("Erro ao inserir hospedagem: ", e)

def inserir_produtos(cod_barras, nome, valor):
  try:
    query = "INSERT INTO PRODUTOS (cod_barras, nome, valor) VALUES (%s, %s, %s)"
    values = (cod_barras, nome, valor)
    cur.execute(query, values)
    conn.commit()
    print("Produto inserido com sucesso!")
  except Exception as e:
    print("Erro ao inserir produto: ", e)

def inserir_servicos(cod_barras, nome, valor):
  try:
    query = "INSERT INTO SERVICOS (cod_barras, nome, valor) VALUES (%s, %s, %s)"
    values = (cod_barras, nome, valor)
    cur.execute(query, values)
    conn.commit()
    print("Servico inserido com sucesso!")
  except Exception as e:
    print("Erro ao inserir servico: ", e)