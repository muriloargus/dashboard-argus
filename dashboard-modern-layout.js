/**
 * MODERN DASHBOARD LAYOUT SYSTEM
 * Gerencia menu colapsável, categorias e padrão visual
 */

(function() {
    'use strict';

    // Configuração do menu organizado por categorias
    const MENU_STRUCTURE = {
        operacional: {
            icon: 'speedometer2',
            label: 'Operacional',
            items: [
                { name: 'Status Frota', href: 'status_frota.html', icon: 'speedometer2' },
                { name: 'Ativos', href: 'dashboard_ativos.html', icon: 'truck' },
                { name: 'Dispositivos', href: 'dashboard_dispositivos.html', icon: 'inbox' }
            ]
        },
        rh: {
            icon: 'people',
            label: 'Recursos Humanos',
            items: [
                { name: 'Motoristas', href: 'dashboard_motoristas%20v2.html', icon: 'people' },
                { name: 'Usuários', href: 'dashboard_usuarios.html', icon: 'person-check' }
            ]
        },
        analise: {
            icon: 'bar-chart',
            label: 'Análise & Relatórios',
            items: [
                { name: 'Desempenho - Analista', href: 'dashboard_desempenho_analista.html', icon: 'person-badge' },
                { name: 'Comparativo', href: 'dashboard_comparativo.html', icon: 'bar-chart' },
                { name: 'Temporal & Mapas', href: 'dashboard_temporal_mapas.html', icon: 'calendar-range' },
                { name: 'Dashboard TV', href: 'tv_dashboard.html', icon: 'television' }
            ]
        },
        monitoramento: {
            icon: 'exclamation-triangle',
            label: 'Monitoramento',
            items: [
                { name: 'Exceções', href: 'dashboard_excecoes.html', icon: 'exclamation-triangle' },
                { name: 'Falhas', href: 'dashboard_falhas.html', icon: 'bug' },
                { name: 'Risco de Colisão', href: 'dashboard_risco_colisao.html', icon: 'shield-exclamation' },
                { name: 'Motorista Não ID', href: 'dashboard_timeline.html', icon: 'calendar-event' }
            ]
        }
    };

    /**
     * Inicializa o sistema de layout moderno
     */
    window.initModernLayout = function() {
        // Renderiza o menu estruturado
        renderModernMenu();
        
        // Inicializa eventos
        initMenuEvents();
        
        // Restaura estado colapsado do localStorage
        restoreCollapseState();
        
        // Sincroniza dark mode
        syncDarkMode();
        
        console.log('✅ Modern Layout System inicializado');
    };

    /**
     * Renderiza o menu com categorias
     */
    function renderModernMenu() {
        const sidebarMenu = document.querySelector('.sidebar-menu');
        if (!sidebarMenu) return;

        // Limpa menu anterior
        sidebarMenu.innerHTML = '';

        // Constrói cada seção
        Object.entries(MENU_STRUCTURE).forEach(([sectionId, sectionData]) => {
            const section = createMenuSection(sectionId, sectionData);
            sidebarMenu.appendChild(section);
        });
    }

    /**
     * Cria um elemento de seção do menu
     */
    function createMenuSection(sectionId, sectionData) {
        const section = document.createElement('div');
        section.className = 'menu-section';
        section.dataset.section = sectionId;

        // Header da seção
        const header = document.createElement('div');
        header.className = 'section-header';
        header.innerHTML = `
            <i class="bi bi-${sectionData.icon}"></i>
            <span class="section-title">${sectionData.label}</span>
            <i class="bi bi-chevron-down section-toggle"></i>
        `;

        // Lista de itens
        const itemsList = document.createElement('ul');
        itemsList.className = 'section-items';

        sectionData.items.forEach(item => {
            const li = document.createElement('li');
            const link = document.createElement('a');
            link.href = item.href;
            link.innerHTML = `<i class="bi bi-${item.icon}"></i><span>${item.name}</span>`;
            link.setAttribute('data-tooltip', item.name);
            
            li.appendChild(link);
            itemsList.appendChild(li);
        });

        // Detecta página ativa
        markActiveMenu();

        section.appendChild(header);
        section.appendChild(itemsList);
        return section;
    }

    /**
     * Marca o menu ativo baseado na página atual
     */
    function markActiveMenu() {
        const currentPage = window.location.pathname.split('/').pop() || 'index.html';
        
        document.querySelectorAll('.sidebar-menu a').forEach(link => {
            const href = link.getAttribute('href');
            if (href && (href === currentPage || href.includes(currentPage.replace('.html', '')))) {
                link.classList.add('active');
                
                // Expande a seção do link ativo
                const section = link.closest('.menu-section');
                if (section) {
                    const header = section.querySelector('.section-header');
                    const items = section.querySelector('.section-items');
                    
                    header.classList.remove('collapsed');
                    items.classList.remove('collapsed');
                }
            } else {
                link.classList.remove('active');
            }
        });
    }

    /**
     * Inicializa eventos do menu
     */
    function initMenuEvents() {
        // Toggle de seções
        document.querySelectorAll('.section-header').forEach(header => {
            header.addEventListener('click', function(e) {
                e.preventDefault();
                
                const section = this.closest('.menu-section');
                const items = section.querySelector('.section-items');
                const sectionId = section.dataset.section;
                
                const isCollapsed = items.classList.toggle('collapsed');
                this.classList.toggle('collapsed', isCollapsed);
                
                // Salva estado
                saveMenuState(sectionId, isCollapsed);
            });
        });

        // Toggle do sidebar
        const toggleBtn = document.querySelector('.sidebar-toggle');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', function(e) {
                e.preventDefault();
                toggleSidebar();
            });
        }

        // Fechar seções ao clicar em um link
        document.querySelectorAll('.sidebar-menu a').forEach(link => {
            link.addEventListener('click', function() {
                // Fecha modal em mobile se tiver
                const sidebar = document.querySelector('.sidebar');
                if (sidebar && window.innerWidth < 768) {
                    sidebar.classList.remove('active');
                }
            });
        });
    }

    /**
     * Toggle do sidebar colapsado
     */
    function toggleSidebar() {
        const container = document.querySelector('.dashboard-container');
        const sidebar = document.querySelector('.sidebar');
        const mainContent = document.querySelector('.main-content');
        
        if (!container || !sidebar) return;

        const isCollapsed = container.classList.toggle('collapsed');
        
        // Atualiza classes
        if (isCollapsed) {
            sidebar.classList.add('collapsed');
            if (mainContent) mainContent.classList.add('collapsed');
        } else {
            sidebar.classList.remove('collapsed');
            if (mainContent) mainContent.classList.remove('collapsed');
        }

        // Salva estado
        localStorage.setItem('dashboard-sidebar-collapsed', isCollapsed);
    }

    /**
     * Salva estado do menu no localStorage
     */
    function saveMenuState(sectionId, isCollapsed) {
        const state = JSON.parse(localStorage.getItem('dashboard-menu-state') || '{}');
        state[sectionId] = isCollapsed;
        localStorage.setItem('dashboard-menu-state', JSON.stringify(state));
    }

    /**
     * Restaura estado colapsado salvo
     */
    function restoreCollapseState() {
        // Restaura estado do sidebar
        const sidebarCollapsed = localStorage.getItem('dashboard-sidebar-collapsed') === 'true';
        if (sidebarCollapsed) {
            const container = document.querySelector('.dashboard-container');
            container?.classList.add('collapsed');
        }

        // Restaura estado das seções
        const menuState = JSON.parse(localStorage.getItem('dashboard-menu-state') || '{}');
        
        document.querySelectorAll('.menu-section').forEach(section => {
            const sectionId = section.dataset.section;
            const isCollapsed = menuState[sectionId] ?? false;
            
            const items = section.querySelector('.section-items');
            const header = section.querySelector('.section-header');
            
            if (isCollapsed) {
                items?.classList.add('collapsed');
                header?.classList.add('collapsed');
            }
        });
    }

    /**
     * Sincroniza dark mode com storage
     */
    function syncDarkMode() {
        const isDarkMode = localStorage.getItem('dashboard-dark-mode') === 'true';
        
        if (isDarkMode) {
            document.body.classList.add('dark-mode');
            updateChartsForDarkMode?.();
        }

        // Listener para mudanças
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.attributeName === 'class') {
                    const isDark = document.body.classList.contains('dark-mode');
                    localStorage.setItem('dashboard-dark-mode', isDark);
                    updateChartsForDarkMode?.();
                }
            });
        });

        observer.observe(document.body, { attributes: true });
    }

    /**
     * Utility: Atualiza charts quando dark mode muda
     */
    window.updateChartsForDarkMode = function() {
        // Será sobrescrito pelos dashboards específicos
        console.log('🎨 Dark mode atualizado');
    };

    /**
     * Utility: Função para rolar suavemente para o topo
     */
    window.scrollToTop = function() {
        const pageContent = document.querySelector('.page-content');
        if (pageContent) {
            pageContent.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    /**
     * Utility: Adiciona animações ao carregar cards
     */
    window.animateCards = function() {
        document.querySelectorAll('.dashboard-card').forEach((card, index) => {
            card.style.animationDelay = `${index * 0.05}s`;
            card.classList.add('animate-slide-in');
        });
    };

    /**
     * Duty: Renderização automática ao carregar DOM
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', window.initModernLayout);
    } else {
        window.initModernLayout();
    }

})();
