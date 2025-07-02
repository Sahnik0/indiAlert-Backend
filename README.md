# 🛰️ Satellite Monitoring System

A comprehensive satellite monitoring system using Google Earth Engine for detecting environmental changes including deforestation, water body changes, urban growth, and vegetation changes.

## 🔧 Setup Instructions

### Option 1: Docker Setup (Recommended)

Docker provides an isolated, consistent environment for running the satellite monitoring system.

#### Prerequisites
- Docker and Docker Compose installed on your system
- At least 4GB RAM available for the container

#### Quick Start with Docker

1. Clone or download the project files
2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```
3. Edit the `.env` file with your credentials:
   ```bash
   nano .env
   ```
4. Start the system:
   ```bash
   ./docker-manage.sh start
   ```
5. Access Jupyter Lab at: http://localhost:8888

#### Docker Management Commands

```bash
# Start the system
./docker-manage.sh start

# Stop the system
./docker-manage.sh stop

# View logs
./docker-manage.sh logs

# Access container shell
./docker-manage.sh shell

# Check system status
./docker-manage.sh status

# Create backup
./docker-manage.sh backup

# Restore from backup
./docker-manage.sh restore <backup_filename>

# Clean up resources
./docker-manage.sh cleanup
```

### Option 2: Manual Setup

### 1. Environment Configuration

1. Copy the sample environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your actual credentials:
   ```bash
   nano .env
   ```

3. Fill in the required values:
   - `PROJECT_ID`: Your Google Earth Engine project ID
   - `EMAIL_USER`: Your Gmail address
   - `EMAIL_PASS`: Your Gmail app password (not your regular password)
   - `CURRENT_USER`: Your username/identifier

### 2. Gmail App Password Setup

For `EMAIL_PASS`, you need to create an App Password:

1. Go to your Google Account settings
2. Enable 2-Factor Authentication
3. Go to Security → App passwords
4. Generate a new app password for "Mail"
5. Use this 16-character password in your `.env` file

### 3. Google Earth Engine Setup

1. Sign up for Google Earth Engine at: https://earthengine.google.com/
2. Create a new project or use an existing one
3. Note your project ID for the `.env` file

### 4. Required Dependencies

The notebook will automatically install required packages:
- `earthengine-api`
- `ipywidgets`
- `python-dotenv`
- `numpy`
- `Pillow`
- `requests`
- `schedule`

## 🚀 Usage

1. Open the Jupyter notebook: `Change_Monitoring.ipynb`
2. Run the first cell to install dependencies and load configuration
3. The system will authenticate with Google Earth Engine
4. Use the interactive dashboard to configure monitoring parameters

## 🔒 Security

- **Never commit the `.env` file** - it contains sensitive credentials
- The `.gitignore` file is configured to exclude sensitive files
- Use app passwords for Gmail, not your regular password
- Keep your Google Earth Engine credentials secure

## 📊 Features

- **Multi-type Detection**: Deforestation, water changes, urban growth, vegetation growth
- **Email Alerts**: Automatic notifications with satellite imagery proof
- **Interactive Dashboard**: Easy-to-use interface for monitoring configuration
- **Smart Date Tracking**: Progressive analysis avoiding duplicate alerts
- **Cloud Filtering**: Automatic removal of cloudy imagery
- **Change Visualization**: Before/after images with change overlays

## 🎯 Detection Types

1. **🌳 Deforestation**: Loss of forest cover (NDVI-based)
2. **💧 Water Loss**: Shrinking water bodies (MNDWI-based)
3. **💧 Water Gain**: Expanding water bodies (MNDWI-based)
4. **🏘️ Urban Growth**: New construction/development (NDBI-based)
5. **🌱 Vegetation Growth**: New vegetation cover (NDVI-based)

## ⚙️ Configuration

Adjust detection sensitivity in `.env`:
- `NDVI_CHANGE_THRESHOLD`: Vegetation change sensitivity (0.1-0.3)
- `MNDWI_CHANGE_THRESHOLD`: Water change sensitivity (0.1-0.2)
- `NDBI_CHANGE_THRESHOLD`: Urban change sensitivity (0.05-0.15)
- `MIN_AREA_PIXELS`: Minimum detection area (pixels)
- `CLOUD_COVER_LIMIT`: Maximum cloud cover percentage

## 📁 File Structure

```
IndiAlert Backend/
├── Change_Monitoring.ipynb      # Main monitoring notebook
├── .env                         # Your credentials (DO NOT COMMIT)
├── .env.example                # Sample environment file
├── .gitignore                  # Git ignore rules
├── .dockerignore               # Docker ignore rules
├── README.md                   # This file
├── Dockerfile                  # Docker container configuration
├── docker-compose.yml          # Docker services configuration
├── requirements.txt            # Python dependencies
├── docker-manage.sh            # Docker management script
├── nginx.conf                  # Nginx configuration for production
├── backups/                    # System backups
├── gee_results/                # Generated images and logs
│   ├── monitoring_log.txt
│   ├── alert_history.json
│   └── *.png                   # Satellite imagery
└── data/                       # Persistent data storage
```

## 🐳 Docker Features

- **Isolated Environment**: Complete Python environment with all dependencies
- **Persistent Storage**: Data and results are preserved between container restarts
- **Easy Management**: Simple commands for start/stop/backup operations
- **Production Ready**: Includes Nginx reverse proxy configuration
- **Health Monitoring**: Built-in health checks for container status
- **Backup System**: Automated backup and restore functionality

## 📊 Container Services

### Main Services
- **satellite-monitoring**: Main Jupyter Lab container
- **nginx**: Reverse proxy (optional, for production)

### Volumes
- **satellite_results**: Stores generated images and detection results
- **satellite_data**: Persistent data storage
- **Current directory**: Mounted for live code editing

## 🛠️ Troubleshooting

### Authentication Issues
- Ensure your Google Earth Engine project ID is correct
- Check that your Gmail app password is valid
- Verify 2FA is enabled on your Google account

### Import Errors
- Run the first cell to install all dependencies
- Restart the kernel if needed

### No Detections
- Adjust threshold values in `.env`
- Check if the monitoring area has sufficient satellite coverage
- Verify the date range includes recent imagery

## 📞 Support

For issues or questions, check the notebook output for detailed error messages and logs in `gee_results/monitoring_log.txt`.
