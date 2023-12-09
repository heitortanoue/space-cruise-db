def extract_queries(file_path):
    """Extrai consultas e seus títulos de um arquivo SQL."""
    with open(file_path, "r", encoding="utf-8") as file:  # Adicione aqui a codificação correta, se não for UTF-8
        content = file.read()
    # Separa as consultas com base nos comentários
    parts = content.split("-- ")
    queries = {}

    for part in parts[1:]:  # Ignora o primeiro item, que é vazio ou não é uma consulta
        lines = part.split('\n')
        title = lines[0].strip()
        query = '\n'.join(lines[1:]).strip()
        if query:
            queries[title] = query

    return queries

def get_query_fields(query):
    """Retorna os campos personalizaveis de uma consulta ({{campo}})."""
    fields = []
    start = 0
    while True:
        start = query.find("{{", start)
        if start == -1:
            break
        end = query.find("}}", start)
        if end == -1:
            break
        fields.append(query[start + 2:end])
        start = end + 2
    return fields

def set_query_fields(query: str, dict: dict):
    """Substitui os campos personalizaveis de uma consulta pelos valores fornecidos."""
    for key in dict:
        query = query.replace("{{" + key + "}}", f'%({key})s')
    return query