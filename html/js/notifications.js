// Nora Panel - Notification System JavaScript
class NoraNotifications {
    constructor() {
        this.container = document.getElementById('notificationContainer');
        this.notifications = new Map();
        this.settings = {
            position: 'top-right',
            duration: 5000,
            maxNotifications: 5,
            sounds: true,
            animations: true
        };
        
        this.init();
    }

    init() {
        this.loadSettings();
        this.setupEventListeners();
        this.createNotificationStyles();
    }

    setupEventListeners() {
        // Listen for NUI messages
        window.addEventListener('message', (e) => {
            if (e.data.type === 'notification') {
                this.show(e.data.data);
            } else if (e.data.type === 'removeNotification') {
                this.remove(e.data.data.id);
            } else if (e.data.type === 'clearNotifications') {
                this.clear();
            } else if (e.data.type === 'setNotificationPosition') {
                this.setPosition(e.data.data.position);
            } else if (e.data.type === 'setNotificationTheme') {
                this.setTheme(e.data.data.theme);
            } else if (e.data.type === 'setNotificationSound') {
                this.setSound(e.data.data.enabled, e.data.data.volume);
            }
        });
    }

    show(data) {
        const notification = {
            id: data.id || Date.now() + Math.random(),
            type: data.type || 'info',
            title: data.title || 'Notification',
            message: data.message || '',
            duration: data.duration || this.settings.duration,
            timestamp: Date.now(),
            persistent: data.persistent || false,
            actions: data.actions || [],
            icon: data.icon || this.getDefaultIcon(data.type),
            sound: data.sound !== false
        };

        // Remove oldest notification if at max capacity
        if (this.notifications.size >= this.settings.maxNotifications) {
            const oldest = Array.from(this.notifications.values())[0];
            this.remove(oldest.id);
        }

        this.notifications.set(notification.id, notification);
        this.render(notification);

        // Play sound
        if (notification.sound && this.settings.sounds) {
            this.playSound(notification.type);
        }

        // Auto-remove if not persistent
        if (!notification.persistent && notification.duration > 0) {
            setTimeout(() => {
                this.remove(notification.id);
            }, notification.duration);
        }

        return notification.id;
    }

    remove(id) {
        const notification = this.notifications.get(id);
        if (notification) {
            this.notifications.delete(id);
            const element = document.getElementById(`notification-${id}`);
            if (element) {
                if (this.settings.animations) {
                    element.classList.add('notification-exit');
                    setTimeout(() => {
                        element.remove();
                    }, 300);
                } else {
                    element.remove();
                }
            }
        }
    }

    clear() {
        this.notifications.clear();
        this.container.innerHTML = '';
    }

    render(notification) {
        const element = document.createElement('div');
        element.id = `notification-${notification.id}`;
        element.className = `notification ${notification.type}`;
        
        if (this.settings.animations) {
            element.classList.add('notification-enter');
        }

        element.innerHTML = this.createNotificationHTML(notification);
        this.container.appendChild(element);

        // Add click handlers for actions
        if (notification.actions.length > 0) {
            notification.actions.forEach(action => {
                const button = element.querySelector(`[data-action="${action.id}"]`);
                if (button) {
                    button.addEventListener('click', () => {
                        if (action.handler) {
                            action.handler();
                        }
                        if (action.close) {
                            this.remove(notification.id);
                        }
                    });
                }
            });
        }

        // Add close button handler
        const closeButton = element.querySelector('.notification-close');
        if (closeButton) {
            closeButton.addEventListener('click', () => {
                this.remove(notification.id);
            });
        }

        // Add click-to-close for the entire notification
        element.addEventListener('click', (e) => {
            if (e.target === element || e.target.classList.contains('notification-message')) {
                this.remove(notification.id);
            }
        });
    }

    createNotificationHTML(notification) {
        const actionsHTML = notification.actions.map(action => 
            `<button class="notification-action" data-action="${action.id}">${action.label}</button>`
        ).join('');

        return `
            <div class="notification-content">
                <div class="notification-icon">
                    <i class="${notification.icon}"></i>
                </div>
                <div class="notification-body">
                    <div class="notification-header">
                        <div class="notification-title">${notification.title}</div>
                        <button class="notification-close">×</button>
                    </div>
                    <div class="notification-message">${notification.message}</div>
                    ${actionsHTML ? `<div class="notification-actions">${actionsHTML}</div>` : ''}
                </div>
            </div>
            <div class="notification-progress">
                <div class="notification-progress-bar"></div>
            </div>
        `;
    }

    getDefaultIcon(type) {
        const icons = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle',
            loading: 'fas fa-spinner fa-spin',
            progress: 'fas fa-chart-line',
            confirmation: 'fas fa-question-circle',
            input: 'fas fa-edit',
            toast: 'fas fa-bell',
            system: 'fas fa-cog',
            achievement: 'fas fa-trophy',
            announcement: 'fas fa-bullhorn'
        };
        return icons[type] || icons.info;
    }

    playSound(type) {
        const sounds = {
            success: 'success.ogg',
            error: 'error.ogg',
            warning: 'warning.ogg',
            info: 'notification.ogg'
        };

        const soundFile = sounds[type] || sounds.info;
        const audio = new Audio(`assets/sounds/${soundFile}`);
        audio.volume = 0.5;
        audio.play().catch(e => console.log('Could not play notification sound:', e));
    }

    setPosition(position) {
        this.settings.position = position;
        this.container.className = `notification-container ${position}`;
        this.saveSettings();
    }

    setTheme(theme) {
        this.settings.theme = theme;
        document.body.setAttribute('data-theme', theme);
        this.saveSettings();
    }

    setSound(enabled, volume = 0.5) {
        this.settings.sounds = enabled;
        this.settings.volume = volume;
        this.saveSettings();
    }

    setDuration(duration) {
        this.settings.duration = duration;
        this.saveSettings();
    }

    setMaxNotifications(max) {
        this.settings.maxNotifications = max;
        this.saveSettings();
    }

    setAnimations(enabled) {
        this.settings.animations = enabled;
        this.saveSettings();
    }

    // Predefined notification types
    success(title, message, options = {}) {
        return this.show({
            type: 'success',
            title,
            message,
            ...options
        });
    }

    error(title, message, options = {}) {
        return this.show({
            type: 'error',
            title,
            message,
            ...options
        });
    }

    warning(title, message, options = {}) {
        return this.show({
            type: 'warning',
            title,
            message,
            ...options
        });
    }

    info(title, message, options = {}) {
        return this.show({
            type: 'info',
            title,
            message,
            ...options
        });
    }

    loading(title, message, options = {}) {
        return this.show({
            type: 'loading',
            title,
            message,
            persistent: true,
            ...options
        });
    }

    progress(title, message, progress, options = {}) {
        const id = this.show({
            type: 'progress',
            title,
            message,
            progress,
            persistent: true,
            ...options
        });

        // Update progress bar
        const element = document.getElementById(`notification-${id}`);
        if (element) {
            const progressBar = element.querySelector('.notification-progress-bar');
            if (progressBar) {
                progressBar.style.width = `${progress}%`;
            }
        }

        return id;
    }

    confirmation(title, message, onConfirm, onCancel) {
        return this.show({
            type: 'confirmation',
            title,
            message,
            persistent: true,
            actions: [
                {
                    id: 'confirm',
                    label: 'Confirm',
                    handler: onConfirm,
                    close: true
                },
                {
                    id: 'cancel',
                    label: 'Cancel',
                    handler: onCancel,
                    close: true
                }
            ]
        });
    }

    input(title, message, placeholder, onSubmit, onCancel) {
        const id = this.show({
            type: 'input',
            title,
            message,
            persistent: true,
            actions: [
                {
                    id: 'submit',
                    label: 'Submit',
                    handler: () => {
                        const input = document.querySelector(`#notification-${id} .notification-input`);
                        if (input && onSubmit) {
                            onSubmit(input.value);
                        }
                    },
                    close: true
                },
                {
                    id: 'cancel',
                    label: 'Cancel',
                    handler: onCancel,
                    close: true
                }
            ]
        });

        // Add input field
        setTimeout(() => {
            const element = document.getElementById(`notification-${id}`);
            if (element) {
                const messageDiv = element.querySelector('.notification-message');
                const input = document.createElement('input');
                input.type = 'text';
                input.className = 'notification-input';
                input.placeholder = placeholder || 'Enter value...';
                input.addEventListener('keypress', (e) => {
                    if (e.key === 'Enter') {
                        const submitButton = element.querySelector('[data-action="submit"]');
                        if (submitButton) {
                            submitButton.click();
                        }
                    }
                });
                messageDiv.appendChild(input);
                input.focus();
            }
        }, 100);

        return id;
    }

    toast(message, type = 'info', duration = 3000) {
        return this.show({
            type: 'toast',
            title: '',
            message,
            duration,
            icon: 'fas fa-bell'
        });
    }

    system(title, message, options = {}) {
        return this.show({
            type: 'system',
            title,
            message,
            duration: 10000,
            ...options
        });
    }

    achievement(title, message, icon = 'fas fa-trophy') {
        return this.show({
            type: 'achievement',
            title,
            message,
            icon,
            duration: 8000
        });
    }

    announcement(title, message, type = 'info') {
        return this.show({
            type: 'announcement',
            title,
            message,
            duration: 15000,
            icon: 'fas fa-bullhorn'
        });
    }

    // Update progress
    updateProgress(id, progress, message) {
        const notification = this.notifications.get(id);
        if (notification) {
            notification.progress = progress;
            if (message) {
                notification.message = message;
            }

            const element = document.getElementById(`notification-${id}`);
            if (element) {
                const progressBar = element.querySelector('.notification-progress-bar');
                if (progressBar) {
                    progressBar.style.width = `${progress}%`;
                }

                const messageDiv = element.querySelector('.notification-message');
                if (messageDiv && message) {
                    messageDiv.textContent = message;
                }
            }
        }
    }

    // Hide loading notification
    hideLoading(id) {
        this.remove(id);
    }

    // Get notification statistics
    getStats() {
        const stats = {
            total: this.notifications.size,
            byType: {},
            visible: 0,
            hidden: 0
        };

        this.notifications.forEach(notification => {
            if (stats.byType[notification.type]) {
                stats.byType[notification.type]++;
            } else {
                stats.byType[notification.type] = 1;
            }

            if (notification.visible) {
                stats.visible++;
            } else {
                stats.hidden++;
            }
        });

        return stats;
    }

    // Create notification styles
    createNotificationStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .notification-container {
                position: fixed;
                z-index: 10000;
                display: flex;
                flex-direction: column;
                gap: 8px;
                pointer-events: none;
                max-width: 400px;
            }

            .notification-container.top-right {
                top: 20px;
                right: 20px;
            }

            .notification-container.top-left {
                top: 20px;
                left: 20px;
            }

            .notification-container.bottom-right {
                bottom: 20px;
                right: 20px;
                flex-direction: column-reverse;
            }

            .notification-container.bottom-left {
                bottom: 20px;
                left: 20px;
                flex-direction: column-reverse;
            }

            .notification {
                background: #1e1e3f;
                border-radius: 8px;
                border: 1px solid #2a2a4a;
                box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
                min-width: 300px;
                max-width: 400px;
                pointer-events: auto;
                position: relative;
                overflow: hidden;
                animation: slideInRight 0.3s ease;
            }

            .notification::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 4px;
                background: #e94560;
            }

            .notification.success::before {
                background: #4CAF50;
            }

            .notification.error::before {
                background: #F44336;
            }

            .notification.warning::before {
                background: #FF9800;
            }

            .notification.info::before {
                background: #2196F3;
            }

            .notification-content {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                padding: 16px;
            }

            .notification-icon {
                width: 24px;
                height: 24px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                color: #e94560;
                flex-shrink: 0;
            }

            .notification.success .notification-icon {
                color: #4CAF50;
            }

            .notification.error .notification-icon {
                color: #F44336;
            }

            .notification.warning .notification-icon {
                color: #FF9800;
            }

            .notification.info .notification-icon {
                color: #2196F3;
            }

            .notification-body {
                flex: 1;
                min-width: 0;
            }

            .notification-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 4px;
            }

            .notification-title {
                font-weight: 600;
                color: #ffffff;
                font-size: 14px;
                line-height: 1.4;
            }

            .notification-close {
                background: none;
                border: none;
                color: #b0b0b0;
                cursor: pointer;
                font-size: 18px;
                padding: 4px;
                border-radius: 4px;
                transition: all 0.15s ease;
                line-height: 1;
            }

            .notification-close:hover {
                color: #ffffff;
                background: #2a2a4a;
            }

            .notification-message {
                color: #b0b0b0;
                font-size: 13px;
                line-height: 1.4;
                margin-bottom: 8px;
            }

            .notification-actions {
                display: flex;
                gap: 8px;
                margin-top: 8px;
            }

            .notification-action {
                background: #0f3460;
                border: none;
                color: #ffffff;
                padding: 6px 12px;
                border-radius: 4px;
                font-size: 12px;
                cursor: pointer;
                transition: all 0.15s ease;
            }

            .notification-action:hover {
                background: #0a2a4a;
            }

            .notification-input {
                width: 100%;
                padding: 8px;
                background: #2a2a4a;
                border: 1px solid #3a3a5a;
                border-radius: 4px;
                color: #ffffff;
                font-size: 13px;
                margin-top: 8px;
            }

            .notification-input:focus {
                outline: none;
                border-color: #0f3460;
                box-shadow: 0 0 0 2px rgba(15, 52, 96, 0.2);
            }

            .notification-progress {
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                height: 3px;
                background: #2a2a4a;
            }

            .notification-progress-bar {
                height: 100%;
                background: #e94560;
                transition: width 0.3s ease;
            }

            .notification.success .notification-progress-bar {
                background: #4CAF50;
            }

            .notification.error .notification-progress-bar {
                background: #F44336;
            }

            .notification.warning .notification-progress-bar {
                background: #FF9800;
            }

            .notification.info .notification-progress-bar {
                background: #2196F3;
            }

            .notification-enter {
                animation: slideInRight 0.3s ease;
            }

            .notification-exit {
                animation: slideOutRight 0.3s ease;
            }

            @keyframes slideInRight {
                from {
                    opacity: 0;
                    transform: translateX(100%);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            @keyframes slideOutRight {
                from {
                    opacity: 1;
                    transform: translateX(0);
                }
                to {
                    opacity: 0;
                    transform: translateX(100%);
                }
            }

            @media (max-width: 480px) {
                .notification-container {
                    left: 16px;
                    right: 16px;
                    max-width: none;
                }

                .notification {
                    min-width: auto;
                    max-width: none;
                }
            }
        `;
        document.head.appendChild(style);
    }

    loadSettings() {
        try {
            const saved = localStorage.getItem('noraNotificationSettings');
            if (saved) {
                this.settings = {...this.settings, ...JSON.parse(saved)};
            }
        } catch (e) {
            console.error('Failed to load notification settings:', e);
        }
    }

    saveSettings() {
        try {
            localStorage.setItem('noraNotificationSettings', JSON.stringify(this.settings));
        } catch (e) {
            console.error('Failed to save notification settings:', e);
        }
    }
}

// Create global notification instance
const noraNotifications = new NoraNotifications();

// Export for use in other modules
window.noraNotifications = noraNotifications;