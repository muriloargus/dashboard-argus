/**
 * Funções Compartilhadas - Dashboard Argus
 * Validação, Export, Empty States, Dark Mode Sync, Google Sheets Integration
 */

// ============ VALIDAÇÃO CSV ============
function validateCSVColumns(headerRow, requiredColumns) {
    const normalizedHeader = headerRow.map(h => h.toLowerCase().trim());
    const missing = requiredColumns.filter(col => 
        !normalizedHeader.some(h => h.includes(col.toLowerCase()))
    );
    return {
        valid: missing.length === 0,
        missing: missing,
        message: missing.length > 0 
            ? `❌ Colunas obrigatórias faltando: ${missing.join(', ')}`
            : '✅ CSV válido'
    };
}

// ============ EMPTY STATE ============
function createEmptyState(dashboardName = 'Dashboard') {
    return `
        <div style="
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 400px;
            background: linear-gradient(135deg, rgba(99,163,216,0.05) 0%, rgba(230,0,0,0.02) 100%);
            border-radius: 12px;
            border: 2px dashed #ccc;
            flex-direction: column;
            padding: 40px;
            text-align: center;
        ">
            <div style="font-size: 3rem; margin-bottom: 15px;">📊</div>
            <h3 style="color: #555; margin-bottom: 10px;">Nenhum dado carregado</h3>
            <p style="color: #999; margin-bottom: 20px; font-size: 0.95rem;">
                Carregue um arquivo CSV para visualizar o ${dashboardName}
            </p>
            <button onclick="document.querySelector('input[type=file]')?.click()" 
                style="
                    padding: 10px 20px;
                    background: #63a3d8;
                    color: white;
                    border: none;
                    border-radius: 6px;
                    cursor: pointer;
                    font-weight: 600;
                    transition: all 0.3s;
                "
                onmouseover="this.style.background='#4a8fb8'; this.style.transform='scale(1.05)'"
                onmouseout="this.style.background='#63a3d8'; this.style.transform='scale(1)'"
            >
                📤 Selecionar CSV
            </button>
        </div>
    `;
}

// ============ EXPORT FUNCIONALIDADE ============
function exportToCSV(data, filename = 'export.csv') {
    if (!data || data.length === 0) {
        alert('❌ Nenhum dado para exportar');
        return;
    }
    
    const headers = Object.keys(data[0]);
    const csvContent = [
        headers.join(','),
        ...data.map(row => 
            headers.map(h => {
                const val = row[h];
                if (typeof val === 'string' && val.includes(',')) {
                    return `"${val.replace(/"/g, '""')}"`;
                }
                return val || '';
            }).join(',')
        )
    ].join('\n');
    
    downloadFile(csvContent, filename, 'text/csv');
}

function exportToJSON(data, filename = 'export.json') {
    if (!data || data.length === 0) {
        alert('❌ Nenhum dado para exportar');
        return;
    }
    
    const jsonContent = JSON.stringify(data, null, 2);
    downloadFile(jsonContent, filename, 'application/json');
}

function downloadFile(content, filename, type) {
    const blob = new Blob([content], { type });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
}

// ============ DARK MODE SYNC GLOBAL ============
function initDarkModeSync() {
    // Restaurar preferência ao carregar (com try/catch para privacy)
    try {
        if (localStorage.getItem('darkMode') === 'true') {
            document.body.classList.add('dark');
        }
    } catch(e) {
        console.warn('Storage access denied, using default light mode');
    }
    
    // Observar mudanças em outras abas
    window.addEventListener('storage', (e) => {
        if (e.key === 'darkMode') {
            if (e.newValue === 'true') {
                document.body.classList.add('dark');
            } else {
                document.body.classList.remove('dark');
            }
            // Atualizar gráficos se existirem
            if (window.updateChartsForDarkMode) {
                window.updateChartsForDarkMode();
            }
        }
    });
}

function toggleDarkModeGlobal() {
    const isDark = document.body.classList.toggle('dark');
    // IMPORTANTE: Salvar como string 'true'/'false' NÃO como boolean
    try {
        localStorage.setItem('darkMode', isDark ? 'true' : 'false');
    } catch(e) {
        console.warn('Storage access denied, dark mode preference not saved');
    }
    
    // Notificar outras abas
    try {
        window.dispatchEvent(new StorageEvent('storage', {
            key: 'darkMode',
            newValue: isDark ? 'true' : 'false'
        }));
    } catch(e) {}
    
    if (window.updateChartsForDarkMode) {
        window.updateChartsForDarkMode();
    }
}

// ============ GOOGLE SHEETS INTEGRATION ============
// Carrega dados de Google Sheet via Google Sheets API
async function loadFromGoogleSheet(sheetId, sheetName = 'Sheet1', apiKey) {
    if (!apiKey) {
        console.warn('Google Sheets API key não configurada');
        return null;
    }
    
    try {
        const url = `https://sheets.googleapis.com/v4/spreadsheets/${sheetId}/values/${sheetName}?key=${apiKey}`;
        const response = await fetch(url);
        if (!response.ok) throw new Error('Erro ao carregar Google Sheet');
        
        const data = await response.json();
        const values = data.values || [];
        
        if (values.length < 2) return [];
        
        const headers = values[0];
        return values.slice(1).map(row => {
            const obj = {};
            headers.forEach((header, i) => {
                obj[header] = row[i] || '';
            });
            return obj;
        });
    } catch (error) {
        console.error('Erro ao carregar Google Sheet:', error);
        return null;
    }
}

// ============ KPI ALERT CARD ============
function createKPIAlert(icon, title, value, status = 'normal', color = '#63a3d8') {
    const statusColors = {
        'normal': color,
        'warning': '#ffc107',
        'critical': '#dc3545',
        'success': '#28a745'
    };
    
    return `
        <div style="
            padding: 15px;
            background: white;
            border-left: 4px solid ${statusColors[status]};
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-bottom: 10px;
        ">
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                <span style="font-size: 1.5rem;">${icon}</span>
                <span style="font-weight: 600; color: #333;">${title}</span>
            </div>
            <div style="font-size: 1.8rem; font-weight: 700; color: ${statusColors[status]};">
                ${value}
            </div>
        </div>
    `;
}

// ============ UTILIDADES DATAS ============
function parseDateFlexible(value) {
    if (!value || value === '0') return null;
    const str = String(value).trim();
    
    // Excel format
    const asNum = Number(str.replace(',', '.'));
    if (!isNaN(asNum) && asNum > 1000) {
        const utc_days = asNum - 25569;
        const date_info = new Date(utc_days * 86400 * 1000);
        if (!isNaN(date_info.getTime())) return date_info;
    }
    
    // ISO (YYYY-MM-DD)
    if (/^\d{4}-\d{2}-\d{2}/.test(str)) {
        const parsed = new Date(str);
        if (!isNaN(parsed.getTime())) return parsed;
    }
    
    // Brazilian (DD/MM/YYYY)
    const brMatch = str.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})/);
    if (brMatch) {
        const parsed = new Date(brMatch[3], brMatch[2] - 1, brMatch[1]);
        if (!isNaN(parsed.getTime())) return parsed;
    }
    
    // Generic
    const parsed = new Date(str);
    if (!isNaN(parsed.getTime())) return parsed;
    
    return null;
}

// ============ MOBILE RESPONSIVE CHECK ============
function isMobileView() {
    return window.innerWidth < 768;
}

function onMobileChange(callback) {
    callback(isMobileView());
    window.addEventListener('resize', () => callback(isMobileView()));
}

// ============ CHART RESPONSIVE COLORS ============
function getChartColor(isDark, index = 0) {
    const lightColors = ['#63a3d8','#2f4b7c','#665191','#a05195','#d45087','#f95d6a','#ff7c43','#ffa600'];
    const darkColors = ['#4a8fb8','#5a7fb0','#7a7ba8','#b07bb0','#e47ba8','#ff8a8a','#ffaa77','#ffcc77'];
    return isDark ? darkColors[index % darkColors.length] : lightColors[index % lightColors.length];
}

// ============ SAFE JSON PARSE ============
function safeParseJSON(jsonStr, defaultValue = null) {
    try {
        return JSON.parse(jsonStr);
    } catch(e) {
        console.warn('Erro ao fazer parse de JSON:', e);
        return defaultValue;
    }
}

// ============ AUTO-REFRESH ============
function setAutoRefresh(callback, intervalMinutes = 5) {
    setInterval(callback, intervalMinutes * 60 * 1000);
    console.log(`✅ Auto-refresh configurado: ${intervalMinutes} minutos`);
}
