# Nora Panel - Installation Guide

This guide will walk you through the complete installation process for Nora Panel on your FiveM server.

## 📋 Prerequisites

Before installing Nora Panel, ensure you have:

- **FiveM Server** (latest version recommended)
- **MySQL Database** (5.7+ or MariaDB 10.2+)
- **ESX Framework** (optional but recommended for full functionality)
- **Admin Access** to your FiveM server
- **Basic Knowledge** of FiveM server management

## 🚀 Quick Installation

### Step 1: Download Nora Panel

1. Download the latest release from our [GitHub Releases](https://github.com/your-repo/nora-panel/releases)
2. Extract the `nora_panel` folder to your server's `resources` directory
3. Ensure the folder structure looks like this:
```
resources/
└── nora_panel/
    ├── fxmanifest.lua
    ├── server/
    ├── client/
    ├── html/
    └── README.md
```

### Step 2: Database Setup

1. **Create Database**:
   ```sql
   CREATE DATABASE nora_panel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. **Create Database User** (optional but recommended):
   ```sql
   CREATE USER 'nora_user'@'localhost' IDENTIFIED BY 'your_secure_password';
   GRANT ALL PRIVILEGES ON nora_panel.* TO 'nora_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Import Schema** (automatic):
   - The database schema will be created automatically when the resource starts
   - No manual import required

### Step 3: Configure Database

1. Open `server/config.lua`
2. Update the database configuration:
   ```lua
   Config.Database = {
       host = "localhost",        -- Your MySQL host
       database = "nora_panel",   -- Database name
       username = "nora_user",    -- Database username
       password = "your_password", -- Database password
       port = 3306               -- MySQL port
   }
   ```

### Step 4: Server Configuration

1. **Add to server.cfg**:
   ```cfg
   # Add after ESX (if using)
   ensure es_extended
   ensure nora_panel
   ```

2. **Set Resource Order** (important):
   ```cfg
   # Make sure nora_panel loads after ESX
   ensure es_extended
   ensure nora_panel
   ```

### Step 5: Set Permissions

1. **Add Admin Permissions**:
   ```cfg
   # Add to server.cfg
   add_ace group.admin nora.admin allow
   add_ace group.superadmin nora.admin allow
   ```

2. **Alternative - Individual Permissions**:
   ```cfg
   # Add specific player permissions
   add_ace identifier.steam:YOUR_STEAM_ID nora.admin allow
   ```

### Step 6: Start the Server

1. **Restart your FiveM server**
2. **Check console for errors**:
   - Look for `[Nora Panel] Database connection established successfully!`
   - Ensure no error messages appear

3. **Verify Installation**:
   - Join your server
   - Press `F1` or type `/nora panel`
   - The panel should open

## 🔧 Advanced Configuration

### ESX Integration

If you're using ESX, configure the integration:

1. **Enable ESX Features** in `server/config.lua`:
   ```lua
   Config.Features.economySystem.enabled = true
   Config.Features.playerManagement.enabled = true
   ```

2. **ESX Commands** (optional):
   ```lua
   -- Add to server.cfg if you want ESX integration
   set es_enableLogging 1
   set es_enableMultichar true
   ```

### API Configuration

To enable the REST API:

1. **Enable API** in `server/config.lua`:
   ```lua
   Config.API = {
       enabled = true,
       port = 3000,
       rateLimit = {
           enabled = true,
           maxRequests = 100,
           windowMs = 60000
       }
   }
   ```

2. **Access API**:
   - URL: `http://your-server-ip:3000/api`
   - Authentication required for most endpoints

### Security Configuration

1. **IP Whitelist** (optional):
   ```lua
   Config.Security.allowedIPs = {
       "192.168.1.100",
       "10.0.0.50"
   }
   ```

2. **Anti-Cheat Settings**:
   ```lua
   Config.Features.securitySystem = {
       enabled = true,
       antiCheat = true,
       antiSpam = true,
       antiExploit = true
   }
   ```

## 🎮 Usage Guide

### Opening the Panel

1. **In-Game**:
   - Press `F1` (default key)
   - Type `/nora panel`
   - Use `/noraadmin` to get admin access

2. **Web Interface** (if API enabled):
   - Navigate to `http://your-server-ip:3000`
   - Login with admin credentials

### Basic Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/nora panel` | Open admin panel | `/nora panel` |
| `/nora ban <id> <reason>` | Ban a player | `/nora ban 1 Cheating` |
| `/nora kick <id> <reason>` | Kick a player | `/nora kick 1 Spamming` |
| `/nora heal <id>` | Heal a player | `/nora heal 1` |
| `/nora revive <id>` | Revive a player | `/nora revive 1` |
| `/nora weather <type>` | Change weather | `/nora weather CLEAR` |
| `/nora announce <msg>` | Send announcement | `/nora announce Server restart in 5 minutes` |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `F1` | Open/Close Panel |
| `Ctrl + 1-9` | Navigate to different pages |
| `Escape` | Close Panel |
| `I` | Toggle Spectate |
| `F` | Toggle Freeze |
| `N` | Toggle Noclip |
| `G` | Teleport to Marker |

## 🐛 Troubleshooting

### Common Issues

#### 1. Panel Not Opening
**Symptoms**: Pressing F1 or using commands doesn't open the panel

**Solutions**:
- Check if you have admin permissions: `/noraadmin`
- Verify the resource is started: `restart nora_panel`
- Check console for errors
- Ensure you're not in a vehicle (some conflicts)

#### 2. Database Connection Failed
**Symptoms**: Console shows database connection errors

**Solutions**:
- Verify MySQL is running
- Check database credentials in `server/config.lua`
- Ensure database exists: `nora_panel`
- Check MySQL user permissions
- Verify network connectivity

#### 3. Permission Denied
**Symptoms**: "You don't have permission" messages

**Solutions**:
- Add your identifier to admin group
- Check ACE permissions in server.cfg
- Use `/noraadmin` command
- Verify resource permissions

#### 4. ESX Features Not Working
**Symptoms**: Economy features, job management not working

**Solutions**:
- Ensure ESX is loaded before Nora Panel
- Check ESX configuration
- Verify ESX exports are available
- Enable ESX features in config

#### 5. Performance Issues
**Symptoms**: Server lag, high resource usage

**Solutions**:
- Disable unused features in config
- Reduce update intervals
- Check for conflicting resources
- Monitor server resources

### Debug Mode

Enable debug mode for detailed logging:

1. **Server Debug**:
   ```lua
   Config.Debug = {
       enabled = true,
       logLevel = "DEBUG"
   }
   ```

2. **Client Debug**:
   ```lua
   Config.Debug = {
       enabled = true,
       showFPS = true,
       showPing = true
   }
   ```

### Log Files

Check these locations for error logs:

1. **FiveM Console** - Main error source
2. **nora_panel.log** - Panel-specific logs
3. **Browser Console** - UI-related errors (F12)
4. **MySQL Error Log** - Database issues

### Getting Help

If you're still having issues:

1. **Check Documentation** - Read the full README.md
2. **Search Issues** - Look for similar problems on GitHub
3. **Create Issue** - Provide detailed information
4. **Join Discord** - Get real-time help from community

## 🔄 Updates

### Updating Nora Panel

1. **Backup Current Installation**:
   ```bash
   cp -r resources/nora_panel resources/nora_panel_backup
   ```

2. **Download New Version**:
   - Download latest release
   - Extract to temporary folder

3. **Update Files**:
   - Replace old files with new ones
   - Keep your `config.lua` customizations
   - Update database if needed

4. **Restart Resource**:
   ```cfg
   restart nora_panel
   ```

### Version Compatibility

| Nora Panel | FiveM | ESX | MySQL |
|------------|-------|-----|-------|
| 1.0.0 | 2372+ | 1.8+ | 5.7+ |

## 📊 Performance Tips

### Optimization Settings

1. **Reduce Update Intervals**:
   ```lua
   Config.Features.performanceMonitor.updateInterval = 5000 -- 5 seconds
   ```

2. **Disable Unused Features**:
   ```lua
   Config.Features.backupSystem.enabled = false
   Config.Features.performanceMonitor.enabled = false
   ```

3. **Limit Log Entries**:
   ```lua
   Config.Features.loggingSystem.maxLogEntries = 5000
   ```

### Resource Usage

- **Memory**: ~50-100MB
- **CPU**: ~1-3% (idle)
- **Database**: ~10-50MB (depending on usage)

## 🔒 Security Best Practices

### Server Security

1. **Use Strong Database Passwords**
2. **Enable IP Whitelisting** for admin access
3. **Regular Backups** of database and files
4. **Monitor Logs** for suspicious activity
5. **Keep Updated** with latest versions

### Panel Security

1. **Change Default Passwords**
2. **Enable Two-Factor Authentication** (if available)
3. **Limit Admin Access** to trusted users
4. **Regular Permission Audits**
5. **Secure API Endpoints**

## 📞 Support

### Getting Help

- **GitHub Issues**: [Create an issue](https://github.com/your-repo/nora-panel/issues)
- **Discord Server**: [Join our community](https://discord.gg/your-server)
- **Documentation**: [Full documentation](https://docs.nora-panel.com)
- **Email Support**: support@nora-panel.com

### Reporting Bugs

When reporting bugs, include:

1. **Nora Panel Version**
2. **FiveM Server Version**
3. **Error Messages** (console logs)
4. **Steps to Reproduce**
5. **Server Configuration** (anonymized)

### Feature Requests

For feature requests:

1. **Check Existing Issues** first
2. **Describe Use Case** clearly
3. **Provide Mockups** if applicable
4. **Consider Contributing** code

---

**Need more help? Join our Discord community for real-time support!**