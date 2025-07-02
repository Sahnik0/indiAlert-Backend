#!/bin/bash

# Satellite Monitoring System - Docker Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        print_status "Creating .env from .env.example..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_warning "Please edit .env file with your actual credentials before starting the system."
            exit 1
        else
            print_error ".env.example file not found. Please create a .env file manually."
            exit 1
        fi
    fi
}

# Function to start the system
start_system() {
    print_status "Starting Satellite Monitoring System..."
    check_env_file
    
    # Build and start containers
    docker-compose up --build -d
    
    print_success "System started successfully!"
    print_status "Jupyter Lab is available at: http://localhost:8888"
    print_status "To view logs: ./docker-manage.sh logs"
}

# Function to stop the system
stop_system() {
    print_status "Stopping Satellite Monitoring System..."
    docker-compose down
    print_success "System stopped successfully!"
}

# Function to restart the system
restart_system() {
    print_status "Restarting Satellite Monitoring System..."
    docker-compose restart
    print_success "System restarted successfully!"
}

# Function to view logs
view_logs() {
    print_status "Viewing system logs..."
    docker-compose logs -f satellite-monitoring
}

# Function to open shell in container
shell_access() {
    print_status "Opening shell in monitoring container..."
    docker-compose exec satellite-monitoring /bin/bash
}

# Function to clean up Docker resources
cleanup() {
    print_status "Cleaning up Docker resources..."
    docker-compose down -v
    docker system prune -f
    print_success "Cleanup completed!"
}

# Function to show system status
status() {
    print_status "System Status:"
    echo ""
    docker-compose ps
    echo ""
    print_status "Docker Images:"
    docker images | grep -E "(satellite|monitoring|REPOSITORY)"
    echo ""
    print_status "Docker Volumes:"
    docker volume ls | grep -E "(satellite|monitoring|DRIVER)"
}

# Function to backup data
backup_data() {
    print_status "Creating backup of monitoring data..."
    BACKUP_NAME="satellite_monitoring_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Create backup directory
    mkdir -p backups
    
    # Backup volumes and configuration
    docker run --rm \
        -v satellite_results:/backup/results \
        -v satellite_data:/backup/data \
        -v $(pwd):/backup/config \
        alpine tar czf /backup/config/backups/$BACKUP_NAME \
        -C /backup . \
        --exclude='config/.git' \
        --exclude='config/backups'
    
    print_success "Backup created: backups/$BACKUP_NAME"
}

# Function to restore data
restore_data() {
    if [ -z "$1" ]; then
        print_error "Please specify backup file: ./docker-manage.sh restore <backup_file>"
        exit 1
    fi
    
    if [ ! -f "backups/$1" ]; then
        print_error "Backup file not found: backups/$1"
        exit 1
    fi
    
    print_status "Restoring from backup: $1"
    print_warning "This will overwrite existing data. Continue? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        docker run --rm \
            -v satellite_results:/restore/results \
            -v satellite_data:/restore/data \
            -v $(pwd)/backups:/backups \
            alpine tar xzf /backups/$1 -C /restore
        
        print_success "Data restored from backup successfully!"
    else
        print_status "Restore cancelled."
    fi
}

# Function to show help
show_help() {
    echo "Satellite Monitoring System - Docker Management"
    echo ""
    echo "Usage: ./docker-manage.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start      Start the monitoring system"
    echo "  stop       Stop the monitoring system"
    echo "  restart    Restart the monitoring system"
    echo "  status     Show system status"
    echo "  logs       View system logs"
    echo "  shell      Access container shell"
    echo "  backup     Create data backup"
    echo "  restore    Restore from backup"
    echo "  cleanup    Clean up Docker resources"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./docker-manage.sh start"
    echo "  ./docker-manage.sh logs"
    echo "  ./docker-manage.sh backup"
    echo "  ./docker-manage.sh restore satellite_monitoring_backup_20250702_120000.tar.gz"
}

# Main script logic
case "${1:-help}" in
    start)
        start_system
        ;;
    stop)
        stop_system
        ;;
    restart)
        restart_system
        ;;
    logs)
        view_logs
        ;;
    shell)
        shell_access
        ;;
    status)
        status
        ;;
    backup)
        backup_data
        ;;
    restore)
        restore_data "$2"
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
