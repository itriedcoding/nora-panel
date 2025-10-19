// Nora Panel - API Communication JavaScript
class NoraAPI {
    constructor() {
        this.baseURL = 'http://localhost:3000/api';
        this.timeout = 10000;
        this.retries = 3;
        this.authToken = null;
    }

    // Authentication methods
    async login(username, password) {
        try {
            const response = await this.request('POST', '/auth/login', {
                username,
                password
            });

            if (response.success) {
                this.authToken = response.token;
                localStorage.setItem('noraAuthToken', response.token);
                return response;
            } else {
                throw new Error(response.error || 'Login failed');
            }
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    }

    async logout() {
        try {
            await this.request('POST', '/auth/logout');
            this.authToken = null;
            localStorage.removeItem('noraAuthToken');
        } catch (error) {
            console.error('Logout error:', error);
        }
    }

    async validateToken() {
        try {
            const response = await this.request('POST', '/auth/validate');
            return response.valid;
        } catch (error) {
            console.error('Token validation error:', error);
            return false;
        }
    }

    // Player methods
    async getPlayers() {
        return await this.request('GET', '/players');
    }

    async getOnlinePlayers() {
        return await this.request('GET', '/players/online');
    }

    async getPlayer(id) {
        return await this.request('GET', `/players/${id}`);
    }

    async banPlayer(id, reason, duration, permanent) {
        return await this.request('POST', `/players/${id}/ban`, {
            reason,
            duration,
            permanent
        });
    }

    async kickPlayer(id, reason) {
        return await this.request('POST', `/players/${id}/kick`, {
            reason
        });
    }

    async healPlayer(id) {
        return await this.request('POST', `/players/${id}/heal`);
    }

    async revivePlayer(id) {
        return await this.request('POST', `/players/${id}/revive`);
    }

    async freezePlayer(id, freeze) {
        return await this.request('POST', `/players/${id}/freeze`, {
            freeze
        });
    }

    async teleportPlayer(id, coords, heading) {
        return await this.request('POST', `/players/${id}/teleport`, {
            coords,
            heading
        });
    }

    async spectatePlayer(id) {
        return await this.request('POST', `/players/${id}/spectate`);
    }

    // Ban methods
    async getBans() {
        return await this.request('GET', '/bans');
    }

    async unbanPlayer(id) {
        return await this.request('DELETE', `/bans/${id}`);
    }

    async getBanStats() {
        return await this.request('GET', '/bans/stats');
    }

    // Kick methods
    async getKicks() {
        return await this.request('GET', '/kicks');
    }

    async getKickStats() {
        return await this.request('GET', '/kicks/stats');
    }

    // Log methods
    async getLogs(limit = 100, offset = 0) {
        return await this.request('GET', '/logs', {
            limit,
            offset
        });
    }

    async searchLogs(query, limit = 100, offset = 0) {
        return await this.request('POST', '/logs/search', {
            query,
            limit,
            offset
        });
    }

    async getLogStats() {
        return await this.request('GET', '/logs/stats');
    }

    // Server stats methods
    async getStats() {
        return await this.request('GET', '/stats');
    }

    async getPerformanceStats() {
        return await this.request('GET', '/stats/performance');
    }

    async getSecurityStats() {
        return await this.request('GET', '/stats/security');
    }

    // Vehicle methods
    async getVehicles() {
        return await this.request('GET', '/vehicles');
    }

    async spawnVehicle(playerId, model, coords, heading) {
        return await this.request('POST', '/vehicles/spawn', {
            playerId,
            model,
            coords,
            heading
        });
    }

    async deleteVehicle(id, playerId) {
        return await this.request('DELETE', `/vehicles/${id}`, {
            playerId
        });
    }

    async repairVehicle(id, playerId) {
        return await this.request('POST', `/vehicles/${id}/repair`, {
            playerId
        });
    }

    // Weapon methods
    async getWeapons() {
        return await this.request('GET', '/weapons');
    }

    async giveWeapon(playerId, weaponHash, ammo) {
        return await this.request('POST', '/weapons/give', {
            playerId,
            weaponHash,
            ammo
        });
    }

    async removeWeapon(playerId, weaponHash) {
        return await this.request('POST', '/weapons/remove', {
            playerId,
            weaponHash
        });
    }

    // Weather methods
    async getWeather() {
        return await this.request('GET', '/weather');
    }

    async setWeather(weatherType, transition, playerId) {
        return await this.request('POST', '/weather/set', {
            weatherType,
            transition,
            playerId
        });
    }

    async getWeatherPresets() {
        return await this.request('GET', '/weather/presets');
    }

    // Economy methods
    async getEconomyStats() {
        return await this.request('GET', '/economy/stats');
    }

    async giveMoney(playerId, amount, account) {
        return await this.request('POST', '/economy/give', {
            playerId,
            amount,
            account
        });
    }

    async removeMoney(playerId, amount, account) {
        return await this.request('POST', '/economy/remove', {
            playerId,
            amount,
            account
        });
    }

    // Announcement methods
    async getAnnouncements() {
        return await this.request('GET', '/announcements');
    }

    async createAnnouncement(title, message, type, target, expiresAt) {
        return await this.request('POST', '/announcements/create', {
            title,
            message,
            type,
            target,
            expiresAt
        });
    }

    async deleteAnnouncement(id) {
        return await this.request('DELETE', `/announcements/${id}/delete`);
    }

    // Backup methods
    async getBackups() {
        return await this.request('GET', '/backups');
    }

    async createBackup(name, includeDatabase, includeLogs, includeConfig) {
        return await this.request('POST', '/backups/create', {
            name,
            includeDatabase,
            includeLogs,
            includeConfig
        });
    }

    async restoreBackup(id) {
        return await this.request('POST', `/backups/${id}/restore`);
    }

    async deleteBackup(id) {
        return await this.request('DELETE', `/backups/${id}/delete`);
    }

    // Generic request method
    async request(method, endpoint, data = null) {
        const url = `${this.baseURL}${endpoint}`;
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            timeout: this.timeout
        };

        // Add authentication token if available
        if (this.authToken) {
            options.headers['Authorization'] = `Bearer ${this.authToken}`;
        }

        // Add data for POST/PUT requests
        if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
            options.body = JSON.stringify(data);
        }

        // Add query parameters for GET requests
        if (data && method === 'GET') {
            const params = new URLSearchParams(data);
            const urlWithParams = `${url}?${params}`;
            return await this.makeRequest(urlWithParams, options);
        }

        return await this.makeRequest(url, options);
    }

    async makeRequest(url, options) {
        let lastError;
        
        for (let attempt = 0; attempt < this.retries; attempt++) {
            try {
                const controller = new AbortController();
                const timeoutId = setTimeout(() => controller.abort(), this.timeout);
                
                options.signal = controller.signal;
                
                const response = await fetch(url, options);
                clearTimeout(timeoutId);
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                const result = await response.json();
                return result;
            } catch (error) {
                lastError = error;
                
                if (attempt < this.retries - 1) {
                    // Wait before retrying (exponential backoff)
                    await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
                }
            }
        }
        
        throw lastError;
    }

    // Utility methods
    setBaseURL(url) {
        this.baseURL = url;
    }

    setTimeout(timeout) {
        this.timeout = timeout;
    }

    setRetries(retries) {
        this.retries = retries;
    }

    // Error handling
    handleError(error) {
        console.error('API Error:', error);
        
        if (error.name === 'AbortError') {
            throw new Error('Request timeout');
        }
        
        if (error.message.includes('HTTP 401')) {
            this.authToken = null;
            localStorage.removeItem('noraAuthToken');
            throw new Error('Authentication required');
        }
        
        if (error.message.includes('HTTP 403')) {
            throw new Error('Access denied');
        }
        
        if (error.message.includes('HTTP 404')) {
            throw new Error('Resource not found');
        }
        
        if (error.message.includes('HTTP 500')) {
            throw new Error('Server error');
        }
        
        throw error;
    }

    // Connection status
    async checkConnection() {
        try {
            await this.request('GET', '/stats');
            return true;
        } catch (error) {
            return false;
        }
    }

    // Rate limiting
    async rateLimitedRequest(method, endpoint, data = null) {
        // Simple rate limiting implementation
        const now = Date.now();
        const key = `${method}:${endpoint}`;
        
        if (!this.rateLimit) {
            this.rateLimit = {};
        }
        
        if (this.rateLimit[key] && now - this.rateLimit[key] < 1000) {
            await new Promise(resolve => setTimeout(resolve, 1000 - (now - this.rateLimit[key])));
        }
        
        this.rateLimit[key] = now;
        return await this.request(method, endpoint, data);
    }

    // Batch requests
    async batchRequest(requests) {
        const promises = requests.map(req => this.request(req.method, req.endpoint, req.data));
        return await Promise.allSettled(promises);
    }

    // Caching
    setCache(key, data, ttl = 300000) { // 5 minutes default TTL
        const item = {
            data,
            timestamp: Date.now(),
            ttl
        };
        localStorage.setItem(`nora_cache_${key}`, JSON.stringify(item));
    }

    getCache(key) {
        try {
            const item = JSON.parse(localStorage.getItem(`nora_cache_${key}`));
            if (item && Date.now() - item.timestamp < item.ttl) {
                return item.data;
            }
            return null;
        } catch (error) {
            return null;
        }
    }

    clearCache() {
        const keys = Object.keys(localStorage);
        keys.forEach(key => {
            if (key.startsWith('nora_cache_')) {
                localStorage.removeItem(key);
            }
        });
    }

    // Cached request
    async cachedRequest(method, endpoint, data = null, ttl = 300000) {
        const cacheKey = `${method}:${endpoint}:${JSON.stringify(data)}`;
        const cached = this.getCache(cacheKey);
        
        if (cached) {
            return cached;
        }
        
        try {
            const result = await this.request(method, endpoint, data);
            this.setCache(cacheKey, result, ttl);
            return result;
        } catch (error) {
            throw error;
        }
    }
}

// Create global API instance
const noraAPI = new NoraAPI();

// Auto-load auth token from localStorage
const savedToken = localStorage.getItem('noraAuthToken');
if (savedToken) {
    noraAPI.authToken = savedToken;
}

// Export for use in other modules
window.noraAPI = noraAPI;