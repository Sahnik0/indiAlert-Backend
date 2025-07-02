# 🛰️ Satellite Monitoring System

A comprehensive satellite monitoring system using Google Earth Engine for detecting environmental changes including deforestation, water body changes, urban growth, and vegetation changes.

## 🔧 Setup Instructions

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
├── Change_Monitoring.ipynb    # Main monitoring notebook
├── .env                       # Your credentials (DO NOT COMMIT)
├── .env.example              # Sample environment file
├── .gitignore                # Git ignore rules
├── README.md                 # This file
└── gee_results/              # Generated images and logs
    ├── monitoring_log.txt
    ├── alert_history.json
    └── *.png                 # Satellite imagery
```

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
