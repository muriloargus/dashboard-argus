import os
import pandas as pd
from supabase import create_client

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

INPUT_FOLDER = "input"

def clear_table(table_name):
    supabase.table(table_name).delete().neq("id", 0).execute()

def load_csv_to_table(file_path, table_name):
    print(f"Processando {file_path} -> {table_name}")

    df = pd.read_csv(file_path)

    # Normalizações padrão
    if "Grupo de dispositivo" in df.columns:
        df = df[df["Grupo de dispositivo"].str.contains(r"^TRS_", na=False)]
        df["Grupo de dispositivo"] = df["Grupo de dispositivo"].str.upper()

    if "Placa" in df.columns:
        df["Placa"] = df["Placa"].str.upper().str.replace("-", "", regex=False)

    # Limpa staging antes de inserir
    clear_table(table_name)

    # Inserção em lotes
    batch_size = 500
    for i in range(0, len(df), batch_size):
        batch = df.iloc[i:i+batch_size]
        supabase.table(table_name).insert(
            batch.to_dict(orient="records")
        ).execute()

    print(f"{table_name} atualizado com sucesso")

def run():
    for file in os.listdir(INPUT_FOLDER):
        path = os.path.join(INPUT_FOLDER, file)

        if "ativos" in file.lower():
            load_csv_to_table(path, "staging_ativos")

        elif "usuarios_driver" in file.lower():
            load_csv_to_table(path, "staging_usuarios_driver")

if __name__ == "__main__":
    run()
