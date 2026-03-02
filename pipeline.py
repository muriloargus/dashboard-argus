import os
import re
import unicodedata
import pandas as pd
from supabase import create_client

# ==============================
# CONFIG SUPABASE
# ==============================

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# ==============================
# NORMALIZAÇÃO
# ==============================

def normalizar_coluna(col):
    col = str(col).strip()

    # remover acentos
    col = unicodedata.normalize("NFKD", col)
    col = col.encode("ASCII", "ignore").decode("ASCII")

    col = col.lower()

    # remover caracteres problemáticos
    col = col.replace("/", "_")
    col = col.replace(":", "")
    col = col.replace("-", "_")

    # substituir qualquer coisa que não seja letra/número por _
    col = re.sub(r"[^a-z0-9]+", "_", col)

    # remover múltiplos _
    col = re.sub(r"_+", "_", col)

    # remover _ início/fim
    col = col.strip("_")

    return col


def normalizar_dataframe(df):
    df.columns = [normalizar_coluna(col) for col in df.columns]
    return df


# ==============================
# LEITURA CSV ROBUSTA
# ==============================

def read_csv_robusto(path):
    try:
        return pd.read_csv(path, sep=";", encoding="utf-8")
    except:
        return pd.read_csv(path, sep=",", encoding="latin1")


# ==============================
# LOAD CSV -> SUPABASE
# ==============================

def load_csv_to_table(file_path, table_name):
    print(f"Processando {file_path} -> {table_name}")

    df = read_csv_robusto(file_path)

    if df.empty:
        print("Arquivo vazio. Pulando.")
        return

    print("Colunas detectadas:", df.columns.tolist())

    df = normalizar_dataframe(df)

    print("Colunas normalizadas:", df.columns.tolist())

    # converter tudo para string (evita erro de tipo)
    df = df.astype(str)

    data = df.to_dict(orient="records")

    print(f"Limpando tabela {table_name}...")
    supabase.table(table_name).delete().neq("id", 0).execute()

    batch_size = 500

    for i in range(0, len(data), batch_size):
        batch = data[i:i + batch_size]
        supabase.table(table_name).insert(batch).execute()

    print(f"{table_name} atualizado com sucesso\n")


# ==============================
# PIPELINE PRINCIPAL
# ==============================

def run():
    input_folder = "input"

    arquivos = {
        "risco de colisão.csv": "staging_risco_colisao",
        "ativos 23-02.csv": "staging_ativos",
        "usuarios ambev 26-02.csv": "staging_usuarios_ambev",
        "status frota 26-02.csv": "staging_status_frota",
    }

    for filename, table in arquivos.items():
        path = os.path.join(input_folder, filename)

        if not os.path.exists(path):
            print(f"Arquivo ignorado: {filename}")
            continue

        load_csv_to_table(path, table)


if __name__ == "__main__":
    run()
