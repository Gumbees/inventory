#!/bin/bash
# SnipeIT Quick Setup Script

set -e

echo "🚀 SnipeIT Inventory Management Setup"
echo "======================================"

# Check if Docker and Docker Compose are available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp environment.example .env
    
    # Generate a secure APP_KEY
    echo "🔑 Generating secure application key..."
    APP_KEY=$(openssl rand -base64 32)
    sed -i.bak "s/CHANGE_ME_TO_32_CHARACTER_RANDOM_STRING/$APP_KEY/" .env && rm .env.bak
    
    echo "⚠️  IMPORTANT: Please edit .env file and configure:"
    echo "   - SNIPEIT_DOMAIN (your domain name)"
    echo "   - APP_URL (your public URL)"
    echo "   - Database passwords"
    echo "   - Mail configuration (optional)"
    echo ""
else
    echo "✅ .env file already exists"
fi

# Create data directories
echo "📁 Creating data directories..."
mkdir -p data/{snipeit,mysql,redis}
mkdir -p backups
mkdir -p logs

echo "✅ Data directories created:"
echo "   - data/snipeit/ (SnipeIT application data and uploads)"
echo "   - data/mysql/ (Database files)"
echo "   - data/redis/ (Redis persistence)"
echo "   - backups/ (Database backups)"
echo "   - logs/ (Application logs)"

# Set proper permissions (if on Unix-like system)
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🔒 Setting directory permissions..."
    chmod -R 755 data/
    chmod -R 755 backups/
    chmod +x scripts/*.sh
fi

echo ""
echo "🎯 Setup completed! Next steps:"
echo ""
echo "1. Edit your .env file:"
echo "   nano .env"
echo ""
echo "2. Review and customize docker-compose.yml if needed"
echo ""
echo "3. Ensure external network exists (already done by this script):"
echo "   docker network create containers_internet"
echo ""
echo "4. Start the services:"
echo "   docker-compose up -d"
echo ""
echo "5. Monitor the startup:"
echo "   docker-compose logs -f"
echo ""
echo "6. Access SnipeIT at your configured domain"
echo ""
echo "📚 For more information, see README.md"
echo ""
echo "🔧 Useful commands:"
echo "   docker-compose ps                    # View running services"
echo "   docker-compose logs snipeit          # View SnipeIT logs"
echo "   docker-compose restart               # Restart all services"
echo "   docker-compose pull && docker-compose up -d  # Update services"
echo ""
echo "💾 To backup the database:"
echo "   docker-compose --profile backup run snipeit_backup /scripts/backup.sh"
echo ""

# Create external network if it doesn't exist
echo "🌐 Setting up external network..."
if ! docker network ls | grep -q "containers_internet"; then
    echo "📡 Creating containers_internet network..."
    docker network create containers_internet
    echo "✅ External network created"
else
    echo "✅ External network already exists"
fi

# Validate docker-compose.yml
echo "🔍 Validating Docker Compose configuration..."
if docker-compose config >/dev/null 2>&1; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors. Please check docker-compose.yml"
    exit 1
fi

echo "🎉 SnipeIT setup is ready!" 