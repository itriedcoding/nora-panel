// Nora Panel - Utility Functions JavaScript
class NoraUtils {
    constructor() {
        this.init();
    }

    init() {
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Global event listeners for utility functions
        document.addEventListener('DOMContentLoaded', () => {
            this.initializeTooltips();
            this.initializeCopyButtons();
            this.initializeFormValidation();
        });
    }

    // String utilities
    capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    }

    camelCase(str) {
        return str.replace(/-([a-z])/g, (g) => g[1].toUpperCase());
    }

    kebabCase(str) {
        return str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
    }

    snakeCase(str) {
        return str.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase();
    }

    truncate(str, length, suffix = '...') {
        if (str.length <= length) return str;
        return str.substring(0, length) + suffix;
    }

    slugify(str) {
        return str
            .toLowerCase()
            .replace(/[^\w\s-]/g, '')
            .replace(/[\s_-]+/g, '-')
            .replace(/^-+|-+$/g, '');
    }

    // Number utilities
    formatNumber(num, decimals = 0) {
        return new Intl.NumberFormat('en-US', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        }).format(num);
    }

    formatCurrency(amount, currency = 'USD') {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currency
        }).format(amount);
    }

    formatPercent(value, decimals = 1) {
        return new Intl.NumberFormat('en-US', {
            style: 'percent',
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        }).format(value / 100);
    }

    formatBytes(bytes, decimals = 2) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    random(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    clamp(value, min, max) {
        return Math.min(Math.max(value, min), max);
    }

    // Date utilities
    formatDate(date, format = 'short') {
        const d = new Date(date);
        const options = {
            short: { year: 'numeric', month: 'short', day: 'numeric' },
            long: { year: 'numeric', month: 'long', day: 'numeric' },
            time: { hour: '2-digit', minute: '2-digit' },
            datetime: { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }
        };
        return d.toLocaleDateString('en-US', options[format] || options.short);
    }

    formatRelativeTime(date) {
        const now = new Date();
        const diff = now - new Date(date);
        const seconds = Math.floor(diff / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);

        if (seconds < 60) return 'just now';
        if (minutes < 60) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
        if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
        if (days < 7) return `${days} day${days > 1 ? 's' : ''} ago`;
        return this.formatDate(date);
    }

    isToday(date) {
        const today = new Date();
        const d = new Date(date);
        return d.toDateString() === today.toDateString();
    }

    isYesterday(date) {
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const d = new Date(date);
        return d.toDateString() === yesterday.toDateString();
    }

    // Array utilities
    unique(array) {
        return [...new Set(array)];
    }

    groupBy(array, key) {
        return array.reduce((groups, item) => {
            const group = item[key];
            groups[group] = groups[group] || [];
            groups[group].push(item);
            return groups;
        }, {});
    }

    sortBy(array, key, direction = 'asc') {
        return array.sort((a, b) => {
            const aVal = a[key];
            const bVal = b[key];
            if (direction === 'asc') {
                return aVal > bVal ? 1 : -1;
            } else {
                return aVal < bVal ? 1 : -1;
            }
        });
    }

    chunk(array, size) {
        const chunks = [];
        for (let i = 0; i < array.length; i += size) {
            chunks.push(array.slice(i, i + size));
        }
        return chunks;
    }

    shuffle(array) {
        const shuffled = [...array];
        for (let i = shuffled.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
        }
        return shuffled;
    }

    // Object utilities
    deepClone(obj) {
        if (obj === null || typeof obj !== 'object') return obj;
        if (obj instanceof Date) return new Date(obj.getTime());
        if (obj instanceof Array) return obj.map(item => this.deepClone(item));
        if (typeof obj === 'object') {
            const cloned = {};
            Object.keys(obj).forEach(key => {
                cloned[key] = this.deepClone(obj[key]);
            });
            return cloned;
        }
    }

    merge(target, ...sources) {
        if (!sources.length) return target;
        const source = sources.shift();
        if (this.isObject(target) && this.isObject(source)) {
            Object.keys(source).forEach(key => {
                if (this.isObject(source[key])) {
                    if (!target[key]) Object.assign(target, { [key]: {} });
                    this.merge(target[key], source[key]);
                } else {
                    Object.assign(target, { [key]: source[key] });
                }
            });
        }
        return this.merge(target, ...sources);
    }

    isObject(item) {
        return item && typeof item === 'object' && !Array.isArray(item);
    }

    pick(obj, keys) {
        const result = {};
        keys.forEach(key => {
            if (key in obj) {
                result[key] = obj[key];
            }
        });
        return result;
    }

    omit(obj, keys) {
        const result = { ...obj };
        keys.forEach(key => {
            delete result[key];
        });
        return result;
    }

    // DOM utilities
    $(selector) {
        return document.querySelector(selector);
    }

    $$(selector) {
        return document.querySelectorAll(selector);
    }

    createElement(tag, className, content) {
        const element = document.createElement(tag);
        if (className) element.className = className;
        if (content) element.innerHTML = content;
        return element;
    }

    addClass(element, className) {
        if (element) element.classList.add(className);
    }

    removeClass(element, className) {
        if (element) element.classList.remove(className);
    }

    toggleClass(element, className) {
        if (element) element.classList.toggle(className);
    }

    hasClass(element, className) {
        return element ? element.classList.contains(className) : false;
    }

    getStyle(element, property) {
        return element ? window.getComputedStyle(element)[property] : null;
    }

    setStyle(element, property, value) {
        if (element) element.style[property] = value;
    }

    // Event utilities
    on(element, event, handler) {
        if (element) element.addEventListener(event, handler);
    }

    off(element, event, handler) {
        if (element) element.removeEventListener(event, handler);
    }

    once(element, event, handler) {
        if (element) {
            const onceHandler = (e) => {
                handler(e);
                element.removeEventListener(event, onceHandler);
            };
            element.addEventListener(event, onceHandler);
        }
    }

    emit(element, event, detail) {
        if (element) {
            element.dispatchEvent(new CustomEvent(event, { detail }));
        }
    }

    // Storage utilities
    setStorage(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (e) {
            console.error('Failed to save to localStorage:', e);
            return false;
        }
    }

    getStorage(key, defaultValue = null) {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (e) {
            console.error('Failed to read from localStorage:', e);
            return defaultValue;
        }
    }

    removeStorage(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (e) {
            console.error('Failed to remove from localStorage:', e);
            return false;
        }
    }

    clearStorage() {
        try {
            localStorage.clear();
            return true;
        } catch (e) {
            console.error('Failed to clear localStorage:', e);
            return false;
        }
    }

    // Validation utilities
    isEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }

    isUrl(url) {
        try {
            new URL(url);
            return true;
        } catch (e) {
            return false;
        }
    }

    isPhone(phone) {
        const re = /^[\+]?[1-9][\d]{0,15}$/;
        return re.test(phone.replace(/\s/g, ''));
    }

    isNumeric(value) {
        return !isNaN(parseFloat(value)) && isFinite(value);
    }

    isAlpha(value) {
        const re = /^[a-zA-Z]+$/;
        return re.test(value);
    }

    isAlphaNumeric(value) {
        const re = /^[a-zA-Z0-9]+$/;
        return re.test(value);
    }

    // Form utilities
    serializeForm(form) {
        const formData = new FormData(form);
        const data = {};
        for (let [key, value] of formData.entries()) {
            data[key] = value;
        }
        return data;
    }

    validateForm(form, rules) {
        const errors = {};
        const formData = this.serializeForm(form);

        Object.keys(rules).forEach(field => {
            const value = formData[field];
            const fieldRules = rules[field];

            fieldRules.forEach(rule => {
                if (rule.required && (!value || value.trim() === '')) {
                    errors[field] = rule.message || `${field} is required`;
                    return;
                }

                if (value && rule.type) {
                    if (rule.type === 'email' && !this.isEmail(value)) {
                        errors[field] = rule.message || 'Invalid email format';
                        return;
                    }
                    if (rule.type === 'url' && !this.isUrl(value)) {
                        errors[field] = rule.message || 'Invalid URL format';
                        return;
                    }
                    if (rule.type === 'phone' && !this.isPhone(value)) {
                        errors[field] = rule.message || 'Invalid phone format';
                        return;
                    }
                    if (rule.type === 'numeric' && !this.isNumeric(value)) {
                        errors[field] = rule.message || 'Must be a number';
                        return;
                    }
                }

                if (value && rule.min && value.length < rule.min) {
                    errors[field] = rule.message || `Minimum length is ${rule.min}`;
                    return;
                }

                if (value && rule.max && value.length > rule.max) {
                    errors[field] = rule.message || `Maximum length is ${rule.max}`;
                    return;
                }

                if (value && rule.pattern && !rule.pattern.test(value)) {
                    errors[field] = rule.message || 'Invalid format';
                    return;
                }
            });
        });

        return {
            isValid: Object.keys(errors).length === 0,
            errors
        };
    }

    initializeFormValidation() {
        document.querySelectorAll('form[data-validate]').forEach(form => {
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                const rules = JSON.parse(form.dataset.validate);
                const validation = this.validateForm(form, rules);
                
                if (validation.isValid) {
                    form.submit();
                } else {
                    this.displayFormErrors(form, validation.errors);
                }
            });
        });
    }

    displayFormErrors(form, errors) {
        // Clear previous errors
        form.querySelectorAll('.error-message').forEach(error => error.remove());
        form.querySelectorAll('.error').forEach(field => field.classList.remove('error'));

        // Display new errors
        Object.keys(errors).forEach(field => {
            const fieldElement = form.querySelector(`[name="${field}"]`);
            if (fieldElement) {
                fieldElement.classList.add('error');
                const errorElement = this.createElement('div', 'error-message', errors[field]);
                fieldElement.parentNode.appendChild(errorElement);
            }
        });
    }

    // Copy utilities
    copyToClipboard(text) {
        if (navigator.clipboard) {
            return navigator.clipboard.writeText(text);
        } else {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            const result = document.execCommand('copy');
            document.body.removeChild(textArea);
            return Promise.resolve(result);
        }
    }

    initializeCopyButtons() {
        document.querySelectorAll('[data-copy]').forEach(button => {
            button.addEventListener('click', () => {
                const text = button.dataset.copy;
                this.copyToClipboard(text).then(() => {
                    this.showToast('Copied to clipboard!', 'success');
                }).catch(() => {
                    this.showToast('Failed to copy', 'error');
                });
            });
        });
    }

    // Tooltip utilities
    initializeTooltips() {
        document.querySelectorAll('[data-tooltip]').forEach(element => {
            element.addEventListener('mouseenter', (e) => {
                this.showTooltip(e.target, e.target.dataset.tooltip);
            });
            element.addEventListener('mouseleave', () => {
                this.hideTooltip();
            });
        });
    }

    showTooltip(element, text) {
        this.hideTooltip();
        
        const tooltip = this.createElement('div', 'tooltip', text);
        tooltip.id = 'nora-tooltip';
        document.body.appendChild(tooltip);
        
        const rect = element.getBoundingClientRect();
        const tooltipRect = tooltip.getBoundingClientRect();
        
        let left = rect.left + rect.width / 2 - tooltipRect.width / 2;
        let top = rect.top - tooltipRect.height - 8;
        
        // Adjust if tooltip goes off screen
        if (left < 8) left = 8;
        if (left + tooltipRect.width > window.innerWidth - 8) {
            left = window.innerWidth - tooltipRect.width - 8;
        }
        if (top < 8) {
            top = rect.bottom + 8;
        }
        
        tooltip.style.left = `${left}px`;
        tooltip.style.top = `${top}px`;
        tooltip.classList.add('active');
    }

    hideTooltip() {
        const tooltip = document.getElementById('nora-tooltip');
        if (tooltip) {
            tooltip.remove();
        }
    }

    // Toast utilities
    showToast(message, type = 'info', duration = 3000) {
        const toast = this.createElement('div', `toast toast-${type}`, message);
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.classList.add('active');
        }, 10);
        
        setTimeout(() => {
            toast.classList.remove('active');
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, duration);
    }

    // Debounce utility
    debounce(func, wait, immediate) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                timeout = null;
                if (!immediate) func(...args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func(...args);
        };
    }

    // Throttle utility
    throttle(func, limit) {
        let inThrottle;
        return function executedFunction(...args) {
            if (!inThrottle) {
                func.apply(this, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }

    // Color utilities
    hexToRgb(hex) {
        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }

    rgbToHex(r, g, b) {
        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }

    // Animation utilities
    fadeIn(element, duration = 300) {
        element.style.opacity = '0';
        element.style.display = 'block';
        
        let start = performance.now();
        
        function animate(timestamp) {
            const elapsed = timestamp - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.opacity = progress;
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        }
        
        requestAnimationFrame(animate);
    }

    fadeOut(element, duration = 300) {
        let start = performance.now();
        const initialOpacity = parseFloat(getComputedStyle(element).opacity);
        
        function animate(timestamp) {
            const elapsed = timestamp - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.opacity = initialOpacity * (1 - progress);
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.style.display = 'none';
            }
        }
        
        requestAnimationFrame(animate);
    }

    slideDown(element, duration = 300) {
        element.style.height = '0';
        element.style.overflow = 'hidden';
        element.style.display = 'block';
        
        const targetHeight = element.scrollHeight;
        let start = performance.now();
        
        function animate(timestamp) {
            const elapsed = timestamp - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.height = (targetHeight * progress) + 'px';
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.style.height = 'auto';
                element.style.overflow = 'visible';
            }
        }
        
        requestAnimationFrame(animate);
    }

    slideUp(element, duration = 300) {
        const initialHeight = element.offsetHeight;
        element.style.height = initialHeight + 'px';
        element.style.overflow = 'hidden';
        
        let start = performance.now();
        
        function animate(timestamp) {
            const elapsed = timestamp - start;
            const progress = Math.min(elapsed / duration, 1);
            
            element.style.height = (initialHeight * (1 - progress)) + 'px';
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.style.display = 'none';
                element.style.height = 'auto';
                element.style.overflow = 'visible';
            }
        }
        
        requestAnimationFrame(animate);
    }

    // URL utilities
    getQueryParams() {
        const params = new URLSearchParams(window.location.search);
        const result = {};
        for (let [key, value] of params) {
            result[key] = value;
        }
        return result;
    }

    setQueryParam(key, value) {
        const url = new URL(window.location);
        url.searchParams.set(key, value);
        window.history.pushState({}, '', url);
    }

    removeQueryParam(key) {
        const url = new URL(window.location);
        url.searchParams.delete(key);
        window.history.pushState({}, '', url);
    }

    // Device utilities
    isMobile() {
        return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    }

    isTablet() {
        return /iPad|Android/i.test(navigator.userAgent) && window.innerWidth >= 768;
    }

    isDesktop() {
        return !this.isMobile() && !this.isTablet();
    }

    // Performance utilities
    measurePerformance(name, fn) {
        const start = performance.now();
        const result = fn();
        const end = performance.now();
        console.log(`${name} took ${end - start} milliseconds`);
        return result;
    }

    // Error handling utilities
    handleError(error, context = '') {
        console.error(`Error in ${context}:`, error);
        this.showToast(`Error: ${error.message}`, 'error');
    }

    // Async utilities
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    retry(fn, maxAttempts = 3, delay = 1000) {
        return new Promise((resolve, reject) => {
            let attempts = 0;
            
            function attempt() {
                attempts++;
                fn().then(resolve).catch(error => {
                    if (attempts < maxAttempts) {
                        setTimeout(attempt, delay);
                    } else {
                        reject(error);
                    }
                });
            }
            
            attempt();
        });
    }

    // File utilities
    downloadFile(data, filename, type = 'text/plain') {
        const blob = new Blob([data], { type });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = e => resolve(e.target.result);
            reader.onerror = reject;
            reader.readAsText(file);
        });
    }

    // Math utilities
    lerp(start, end, factor) {
        return start + (end - start) * factor;
    }

    map(value, inMin, inMax, outMin, outMax) {
        return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }

    // Random utilities
    randomId(length = 8) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    randomColor() {
        return '#' + Math.floor(Math.random() * 16777215).toString(16);
    }

    // Time utilities
    formatDuration(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);

        if (days > 0) return `${days}d ${hours % 24}h`;
        if (hours > 0) return `${hours}h ${minutes % 60}m`;
        if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
        return `${seconds}s`;
    }

    // Validation utilities
    isValidJSON(str) {
        try {
            JSON.parse(str);
            return true;
        } catch (e) {
            return false;
        }
    }

    isValidEmail(email) {
        return this.isEmail(email);
    }

    isValidUrl(url) {
        return this.isUrl(url);
    }

    // Search utilities
    searchArray(array, query, fields = []) {
        if (!query) return array;
        
        const lowercaseQuery = query.toLowerCase();
        
        return array.filter(item => {
            if (fields.length === 0) {
                return Object.values(item).some(value => 
                    String(value).toLowerCase().includes(lowercaseQuery)
                );
            }
            
            return fields.some(field => {
                const value = this.getNestedValue(item, field);
                return String(value).toLowerCase().includes(lowercaseQuery);
            });
        });
    }

    getNestedValue(obj, path) {
        return path.split('.').reduce((current, key) => current?.[key], obj);
    }

    // Sort utilities
    sortArray(array, key, direction = 'asc') {
        return array.sort((a, b) => {
            const aVal = this.getNestedValue(a, key);
            const bVal = this.getNestedValue(b, key);
            
            if (direction === 'asc') {
                return aVal > bVal ? 1 : -1;
            } else {
                return aVal < bVal ? 1 : -1;
            }
        });
    }
}

// Create global utils instance
const noraUtils = new NoraUtils();

// Export for use in other modules
window.noraUtils = noraUtils;