import os
import pandas as pd
import unicodedata
from supabase import create_client

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

INPUT_FOLDER = "input"


# =============================
# UTILIDADES
# =============================

def limpar_nome_coluna(nome):
    nome = unicodedata.normalize("NFKD", nome)
    nome = nome.encode("ascii", "ignore").decode("utf-8")
    nome = nome.lower()
    nome = nome.replace(" ", "_")
    nome = nome.replace("(", "")
    nome = nome.replace(")", "")
    nome = nome.replace(",", "")
    nome = nome.replace("-", "_")
    nome = nome.replace("__", "_")
    return nome


def read_csv_robusto(file_path):
    print(f"Lendo arquivo {file_path}...")

    df = pd.read_csv(
        file_path,
        sep=";",
        encoding="utf-8-sig",
        engine="python",
        on_bad_lines="skip"
    )

    print("Colunas detectadas:", df.columns.tolist())

    return df


def normalizar_dataframe(df):
    # Remove infinitos
    df = df.replace([float("inf"), float("-inf")], None)

    # Remove NaN
    df = df.where(pd.notnull(df), None)

    # Normaliza nomes de colunas
    df.columns = [limpar_nome_coluna(col) for col in df.columns]

    print("Colunas normalizadas:", df.columns.tolist())

    # Normalizações específicas
    if "grupo_de_dispositivo" in df.columns:
        df = df[df["grupo_de_dispositivo"].str.contains(r"^TRS_", na=False)]
        df["grupo_de_dispositivo"] = df["grupo_de_dispositivo"].str.upper()

    if "placa" in df.columns:
        df["placa"] = (
            df["placa"]
            .astype(str)
            .str.upper()
            .str.replace("-", "", regex=False)
            .str.strip()
        )

    return df


def clear_table(table_name):
    print(f"Limpando tabela {table_name}...")

    response = supabase.rpc(
        "truncate_table",
        {"table_name": table_name}
    ).execute()

    if hasattr(response, "error") and response.error:
        print("Erro ao truncar:", response.error)


# =============================
# LOAD
# =============================

def load_csv_to_table(file_path, table_name):
    print(f"Processando {file_path} -> {table_name}")

    df = read_csv_robusto(file_path)
    df = normalizar_dataframe(df)

    if df.empty:
        print("Arquivo vazio após filtros. Pulando.")
        return

    clear_table(table_name)

    # Converte tudo para objeto (evita erro JSON)
    df = df.astype(object)
    df = df.where(pd.notnull(df), None)

    records = df.to_dict(orient="records")

    batch_size = 500

    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]

        response = supabase.table(table_name).insert(batch).execute()

        if hasattr(response, "error") and response.error:
            print("Erro ao inserir lote:", response.error)

    print(f"{table_name} atualizado com sucesso")


# =============================
# EXECUÇÃO
# =============================

def run():
    if not os.path.exists(INPUT_FOLDER):
        print("Pasta input não encontrada.")
        return

    arquivos = os.listdir(INPUT_FOLDER)

    if not arquivos:
        print("Nenhum arquivo encontrado.")
        return

    for file in arquivos:
        path = os.path.join(INPUT_FOLDER, file)
        nome = file.lower()

        if not file.endswith(".csv"):
            print(f"Arquivo ignorado: {file}")
            continue

        if "ativos" in nome:
            load_csv_to_table(path, "staging_ativos")

        elif "usuarios_driver" in nome:
            load_csv_to_table(path, "staging_usuarios_driver")

        elif "exce" in nome:
            load_csv_to_table(path, "staging_excecoes")

        elif "falha" in nome:
            load_csv_to_table(path, "staging_falhas")

        elif "risco" in nome:
            load_csv_to_table(path, "staging_risco_colisao")

        elif "status" in nome:
            load_csv_to_table(path, "staging_status_frota")

        elif "ambev" in nome:
            load_csv_to_table(path, "staging_usuarios_ambev")

        elif "nao_identificado" in nome:
            load_csv_to_table(path, "staging_motorista_nao_identificado")

        elif "sem_vinculo" in nome:
            load_csv_to_table(path, "staging_dispositivos_sem_vinculo")

        else:
            print(f"Arquivo ignorado: {file}")


if __name__ == "__main__":
    run()
