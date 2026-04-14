/**
 * Data Loader - Sistema de Carregamento Automático de Datasets
 * =============================================================
 * Permite compartilhar links como:
 *   dashboard_ativos.html?dataset=ativos-24-03
 *   dashboard_usuarios.html?dataset=usuarios-driver-24-03
 * 
 * Os dados carregam automaticamente sem precisar fazer upload!
 */

class DatasetLoader {
    constructor() {
        this.metadata = null;
        this.currentDataset = null;
        this.isLoaded = false;
    }

    /**
     * Carregar metadata.json (índice de datasets)
     */
    async loadMetadata() {
        try {
            const response = await fetch('data/metadata.json');
            if (!response.ok) {
                console.warn('⚠️ metadata.json não encontrado');
                return false;
            }
            this.metadata = await response.json();
            console.log('✅ Metadata carregado');
            return true;
        } catch (error) {
            console.warn('⚠️ Erro ao carregar metadata:', error);
            return false;
        }
    }

    /**
     * Obter parâmetro da URL
     * @param {string} param - Nome do parâmetro (ex: 'dataset')
     * @returns {string|null}
     */
    getUrlParam(param) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(param);
    }

    /**
     * Carregar dataset específico
     * @param {string} datasetId - ID do dataset (ex: 'ativos-24-03')
     * @returns {Promise<Array|null>}
     */
    async loadDataset(datasetId) {
        if (!this.metadata) {
            await this.loadMetadata();
        }

        if (!this.metadata || !this.metadata.datasets[datasetId]) {
            console.error(`❌ Dataset '${datasetId}' não encontrado`);
            return null;
        }

        const datasetConfig = this.metadata.datasets[datasetId];
        const filePath = datasetConfig.file;

        console.log(`📥 Carregando dataset: ${datasetId}`);
        console.log(`   Arquivo: ${filePath}`);
        console.log(`   Registros: ${datasetConfig.registros}`);

        try {
            const response = await fetch(filePath);
            
            if (!response.ok) {
                console.error(`❌ Erro ao carregar arquivo: ${response.status}`);
                return null;
            }

            const data = await response.json();
            
            if (!Array.isArray(data)) {
                console.error('❌ Arquivo não contém um array válido');
                return null;
            }

            console.log(`✅ Dataset carregado: ${data.length} registros`);
            
            this.currentDataset = {
                id: datasetId,
                config: datasetConfig,
                data: data
            };

            this.isLoaded = true;
            return data;

        } catch (error) {
            console.error(`❌ Erro ao processar dataset:`, error);
            return null;
        }
    }

    /**
     * Carregar dataset automático baseado em URL
     * Se URL tem ?dataset=xxx, carrega esse
     * Senão, carrega o padrão do dashboard
     */
    async loadFromUrl(currentPageDashboard) {
        // 1. Carregar metadata
        const metadataLoaded = await this.loadMetadata();
        if (!metadataLoaded) {
            console.log('ℹ️ Metadata não disponível, usando carregamento normal');
            return null;
        }

        // 2. Verificar se tem parâmetro na URL
        const datasetParam = this.getUrlParam('dataset');

        if (datasetParam) {
            console.log(`🔗 Parâmetro detectado: ?dataset=${datasetParam}`);
            const data = await this.loadDataset(datasetParam);
            if (data) {
                return {
                    data: data,
                    source: 'url-parameter',
                    datasetId: datasetParam
                };
            }
        }

        // 3. Se não houver parâmetro, usar dataset padrão do dashboard
        const dashboardConfig = this.metadata.dashboards[currentPageDashboard];
        if (dashboardConfig && dashboardConfig.defaultDataset) {
            console.log(`📌 Usando dataset padrão: ${dashboardConfig.defaultDataset}`);
            const data = await this.loadDataset(dashboardConfig.defaultDataset);
            if (data) {
                return {
                    data: data,
                    source: 'dashboard-default',
                    datasetId: dashboardConfig.defaultDataset
                };
            }
        }

        console.log('ℹ️ Nenhum dataset automático disponível');
        return null;
    }

    /**
     * Listar todos os datasets disponíveis
     */
    listAvailableDatasets() {
        if (!this.metadata) {
            console.warn('⚠️ Metadata não carregado');
            return [];
        }

        return Object.entries(this.metadata.datasets).map(([id, config]) => ({
            id: id,
            nome: config.nome,
            descricao: config.descricao,
            registros: config.registros,
            dashboard: config.dashboard
        }));
    }

    /**
     * Obter configuração de um dashboard
     */
    getDashboardConfig(dashboardName) {
        if (!this.metadata) return null;
        return this.metadata.dashboards[dashboardName];
    }
}

// Instância global única
const DatasetLoader_instance = new DatasetLoader();

/**
 * Função auxiliar para carregar dados no dashboard automátic amente
 * Usar na inicialização do DOMContentLoaded
 * 
 * EXEMPLO DE USO:
 * 
 * document.addEventListener('DOMContentLoaded', async function() {
 *     const result = await autoLoadDataset('dashboard_ativos.html');
 *     
 *     if (result && result.data) {
 *         rawData = result.data;
 *         Console.log(`✅ ${result.registros} registros carregados de ${result.source}`);
 *         // Atualizar dashboard
 *         updateDashboard();
 *     }
 * });
 */
async function autoLoadDataset(dashboardFileName) {
    const result = await DatasetLoader_instance.loadFromUrl(dashboardFileName);
    
    if (result) {
        console.log(`✅ Dados carregados automaticamente (${result.data.length} registros)`);
        console.log(`   Origem: ${result.source}`);
        console.log(`   Dataset: ${result.datasetId}`);
        
        return {
            data: result.data,
            datasetId: result.datasetId,
            registros: result.data.length,
            source: result.source
        };
    }
    
    return null;
}
