"""
vhdl_uppercase.py
Converte palavras-chave VHDL de minúsculas para maiúsculas em um arquivo .vhd ou .vhdl.
Uso: python vhdl_uppercase.py <arquivo_entrada> [arquivo_saida]
"""

import re
import sys
import os

# Palavras-chave da linguagem VHDL (IEEE Std 1076)
VHDL_KEYWORDS = {
    # Estrutura do design
    "entity", "architecture", "of", "is", "begin", "end",
    "configuration", "package", "body", "use", "library",
    # Declarações de portas e sinais
    "port", "map", "generic", "signal", "variable", "constant",
    "file", "alias", "attribute", "shared",
    # Tipos
    "type", "subtype", "range", "to", "downto", "array", "record",
    "access", "buffer", "bus", "register",
    # Modos de porta
    "in", "out", "inout", "linkage",
    # Instanciação e componentes
    "component", "for", "others",
    # Lógica condicional e sequencial
    "if", "then", "else", "elsif", "end", "case", "when",
    "loop", "while", "until", "exit", "next", "return",
    # Processos e concorrência
    "process", "wait", "on", "after", "with", "select",
    "generate", "block", "guarded",
    # Operadores lógicos
    "and", "or", "not", "nand", "nor", "xor", "xnor",
    # Operadores relacionais e aritméticos
    "mod", "rem", "abs", "sll", "srl", "sla", "sra", "rol", "ror",
    # Funções e procedimentos
    "function", "procedure", "impure", "pure",
    "parameter", "subprogram",
    # Qualificadores e conversão
    "in", "out", "of", "new", "null", "open", "all",
    # Temporização e simulação
    "transport", "reject", "inertial", "unaffected",
    # Literais e constantes especiais
    "true", "false",
    # Atributos e restrições
    "severity", "note", "warning", "error", "failure",
    "assert", "report",
    # Outros
    "label", "literal", "units", "group", "postponed",
    "disconnect", "if",
}

def uppercase_vhdl_keywords(source: str) -> str:
    """
    Substitui palavras-chave VHDL em minúsculas (ou misto) por MAIÚSCULAS,
    preservando strings entre aspas, caracteres literais e comentários (-- até fim da linha).
    """

    result = []
    i = 0
    n = len(source)

    # Regex para identificar uma palavra (identificador)
    word_re = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')

    while i < n:
        # Comentário de linha: -- até o fim da linha
        if source[i:i+2] == '--':
            end = source.find('\n', i)
            if end == -1:
                result.append(source[i:])
                break
            result.append(source[i:end+1])
            i = end + 1
            continue

        # String entre aspas duplas (string literal em VHDL)
        if source[i] == '"':
            j = i + 1
            while j < n and source[j] != '"':
                if source[j] == '\\':   # escape
                    j += 1
                j += 1
            result.append(source[i:j+1])
            i = j + 1
            continue

        # Caractere literal entre aspas simples: 'X'
        # Cuidado: em VHDL, 'A' é literal de caractere, mas '0' também é válido.
        # Evitamos substituir o conteúdo entre aspas simples.
        if source[i] == "'":
            # Verifica se é um literal de caractere: ' <char> '
            if i + 2 < n and source[i+2] == "'":
                result.append(source[i:i+3])
                i += 3
                continue
            else:
                result.append(source[i])
                i += 1
                continue

        # Palavra / identificador
        m = word_re.match(source, i)
        if m:
            word = m.group()
            if word.lower() in VHDL_KEYWORDS:
                result.append(word.upper())
            else:
                result.append(word)
            i = m.end()
            continue

        # Qualquer outro caractere
        result.append(source[i])
        i += 1

    return ''.join(result)


def process_file(input_path: str, output_path: str = None) -> None:
    if not os.path.isfile(input_path):
        print(f"Erro: arquivo '{input_path}' não encontrado.")
        sys.exit(1)

    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        original = f.read()

    converted = uppercase_vhdl_keywords(original)

    if output_path is None:
        output_path = input_path

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(converted)

    # Relatório
    orig_lines = original.splitlines()
    conv_lines = converted.splitlines()
    changes = sum(1 for a, b in zip(orig_lines, conv_lines) if a != b)

    print(f"Arquivo de entrada : {input_path}")
    print(f"Arquivo de saída   : {output_path}")
    print(f"Linhas modificadas : {changes}")
    print("Concluído com sucesso!")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: python vhdl_uppercase.py <arquivo_entrada> [arquivo_saida]")
        print("Exemplo: python vhdl_uppercase.py projeto.vhd projeto_upper.vhd")
        sys.exit(1)

    input_file  = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) >= 3 else None

    process_file(input_file, output_file)
