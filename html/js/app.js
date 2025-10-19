// Nora Panel - Main Application JavaScript
class NoraPanel {
    constructor() {
        this.isOpen = false;
        this.currentPage = 'dashboard';
        this.notifications = [];
        this.players = [];
        this.vehicles = [];
        this.weapons = [];
        this.logs = [];
        this.backups = [];
        this.settings = this.loadSettings();
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadData();
        this.startAutoRefresh();
        this.hideLoadingScreen();
    }

    setupEventListeners() {
        // Panel toggle
        document.getElementById('closePanel').addEventListener('click', () => {
            this.closePanel();
        });

        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const page = item.dataset.page;
                this.navigateToPage(page);
            });
        });

        // Quick actions
        document.getElementById('quickHeal').addEventListener('click', () => {
            this.quickHeal();
        });

        document.getElementById('quickRevive').addEventListener('click', () => {
            this.quickRevive();
        });

        document.getElementById('quickWeather').addEventListener('click', () => {
            this.quickWeather();
        });

        document.getElementById('quickAnnounce').addEventListener('click', () => {
            this.quickAnnounce();
        });

        // Player search
        document.getElementById('playerSearch').addEventListener('input', (e) => {
            this.filterPlayers(e.target.value);
        });

        // Player filters
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.setPlayerFilter(e.target.dataset.filter);
            });
        });

        // Vehicle controls
        document.getElementById('spawnVehicle').addEventListener('click', () => {
            this.spawnVehicle();
        });

        // Weapon controls
        document.getElementById('giveWeapon').addEventListener('click', () => {
            this.giveWeapon();
        });

        // Teleport controls
        document.getElementById('teleportPlayer').addEventListener('click', () => {
            this.teleportPlayer();
        });

        // Weather controls
        document.getElementById('setWeather').addEventListener('click', () => {
            this.setWeather();
        });

        // Economy controls
        document.getElementById('giveMoney').addEventListener('click', () => {
            this.giveMoney();
        });

        // Announcement controls
        document.getElementById('sendAnnouncement').addEventListener('click', () => {
            this.sendAnnouncement();
        });

        // Backup controls
        document.getElementById('createBackup').addEventListener('click', () => {
            this.createBackup();
        });

        // Log search
        document.getElementById('logSearch').addEventListener('input', (e) => {
            this.searchLogs(e.target.value);
        });

        // Log filters
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.setLogFilter(e.target.dataset.filter);
            });
        });

        // Settings
        document.getElementById('panelTheme').addEventListener('change', (e) => {
            this.setTheme(e.target.value);
        });

        document.getElementById('autoRefresh').addEventListener('change', (e) => {
            this.setAutoRefresh(e.target.checked);
        });

        document.getElementById('enableNotifications').addEventListener('change', (e) => {
            this.setNotifications(e.target.checked);
        });

        document.getElementById('notificationPosition').addEventListener('change', (e) => {
            this.setNotificationPosition(e.target.value);
        });

        document.getElementById('updateInterval').addEventListener('change', (e) => {
            this.setUpdateInterval(parseInt(e.target.value));
        });

        document.getElementById('enableCharts').addEventListener('change', (e) => {
            this.setCharts(e.target.checked);
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            this.handleKeyboardShortcuts(e);
        });

        // NUI callbacks
        window.addEventListener('message', (e) => {
            this.handleNUIMessage(e.data);
        });
    }

    handleKeyboardShortcuts(e) {
        if (e.ctrlKey || e.metaKey) {
            switch (e.key) {
                case '1':
                    e.preventDefault();
                    this.navigateToPage('dashboard');
                    break;
                case '2':
                    e.preventDefault();
                    this.navigateToPage('players');
                    break;
                case '3':
                    e.preventDefault();
                    this.navigateToPage('vehicles');
                    break;
                case '4':
                    e.preventDefault();
                    this.navigateToPage('weapons');
                    break;
                case '5':
                    e.preventDefault();
                    this.navigateToPage('teleport');
                    break;
                case '6':
                    e.preventDefault();
                    this.navigateToPage('weather');
                    break;
                case '7':
                    e.preventDefault();
                    this.navigateToPage('economy');
                    break;
                case '8':
                    e.preventDefault();
                    this.navigateToPage('announcements');
                    break;
                case '9':
                    e.preventDefault();
                    this.navigateToPage('logs');
                    break;
                case '0':
                    e.preventDefault();
                    this.navigateToPage('backups');
                    break;
            }
        }

        if (e.key === 'Escape') {
            this.closePanel();
        }
    }

    handleNUIMessage(data) {
        switch (data.type) {
            case 'openPanel':
                this.openPanel();
                break;
            case 'closePanel':
                this.closePanel();
                break;
            case 'notification':
                this.showNotification(data.data);
                break;
            case 'removeNotification':
                this.removeNotification(data.data.id);
                break;
            case 'clearNotifications':
                this.clearNotifications();
                break;
            case 'setNotificationPosition':
                this.setNotificationPosition(data.data.position);
                break;
            case 'setNotificationTheme':
                this.setNotificationTheme(data.data.theme);
                break;
            case 'setNotificationSound':
                this.setNotificationSound(data.data.enabled, data.data.volume);
                break;
        }
    }

    openPanel() {
        this.isOpen = true;
        document.getElementById('mainPanel').classList.remove('hidden');
        this.loadData();
    }

    closePanel() {
        this.isOpen = false;
        document.getElementById('mainPanel').classList.add('hidden');
        this.sendNUIMessage('closePanel', {});
    }

    navigateToPage(page) {
        // Update navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-page="${page}"]`).classList.add('active');

        // Update content
        document.querySelectorAll('.page').forEach(p => {
            p.classList.remove('active');
        });
        document.getElementById(page).classList.add('active');

        this.currentPage = page;
        this.loadPageData(page);
    }

    loadPageData(page) {
        switch (page) {
            case 'dashboard':
                this.loadDashboardData();
                break;
            case 'players':
                this.loadPlayersData();
                break;
            case 'vehicles':
                this.loadVehiclesData();
                break;
            case 'weapons':
                this.loadWeaponsData();
                break;
            case 'teleport':
                this.loadTeleportData();
                break;
            case 'weather':
                this.loadWeatherData();
                break;
            case 'economy':
                this.loadEconomyData();
                break;
            case 'announcements':
                this.loadAnnouncementsData();
                break;
            case 'logs':
                this.loadLogsData();
                break;
            case 'backups':
                this.loadBackupsData();
                break;
            case 'performance':
                this.loadPerformanceData();
                break;
            case 'security':
                this.loadSecurityData();
                break;
            case 'settings':
                this.loadSettingsData();
                break;
        }
    }

    loadData() {
        this.loadDashboardData();
        this.loadPlayersData();
        this.loadVehiclesData();
        this.loadWeaponsData();
        this.loadTeleportData();
        this.loadWeatherData();
        this.loadEconomyData();
        this.loadAnnouncementsData();
        this.loadLogsData();
        this.loadBackupsData();
        this.loadPerformanceData();
        this.loadSecurityData();
    }

    loadDashboardData() {
        // Load dashboard statistics
        this.sendNUIMessage('getPlayerData', {}, (data) => {
            this.updateDashboardStats(data);
        });

        this.sendNUIMessage('getAllPlayers', {}, (data) => {
            this.updatePlayerCount(data.length);
        });

        this.sendNUIMessage('getBanStats', {}, (data) => {
            this.updateBanCount(data.total);
        });

        this.sendNUIMessage('getKickStats', {}, (data) => {
            this.updateKickCount(data.total);
        });

        this.sendNUIMessage('getServerStats', {}, (data) => {
            this.updateServerStats(data);
        });
    }

    loadPlayersData() {
        this.sendNUIMessage('getAllPlayers', {}, (data) => {
            this.players = data;
            this.renderPlayersTable();
        });
    }

    loadVehiclesData() {
        this.sendNUIMessage('getVehicleList', {}, (data) => {
            this.vehicles = data;
            this.populateVehicleSelect();
        });

        this.sendNUIMessage('getNearbyVehicles', {radius: 100}, (data) => {
            this.renderVehiclesList(data);
        });
    }

    loadWeaponsData() {
        this.sendNUIMessage('getWeaponList', {}, (data) => {
            this.weapons = data;
            this.populateWeaponSelect();
        });

        this.sendNUIMessage('getPlayerWeapons', {}, (data) => {
            this.renderWeaponsList(data);
        });
    }

    loadTeleportData() {
        this.sendNUIMessage('getPredefinedLocations', {}, (data) => {
            this.renderPredefinedLocations(data);
        });

        this.sendNUIMessage('getSavedLocations', {}, (data) => {
            this.renderSavedLocations(data);
        });

        this.sendNUIMessage('getAllPlayers', {}, (data) => {
            this.populateTeleportTargets(data);
        });
    }

    loadWeatherData() {
        this.sendNUIMessage('getWeatherTypes', {}, (data) => {
            this.populateWeatherSelect(data);
        });

        this.sendNUIMessage('getWeatherPresets', {}, (data) => {
            this.renderWeatherPresets(data);
        });

        this.sendNUIMessage('getCurrentWeather', {}, (data) => {
            this.updateCurrentWeather(data);
        });
    }

    loadEconomyData() {
        this.sendNUIMessage('getEconomyStats', {}, (data) => {
            this.updateEconomyStats(data);
        });

        this.sendNUIMessage('getAllPlayers', {}, (data) => {
            this.populateEconomyTargets(data);
        });
    }

    loadAnnouncementsData() {
        this.sendNUIMessage('getAllAnnouncements', {}, (data) => {
            this.renderAnnouncements(data);
        });
    }

    loadLogsData() {
        this.sendNUIMessage('getLogs', {limit: 100}, (data) => {
            this.logs = data;
            this.renderLogsTable();
        });
    }

    loadBackupsData() {
        this.sendNUIMessage('getBackups', {}, (data) => {
            this.backups = data;
            this.renderBackupsList();
        });
    }

    loadPerformanceData() {
        this.sendNUIMessage('getPerformanceStats', {}, (data) => {
            this.updatePerformanceMetrics(data);
        });
    }

    loadSecurityData() {
        this.sendNUIMessage('getSecurityStats', {}, (data) => {
            this.updateSecurityStats(data);
        });

        this.sendNUIMessage('getSecurityEvents', {limit: 50}, (data) => {
            this.renderSecurityEvents(data);
        });
    }

    loadSettingsData() {
        // Load current settings
        document.getElementById('panelTheme').value = this.settings.theme || 'dark';
        document.getElementById('autoRefresh').checked = this.settings.autoRefresh !== false;
        document.getElementById('enableNotifications').checked = this.settings.notifications !== false;
        document.getElementById('notificationPosition').value = this.settings.notificationPosition || 'top-right';
        document.getElementById('updateInterval').value = this.settings.updateInterval || 1000;
        document.getElementById('enableCharts').checked = this.settings.charts !== false;
    }

    // Dashboard methods
    updateDashboardStats(data) {
        document.getElementById('totalPlayers').textContent = data.totalPlayers || 0;
        document.getElementById('onlinePlayers').textContent = data.onlinePlayers || 0;
    }

    updatePlayerCount(count) {
        document.getElementById('playerCount').textContent = count;
    }

    updateBanCount(count) {
        document.getElementById('totalBans').textContent = count;
    }

    updateKickCount(count) {
        document.getElementById('totalKicks').textContent = count;
    }

    updateServerStats(data) {
        if (data.fps) {
            document.getElementById('serverFPS').textContent = data.fps;
            document.getElementById('serverFPSValue').textContent = data.fps;
        }
        if (data.ping) {
            document.getElementById('serverPingValue').textContent = data.ping + 'ms';
        }
        if (data.memory) {
            document.getElementById('serverMemoryValue').textContent = data.memory + '%';
        }
    }

    // Player methods
    renderPlayersTable() {
        const tbody = document.getElementById('playersTableBody');
        tbody.innerHTML = '';

        this.players.forEach(player => {
            const row = document.createElement('div');
            row.className = 'table-row';
            row.innerHTML = `
                <div class="table-cell">${player.id}</div>
                <div class="table-cell">${player.name}</div>
                <div class="table-cell">${player.ping || 0}ms</div>
                <div class="table-cell">${player.health || 0}</div>
                <div class="table-cell">${player.armor || 0}</div>
                <div class="table-cell">$${player.money || 0}</div>
                <div class="table-cell">${player.job || 'unemployed'}</div>
                <div class="table-cell">
                    <button class="btn btn-sm btn-primary" onclick="noraPanel.banPlayer(${player.id})">Ban</button>
                    <button class="btn btn-sm btn-warning" onclick="noraPanel.kickPlayer(${player.id})">Kick</button>
                    <button class="btn btn-sm btn-success" onclick="noraPanel.healPlayer(${player.id})">Heal</button>
                </div>
            `;
            tbody.appendChild(row);
        });
    }

    filterPlayers(query) {
        const rows = document.querySelectorAll('.table-row');
        rows.forEach(row => {
            const name = row.querySelector('.table-cell:nth-child(2)').textContent.toLowerCase();
            if (name.includes(query.toLowerCase())) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    setPlayerFilter(filter) {
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-filter="${filter}"]`).classList.add('active');

        // Filter logic would go here
        this.filterPlayers('');
    }

    banPlayer(playerId) {
        const reason = prompt('Enter ban reason:');
        if (reason) {
            this.sendNUIMessage('banPlayer', {playerId, reason});
        }
    }

    kickPlayer(playerId) {
        const reason = prompt('Enter kick reason:');
        if (reason) {
            this.sendNUIMessage('kickPlayer', {playerId, reason});
        }
    }

    healPlayer(playerId) {
        this.sendNUIMessage('healPlayer', {playerId});
    }

    // Vehicle methods
    populateVehicleSelect() {
        const select = document.getElementById('vehicleModel');
        select.innerHTML = '<option value="">Select a vehicle...</option>';
        
        this.vehicles.forEach(vehicle => {
            const option = document.createElement('option');
            option.value = vehicle.model;
            option.textContent = vehicle.name;
            select.appendChild(option);
        });
    }

    renderVehiclesList(vehicles) {
        const container = document.getElementById('vehiclesList');
        container.innerHTML = '';

        vehicles.forEach(vehicle => {
            const item = document.createElement('div');
            item.className = 'vehicle-item';
            item.innerHTML = `
                <div class="vehicle-info">
                    <h4>${vehicle.name}</h4>
                    <p>Distance: ${vehicle.distance.toFixed(2)}m</p>
                    <p>Health: ${vehicle.health}/${vehicle.maxHealth}</p>
                </div>
                <div class="vehicle-actions">
                    <button class="btn btn-sm btn-primary" onclick="noraPanel.teleportToVehicle(${vehicle.id})">Teleport</button>
                    <button class="btn btn-sm btn-warning" onclick="noraPanel.repairVehicle(${vehicle.id})">Repair</button>
                    <button class="btn btn-sm btn-error" onclick="noraPanel.deleteVehicle(${vehicle.id})">Delete</button>
                </div>
            `;
            container.appendChild(item);
        });
    }

    spawnVehicle() {
        const model = document.getElementById('vehicleModel').value;
        const coords = document.getElementById('vehicleCoords').value;
        const heading = document.getElementById('vehicleHeading').value;

        if (!model) {
            this.showNotification('error', 'Error', 'Please select a vehicle model');
            return;
        }

        const coordsArray = coords ? coords.split(',').map(Number) : null;
        const headingValue = heading ? parseFloat(heading) : 0;

        this.sendNUIMessage('spawnVehicle', {
            model: parseInt(model),
            coords: coordsArray,
            heading: headingValue
        });
    }

    teleportToVehicle(vehicleId) {
        this.sendNUIMessage('teleportToVehicle', {vehicleId});
    }

    repairVehicle(vehicleId) {
        this.sendNUIMessage('repairVehicle', {vehicleId});
    }

    deleteVehicle(vehicleId) {
        this.sendNUIMessage('deleteVehicle', {vehicleId});
    }

    // Weapon methods
    populateWeaponSelect() {
        const select = document.getElementById('weaponSelect');
        select.innerHTML = '<option value="">Select a weapon...</option>';
        
        this.weapons.forEach(weapon => {
            const option = document.createElement('option');
            option.value = weapon.hash;
            option.textContent = weapon.name;
            select.appendChild(option);
        });
    }

    renderWeaponsList(weapons) {
        const container = document.getElementById('weaponsList');
        container.innerHTML = '';

        weapons.forEach(weapon => {
            const item = document.createElement('div');
            item.className = 'weapon-item';
            item.innerHTML = `
                <div class="weapon-info">
                    <h4>${weapon.name}</h4>
                    <p>Ammo: ${weapon.ammo}/${weapon.maxAmmo}</p>
                </div>
                <div class="weapon-actions">
                    <button class="btn btn-sm btn-warning" onclick="noraPanel.removeWeapon(${weapon.hash})">Remove</button>
                    <button class="btn btn-sm btn-primary" onclick="noraPanel.setWeaponAmmo(${weapon.hash})">Set Ammo</button>
                </div>
            `;
            container.appendChild(item);
        });
    }

    giveWeapon() {
        const weaponHash = document.getElementById('weaponSelect').value;
        const ammo = document.getElementById('weaponAmmo').value;

        if (!weaponHash) {
            this.showNotification('error', 'Error', 'Please select a weapon');
            return;
        }

        this.sendNUIMessage('giveWeapon', {
            weaponHash: parseInt(weaponHash),
            ammo: parseInt(ammo) || 250
        });
    }

    removeWeapon(weaponHash) {
        this.sendNUIMessage('removeWeapon', {weaponHash: parseInt(weaponHash)});
    }

    setWeaponAmmo(weaponHash) {
        const ammo = prompt('Enter ammo amount:');
        if (ammo) {
            this.sendNUIMessage('setWeaponAmmo', {
                weaponHash: parseInt(weaponHash),
                ammo: parseInt(ammo)
            });
        }
    }

    // Teleport methods
    renderPredefinedLocations(locations) {
        const container = document.getElementById('predefinedLocations');
        container.innerHTML = '';

        locations.forEach(location => {
            const item = document.createElement('div');
            item.className = 'location-item';
            item.innerHTML = `
                <div class="location-name">${location.name}</div>
                <div class="location-coords">${location.coords.x}, ${location.coords.y}, ${location.coords.z}</div>
                <button class="btn btn-sm btn-primary" onclick="noraPanel.teleportToLocation('${location.name}')">Teleport</button>
            `;
            container.appendChild(item);
        });
    }

    renderSavedLocations(locations) {
        const container = document.getElementById('savedLocations');
        container.innerHTML = '';

        locations.forEach(location => {
            const item = document.createElement('div');
            item.className = 'location-item';
            item.innerHTML = `
                <div class="location-name">${location.name}</div>
                <div class="location-coords">${location.coords.x}, ${location.coords.y}, ${location.coords.z}</div>
                <div class="location-actions">
                    <button class="btn btn-sm btn-primary" onclick="noraPanel.teleportToLocation('${location.name}')">Teleport</button>
                    <button class="btn btn-sm btn-error" onclick="noraPanel.deleteLocation('${location.name}')">Delete</button>
                </div>
            `;
            container.appendChild(item);
        });
    }

    populateTeleportTargets(players) {
        const select = document.getElementById('teleportTarget');
        select.innerHTML = '<option value="">Select a player...</option>';
        
        players.forEach(player => {
            const option = document.createElement('option');
            option.value = player.id;
            option.textContent = player.name;
            select.appendChild(option);
        });
    }

    teleportToLocation(locationName) {
        this.sendNUIMessage('teleportToLocation', {locationName});
    }

    deleteLocation(locationName) {
        if (confirm('Are you sure you want to delete this location?')) {
            this.sendNUIMessage('deleteLocation', {locationName});
        }
    }

    teleportPlayer() {
        const targetId = document.getElementById('teleportTarget').value;
        const destination = document.getElementById('teleportDestination').value;

        if (!targetId) {
            this.showNotification('error', 'Error', 'Please select a target player');
            return;
        }

        this.sendNUIMessage('teleportPlayer', {
            targetId: parseInt(targetId),
            destination: destination
        });
    }

    // Weather methods
    populateWeatherSelect(weatherTypes) {
        const select = document.getElementById('weatherType');
        select.innerHTML = '<option value="">Select weather...</option>';
        
        weatherTypes.forEach(weather => {
            const option = document.createElement('option');
            option.value = weather;
            option.textContent = weather;
            select.appendChild(option);
        });
    }

    renderWeatherPresets(presets) {
        const container = document.getElementById('weatherPresets');
        container.innerHTML = '';

        presets.forEach(preset => {
            const item = document.createElement('div');
            item.className = 'preset-btn';
            item.innerHTML = `
                <i class="fas fa-cloud-sun"></i>
                <span>${preset.displayName}</span>
            `;
            item.addEventListener('click', () => {
                this.setWeatherPreset(preset.name);
            });
            container.appendChild(item);
        });
    }

    updateCurrentWeather(data) {
        // Update current weather display
        if (data.weather) {
            document.getElementById('weatherType').value = data.weather;
        }
        if (data.time) {
            const timeString = `${data.time.hour.toString().padStart(2, '0')}:${data.time.minute.toString().padStart(2, '0')}`;
            document.getElementById('timeInput').value = timeString;
        }
    }

    setWeather() {
        const weatherType = document.getElementById('weatherType').value;
        const time = document.getElementById('timeInput').value;
        const windSpeed = document.getElementById('windSpeed').value;

        if (!weatherType) {
            this.showNotification('error', 'Error', 'Please select a weather type');
            return;
        }

        const timeArray = time ? time.split(':').map(Number) : null;

        this.sendNUIMessage('setWeather', {
            weatherType,
            time: timeArray,
            windSpeed: parseFloat(windSpeed)
        });
    }

    setWeatherPreset(presetName) {
        this.sendNUIMessage('setWeatherPreset', {presetName});
    }

    // Economy methods
    updateEconomyStats(data) {
        document.getElementById('totalCash').textContent = this.formatMoney(data.totalCash);
        document.getElementById('totalBank').textContent = this.formatMoney(data.totalBank);
        document.getElementById('totalDirty').textContent = this.formatMoney(data.totalDirty);
    }

    populateEconomyTargets(players) {
        const select = document.getElementById('economyTarget');
        select.innerHTML = '<option value="">Select a player...</option>';
        
        players.forEach(player => {
            const option = document.createElement('option');
            option.value = player.id;
            option.textContent = player.name;
            select.appendChild(option);
        });
    }

    giveMoney() {
        const targetId = document.getElementById('economyTarget').value;
        const amount = document.getElementById('economyAmount').value;
        const account = document.getElementById('economyAccount').value;

        if (!targetId || !amount) {
            this.showNotification('error', 'Error', 'Please fill in all fields');
            return;
        }

        this.sendNUIMessage('giveMoney', {
            targetId: parseInt(targetId),
            amount: parseInt(amount),
            account
        });
    }

    // Announcement methods
    renderAnnouncements(announcements) {
        const container = document.getElementById('announcementsList');
        container.innerHTML = '';

        announcements.forEach(announcement => {
            const item = document.createElement('div');
            item.className = 'announcement-item';
            item.innerHTML = `
                <div class="announcement-header">
                    <div class="announcement-title">${announcement.title}</div>
                    <div class="announcement-type ${announcement.type}">${announcement.type}</div>
                </div>
                <div class="announcement-message">${announcement.message}</div>
                <div class="announcement-meta">
                    <span>Target: ${announcement.target}</span>
                    <span>Created: ${new Date(announcement.created_at).toLocaleString()}</span>
                </div>
            `;
            container.appendChild(item);
        });
    }

    sendAnnouncement() {
        const title = document.getElementById('announcementTitle').value;
        const message = document.getElementById('announcementMessage').value;
        const type = document.getElementById('announcementType').value;
        const target = document.getElementById('announcementTarget').value;

        if (!title || !message) {
            this.showNotification('error', 'Error', 'Please fill in all required fields');
            return;
        }

        this.sendNUIMessage('sendAnnouncement', {
            title,
            message,
            type,
            target
        });
    }

    // Log methods
    renderLogsTable() {
        const tbody = document.getElementById('logsTableBody');
        tbody.innerHTML = '';

        this.logs.forEach(log => {
            const row = document.createElement('div');
            row.className = 'table-row';
            row.innerHTML = `
                <div class="table-cell">${new Date(log.created_at).toLocaleString()}</div>
                <div class="table-cell">${log.type}</div>
                <div class="table-cell">${log.action}</div>
                <div class="table-cell">${log.player_name || 'N/A'}</div>
                <div class="table-cell">${log.admin_name || 'N/A'}</div>
                <div class="table-cell">${log.details || 'N/A'}</div>
            `;
            tbody.appendChild(row);
        });
    }

    searchLogs(query) {
        const rows = document.querySelectorAll('.table-row');
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(query.toLowerCase())) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    setLogFilter(filter) {
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-filter="${filter}"]`).classList.add('active');

        // Filter logic would go here
        this.searchLogs('');
    }

    // Backup methods
    renderBackupsList() {
        const container = document.getElementById('backupsList');
        container.innerHTML = '';

        this.backups.forEach(backup => {
            const item = document.createElement('div');
            item.className = 'backup-item';
            item.innerHTML = `
                <div class="backup-info">
                    <div class="backup-name">${backup.name}</div>
                    <div class="backup-details">
                        <span>Size: ${backup.formatted_size}</span>
                        <span>Created: ${new Date(backup.created_at).toLocaleString()}</span>
                    </div>
                </div>
                <div class="backup-actions">
                    <button class="btn btn-sm btn-primary" onclick="noraPanel.restoreBackup('${backup.name}')">Restore</button>
                    <button class="btn btn-sm btn-error" onclick="noraPanel.deleteBackup('${backup.name}')">Delete</button>
                </div>
            `;
            container.appendChild(item);
        });
    }

    createBackup() {
        const name = document.getElementById('backupName').value;
        const includeDatabase = document.getElementById('includeDatabase').checked;
        const includeLogs = document.getElementById('includeLogs').checked;
        const includeConfig = document.getElementById('includeConfig').checked;

        if (!name) {
            this.showNotification('error', 'Error', 'Please enter a backup name');
            return;
        }

        this.sendNUIMessage('createBackup', {
            name,
            includeDatabase,
            includeLogs,
            includeConfig
        });
    }

    restoreBackup(backupName) {
        if (confirm('Are you sure you want to restore this backup?')) {
            this.sendNUIMessage('restoreBackup', {backupName});
        }
    }

    deleteBackup(backupName) {
        if (confirm('Are you sure you want to delete this backup?')) {
            this.sendNUIMessage('deleteBackup', {backupName});
        }
    }

    // Performance methods
    updatePerformanceMetrics(data) {
        if (data.averageFPS) {
            document.getElementById('fpsValue').textContent = data.averageFPS.toFixed(1);
        }
        if (data.averagePing) {
            document.getElementById('pingValue').textContent = data.averagePing.toFixed(0) + 'ms';
        }
        if (data.averageMemory) {
            document.getElementById('memoryValue').textContent = data.averageMemory.toFixed(1) + '%';
        }
        if (data.averageCPU) {
            document.getElementById('cpuValue').textContent = data.averageCPU.toFixed(1) + '%';
        }
    }

    // Security methods
    updateSecurityStats(data) {
        document.getElementById('securityEvents').textContent = data.total || 0;
        document.getElementById('threatsBlocked').textContent = data.unresolved || 0;
        document.getElementById('suspiciousPlayers').textContent = data.byType?.suspicious_behavior || 0;
    }

    renderSecurityEvents(events) {
        const container = document.getElementById('securityEventsList');
        container.innerHTML = '';

        events.forEach(event => {
            const item = document.createElement('div');
            item.className = 'security-event';
            item.innerHTML = `
                <div class="security-event-icon ${event.severity}">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <div class="security-event-content">
                    <div class="security-event-title">${event.event_type}</div>
                    <div class="security-event-description">${event.details}</div>
                    <div class="security-event-time">${new Date(event.created_at).toLocaleString()}</div>
                </div>
            `;
            container.appendChild(item);
        });
    }

    // Quick actions
    quickHeal() {
        this.sendNUIMessage('healAllPlayers');
    }

    quickRevive() {
        this.sendNUIMessage('reviveAllPlayers');
    }

    quickWeather() {
        this.sendNUIMessage('setWeather', {weatherType: 'CLEAR'});
    }

    quickAnnounce() {
        const message = prompt('Enter announcement message:');
        if (message) {
            this.sendNUIMessage('sendQuickAnnouncement', {message});
        }
    }

    // Settings methods
    setTheme(theme) {
        this.settings.theme = theme;
        this.saveSettings();
        document.body.className = theme;
    }

    setAutoRefresh(enabled) {
        this.settings.autoRefresh = enabled;
        this.saveSettings();
    }

    setNotifications(enabled) {
        this.settings.notifications = enabled;
        this.saveSettings();
    }

    setNotificationPosition(position) {
        this.settings.notificationPosition = position;
        this.saveSettings();
        this.sendNUIMessage('setNotificationPosition', {position});
    }

    setUpdateInterval(interval) {
        this.settings.updateInterval = interval;
        this.saveSettings();
    }

    setCharts(enabled) {
        this.settings.charts = enabled;
        this.saveSettings();
    }

    loadSettings() {
        const defaultSettings = {
            theme: 'dark',
            autoRefresh: true,
            notifications: true,
            notificationPosition: 'top-right',
            updateInterval: 1000,
            charts: true
        };

        try {
            const saved = localStorage.getItem('noraPanelSettings');
            return saved ? {...defaultSettings, ...JSON.parse(saved)} : defaultSettings;
        } catch (e) {
            return defaultSettings;
        }
    }

    saveSettings() {
        try {
            localStorage.setItem('noraPanelSettings', JSON.stringify(this.settings));
        } catch (e) {
            console.error('Failed to save settings:', e);
        }
    }

    // Notification methods
    showNotification(type, title, message, duration = 5000) {
        const notification = {
            id: Date.now(),
            type,
            title,
            message,
            duration,
            timestamp: Date.now()
        };

        this.notifications.push(notification);
        this.renderNotification(notification);

        if (duration > 0) {
            setTimeout(() => {
                this.removeNotification(notification.id);
            }, duration);
        }
    }

    removeNotification(id) {
        this.notifications = this.notifications.filter(n => n.id !== id);
        const element = document.getElementById(`notification-${id}`);
        if (element) {
            element.remove();
        }
    }

    clearNotifications() {
        this.notifications = [];
        document.getElementById('notificationContainer').innerHTML = '';
    }

    renderNotification(notification) {
        const container = document.getElementById('notificationContainer');
        const element = document.createElement('div');
        element.id = `notification-${notification.id}`;
        element.className = `notification ${notification.type}`;
        element.innerHTML = `
            <div class="notification-header">
                <div class="notification-title">${notification.title}</div>
                <button class="notification-close" onclick="noraPanel.removeNotification(${notification.id})">×</button>
            </div>
            <div class="notification-message">${notification.message}</div>
        `;
        container.appendChild(element);
    }

    // Utility methods
    formatMoney(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount);
    }

    sendNUIMessage(type, data, callback) {
        if (typeof data === 'function') {
            callback = data;
            data = {};
        }

        fetch(`https://${GetParentResourceName()}/${type}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(response => response.json())
        .then(result => {
            if (callback) {
                callback(result);
            }
        })
        .catch(error => {
            console.error('NUI Message Error:', error);
            if (callback) {
                callback(null);
            }
        });
    }

    hideLoadingScreen() {
        setTimeout(() => {
            document.getElementById('loadingScreen').classList.add('hidden');
        }, 2000);
    }

    startAutoRefresh() {
        if (this.settings.autoRefresh) {
            setInterval(() => {
                if (this.isOpen) {
                    this.loadPageData(this.currentPage);
                }
            }, this.settings.updateInterval);
        }
    }
}

// Initialize the application
const noraPanel = new NoraPanel();

// Global functions for inline event handlers
window.noraPanel = noraPanel;