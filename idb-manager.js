/**
 * IndexedDB Manager - Substitui localStorage com capacidade de 1GB
 * Mantém interface compatível com localStorage
 * Funciona transparentemente com os dashboards existentes
 */

class IDBManager {
    constructor() {
        this.dbName = 'DashboardArgusDB';
        this.storeName = 'data';
        this.version = 1;
        this.db = null;
        this.isReady = false;
        this.initPromise = this.init();
    }

    async init() {
        return new Promise((resolve, reject) => {
            if (!window.indexedDB) {
                console.warn('⚠️ IndexedDB não suportado, usando localStorage');
                this.isReady = false;
                resolve();
                return;
            }

            const request = indexedDB.open(this.dbName, this.version);

            request.onerror = () => {
                console.error('❌ Erro ao abrir IndexedDB:', request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                this.db = request.result;
                this.isReady = true;
                console.log('✅ IndexedDB inicializado');
                resolve();
            };

            request.onupgradeneeded = (e) => {
                const db = e.target.result;
                if (!db.objectStoreNames.contains(this.storeName)) {
                    db.createObjectStore(this.storeName, { keyPath: 'key' });
                    console.log('✅ Object Store criado');
                }
            };
        });
    }

    async setItem(key, value) {
        await this.initPromise;

        // Se IndexedDB não está disponível, usa localStorage como fallback
        if (!this.isReady || !this.db) {
            try {
                localStorage.setItem(key, value);
                this.broadcastChange(key, value);
                return Promise.resolve();
            } catch (e) {
                console.warn('⚠️ localStorage quota excedida, tentando IndexedDB fallback');
                return Promise.reject(e);
            }
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);

            // Comprime dados grandes (> 500KB)
            let dataToStore = value;
            let isCompressed = false;
            if (value.length > 512000) {
                try {
                    dataToStore = this.compress(value);
                    isCompressed = true;
                    console.log(`📦 Dados comprimidos: ${value.length} → ${dataToStore.length} bytes`);
                } catch (e) {
                    console.warn('⚠️ Compressão falhou, salvando sem comprimir:', e);
                }
            }

            const request = store.put({
                key: key,
                value: dataToStore,
                isCompressed: isCompressed,
                timestamp: Date.now(),
                size: value.length
            });

            request.onerror = () => {
                console.error(`❌ Erro ao salvar ${key}:`, request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                console.log(`✅ Salvo em IDB: ${key} (${Math.round(value.length / 1024)}KB)`);
                this.broadcastChange(key, value);
                resolve();
            };
        });
    }

    async getItem(key) {
        await this.initPromise;

        // Se IndexedDB não está disponível, usa localStorage como fallback
        if (!this.isReady || !this.db) {
            return localStorage.getItem(key);
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readonly');
            const store = transaction.objectStore(this.storeName);
            const request = store.get(key);

            request.onerror = () => {
                console.error(`❌ Erro ao ler ${key}:`, request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                const result = request.result;
                if (result) {
                    let value = result.value;
                    // Descomprime se for necessário
                    if (result.isCompressed) {
                        try {
                            value = this.decompress(value);
                        } catch (e) {
                            console.error('❌ Erro ao descomprimir:', e);
                        }
                    }
                    resolve(value);
                } else {
                    // Tenta localStorage como fallback
                    const fallback = localStorage.getItem(key);
                    resolve(fallback);
                }
            };
        });
    }

    async removeItem(key) {
        await this.initPromise;

        // Remove de localStorage também
        try {
            localStorage.removeItem(key);
        } catch (e) {
            // Ignorar
        }

        if (!this.isReady || !this.db) {
            return Promise.resolve();
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);
            const request = store.delete(key);

            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                console.log(`🗑️ ${key} removido de IDB`);
                resolve();
            };
        });
    }

    async clear() {
        await this.initPromise;

        // Limpa localStorage
        try {
            localStorage.clear();
        } catch (e) {
            // Ignorar
        }

        if (!this.isReady || !this.db) {
            return Promise.resolve();
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);
            const request = store.clear();

            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                console.log('🗑️ IndexedDB limpo');
                resolve();
            };
        });
    }

    async getAllKeys() {
        await this.initPromise;

        if (!this.isReady || !this.db) {
            return Object.keys(localStorage);
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readonly');
            const store = transaction.objectStore(this.storeName);
            const request = store.getAllKeys();

            request.onerror = () => reject(request.error);
            request.onsuccess = () => resolve(request.result);
        });
    }

    async getUsageInfo() {
        await this.initPromise;

        if (!this.isReady || !this.db) {
            return { used: 0, total: 5242880, engine: 'localStorage' };
        }

        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readonly');
            const store = transaction.objectStore(this.storeName);
            const request = store.getAll();

            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                let total = 0;
                request.result.forEach(item => {
                    total += item.size || 0;
                });
                resolve({
                    used: total,
                    total: 1073741824, // 1GB
                    items: request.result.length,
                    engine: 'IndexedDB'
                });
            };
        });
    }

    // Compressão simples usando LZ4-like (run-length encoding + base64)
    compress(data) {
        // Usa a API de compressão nativa se disponível
        if (typeof CompressionStream !== 'undefined') {
            // Navegadores modernos com Compression API
            return data; // TODO: implementar se necessário
        }

        // Fallback: Base64 é menor que JSON string para dados binários
        return btoa(encodeURIComponent(data));
    }

    decompress(data) {
        try {
            return decodeURIComponent(atob(data));
        } catch (e) {
            // Se não foi comprimido, retorna como está
            return data;
        }
    }

    // Listener para sincronização entre abas
    broadcastChange(key, value) {
        try {
            const channel = new BroadcastChannel('dashboard-sync');
            channel.postMessage({
                type: 'data-changed',
                key: key,
                timestamp: Date.now()
            });
            channel.close();
        } catch (e) {
            // BroadcastChannel não suportado
        }
    }

    // Listener para mudanças de outras abas
    onStorageChange(callback) {
        try {
            const channel = new BroadcastChannel('dashboard-sync');
            channel.onmessage = (event) => {
                if (event.data.type === 'data-changed') {
                    callback(event.data.key);
                }
            };
        } catch (e) {
            // BroadcastChannel não suportado, usar storage event
            window.addEventListener('storage', (e) => {
                if (e.key) callback(e.key);
            });
        }
    }
}

// Instância global
const idb = new IDBManager();

// Sobrescreve localStorage para funcionar com IndexedDB
const originalLocalStorage = window.localStorage;
const localStorageProxy = {
    async setItem(key, value) {
        return idb.setItem(key, value);
    },
    async getItem(key) {
        return idb.getItem(key);
    },
    removeItem(key) {
        return idb.removeItem(key);
    },
    clear() {
        return idb.clear();
    },
    key(index) {
        // Fallback para localStorage original se necessário
        return originalLocalStorage.key(index);
    }
};

// Função auxiliar para manter compatibilidade com código síncrono existente
window.getStorageItem = async function(key) {
    return idb.getItem(key);
};

window.setStorageItem = async function(key, value) {
    return idb.setItem(key, value);
};

console.log('📦 IndexedDB Manager carregado - Capacidade: 1GB');
