# Sistema de Gestão de Viagens Intergalácticas

## 1 - Descrição do Problema e Requisitos de Dados

### 1.1 - Visão Geral dos Objetivos

Este sistema tem como objetivo principal simplificar a reserva de quartos em naves espaciais para clientes, permitindo uma seleção clara e fácil dos itinerários e dos serviços extras disponíveis. Busca também facilitar o gerenciamento interno de cada nave, oferecendo supervisão detalhada sobre a tripulação e os serviços prestados. Em um contexto futurístico de turismo espacial, o sistema permite um mapeamento eficiente de origens e destinos dos passageiros, evitando possíveis desaparecimentos e centralizando as despesas em um modelo de reservas integrado.

### 1.2 - Entidades e Relacionamentos

A aplicação é um sistema complexo de gerenciamento de viagens espaciais, com viagens programadas e naves identificadas por modelos específicos. Cada viagem é liderada por um capitão qualificado, com uma equipe que varia de acordo com as necessidades de serviço. As naves possuem características únicas e quartos vinculados a cada modelo, que são reservados pelos passageiros. As reservas são identificadas por quarto e responsável, podendo incluir passageiros com restrições alimentares. O custo total é calculado pelo valor do quarto e pelos serviços consumidos.

Os itinerários definem rotas com paradas específicas, produtos consumíveis e serviços dependentes da disponibilidade dos funcionários. As informações pessoais dos indivíduos incluem dados criptografados, origem planetária e um "CPI" exclusivo para identificação.

## 2 - Estrutura do Projeto

A estrutura do projeto é delineada pelas seguintes diretórios e arquivos essenciais:

- `config.py`: Configurações iniciais do sistema.
- `create.py`: Scripts para criação de entidades no banco de dados.
- `database.ini`: Arquivo de configuração para conexão com o banco de dados.
- `insert.py`: Scripts para inserção de dados no sistema.
- `query.py`: Scripts para consultas e operações de dados.

## 3 - Instruções de Uso

(descreva aqui como instalar, configurar e executar o sistema)

## 4 - Contribuições

(descreva como outros desenvolvedores podem contribuir para o projeto)