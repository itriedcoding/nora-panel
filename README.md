# Nora Panel - Advanced FiveM Admin Panel

![Nora Panel](https://img.shields.io/badge/Version-1.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

Nora Panel is a comprehensive, advanced admin panel for FiveM servers featuring 30+ powerful administrative tools with a modern black and blue aesthetic design. Built with Lua, JavaScript, and modern web technologies.

## ✨ Features

### 🎮 Player Management
- **Real-time Player Monitoring** - View all online players with live stats
- **Advanced Player Actions** - Ban, kick, heal, revive, freeze, spectate
- **Player Information** - Detailed player data including health, armor, money, job
- **Mass Actions** - Heal all, revive all, kick all players
- **Player Search & Filtering** - Find players quickly with advanced filters

### 🚗 Vehicle Management
- **Vehicle Spawning** - Spawn any vehicle with custom coordinates
- **Vehicle Control** - Repair, delete, modify, teleport vehicles
- **Vehicle Information** - Real-time vehicle stats and health
- **Nearby Vehicles** - View and manage vehicles in proximity
- **Vehicle Modifications** - Customize vehicles with advanced options

### 🔫 Weapon Management
- **Weapon Distribution** - Give weapons with custom ammo amounts
- **Weapon Removal** - Remove specific weapons or all weapons
- **Weapon Components** - Add/remove weapon attachments
- **Weapon Categories** - Organized by weapon types and groups
- **Ammo Management** - Set custom ammo amounts for weapons

### 🗺️ Teleport System
- **Player Teleportation** - Teleport players to locations or other players
- **Predefined Locations** - 15+ popular FiveM locations
- **Custom Locations** - Save and manage custom teleport points
- **Coordinate Teleporting** - Teleport to specific coordinates
- **Bring/Go To** - Bring players to you or go to players

### 🌤️ Weather Control
- **Weather Types** - 12 different weather conditions
- **Time Control** - Set server time with freeze option
- **Weather Presets** - Quick weather configurations
- **Wind Control** - Adjust wind speed and direction
- **Blackout Mode** - Toggle server blackout

### 💰 Economy System
- **Money Management** - Give, remove, set player money
- **Bank Management** - Control player bank accounts
- **Economy Statistics** - Server-wide economy overview
- **Money Transfer** - Transfer money between players
- **Economy Monitoring** - Track money flow and transactions

### 📢 Announcement System
- **Global Announcements** - Send messages to all players
- **Staff Announcements** - Admin-only communications
- **Player Messages** - Direct messages to specific players
- **Announcement Types** - Success, error, warning, info messages
- **Message History** - Track all announcements

### 📊 Logging System
- **Comprehensive Logging** - Track all admin actions and events
- **Log Categories** - Organized by action types
- **Search & Filter** - Find specific logs quickly
- **Export Logs** - Download logs in various formats
- **Real-time Updates** - Live log monitoring

### 💾 Backup System
- **Automatic Backups** - Scheduled server backups
- **Manual Backups** - Create backups on demand
- **Backup Management** - View, restore, delete backups
- **Database Backups** - Include/exclude database data
- **Backup Statistics** - Monitor backup sizes and frequency

### 📈 Performance Monitor
- **Server Performance** - Real-time FPS, ping, memory, CPU monitoring
- **Performance Charts** - Visual performance data
- **Performance Alerts** - Notifications for performance issues
- **Resource Monitoring** - Track resource usage
- **Performance History** - Historical performance data

### 🔒 Security System
- **Security Monitoring** - Track suspicious activities
- **Anti-Cheat Detection** - Detect and prevent cheating
- **IP Management** - Whitelist/blacklist IP addresses
- **Security Events** - Log security-related incidents
- **Threat Detection** - Automatic threat identification

### 🎨 Modern UI/UX
- **Black & Blue Theme** - Aesthetic dark theme with blue accents
- **Responsive Design** - Works on all screen sizes
- **Smooth Animations** - 60+ CSS animations and transitions
- **Interactive Components** - Modern UI components
- **Keyboard Shortcuts** - Quick access to features

## 🚀 Installation

### Prerequisites
- FiveM Server
- MySQL Database
- ESX Framework (optional but recommended)

### Step 1: Download
1. Download the latest release from the [Releases](https://github.com/your-repo/nora-panel/releases) page
2. Extract the files to your FiveM server's `resources` folder

### Step 2: Database Setup
1. Create a new MySQL database named `nora_panel`
2. Import the database schema:
```sql
-- The database schema will be automatically created when the resource starts
-- Make sure your MySQL credentials are correct in server/config.lua
```

### Step 3: Configuration
1. Open `server/config.lua`
2. Update the database configuration:
```lua
Config.Database = {
    host = "localhost",
    database = "nora_panel",
    username = "your_username",
    password = "your_password",
    port = 3306
}
```

### Step 4: Server Configuration
1. Add the resource to your `server.cfg`:
```cfg
ensure nora_panel
```

2. Add the resource to your `server.cfg` after ESX (if using):
```cfg
ensure es_extended
ensure nora_panel
```

### Step 5: Permissions
1. Add admin permissions to your `server.cfg`:
```cfg
add_ace group.admin nora.admin allow
add_ace group.superadmin nora.admin allow
```

### Step 6: Start the Server
1. Restart your FiveM server
2. The panel will be available at `http://your-server-ip:3000` (if API is enabled)

## 📖 Usage

### Opening the Panel
- **In-Game**: Press `F1` or use `/nora panel`
- **Web Interface**: Navigate to the panel URL
- **Admin Command**: `/noraadmin` (gives admin access)

### Basic Commands
- `/nora panel` - Open the admin panel
- `/nora ban <id> <reason>` - Ban a player
- `/nora kick <id> <reason>` - Kick a player
- `/nora heal <id>` - Heal a player
- `/nora revive <id>` - Revive a player
- `/nora weather <type>` - Change weather
- `/nora announce <message>` - Send announcement

### Panel Navigation
1. **Dashboard** - Overview of server statistics
2. **Players** - Manage online and offline players
3. **Vehicles** - Spawn and manage vehicles
4. **Weapons** - Distribute and manage weapons
5. **Teleport** - Teleport players and manage locations
6. **Weather** - Control weather and time
7. **Economy** - Manage server economy
8. **Announcements** - Send server messages
9. **Logs** - View server logs
10. **Backups** - Manage server backups
11. **Performance** - Monitor server performance
12. **Security** - Security monitoring and management
13. **Settings** - Configure panel settings

## ⚙️ Configuration

### Server Configuration
Edit `server/config.lua` to customize:
- Database settings
- Feature toggles
- Security settings
- API configuration
- Notification settings

### Client Configuration
Edit `client/config.lua` to customize:
- Key bindings
- UI settings
- Notification preferences
- Performance settings

### UI Configuration
Edit `html/css/style.css` to customize:
- Color scheme
- Typography
- Layout
- Animations

## 🔧 API Documentation

### Authentication
```javascript
// Login
POST /api/auth/login
{
    "username": "admin",
    "password": "password"
}

// Validate token
POST /api/auth/validate
Headers: { "Authorization": "Bearer <token>" }
```

### Players
```javascript
// Get all players
GET /api/players

// Get online players
GET /api/players/online

// Get player by ID
GET /api/players/:id

// Ban player
POST /api/players/:id/ban
{
    "reason": "Cheating",
    "duration": 7,
    "permanent": false
}

// Kick player
POST /api/players/:id/kick
{
    "reason": "Inappropriate behavior"
}
```

### Vehicles
```javascript
// Get vehicle list
GET /api/vehicles

// Spawn vehicle
POST /api/vehicles/spawn
{
    "playerId": 1,
    "model": "adder",
    "coords": {"x": 0, "y": 0, "z": 0},
    "heading": 0
}
```

### Weather
```javascript
// Get current weather
GET /api/weather

// Set weather
POST /api/weather/set
{
    "weatherType": "CLEAR",
    "transition": 0,
    "playerId": 1
}
```

## 🛠️ Development

### Project Structure
```
nora_panel/
├── server/                 # Server-side Lua scripts
│   ├── config.lua         # Main configuration
│   ├── database.lua       # Database management
│   ├── ban_system.lua     # Ban management
│   ├── kick_system.lua    # Kick management
│   ├── player_management.lua
│   ├── vehicle_management.lua
│   ├── weapon_management.lua
│   ├── teleport_system.lua
│   ├── weather_control.lua
│   ├── economy_system.lua
│   ├── announcement_system.lua
│   ├── backup_system.lua
│   ├── performance_monitor.lua
│   ├── security_system.lua
│   ├── api_server.lua
│   └── main.lua
├── client/                 # Client-side Lua scripts
│   ├── config.lua
│   ├── player_utils.lua
│   ├── vehicle_utils.lua
│   ├── weapon_utils.lua
│   ├── teleport_utils.lua
│   ├── weather_utils.lua
│   ├── economy_utils.lua
│   ├── notification_system.lua
│   └── main.lua
├── html/                   # Web interface
│   ├── index.html
│   ├── css/
│   │   ├── style.css
│   │   └── animations.css
│   ├── js/
│   │   ├── app.js
│   │   ├── api.js
│   │   ├── components.js
│   │   ├── charts.js
│   │   ├── notifications.js
│   │   └── utils.js
│   └── assets/
├── fxmanifest.lua
└── README.md
```

### Building from Source
1. Clone the repository
2. Install dependencies (if any)
3. Make your changes
4. Test thoroughly
5. Create a pull request

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 🐛 Troubleshooting

### Common Issues

#### Panel Not Opening
- Check if you have admin permissions
- Verify the resource is started
- Check console for errors

#### Database Connection Issues
- Verify MySQL credentials
- Check database exists
- Ensure MySQL is running

#### Permission Denied
- Add your identifier to admin group
- Check ACE permissions
- Verify resource permissions

#### Performance Issues
- Disable unused features in config
- Check server resources
- Optimize database queries

### Debug Mode
Enable debug mode in `server/config.lua`:
```lua
Config.Debug = {
    enabled = true,
    logLevel = "DEBUG"
}
```

### Logs
Check the following for error logs:
- FiveM server console
- `nora_panel.log` file
- Browser console (for UI issues)

## 📝 Changelog

### Version 1.0.0
- Initial release
- 30+ advanced admin features
- Modern black/blue UI theme
- Comprehensive player management
- Vehicle and weapon systems
- Teleport and weather control
- Economy management
- Announcement system
- Logging and backup systems
- Performance monitoring
- Security features
- REST API
- Responsive design

## 🤝 Support

### Getting Help
- Check the [Issues](https://github.com/your-repo/nora-panel/issues) page
- Join our [Discord Server](https://discord.gg/your-server)
- Read the [Documentation](https://docs.nora-panel.com)

### Reporting Bugs
1. Check if the issue already exists
2. Provide detailed information
3. Include error logs
4. Describe steps to reproduce

### Feature Requests
1. Check if the feature already exists
2. Provide detailed description
3. Explain the use case
4. Consider contributing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- FiveM Community
- ESX Framework
- All contributors and testers
- Open source libraries used

## 📞 Contact

- **Developer**: Nora Development Team
- **Email**: support@nora-panel.com
- **Discord**: [Join our server](https://discord.gg/your-server)
- **Website**: [https://nora-panel.com](https://nora-panel.com)

---

**Made with ❤️ for the FiveM community**