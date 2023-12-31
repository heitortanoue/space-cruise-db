import psycopg2
from config import config
from termcolor import colored
import functions

params = config()

# connect to the PostgreSQL server
conn = psycopg2.connect(**params)
cur = conn.cursor()

def inserir_pessoa():
    print("\nInserindo pessoa")
    # cpi = (input('Digite o cpi da pessoa: '))
    cpi = (input(f'{"Digite o CPI da pessoa"} {colored("(ex: 123.123.123-AA)", "grey")}: '))
    nome = input('Digite o nome da pessoa: ')
    tipo = (input(f'{"Digite o tipo da pessoa"} {colored("(PASSAGEIRO OU FUNCIONARIO)", "grey")}: '))
    senha = input('Digite a senha da pessoa: ')
    planeta_origem = input('Digite o planeta de origem da pessoa: ')
    data_nascimento = (input(f'{"Digite a data de nascimento pessoa"} {colored("(ex: YYYY-MM-DD)", "grey")}: '))
    especie = input('Digite a especie da pessoa: ')

    functions.inserir_pessoa(cpi, nome, tipo, senha, planeta_origem, data_nascimento, especie)

def inserir_passageiro():
    print("\nInserindo passageiro")
    cpi = (input(f'{"Digite o CPI de um passageiro existente"} {colored("(ex: 123.123.123-AA)", "grey")}: '))

    functions.inserir_passageiro(cpi)

def inserir_funcionario():
    print("\nInserindo funcionario")
    cpi = (input(f'{"Digite o CPI de um funcionario existente"} {colored("(ex: 123.123.123-AA)", "grey")}: '))
    num_funcional = (input(f'{"Digite o numero funcional do funcionario"} {colored("(ex: 123456789)", "grey")}: '))
    cargo = tipo = (input(f'{"Digite o cargo do funcionario"} {colored("(CAPITAO OU COMISSARIO OU COMUM)", "grey")}: '))
    salario = input('Digite o salario do funcionario: ')

    functions.inserir_funcionario(cpi,num_funcional, cargo, salario)

def inserir_hospedagem():
    print("\nInserindo hospedagem")
    quarto_reserva = (input('Digite o numero do quarto da reserva existente: '))
    passageiro = cpi = (input(f'{"Digite o CPI de um passageiro existente"} {colored("(ex: 123.123.123-AA)", "grey")}: '))

    functions.inserir_hospedagem(quarto_reserva, passageiro)

def inserir_produtos():
    cod_barras = (input(f'{"Digite o codigo de barras de um produto novo"} {colored("(ex: 1 123456 123456)", "grey")}: '))
    nome = (input('Digite o nome do produto: '))
    valor = input('Digite o valor do produto: ')

    functions.inserir_produtos(cod_barras, nome, valor)

def inserir_servicos():
    print("\nInserindo servico")
    cod_barras = (input(f'{"Digite o codigo de barras de um servico novo"} {colored("(ex: 1 123456 123456)", "grey")}: '))
    nome = (input('Digite o nome do servico: '))
    valor = input('Digite o valor do servico: ')

    functions.inserir_servicos(cod_barras, nome, valor)

def exibir_opcoes():
    print("\nOpções:")
    print("1 - Inserir pessoa")
    print("2 - Inserir passageiro")
    print("3 - Inserir funcionario")
    print("4 - Inserir hospedagem")
    print("5 - Inserir um novo produto")
    print("6 - Inserir um novo servico")
    print("0 - Sair")

operacao = -1
while operacao != 0:
    exibir_opcoes()
    operacao = int(input("\nDigite o código do comando: "))
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
    

# Fechar cursor e conexão
cur.close()
conn.close()