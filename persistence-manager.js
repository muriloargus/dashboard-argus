/**
 * Persistence Manager - Sistema Universal de Persistência
 * ========================================================
 * Gerencia salvamento e carregamento de dados de forma confiável
 * Compatível com localStorage, IndexedDB e CompressedStorage
 * 
 * USO:
 *   PersistenceManager.save('dashboard_name', dataArray)  // Ao carregar CSV
 *   PersistenceManager.load('dashboard_name')            // Ao iniciar página
 */

class PersistenceManager {
    constructor() {
        this.storageType = 'localStorage'; // ou 'indexedDB'
        this.maxLocalStorageSize = 5 * 1024 * 1024; // 5MB
        this.compressThreshold = 1 * 1024 * 1024; // 1MB - acima disso, comprime
        this.init();
    }

    init() {
        // Detectar suporte a IndexedDB
        if ('indexedDB' in window) {
            console.log('✅ IndexedDB disponível para persistência');
            this.storageType = 'indexedDB';
        } else {
            console.log('⚠️ Usando localStorage (tamanho limitado a 5MB)');
            this.storageType = 'localStorage';
        }
    }

    /**
     * Salvar dados com sistema de fallback automático
     * @param {string} key - Chave para armazenar (ex: 'dashboard_usuarios')
     * @param {Array} data - Array de dados a salvar
     * @returns {Promise<boolean>}
     */
    async save(key, data) {
        if (!Array.isArray(data)) {
            console.error('❌ Dados devem ser um array');
            return false;
        }

        const jsonData = JSON.stringify(data);
        const sizeKB = (jsonData.length / 1024).toFixed(2);
        console.log(`📦 Salvando ${key}: ${sizeKB}KB, ${data.length} registros`);

        try {
            // OPÇÃO 1: IndexedDB (melhor para dados grandes)
            if (this.storageType === 'indexedDB' && 'indexedDB' in window) {
                const result = await this._saveToIndexedDB(key, jsonData, data.length);
                if (result) {
                    console.log(`✅ Dados salvos em IndexedDB (${sizeKB}KB)`);
                    // Propagate para localStorage também (pequena cópia, para compatibilidade)
                    if (jsonData.length < 100 * 1024) { // Só se < 100KB
                        this._saveToLocalStorage(key + '__meta', JSON.stringify({
                            count: data.length,
                            size: sizeKB,
                            source: 'indexedDB',
                            timestamp: new Date().toISOString()
                        }));
                    }
                    return true;
                }
            }

            // OPÇÃO 2: localStorage direto (compatível)
            const success = this._saveToLocalStorage(key, jsonData);
            if (success) {
                console.log(`✅ Dados salvos em localStorage (${sizeKB}KB)`);
                return true;
            }

            // OPÇÃO 3: Falha nos dois - avisar ao usuário
            console.error(`❌ Não foi possível salvar ${key} (quota excedida?)`);
            return false;

        } catch (error) {
            console.error(`❌ Erro ao salvar ${key}:`, error);
            return false;
        }
    }

    /**
     * Carregar dados do melhor armazenamento disponível
     * @param {string} key - Chave de dados a carregar
     * @returns {Promise<Array|null>}
     */
    async load(key) {
        console.log(`🔍 Carregando ${key}...`);

        try {
            // OPÇÃO 1: Tentar IndexedDB primeiro
            if (this.storageType === 'indexedDB') {
                const data = await this._loadFromIndexedDB(key);
                if (data) {
                    const sizeKB = (JSON.stringify(data).length / 1024).toFixed(2);
                    console.log(`✅ Carregado de IndexedDB: ${data.length} registros (${sizeKB}KB)`);
                    return data;
                }
            }

            // OPÇÃO 2: Tentar localStorage
            const localData = this._loadFromLocalStorage(key);
            if (localData) {
                const sizeKB = (JSON.stringify(localData).length / 1024).toFixed(2);
                console.log(`✅ Carregado de localStorage: ${localData.length} registros (${sizeKB}KB)`);
                return localData;
            }

            console.log(`ℹ️ Nenhum dado encontrado para ${key}`);
            return null;

        } catch (error) {
            console.error(`❌ Erro ao carregar ${key}:`, error);
            return null;
        }
    }

    /**
     * Sincronizar dados entre abas (sync em tempo real)
     * @param {string} key - Chave a sincronizar
     * @param {Function} callback - Função chamada quando dados mudam
     */
    syncAcrossTabs(key, callback) {
        window.addEventListener('storage', (e) => {
            if (e.key === key && e.newValue) {
                console.log(`🔄 Sincronizando ${key} entre abas...`);
                try {
                    const data = JSON.parse(e.newValue);
                    if (callback) callback(data);
                } catch (error) {
                    console.error('❌ Erro ao sincronizar:', error);
                }
            }
        });
    }

    /**
     * Limpar dados
     * @param {string} key - Chave a limpar
     */
    async clear(key) {
        try {
            localStorage.removeItem(key);
            localStorage.removeItem(key + '__meta');
            localStorage.removeItem(key + '__compressed');
            console.log(`🗑️ Limpou ${key}`);
            return true;
        } catch (error) {
            console.error(`❌ Erro ao limpar ${key}:`, error);
            return false;
        }
    }

    // ============ MÉTODOS PRIVADOS ============

    /**
     * Salvar em localStorage
     */
    _saveToLocalStorage(key, jsonData) {
        try {
            localStorage.setItem(key, jsonData);
            return true;
        } catch (e) {
            if (e.name === 'QuotaExceededError') {
                console.warn(`⚠️ localStorage quota excedida para ${key}`);
                return false;
            }
            throw e;
        }
    }

    /**
     * Carregar de localStorage
     */
    _loadFromLocalStorage(key) {
        try {
            const item = localStorage.getItem(key);
            if (!item) return null;

            const data = JSON.parse(item);
            return Array.isArray(data) ? data : null;
        } catch (error) {
            console.warn(`⚠️ Erro ao carregar ${key} de localStorage:`, error);
            return null;
        }
    }

    /**
     * Salvar em IndexedDB
     */
    _saveToIndexedDB(key, jsonData, count) {
        return new Promise((resolve, reject) => {
            try {
                const request = indexedDB.open('DashboardArgus', 1);

                request.onerror = () => reject(new Error('Erro ao abrir IndexedDB'));
                request.onsuccess = (event) => {
                    const db = event.target.result;
                    
                    // Criar objectStore se não existir
                    if (!db.objectStoreNames.contains('data')) {
                        db.createObjectStore('data');
                    }

                    const transaction = db.transaction(['data'], 'readwrite');
                    const store = transaction.objectStore('data');

                    const record = {
                        key: key,
                        value: jsonData,
                        count: count,
                        timestamp: new Date().toISOString(),
                        size: jsonData.length
                    };

                    const putRequest = store.put(record, key);
                    putRequest.onsuccess = () => {
                        console.log(`✅ IndexedDB salvou ${key}`);
                        resolve(true);
                    };
                    putRequest.onerror = () => reject(putRequest.error);
                };

                request.onupgradeneeded = (event) => {
                    const db = event.target.result;
                    if (!db.objectStoreNames.contains('data')) {
                        db.createObjectStore('data');
                    }
                };

            } catch (error) {
                reject(error);
            }
        });
    }

    /**
     * Carregar de IndexedDB
     */
    _loadFromIndexedDB(key) {
        return new Promise((resolve, reject) => {
            try {
                const request = indexedDB.open('DashboardArgus', 1);

                request.onerror = () => resolve(null);
                request.onsuccess = (event) => {
                    const db = event.target.result;

                    if (!db.objectStoreNames.contains('data')) {
                        resolve(null);
                        return;
                    }

                    const transaction = db.transaction(['data'], 'readonly');
                    const store = transaction.objectStore('data');
                    const getRequest = store.get(key);

                    getRequest.onsuccess = () => {
                        const result = getRequest.result;
                        if (result && result.value) {
                            try {
                                const data = JSON.parse(result.value);
                                resolve(Array.isArray(data) ? data : null);
                            } catch (error) {
                                console.warn('❌ Erro ao desserializar dados:', error);
                                resolve(null);
                            }
                        } else {
                            resolve(null);
                        }
                    };
                    getRequest.onerror = () => reject(getRequest.error);
                };

                request.onupgradeneeded = (event) => {
                    const db = event.target.result;
                    if (!db.objectStoreNames.contains('data')) {
                        db.createObjectStore('data');
                    }
                };

            } catch (error) {
                resolve(null);
            }
        });
    }
}

// Instância global única
const PersistenceManager_instance = new PersistenceManager();
