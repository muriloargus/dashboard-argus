/**
 * Storage Adapter - Proxy transparente localStorage ↔ IndexedDB
 * Mantém compatibilidade com código síncrono existente
 * Usa IndexedDB para capacidade de 1GB
 */

class StorageAdapter {
    constructor() {
        this.useIDB = false;
        this.syncInProgress = new Map();
        this.initializeIDB();
    }

    async initializeIDB() {
        try {
            await idb.initPromise;
            this.useIDB = idb.isReady;
            console.log('📦 StorageAdapter inicializado com IndexedDB');
        } catch (e) {
            console.warn('⚠️ Usando apenas localStorage');
            this.useIDB = false;
        }
    }

    /**
     * Setters síncronos - compatível com código existente
     */
    setItemSync(key, value) {
        // Salva em localStorage imediatamente (para compatibilidade)
        try {
            // Para dados muito grandes, usa flag para indicar que estão em IndexedDB
            if (value.length > 4000000) { // > 4MB
                localStorage.setItem(key + '__large', 'true');
                // Não salva em localStorage se for > 4MB
                console.log(`⚠️ Dados ${key} muito grandes (${Math.round(value.length/1024)}KB), salvando apenas em IndexedDB`);
            } else if (value.length > 2000000) { // 2MB - limite seguro localStorage
                localStorage.setItem(key + '__compressed', 'true');
                localStorage.setItem(key, this.compressData(value));
                console.log(`📦 Dados ${key} comprimidos em localStorage`);
            } else {
                localStorage.setItem(key, value);
            }
        } catch (e) {
            console.warn(`⚠️ localStorage quota excedido para ${key}, marcando como IDB-only`);
            localStorage.setItem(key + '__idb_only', 'true');
        }

        // Salva em IndexedDB de forma assíncrona (background)
        this.setItemAsync(key, value).catch(err => {
            console.warn(`⚠️ Erro ao salvar ${key} em IndexedDB:`, err);
        });
    }

    /**
     * Getters síncronos - compatível com código existente
     */
    getItemSync(key) {
        // Tenta localStorage primeiro
        let value = localStorage.getItem(key);
        
        if (value !== null) {
            // Descomprime se necessário
            if (localStorage.getItem(key + '__compressed') === 'true') {
                try {
                    return this.decompressData(value);
                } catch (e) {
                    console.warn(`⚠️ Erro ao descomprimir ${key}:`, e);
                    return value;
                }
            }
            return value;
        }

        // Se está marcado como IDB-only ou large, não temos em localStorage
        if (localStorage.getItem(key + '__idb_only') === 'true' || 
            localStorage.getItem(key + '__large') === 'true') {
            console.warn(`ℹ️ ${key} está apenas em IndexedDB, use getItemAsync()`);
            return null;
        }

        return null;
    }

    /**
     * Versão assíncrona - para leitura de dados grandes
     */
    async getItemAsync(key) {
        // Primeiro tenta localStorage
        const localValue = this.getItemSync(key);
        if (localValue !== null) {
            return localValue;
        }

        // Se não está em localStorage, tenta IndexedDB
        if (this.useIDB) {
            try {
                const idbValue = await idb.getItem(key);
                if (idbValue !== null) {
                    return idbValue;
                }
            } catch (e) {
                console.warn(`⚠️ Erro ao ler ${key} de IndexedDB:`, e);
            }
        }

        return null;
    }

    /**
     * Versão assíncrona - para salvar dados
     */
    async setItemAsync(key, value) {
        if (!this.useIDB) return;

        try {
            await idb.setItem(key, value);
        } catch (e) {
            console.warn(`⚠️ Erro ao salvar ${key} em IndexedDB:`, e);
        }
    }

    removeItem(key) {
        localStorage.removeItem(key);
        localStorage.removeItem(key + '__compressed');
        localStorage.removeItem(key + '__large');
        localStorage.removeItem(key + '__idb_only');

        if (this.useIDB) {
            idb.removeItem(key).catch(err => {
                console.warn(`⚠️ Erro ao remover ${key} de IndexedDB:`, err);
            });
        }
    }

    clear() {
        localStorage.clear();
        if (this.useIDB) {
            idb.clear().catch(err => {
                console.warn('⚠️ Erro ao limpar IndexedDB:', err);
            });
        }
    }

    async getStorageStats() {
        const lsSize = this.getLocalStorageSize();
        const idbStats = this.useIDB ? await idb.getUsageInfo() : { used: 0, total: 0 };
        
        return {
            localStorage: {
                used: lsSize,
                total: 5242880, // 5MB
                items: Object.keys(localStorage).length
            },
            indexedDB: {
                used: idbStats.used,
                total: idbStats.total,
                items: idbStats.items || 0
            },
            total: lsSize + idbStats.used,
            maxTotal: 5242880 + 1073741824
        };
    }

    getLocalStorageSize() {
        let total = 0;
        for (let key in localStorage) {
            if (localStorage.hasOwnProperty(key)) {
                total += localStorage[key].length + key.length;
            }
        }
        return total;
    }

    /**
     * Compressão simples - reduz tamanho mantendo legibilidade
     */
    compressData(data) {
        try {
            // Usa URI encoding para reduzir tamanho
            return btoa(encodeURIComponent(data).replace(/%20/g, ' '));
        } catch (e) {
            console.warn('⚠️ Compressão falhou:', e);
            return data;
        }
    }

    decompressData(data) {
        try {
            return decodeURIComponent(atob(data));
        } catch (e) {
            console.warn('⚠️ Descompressão falhou:', e);
            return data;
        }
    }
}

// Instância global
const storageAdapter = new StorageAdapter();

// ⚠️ NÃO intercepta Storage.prototype para evitar travamentos
// Apenas oferece funções auxiliares para acesso assíncrono

// helpers globais para quem quer acessar dados grandes
window.getStorageValueAsync = async function(key) {
    return storageAdapter.getItemAsync(key);
};

window.setStorageValueAsync = async function(key, value) {
    return storageAdapter.setItemAsync(key, value);
};

// localStorage continua 100% normal
// Apenas sincroniza em background com IndexedDB
console.log('✅ Storage Adapter ativo - localStorage intacto, IndexedDB em background');

/**
 * Helpers para carregar dados com fallback IndexedDB
 * Use estas funções para carregar dados que podem estar em IndexedDB
 */
window.loadStorageData = async function(key) {
    // Tenta localStorage primeiro (síncrono, rápido)
    let value = localStorage.getItem(key);
    if (value !== null) {
        try {
            return JSON.parse(value);
        } catch (e) {
            console.warn(`Erro ao parsear ${key} de localStorage`, e);
        }
    }
    
    // Se não achou, tenta IndexedDB
    if (storageAdapter && storageAdapter.useIDB) {
        try {
            const idbValue = await storageAdapter.getItemAsync(key);
            if (idbValue) {
                console.log(`📦 ${key} carregado de IndexedDB`);
                return JSON.parse(idbValue);
            }
        } catch (e) {
            console.warn(`Erro ao carregar ${key} de IndexedDB`, e);
        }
    }
    
    return null;
};

// Versão síncrona que tenta localStorage
window.loadStorageDataSync = function(key) {
    // Tenta localStorage
    let value = localStorage.getItem(key);
    if (value !== null) {
        try {
            return JSON.parse(value);
        } catch (e) {
            return null;
        }
    }
    
    return null;
};

// Wrapper para salvar dados com fallback automático para IndexedDB
window.saveDataSafely = function(key, data) {
    const json = typeof data === 'string' ? data : JSON.stringify(data);
    const size = json.length;
    
    // Tenta localStorage primeiro
    try {
        localStorage.setItem(key, json);
        console.log(`✓ ${key} salvo em localStorage (${(size/1024).toFixed(0)}KB)`);
        
        // Se ≥2MB, também salva em IndexedDB para backup
        if (size > 2000000 && storageAdapter && storageAdapter.useIDB) {
            storageAdapter.setItemAsync(key, json).catch(() => {});
        }
        return true;
    } catch (err) {
        // localStorage cheio - redireciona para IndexedDB
        if (err.name === 'QuotaExceededError' || err.message.includes('quota')) {
            console.warn(`⚠️ localStorage cheio (${(size/1024/1024).toFixed(1)}MB), usando IndexedDB...`);
            
            // Marca como IDB-only
            try {
                localStorage.setItem(key + '__idb_only', 'true');
            } catch (e) {
                localStorage.removeItem(key);
            }
            
            // Salva em IndexedDB
            if (storageAdapter && storageAdapter.useIDB) {
                return storageAdapter.setItemAsync(key, json)
                    .then(() => {
                        console.log(`✓ ${key} salvo em IndexedDB (${(size/1024/1024).toFixed(1)}MB)`);
                        return true;
                    })
                    .catch(err => {
                        console.error(`❌ Erro ao salvar ${key}:`, err);
                        return false;
                    });
            }
            return false;
        }
        throw err;
    }
};

console.log('📦 Helpers localStorage↔IndexedDB carregados');
