#!/bin/bash

# Production Deployment Script for Satellite Monitoring System

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env"

# Check prerequisites
check_prerequisites() {
    print_status "Checking deployment prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        exit 1
    fi
    
    # Check environment file
    if [ ! -f "$ENV_FILE" ]; then
        print_error "Environment file $ENV_FILE not found!"
        print_status "Creating from template..."
        cp .env.example .env
        print_warning "Please configure $ENV_FILE before deploying!"
        exit 1
    fi
    
    # Check required environment variables
    source $ENV_FILE
    required_vars=("PROJECT_ID" "EMAIL_USER" "EMAIL_PASS")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            print_error "Required environment variable $var is not set in $ENV_FILE"
            exit 1
        fi
    done
    
    print_success "Prerequisites check passed!"
}

# Generate SSL certificates for HTTPS
generate_ssl_certs() {
    print_status "Generating SSL certificates..."
    
    mkdir -p ssl
    
    if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
        # Generate self-signed certificate (replace with real certs for production)
        openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem \
            -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
        
        print_success "Self-signed SSL certificates generated!"
        print_warning "For production, replace with real SSL certificates!"
    else
        print_status "SSL certificates already exist."
    fi
}

# Deploy the application
deploy() {
    print_status "Deploying Satellite Monitoring System..."
    
    # Build and start services
    docker-compose -f $COMPOSE_FILE up --build -d
    
    # Wait for services to be healthy
    print_status "Waiting for services to become healthy..."
    sleep 30
    
    # Check service status
    if docker-compose -f $COMPOSE_FILE ps | grep -q "Up (healthy)"; then
        print_success "Deployment successful!"
        print_status "Services are running and healthy."
        
        # Display access information
        echo ""
        print_success "🎉 Satellite Monitoring System is now deployed!"
        echo ""
        echo "📊 Access URLs:"
        echo "   - Jupyter Lab:  http://localhost:${JUPYTER_PORT:-8888}"
        echo "   - Nginx Proxy:  http://localhost:${NGINX_HTTP_PORT:-80}"
        echo "   - HTTPS:        https://localhost:${NGINX_HTTPS_PORT:-443}"
        echo ""
        echo "🔧 Management Commands:"
        echo "   - View logs:    docker-compose -f $COMPOSE_FILE logs -f"
        echo "   - Stop system:  docker-compose -f $COMPOSE_FILE down"
        echo "   - Restart:      docker-compose -f $COMPOSE_FILE restart"
        echo ""
        
    else
        print_error "Deployment failed! Some services are not healthy."
        docker-compose -f $COMPOSE_FILE ps
        exit 1
    fi
}

# Update deployment
update() {
    print_status "Updating deployment..."
    
    # Pull latest images and rebuild
    docker-compose -f $COMPOSE_FILE pull
    docker-compose -f $COMPOSE_FILE up --build -d
    
    print_success "Update completed!"
}

# Scale services
scale() {
    if [ -z "$2" ]; then
        print_error "Usage: $0 scale <service> <replicas>"
        exit 1
    fi
    
    print_status "Scaling $2 to $3 replicas..."
    docker-compose -f $COMPOSE_FILE up -d --scale $2=$3
}

# Backup system
backup() {
    print_status "Creating production backup..."
    
    BACKUP_DIR="backups/prod"
    BACKUP_NAME="satellite_monitoring_prod_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    mkdir -p $BACKUP_DIR
    
    # Create comprehensive backup
    docker run --rm \
        -v satellite_results:/backup/results \
        -v satellite_data:/backup/data \
        -v nginx_logs:/backup/logs \
        -v $(pwd):/backup/config \
        alpine tar czf /backup/config/$BACKUP_DIR/$BACKUP_NAME \
        -C /backup . \
        --exclude='config/.git' \
        --exclude='config/backups' \
        --exclude='config/.env'
    
    print_success "Production backup created: $BACKUP_DIR/$BACKUP_NAME"
}

# Monitor system health
monitor() {
    print_status "System Health Monitor"
    echo "===================="
    
    # Container status
    echo "Container Status:"
    docker-compose -f $COMPOSE_FILE ps
    echo ""
    
    # Resource usage
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
    
    # Service health
    echo "Health Checks:"
    for service in satellite-monitoring nginx; do
        health=$(docker inspect --format='{{.State.Health.Status}}' ${service}_prod 2>/dev/null || echo "unknown")
        echo "  $service: $health"
    done
    echo ""
    
    # Log recent errors
    echo "Recent Errors (last 50 lines):"
    docker-compose -f $COMPOSE_FILE logs --tail=50 | grep -i error || echo "No recent errors found."
}

# Clean deployment
clean() {
    print_warning "This will remove all containers, volumes, and data. Continue? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Cleaning up deployment..."
        docker-compose -f $COMPOSE_FILE down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Show help
show_help() {
    echo "Production Deployment Script for Satellite Monitoring System"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy     Deploy the application"
    echo "  update     Update existing deployment"
    echo "  scale      Scale services (usage: scale <service> <replicas>)"
    echo "  backup     Create system backup"
    echo "  monitor    Show system health and status"
    echo "  clean      Remove all containers and data"
    echo "  ssl        Generate SSL certificates"
    echo "  help       Show this help"
    echo ""
}

# Main execution
case "${1:-help}" in
    deploy)
        check_prerequisites
        generate_ssl_certs
        deploy
        ;;
    update)
        update
        ;;
    scale)
        scale "$@"
        ;;
    backup)
        backup
        ;;
    monitor)
        monitor
        ;;
    clean)
        clean
        ;;
    ssl)
        generate_ssl_certs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
