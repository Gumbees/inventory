# SnipeIT Inventory Management

A Docker Compose setup for SnipeIT asset management with Traefik reverse proxy support, MySQL database, and Redis caching.

## Architecture Support

✅ **Multi-Architecture Support**: This configuration uses the official SnipeIT Docker image which supports:
- AMD64/x86_64
- ARM64/armv8 (Apple Silicon, ARM servers)
- Other architectures supported by the official image

## Features

- **SnipeIT**: Open source asset management system
- **MySQL 8.0**: Database backend with persistent storage
- **Redis**: Session and cache management
- **Traefik Integration**: Automatic SSL/TLS certificates and reverse proxy
- **Backup Support**: Optional database backup service
- **Configurable Storage**: Flexible volume mounting options

## Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd inventory
   ```

2. **Configure Environment**
   ```bash
   cp environment.example .env
   nano .env  # Edit configuration values
   ```

3. **Generate Application Key**
   ```bash
   # Generate a secure APP_KEY
   openssl rand -base64 32
   # Add the result to your .env file as: APP_KEY=base64:<generated_key>
   ```

4. **Create Data Directories**
   ```bash
   mkdir -p data/{snipeit,mysql,redis} backups
   ```

5. **Create External Network** (if not already existing)
   ```bash
   docker network create containers_internet
   ```

6. **Start Services**
   ```bash
   docker-compose up -d
   ```

## Configuration

### Required Environment Variables

Edit the `.env` file with your specific configuration:

- **APP_KEY**: Generate with `openssl rand -base64 32`
- **APP_URL**: Your public URL (e.g., `https://inventory.yourdomain.com`)
- **SNIPEIT_DOMAIN**: Domain for Traefik routing
- **Database credentials**: Set secure passwords for DB_PASSWORD and DB_ROOT_PASSWORD

### Traefik Labels

The compose file includes Traefik labels for:
- **HTTP/HTTPS routing**: Supports both web (80) and websecure (443) entrypoints
- **Automatic SSL**: Uses Let's Encrypt for certificate generation
- **Load balancing**: Routes traffic to SnipeIT on port 80

### Network Architecture

- **inventory_apps**: Internal isolated network for inter-service communication (no internet access)
- **containers_internet**: External network providing internet access (app only)
- **inventory_db_network**: Isolated database network (internal only, no internet access)

## Services

### SnipeIT Application
- **Image**: `snipe/snipe-it:latest` (Official multi-architecture image with ARM64 support)
- **Ports**: 80 (internal)
- **Dependencies**: MySQL, Redis
- **Volumes**: Application data and uploads

### MySQL Database
- **Image**: `mysql:8.0`
- **Features**: Persistent storage, isolated network
- **Authentication**: MySQL native password plugin

### Redis Cache
- **Image**: `redis:7-alpine`
- **Features**: Persistent storage, append-only file

### Backup Service (Optional)
- **Profile**: `backup`
- **Usage**: Manual database backups
- **Command**: `docker-compose --profile backup run snipeit_backup /scripts/backup.sh`

## Usage

### Initial Setup

1. **Access SnipeIT**: Navigate to your configured domain
2. **Run Setup Wizard**: Follow the web-based installation
3. **Create Admin User**: Set up your first administrator account

### Database Management

**View Logs:**
```bash
docker-compose logs snipeit_db
```

**Access Database:**
```bash
docker-compose exec snipeit_db mysql -u root -p
```

**Backup Database:**
```bash
# Create backup script first, then:
docker-compose --profile backup run snipeit_backup /scripts/backup.sh
```

### Maintenance

**Update Services:**
```bash
docker-compose pull
docker-compose up -d
```

**View Application Logs:**
```bash
docker-compose logs -f snipeit
```

**Restart Services:**
```bash
docker-compose restart
```

## Storage Configuration

### Default Setup (Local Bind Mounts)
Data is stored in local directories:
- `./data/snipeit/` - SnipeIT application data and uploads
- `./data/mysql/` - Database files
- `./data/redis/` - Redis persistence
- `./backups/` - Database backups

### Custom Storage Options
Configure different storage backends in `.env`:
```bash
# Example: NFS mount
CONFIG_VOLUME_TYPE=nfs
CONFIG_VOLUME_OPTIONS=addr=nfs-server,rw
CONFIG_BASE=/mnt/nfs/snipeit
```

## Security Considerations

1. **Change Default Passwords**: Set secure passwords in `.env`
2. **APP_KEY Security**: Keep your APP_KEY secret and backed up
3. **Network Isolation**: Database runs on isolated internal network
4. **SSL/TLS**: Traefik provides automatic HTTPS with Let's Encrypt
5. **Regular Updates**: Keep Docker images updated

## Troubleshooting

### Common Issues

**Service Won't Start:**
```bash
# Check logs
docker-compose logs <service-name>

# Verify environment
docker-compose config
```

**Database Connection Issues:**
- Verify database credentials in `.env`
- Check if MySQL service is running: `docker-compose ps`
- Review database logs: `docker-compose logs snipeit_db`

**Traefik Routing Issues:**
- Ensure Traefik is running and configured
- Verify domain DNS points to your server
- Check Traefik logs for certificate generation

### Performance Tuning

**For Large Inventories:**
- Increase MySQL memory limits
- Configure Redis memory settings
- Enable SnipeIT caching features

## Support

- **SnipeIT Documentation**: https://snipe-it.readme.io/
- **Docker Hub**: https://hub.docker.com/r/linuxserver/snipe-it
- **Issues**: Create an issue in this repository

## License

This Docker Compose configuration is provided as-is. SnipeIT is licensed under AGPL-3.0. 