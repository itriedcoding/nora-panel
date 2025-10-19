// Nora Panel - UI Components JavaScript
class NoraComponents {
    constructor() {
        this.components = new Map();
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.createComponentStyles();
    }

    setupEventListeners() {
        // Listen for component-related events
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-component]')) {
                this.handleComponentClick(e);
            }
        });

        document.addEventListener('change', (e) => {
            if (e.target.matches('[data-component]')) {
                this.handleComponentChange(e);
            }
        });
    }

    handleComponentClick(e) {
        const component = e.target.closest('[data-component]');
        const type = component.dataset.component;
        const action = component.dataset.action;

        switch (type) {
            case 'modal':
                this.handleModalClick(component, action);
                break;
            case 'dropdown':
                this.handleDropdownClick(component, action);
                break;
            case 'tabs':
                this.handleTabsClick(component, action);
                break;
            case 'accordion':
                this.handleAccordionClick(component, action);
                break;
            case 'tooltip':
                this.handleTooltipClick(component, action);
                break;
        }
    }

    handleComponentChange(e) {
        const component = e.target.closest('[data-component]');
        const type = component.dataset.component;

        switch (type) {
            case 'switch':
                this.handleSwitchChange(component);
                break;
            case 'slider':
                this.handleSliderChange(component);
                break;
            case 'checkbox':
                this.handleCheckboxChange(component);
                break;
        }
    }

    // Modal Component
    createModal(options = {}) {
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.setAttribute('data-component', 'modal');
        modal.setAttribute('data-modal-id', options.id || Date.now());

        modal.innerHTML = `
            <div class="modal-backdrop"></div>
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">${options.title || 'Modal'}</h3>
                    <button class="modal-close" data-action="close">×</button>
                </div>
                <div class="modal-body">
                    ${options.content || ''}
                </div>
                ${options.footer ? `<div class="modal-footer">${options.footer}</div>` : ''}
            </div>
        `;

        document.body.appendChild(modal);
        this.components.set(modal.dataset.modalId, modal);

        // Add event listeners
        modal.querySelector('.modal-backdrop').addEventListener('click', () => {
            this.closeModal(modal.dataset.modalId);
        });

        modal.querySelector('.modal-close').addEventListener('click', () => {
            this.closeModal(modal.dataset.modalId);
        });

        // Show modal
        setTimeout(() => {
            modal.classList.add('active');
        }, 10);

        return modal;
    }

    openModal(id) {
        const modal = this.components.get(id);
        if (modal) {
            modal.classList.add('active');
        }
    }

    closeModal(id) {
        const modal = this.components.get(id);
        if (modal) {
            modal.classList.remove('active');
            setTimeout(() => {
                modal.remove();
                this.components.delete(id);
            }, 300);
        }
    }

    handleModalClick(component, action) {
        const modalId = component.dataset.modalId;
        switch (action) {
            case 'close':
                this.closeModal(modalId);
                break;
        }
    }

    // Dropdown Component
    createDropdown(options = {}) {
        const dropdown = document.createElement('div');
        dropdown.className = 'dropdown';
        dropdown.setAttribute('data-component', 'dropdown');
        dropdown.setAttribute('data-dropdown-id', options.id || Date.now());

        dropdown.innerHTML = `
            <button class="dropdown-toggle" data-action="toggle">
                ${options.label || 'Select...'}
                <i class="fas fa-chevron-down"></i>
            </button>
            <div class="dropdown-menu">
                ${options.items ? options.items.map(item => 
                    `<div class="dropdown-item" data-value="${item.value}">${item.label}</div>`
                ).join('') : ''}
            </div>
        `;

        // Add event listeners
        dropdown.querySelector('.dropdown-toggle').addEventListener('click', (e) => {
            e.stopPropagation();
            this.toggleDropdown(dropdown.dataset.dropdownId);
        });

        dropdown.querySelectorAll('.dropdown-item').forEach(item => {
            item.addEventListener('click', () => {
                this.selectDropdownItem(dropdown.dataset.dropdownId, item.dataset.value);
            });
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            if (!dropdown.contains(e.target)) {
                this.closeDropdown(dropdown.dataset.dropdownId);
            }
        });

        this.components.set(dropdown.dataset.dropdownId, dropdown);
        return dropdown;
    }

    toggleDropdown(id) {
        const dropdown = this.components.get(id);
        if (dropdown) {
            dropdown.classList.toggle('active');
        }
    }

    closeDropdown(id) {
        const dropdown = this.components.get(id);
        if (dropdown) {
            dropdown.classList.remove('active');
        }
    }

    selectDropdownItem(id, value) {
        const dropdown = this.components.get(id);
        if (dropdown) {
            const item = dropdown.querySelector(`[data-value="${value}"]`);
            const toggle = dropdown.querySelector('.dropdown-toggle');
            
            if (item && toggle) {
                toggle.textContent = item.textContent;
                dropdown.dataset.value = value;
                dropdown.dispatchEvent(new CustomEvent('change', {
                    detail: { value, label: item.textContent }
                }));
            }
            
            this.closeDropdown(id);
        }
    }

    handleDropdownClick(component, action) {
        const dropdownId = component.dataset.dropdownId;
        switch (action) {
            case 'toggle':
                this.toggleDropdown(dropdownId);
                break;
        }
    }

    // Tabs Component
    createTabs(options = {}) {
        const tabs = document.createElement('div');
        tabs.className = 'tabs';
        tabs.setAttribute('data-component', 'tabs');
        tabs.setAttribute('data-tabs-id', options.id || Date.now());

        const tabButtons = options.tabs.map((tab, index) => 
            `<button class="tab-button ${index === 0 ? 'active' : ''}" data-tab="${tab.id}">${tab.label}</button>`
        ).join('');

        const tabContents = options.tabs.map((tab, index) => 
            `<div class="tab-content ${index === 0 ? 'active' : ''}" data-tab="${tab.id}">${tab.content}</div>`
        ).join('');

        tabs.innerHTML = `
            <div class="tab-buttons">${tabButtons}</div>
            <div class="tab-contents">${tabContents}</div>
        `;

        // Add event listeners
        tabs.querySelectorAll('.tab-button').forEach(button => {
            button.addEventListener('click', () => {
                this.switchTab(tabs.dataset.tabsId, button.dataset.tab);
            });
        });

        this.components.set(tabs.dataset.tabsId, tabs);
        return tabs;
    }

    switchTab(id, tabId) {
        const tabs = this.components.get(id);
        if (tabs) {
            // Update buttons
            tabs.querySelectorAll('.tab-button').forEach(button => {
                button.classList.toggle('active', button.dataset.tab === tabId);
            });

            // Update contents
            tabs.querySelectorAll('.tab-content').forEach(content => {
                content.classList.toggle('active', content.dataset.tab === tabId);
            });

            tabs.dispatchEvent(new CustomEvent('tabchange', {
                detail: { tabId }
            }));
        }
    }

    handleTabsClick(component, action) {
        const tabsId = component.dataset.tabsId;
        const tabId = component.dataset.tab;
        switch (action) {
            case 'switch':
                this.switchTab(tabsId, tabId);
                break;
        }
    }

    // Accordion Component
    createAccordion(options = {}) {
        const accordion = document.createElement('div');
        accordion.className = 'accordion';
        accordion.setAttribute('data-component', 'accordion');
        accordion.setAttribute('data-accordion-id', options.id || Date.now());

        const items = options.items.map((item, index) => `
            <div class="accordion-item">
                <button class="accordion-header" data-action="toggle" data-item="${item.id}">
                    <span class="accordion-title">${item.title}</span>
                    <i class="fas fa-chevron-down accordion-icon"></i>
                </button>
                <div class="accordion-content" data-item="${item.id}">
                    <div class="accordion-body">${item.content}</div>
                </div>
            </div>
        `).join('');

        accordion.innerHTML = items;

        // Add event listeners
        accordion.querySelectorAll('.accordion-header').forEach(header => {
            header.addEventListener('click', () => {
                this.toggleAccordionItem(accordion.dataset.accordionId, header.dataset.item);
            });
        });

        this.components.set(accordion.dataset.accordionId, accordion);
        return accordion;
    }

    toggleAccordionItem(id, itemId) {
        const accordion = this.components.get(id);
        if (accordion) {
            const item = accordion.querySelector(`[data-item="${itemId}"]`);
            const content = accordion.querySelector(`.accordion-content[data-item="${itemId}"]`);
            const icon = item.querySelector('.accordion-icon');
            
            if (content) {
                const isActive = content.classList.contains('active');
                
                if (isActive) {
                    content.classList.remove('active');
                    icon.style.transform = 'rotate(0deg)';
                } else {
                    content.classList.add('active');
                    icon.style.transform = 'rotate(180deg)';
                }
            }
        }
    }

    handleAccordionClick(component, action) {
        const accordionId = component.dataset.accordionId;
        const itemId = component.dataset.item;
        switch (action) {
            case 'toggle':
                this.toggleAccordionItem(accordionId, itemId);
                break;
        }
    }

    // Switch Component
    createSwitch(options = {}) {
        const switchElement = document.createElement('label');
        switchElement.className = 'switch';
        switchElement.setAttribute('data-component', 'switch');
        switchElement.setAttribute('data-switch-id', options.id || Date.now());

        switchElement.innerHTML = `
            <input type="checkbox" ${options.checked ? 'checked' : ''}>
            <span class="switch-slider"></span>
            ${options.label ? `<span class="switch-label">${options.label}</span>` : ''}
        `;

        // Add event listener
        switchElement.querySelector('input').addEventListener('change', (e) => {
            switchElement.dispatchEvent(new CustomEvent('change', {
                detail: { checked: e.target.checked }
            }));
        });

        this.components.set(switchElement.dataset.switchId, switchElement);
        return switchElement;
    }

    handleSwitchChange(component) {
        const input = component.querySelector('input');
        component.dispatchEvent(new CustomEvent('change', {
            detail: { checked: input.checked }
        }));
    }

    // Slider Component
    createSlider(options = {}) {
        const slider = document.createElement('div');
        slider.className = 'slider';
        slider.setAttribute('data-component', 'slider');
        slider.setAttribute('data-slider-id', options.id || Date.now());

        slider.innerHTML = `
            ${options.label ? `<label class="slider-label">${options.label}</label>` : ''}
            <div class="slider-track">
                <input type="range" 
                       min="${options.min || 0}" 
                       max="${options.max || 100}" 
                       value="${options.value || 0}" 
                       step="${options.step || 1}">
                <div class="slider-value">${options.value || 0}</div>
            </div>
        `;

        // Add event listener
        const input = slider.querySelector('input');
        const valueDisplay = slider.querySelector('.slider-value');
        
        input.addEventListener('input', (e) => {
            valueDisplay.textContent = e.target.value;
            slider.dispatchEvent(new CustomEvent('change', {
                detail: { value: parseFloat(e.target.value) }
            }));
        });

        this.components.set(slider.dataset.sliderId, slider);
        return slider;
    }

    handleSliderChange(component) {
        const input = component.querySelector('input');
        component.dispatchEvent(new CustomEvent('change', {
            detail: { value: parseFloat(input.value) }
        }));
    }

    // Checkbox Component
    createCheckbox(options = {}) {
        const checkbox = document.createElement('label');
        checkbox.className = 'checkbox';
        checkbox.setAttribute('data-component', 'checkbox');
        checkbox.setAttribute('data-checkbox-id', options.id || Date.now());

        checkbox.innerHTML = `
            <input type="checkbox" ${options.checked ? 'checked' : ''}>
            <span class="checkbox-mark"></span>
            ${options.label ? `<span class="checkbox-label">${options.label}</span>` : ''}
        `;

        // Add event listener
        checkbox.querySelector('input').addEventListener('change', (e) => {
            checkbox.dispatchEvent(new CustomEvent('change', {
                detail: { checked: e.target.checked }
            }));
        });

        this.components.set(checkbox.dataset.checkboxId, checkbox);
        return checkbox;
    }

    handleCheckboxChange(component) {
        const input = component.querySelector('input');
        component.dispatchEvent(new CustomEvent('change', {
            detail: { checked: input.checked }
        }));
    }

    // Tooltip Component
    createTooltip(element, options = {}) {
        const tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.setAttribute('data-component', 'tooltip');
        tooltip.setAttribute('data-tooltip-id', options.id || Date.now());
        tooltip.textContent = options.text || 'Tooltip';

        // Position tooltip
        const rect = element.getBoundingClientRect();
        const position = options.position || 'top';
        
        switch (position) {
            case 'top':
                tooltip.style.top = `${rect.top - tooltip.offsetHeight - 8}px`;
                tooltip.style.left = `${rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
                break;
            case 'bottom':
                tooltip.style.top = `${rect.bottom + 8}px`;
                tooltip.style.left = `${rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
                break;
            case 'left':
                tooltip.style.top = `${rect.top + rect.height / 2 - tooltip.offsetHeight / 2}px`;
                tooltip.style.left = `${rect.left - tooltip.offsetWidth - 8}px`;
                break;
            case 'right':
                tooltip.style.top = `${rect.top + rect.height / 2 - tooltip.offsetHeight / 2}px`;
                tooltip.style.left = `${rect.right + 8}px`;
                break;
        }

        document.body.appendChild(tooltip);
        this.components.set(tooltip.dataset.tooltipId, tooltip);

        // Show/hide on hover
        element.addEventListener('mouseenter', () => {
            tooltip.classList.add('active');
        });

        element.addEventListener('mouseleave', () => {
            tooltip.classList.remove('active');
        });

        return tooltip;
    }

    handleTooltipClick(component, action) {
        const tooltipId = component.dataset.tooltipId;
        switch (action) {
            case 'show':
                component.classList.add('active');
                break;
            case 'hide':
                component.classList.remove('active');
                break;
        }
    }

    // Progress Component
    createProgress(options = {}) {
        const progress = document.createElement('div');
        progress.className = 'progress';
        progress.setAttribute('data-component', 'progress');
        progress.setAttribute('data-progress-id', options.id || Date.now());

        progress.innerHTML = `
            ${options.label ? `<div class="progress-label">${options.label}</div>` : ''}
            <div class="progress-track">
                <div class="progress-fill" style="width: ${options.value || 0}%"></div>
            </div>
            ${options.showValue ? `<div class="progress-value">${options.value || 0}%</div>` : ''}
        `;

        this.components.set(progress.dataset.progressId, progress);
        return progress;
    }

    updateProgress(id, value) {
        const progress = this.components.get(id);
        if (progress) {
            const fill = progress.querySelector('.progress-fill');
            const valueDisplay = progress.querySelector('.progress-value');
            
            if (fill) {
                fill.style.width = `${value}%`;
            }
            
            if (valueDisplay) {
                valueDisplay.textContent = `${value}%`;
            }
        }
    }

    // Card Component
    createCard(options = {}) {
        const card = document.createElement('div');
        card.className = 'card';
        card.setAttribute('data-component', 'card');
        card.setAttribute('data-card-id', options.id || Date.now());

        card.innerHTML = `
            ${options.header ? `<div class="card-header">${options.header}</div>` : ''}
            <div class="card-body">${options.body || ''}</div>
            ${options.footer ? `<div class="card-footer">${options.footer}</div>` : ''}
        `;

        this.components.set(card.dataset.cardId, card);
        return card;
    }

    // Badge Component
    createBadge(options = {}) {
        const badge = document.createElement('span');
        badge.className = `badge ${options.type || 'default'}`;
        badge.setAttribute('data-component', 'badge');
        badge.setAttribute('data-badge-id', options.id || Date.now());
        badge.textContent = options.text || 'Badge';

        this.components.set(badge.dataset.badgeId, badge);
        return badge;
    }

    // Alert Component
    createAlert(options = {}) {
        const alert = document.createElement('div');
        alert.className = `alert ${options.type || 'info'}`;
        alert.setAttribute('data-component', 'alert');
        alert.setAttribute('data-alert-id', options.id || Date.now());

        alert.innerHTML = `
            <div class="alert-content">
                <i class="alert-icon ${options.icon || 'fas fa-info-circle'}"></i>
                <div class="alert-message">${options.message || ''}</div>
                ${options.dismissible ? '<button class="alert-close" data-action="dismiss">×</button>' : ''}
            </div>
        `;

        // Add dismiss functionality
        if (options.dismissible) {
            alert.querySelector('.alert-close').addEventListener('click', () => {
                this.dismissAlert(alert.dataset.alertId);
            });
        }

        this.components.set(alert.dataset.alertId, alert);
        return alert;
    }

    dismissAlert(id) {
        const alert = this.components.get(id);
        if (alert) {
            alert.classList.add('dismissed');
            setTimeout(() => {
                alert.remove();
                this.components.delete(id);
            }, 300);
        }
    }

    // Create component styles
    createComponentStyles() {
        const style = document.createElement('style');
        style.textContent = `
            /* Modal Styles */
            .modal {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 10000;
                opacity: 0;
                visibility: hidden;
                transition: all 0.3s ease;
            }

            .modal.active {
                opacity: 1;
                visibility: visible;
            }

            .modal-backdrop {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.8);
            }

            .modal-content {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: #1e1e3f;
                border-radius: 12px;
                border: 1px solid #2a2a4a;
                box-shadow: 0 16px 32px rgba(0, 0, 0, 0.4);
                max-width: 500px;
                width: 90%;
                max-height: 80vh;
                overflow-y: auto;
            }

            .modal-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px;
                border-bottom: 1px solid #2a2a4a;
            }

            .modal-title {
                font-size: 18px;
                font-weight: 600;
                color: #ffffff;
            }

            .modal-close {
                background: none;
                border: none;
                color: #b0b0b0;
                cursor: pointer;
                font-size: 24px;
                padding: 4px;
                border-radius: 4px;
                transition: all 0.15s ease;
            }

            .modal-close:hover {
                color: #ffffff;
                background: #2a2a4a;
            }

            .modal-body {
                padding: 20px;
            }

            .modal-footer {
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 12px;
                padding: 20px;
                border-top: 1px solid #2a2a4a;
            }

            /* Dropdown Styles */
            .dropdown {
                position: relative;
                display: inline-block;
            }

            .dropdown-toggle {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px 12px;
                background: #1e1e3f;
                border: 1px solid #2a2a4a;
                border-radius: 8px;
                color: #ffffff;
                cursor: pointer;
                transition: all 0.15s ease;
                font-size: 14px;
            }

            .dropdown-toggle:hover {
                background: #2a2a4a;
            }

            .dropdown-menu {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: #1e1e3f;
                border: 1px solid #2a2a4a;
                border-radius: 8px;
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
                z-index: 1000;
                opacity: 0;
                visibility: hidden;
                transform: translateY(-10px);
                transition: all 0.15s ease;
                margin-top: 4px;
            }

            .dropdown.active .dropdown-menu {
                opacity: 1;
                visibility: visible;
                transform: translateY(0);
            }

            .dropdown-item {
                padding: 8px 12px;
                color: #ffffff;
                cursor: pointer;
                transition: background 0.15s ease;
                font-size: 14px;
            }

            .dropdown-item:hover {
                background: #2a2a4a;
            }

            .dropdown-item:first-child {
                border-radius: 8px 8px 0 0;
            }

            .dropdown-item:last-child {
                border-radius: 0 0 8px 8px;
            }

            /* Tabs Styles */
            .tabs {
                width: 100%;
            }

            .tab-buttons {
                display: flex;
                border-bottom: 1px solid #2a2a4a;
                margin-bottom: 20px;
            }

            .tab-button {
                padding: 12px 20px;
                background: none;
                border: none;
                color: #b0b0b0;
                cursor: pointer;
                transition: all 0.15s ease;
                font-size: 14px;
                border-bottom: 2px solid transparent;
            }

            .tab-button:hover {
                color: #ffffff;
                background: #2a2a4a;
            }

            .tab-button.active {
                color: #e94560;
                border-bottom-color: #e94560;
            }

            .tab-content {
                display: none;
            }

            .tab-content.active {
                display: block;
            }

            /* Accordion Styles */
            .accordion {
                width: 100%;
            }

            .accordion-item {
                border-bottom: 1px solid #2a2a4a;
            }

            .accordion-item:last-child {
                border-bottom: none;
            }

            .accordion-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                width: 100%;
                padding: 16px 0;
                background: none;
                border: none;
                color: #ffffff;
                cursor: pointer;
                transition: all 0.15s ease;
                font-size: 16px;
            }

            .accordion-header:hover {
                color: #e94560;
            }

            .accordion-icon {
                transition: transform 0.15s ease;
            }

            .accordion-content {
                max-height: 0;
                overflow: hidden;
                transition: max-height 0.3s ease;
            }

            .accordion-content.active {
                max-height: 1000px;
            }

            .accordion-body {
                padding: 0 0 16px 0;
                color: #b0b0b0;
                line-height: 1.6;
            }

            /* Switch Styles */
            .switch {
                display: flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
            }

            .switch input {
                display: none;
            }

            .switch-slider {
                position: relative;
                width: 44px;
                height: 24px;
                background: #2a2a4a;
                border-radius: 12px;
                transition: background 0.15s ease;
            }

            .switch-slider::before {
                content: '';
                position: absolute;
                top: 2px;
                left: 2px;
                width: 20px;
                height: 20px;
                background: #ffffff;
                border-radius: 50%;
                transition: transform 0.15s ease;
            }

            .switch input:checked + .switch-slider {
                background: #e94560;
            }

            .switch input:checked + .switch-slider::before {
                transform: translateX(20px);
            }

            .switch-label {
                color: #ffffff;
                font-size: 14px;
            }

            /* Slider Styles */
            .slider {
                width: 100%;
            }

            .slider-label {
                display: block;
                margin-bottom: 8px;
                color: #ffffff;
                font-size: 14px;
                font-weight: 500;
            }

            .slider-track {
                position: relative;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .slider input[type="range"] {
                flex: 1;
                height: 6px;
                background: #2a2a4a;
                border-radius: 3px;
                outline: none;
                -webkit-appearance: none;
            }

            .slider input[type="range"]::-webkit-slider-thumb {
                -webkit-appearance: none;
                width: 18px;
                height: 18px;
                background: #e94560;
                border-radius: 50%;
                cursor: pointer;
            }

            .slider input[type="range"]::-moz-range-thumb {
                width: 18px;
                height: 18px;
                background: #e94560;
                border-radius: 50%;
                cursor: pointer;
                border: none;
            }

            .slider-value {
                min-width: 40px;
                text-align: center;
                color: #ffffff;
                font-size: 14px;
                font-weight: 500;
            }

            /* Checkbox Styles */
            .checkbox {
                display: flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
            }

            .checkbox input {
                display: none;
            }

            .checkbox-mark {
                position: relative;
                width: 18px;
                height: 18px;
                background: #2a2a4a;
                border: 1px solid #3a3a5a;
                border-radius: 4px;
                transition: all 0.15s ease;
            }

            .checkbox-mark::after {
                content: '';
                position: absolute;
                top: 2px;
                left: 6px;
                width: 4px;
                height: 8px;
                border: solid #ffffff;
                border-width: 0 2px 2px 0;
                transform: rotate(45deg);
                opacity: 0;
                transition: opacity 0.15s ease;
            }

            .checkbox input:checked + .checkbox-mark {
                background: #e94560;
                border-color: #e94560;
            }

            .checkbox input:checked + .checkbox-mark::after {
                opacity: 1;
            }

            .checkbox-label {
                color: #ffffff;
                font-size: 14px;
            }

            /* Tooltip Styles */
            .tooltip {
                position: absolute;
                background: #1a1a2e;
                color: #ffffff;
                padding: 8px 12px;
                border-radius: 6px;
                font-size: 12px;
                z-index: 10000;
                opacity: 0;
                visibility: hidden;
                transition: all 0.15s ease;
                pointer-events: none;
                white-space: nowrap;
            }

            .tooltip.active {
                opacity: 1;
                visibility: visible;
            }

            /* Progress Styles */
            .progress {
                width: 100%;
            }

            .progress-label {
                display: block;
                margin-bottom: 8px;
                color: #ffffff;
                font-size: 14px;
                font-weight: 500;
            }

            .progress-track {
                position: relative;
                height: 8px;
                background: #2a2a4a;
                border-radius: 4px;
                overflow: hidden;
            }

            .progress-fill {
                height: 100%;
                background: #e94560;
                border-radius: 4px;
                transition: width 0.3s ease;
            }

            .progress-value {
                margin-top: 4px;
                color: #b0b0b0;
                font-size: 12px;
                text-align: right;
            }

            /* Card Styles */
            .card {
                background: #1e1e3f;
                border: 1px solid #2a2a4a;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

            .card-header {
                padding: 20px;
                background: #16213e;
                border-bottom: 1px solid #2a2a4a;
                font-weight: 600;
                color: #ffffff;
            }

            .card-body {
                padding: 20px;
                color: #b0b0b0;
            }

            .card-footer {
                padding: 20px;
                background: #16213e;
                border-top: 1px solid #2a2a4a;
            }

            /* Badge Styles */
            .badge {
                display: inline-flex;
                align-items: center;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: 500;
                text-transform: uppercase;
            }

            .badge.default {
                background: #2a2a4a;
                color: #ffffff;
            }

            .badge.success {
                background: #4CAF50;
                color: #ffffff;
            }

            .badge.warning {
                background: #FF9800;
                color: #ffffff;
            }

            .badge.error {
                background: #F44336;
                color: #ffffff;
            }

            .badge.info {
                background: #2196F3;
                color: #ffffff;
            }

            /* Alert Styles */
            .alert {
                padding: 16px;
                border-radius: 8px;
                margin-bottom: 16px;
                border: 1px solid;
            }

            .alert.info {
                background: rgba(33, 150, 243, 0.1);
                border-color: #2196F3;
                color: #2196F3;
            }

            .alert.success {
                background: rgba(76, 175, 80, 0.1);
                border-color: #4CAF50;
                color: #4CAF50;
            }

            .alert.warning {
                background: rgba(255, 152, 0, 0.1);
                border-color: #FF9800;
                color: #FF9800;
            }

            .alert.error {
                background: rgba(244, 67, 54, 0.1);
                border-color: #F44336;
                color: #F44336;
            }

            .alert-content {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .alert-icon {
                font-size: 16px;
            }

            .alert-message {
                flex: 1;
                font-size: 14px;
            }

            .alert-close {
                background: none;
                border: none;
                color: inherit;
                cursor: pointer;
                font-size: 18px;
                padding: 4px;
                border-radius: 4px;
                transition: background 0.15s ease;
            }

            .alert-close:hover {
                background: rgba(255, 255, 255, 0.1);
            }

            .alert.dismissed {
                opacity: 0;
                transform: translateX(100%);
                transition: all 0.3s ease;
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .modal-content {
                    width: 95%;
                    margin: 20px;
                }

                .dropdown-menu {
                    position: fixed;
                    top: auto;
                    left: 20px;
                    right: 20px;
                    bottom: 20px;
                    max-height: 50vh;
                    overflow-y: auto;
                }

                .tab-buttons {
                    flex-wrap: wrap;
                }

                .tab-button {
                    flex: 1;
                    min-width: 0;
                }
            }
        `;
        document.head.appendChild(style);
    }
}

// Create global components instance
const noraComponents = new NoraComponents();

// Export for use in other modules
window.noraComponents = noraComponents;