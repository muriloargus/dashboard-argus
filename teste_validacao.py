#!/usr/bin/env python3
"""
✅ TESTE RÁPIDO - Valida se tudo está configurado corretamente
Antes de rodar pipeline.py, execute este teste!
"""

import os
import sys
from pathlib import Path

def print_header():
    print("""
╔════════════════════════════════════════════════════════════╗
║  ✅ VALIDAÇÃO RÁPIDA - Dashboard Argus                   ║
║  Verificando se tudo está pronto                          ║
╚════════════════════════════════════════════════════════════╝
""")

def check_arquivo(nome, descricao):
    """Verifica se arquivo existe"""
    if Path(nome).exists():
        print(f"✅ {nome}")
        print(f"   └─ {descricao}")
        return True
    else:
        print(f"❌ {nome}")
        print(f"   └─ {descricao} - NÃO ENCONTRADO!")
        return False

def check_pasta(nome, descricao):
    """Verifica se pasta existe"""
    if Path(nome).is_dir():
        print(f"✅ {nome}/")
        print(f"   └─ {descricao}")
        return True
    else:
        print(f"❌ {nome}/")
        print(f"   └─ {descricao} - NÃO ENCONTRADA!")
        return False

def check_env():
    """Verifica arquivo .env"""
    print("\n📋 CHECANDO ARQUIVO .env")
    print("─" * 55)
    
    if not Path('.env').exists():
        print("❌ Arquivo .env não encontrado!")
        print("   Execute: COMECE-AQUI.bat")
        return False
    
    try:
        with open('.env', 'r', encoding='utf-8') as f:
            conteudo = f.read()
        
        # Verifica se tem a chave service_role preenchida
        if 'COPIE_SUA_CHAVE_SERVICE_ROLE_AQUI' in conteudo:
            print("⚠️  AVISO: .env não foi editado com a chave!")
            print("   Você precisa:")
            print("   1. Abrir .env")
            print("   2. Procurar por: COPIE_SUA_CHAVE_SERVICE_ROLE_AQUI")
            print("   3. Colar a chave service_role do Supabase no lugar")
            return False
        
        # Verifica se tem chave (começa com eyJh)
        if 'eyJh' in conteudo:
            print("✅ .env configurado corretamente!")
            print("   └─ Chave service_role foi adicionada")
            return True
        else:
            print("❌ .env sem chave service_role!")
            print("   A chave deve começar com: eyJh...")
            return False
            
    except Exception as e:
        print(f"❌ Erro ao ler .env: {str(e)}")
        return False

def check_csv_files():
    """Verifica arquivos CSV em input/"""
    print("\n📊 CHECANDO ARQUIVOS CSV")
    print("─" * 55)
    
    input_path = Path('input')
    if not input_path.exists():
        print("⚠️  Pasta input/ não encontrada!")
        print("   Crie a pasta ou execute COMECE-AQUI.bat novamente")
        return False
    
    csv_files = list(input_path.glob('*.csv'))
    
    if not csv_files:
        print("⚠️  Nenhum arquivo CSV em input/")
        print("   Você precisa copiar seus CSVs para: input/")
        print("   Arquivos esperados:")
        print("     - ativos*.csv")
        print("     - falhas*.csv")
        print("     - usuarios*.csv")
        return False
    
    print(f"✅ {len(csv_files)} arquivo(s) CSV encontrado(s):")
    for csv_file in csv_files:
        size_kb = csv_file.stat().st_size / 1024
        print(f"   └─ {csv_file.name} ({size_kb:.1f} KB)")
    
    return True

def check_python():
    """Verifica se Python está instalado"""
    print("\n🐍 CHECANDO PYTHON")
    print("─" * 55)
    
    import subprocess
    try:
        result = subprocess.run([sys.executable, '--version'], capture_output=True, text=True)
        print(f"✅ Python: {result.stdout.strip()}")
        return True
    except:
        print("❌ Python não encontrado!")
        return False

def check_dependencies():
    """Verifica se bibliotecas estão instaladas"""
    print("\n📦 CHECANDO DEPENDÊNCIAS")
    print("─" * 55)
    
    required_modules = ['dotenv', 'pandas', 'requests']
    all_ok = True
    
    for module in required_modules:
        try:
            __import__(module)
            print(f"✅ {module}")
        except ImportError:
            print(f"❌ {module} - Não instalado!")
            all_ok = False
    
    if not all_ok:
        print("\n⚠️  Execute: pip install -r requirements.txt")
    
    return all_ok

def check_supabase_credentials():
    """Verifica credenciais do Supabase"""
    print("\n🔐 CHECANDO CREDENCIAIS SUPABASE")
    print("─" * 55)
    
    expected_url = 'https://fnlgstkkkxzrszmxqwwf.supabase.co'
    expected_anon = 'sb_publishable_n_XIoBQwq5efny__r71log_fMjQNvh1'
    
    try:
        from dotenv import load_dotenv
        load_dotenv()
        
        url = os.getenv('SUPABASE_URL', '')
        anon_key = os.getenv('SUPABASE_ANON_KEY', '')
        service_key = os.getenv('SUPABASE_SERVICE_ROLE_KEY', '')
        
        if url == expected_url:
            print(f"✅ SUPABASE_URL: {url}")
        else:
            print(f"❌ SUPABASE_URL incorreta: {url}")
            return False
        
        if anon_key == expected_anon:
            print(f"✅ SUPABASE_ANON_KEY: {anon_key[:20]}...")
        else:
            print(f"❌ SUPABASE_ANON_KEY incorreta")
            return False
        
        if service_key and service_key.startswith('eyJh'):
            print(f"✅ SUPABASE_SERVICE_ROLE_KEY: {service_key[:20]}...")
            return True
        else:
            print(f"❌ SUPABASE_SERVICE_ROLE_KEY não configurada!")
            return False
            
    except Exception as e:
        print(f"❌ Erro: {str(e)}")
        return False

def main():
    print_header()
    
    resultados = {
        'Arquivos básicos': False,
        'Arquivo .env': False,
        'Arquivos CSV': False,
        'Python': False,
        'Dependências': False,
        'Credenciais Supabase': False
    }
    
    # 1. Verifica arquivos básicos
    print("📁 CHECANDO ARQUIVOS BÁSICOS")
    print("─" * 55)
    check1 = check_arquivo('pipeline.py', 'Script de sincronização')
    check2 = check_arquivo('supabase-client.js', 'Cliente JavaScript')
    check3 = check_arquivo('requirements.txt', 'Dependências Python')
    resultados['Arquivos básicos'] = check1 and check2 and check3
    
    # 2. Verifica .env
    resultados['Arquivo .env'] = check_env()
    
    # 3. Verifica CSVs
    resultados['Arquivos CSV'] = check_csv_files()
    
    # 4. Verifica Python
    resultados['Python'] = check_python()
    
    # 5. Verifica dependências
    resultados['Dependências'] = check_dependencies()
    
    # 6. Verifica credenciais
    resultados['Credenciais Supabase'] = check_supabase_credentials()
    
    # Resumo final
    print("\n" + "=" * 55)
    print("📊 RESUMO DA VALIDAÇÃO")
    print("=" * 55)
    
    for check, result in resultados.items():
        status = "✅ OK" if result else "❌ ERRO"
        print(f"{check}: {status}")
    
    total_ok = sum(1 for v in resultados.values() if v)
    total = len(resultados)
    
    print("=" * 55)
    print(f"\nPontuação: {total_ok}/{total}")
    
    if total_ok == total:
        print("\n✨ TUDO OK! Você pode executar:")
        print("   python pipeline.py")
        print("\n🚀 Vá em frente!")
        return 0
    else:
        print("\n⚠️  Ainda há problemas. Revise:")
        print("   1. Leia GUIA-VISUAL-SUPER-SIMPLES.txt")
        print("   2. Execute COMECE-AQUI.bat novamente se necessário")
        print("   3. Corrija os erros acima")
        return 1

if __name__ == '__main__':
    sys.exit(main())
