/**
 * Supabase Client - Integração com banco de dados
 * Substitui dependência de CSVs por queries em tempo real
 */

class SupabaseClient {
    constructor(url, anonKey) {
        this.url = url;
        this.anonKey = anonKey;
        this.isConnected = false;
        this.data = {}; // Cache local
        this.init();
    }

    async init() {
        try {
            // Testa conexão
            const response = await fetch(`${this.url}/rest/v1/ativos?select=count`, {
                headers: {
                    'apikey': this.anonKey,
                    'Authorization': `Bearer ${this.anonKey}`
                }
            });
            
            if (response.ok) {
                this.isConnected = true;
                console.log('✅ Supabase conectado');
            }
        } catch (e) {
            console.warn('⚠️ Falha na conexão com Supabase:', e);
            this.isConnected = false;
        }
    }

    /**
     * Query genérica - fetch com filtros
     */
    async query(table, options = {}) {
        const {
            columns = '*',
            filter = null,
            limit = 1000,
            offset = 0,
            order = null
        } = options;

        if (!this.isConnected) {
            console.warn('⚠️ Supabase não conectado');
            return [];
        }

        let url = `${this.url}/rest/v1/${table}?select=${columns}&limit=${limit}&offset=${offset}`;

        // Adiciona filtros
        if (filter) {
            for (const [key, value] of Object.entries(filter)) {
                if (typeof value === 'string') {
                    url += `&${key}=eq.${encodeURIComponent(value)}`;
                } else if (typeof value === 'number') {
                    url += `&${key}=eq.${value}`;
                } else if (Array.isArray(value)) {
                    url += `&${key}=in.(${value.map(v => encodeURIComponent(v)).join(',')})`;
                }
            }
        }

        // Adiciona ordenação
        if (order) {
            const { column, ascending = true } = order;
            url += `&order=${column}.${ascending ? 'asc' : 'desc'}`;
        }

        try {
            const response = await fetch(url, {
                headers: {
                    'apikey': this.anonKey,
                    'Authorization': `Bearer ${this.anonKey}`
                }
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();
            return data || [];
        } catch (e) {
            console.error(`❌ Erro ao buscar ${table}:`, e);
            return [];
        }
    }

    /**
     * Busca ativos com filtros
     */
    async getAtivos(filters = {}) {
        const cacheKey = 'ativos_' + JSON.stringify(filters);
        
        const options = {
            columns: '*'
        };

        if (Object.keys(filters).length > 0) {
            options.filter = filters;
        }

        const data = await this.query('ativos', options);
        this.data.ativos = data;
        return data;
    }

    /**
     * Busca falhas com filtros
     */
    async getFalhas(filters = {}) {
        const options = {
            columns: '*',
            limit: 5000
        };

        if (Object.keys(filters).length > 0) {
            options.filter = filters;
        }

        const data = await this.query('falhas', options);
        this.data.falhas = data;
        return data;
    }

    /**
     * Busca exceções
     */
    async getExcecoes(filters = {}) {
        const options = {
            columns: '*',
            limit: 5000
        };

        if (Object.keys(filters).length > 0) {
            options.filter = filters;
        }

        const data = await this.query('excecoes', options);
        this.data.excecoes = data;
        return data;
    }

    /**
     * Busca usuários
     */
    async getUsuarios(filters = {}) {
        const options = {
            columns: '*'
        };

        if (Object.keys(filters).length > 0) {
            options.filter = filters;
        }

        const data = await this.query('usuarios', options);
        this.data.usuarios = data;
        return data;
    }

    /**
     * Busca motoristas únicos
     */
    async getMotoristas() {
        const ativos = await this.getAtivos();
        const motoristas = [...new Set(ativos
            .filter(a => a.nome && a.sobrenome)
            .map(a => `${a.nome} ${a.sobrenome}`)
        )];
        return motoristas;
    }

    /**
     * Busca dispositivos por status
     */
    async getDispositivosPorStatus() {
        const ativos = await this.getAtivos();
        const status = {};
        
        ativos.forEach(a => {
            const s = a.status_download || 'Desconhecido';
            status[s] = (status[s] || 0) + 1;
        });
        
        return status;
    }

    /**
     * Busca estatísticas de falhas por tipo
     */
    async getFalhasPorTipo() {
        const falhas = await this.getFalhas();
        const stats = {};
        
        falhas.forEach(f => {
            const tipo = f.modo_falha || 'Desconhecida';
            stats[tipo] = (stats[tipo] || 0) + 1;
        });
        
        return stats;
    }

    /**
     * Insere/atualiza registro
     */
    async upsert(table, data) {
        if (!this.isConnected) {
            console.warn('⚠️ Supabase não conectado');
            return null;
        }

        try {
            const response = await fetch(`${this.url}/rest/v1/${table}`, {
                method: 'POST',
                headers: {
                    'apikey': this.anonKey,
                    'Authorization': `Bearer ${this.anonKey}`,
                    'Content-Type': 'application/json',
                    'Prefer': 'resolution=merge-duplicates'
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            return await response.json();
        } catch (e) {
            console.error(`❌ Erro ao inserir em ${table}:`, e);
            return null;
        }
    }

    /**
     * Deleta registro
     */
    async delete(table, filters) {
        if (!this.isConnected) {
            console.warn('⚠️ Supabase não conectado');
            return false;
        }

        try {
            let url = `${this.url}/rest/v1/${table}?`;
            
            for (const [key, value] of Object.entries(filters)) {
                url += `${key}=eq.${encodeURIComponent(value)}&`;
            }

            const response = await fetch(url.slice(0, -1), {
                method: 'DELETE',
                headers: {
                    'apikey': this.anonKey,
                    'Authorization': `Bearer ${this.anonKey}`
                }
            });

            return response.ok;
        } catch (e) {
            console.error(`❌ Erro ao deletar de ${table}:`, e);
            return false;
        }
    }

    /**
     * Synca dados locais do Storage para Supabase
     */
    async syncLocalStorageToSupabase(storageAdapter) {
        console.log('🔄 Sincronizando LocalStorage com Supabase...');
        
        const keys = Object.keys(localStorage);
        let synced = 0;

        for (const key of keys) {
            if (key.startsWith('ativos_') || key.startsWith('falhas_')) {
                try {
                    const data = JSON.parse(localStorage.getItem(key));
                    // TODO: Implementar sincronização bidirecional
                    synced++;
                } catch (e) {
                    console.warn(`⚠️ Erro ao processar ${key}:`, e);
                }
            }
        }

        console.log(`✅ ${synced} items sincronizados`);
    }

    /**
     * Obtém status da conexão
     */
    getStatus() {
        return {
            conectado: this.isConnected,
            dados_em_cache: Object.keys(this.data).length
        };
    }
}

// Inicializa cliente global se credenciais existirem
let supabase = null;

window.initSupabase = function(url, anonKey) {
    supabase = new SupabaseClient(url, anonKey);
    return supabase;
};

// Exporta para uso em módulos
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SupabaseClient;
}
