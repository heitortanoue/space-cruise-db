import psycopg2
from config import config
import functions

params = config()

# connect to the PostgreSQL server
conn = psycopg2.connect(**params)
cur = conn.cursor()

def inserir_pessoa():
    print("\nInserindo pessoa")
    cpi = (input('Digite o cpi da pessoa: '))
    nome = input('Digite o nome da pessoa: ')
    tipo = input('Digite o tipo da pessoa: ')
    senha = input('Digite a senha da pessoa: ')
    planeta_origem = input('Digite o planeta de origem da pessoa: ')
    data_nascimento = input('Digite a data de nascimento da pessoa: ')
    especie = input('Digite a especie da pessoa: ')

    functions.inserir_pessoa(cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie)

def inserir_passageiro():
    print("\nInserindo passageiro")
    cpi = input('Digite o cpi do passageiro: ')

    functions.inserir_passageiro(cpi)

def inserir_funcionario():
    print("\nInserindo funcionario")
    cpi = (input('Digite o cpi do funcionario: '))
    num_funcional = input('Digite o numero funcional do funcionario: ')
    cargo = input('Digite o cargo do funcionario: ')
    salario = input('Digite o salario do funcionario: ')

    functions.inserir_funcionario(cpi,num_funcional, cargo, salario)

def inserir_hospedagem():
    print("\nInserindo hospedagem")
    quarto_reserva = (input('Digite o numero do quarto da reserva: '))
    passageiro = input('Digite o cpi do passageiro: ')

    functions.inserir_hospedagem(quarto_reserva, passageiro)

def inserir_produtos():
    cod_barras = (input('Digite o codigo de barras do produto: '))
    nome = (input('Digite o nome do produto: '))
    valor = input('Digite o valor do produto: ')

    functions.inserir_produtos(cod_barras, nome, valor)

def inserir_servicos():
    print("\nInserindo servico")
    cod_barras = (input('Digite o codigo de barras do servico: '))
    nome = (input('Digite o nome do servico: '))
    valor = input('Digite o valor do servico: ')

    functions.inserir_servicos(cod_barras, nome, valor)

print("1 - Inserir pessoa")
print("2 - Inserir passageiro")
print("3 - Inserir funcionario")
print("4 - Inserir hospedagem")
print("5 - Inserir produtos")
print("6 - Inserir servicos")

print("0 - Sair")

operacao = int(input("\nDigite o código do comando: "))
while(operacao != 0):
    if operacao == 1:
        inserir_pessoa()
    elif operacao == 2:
        inserir_passageiro()
    elif operacao == 3: 
        inserir_funcionario()
    elif operacao == 4:
        inserir_hospedagem()
    elif operacao == 5:
        inserir_produtos()
    elif operacao == 6:
        inserir_servicos()

    operacao = int(input("\nDigite o código do comando: "))
    

# Fechar cursor e conexão
cur.close()
conn.close()