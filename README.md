# Groq AI Chat Application

Full-stack chat application with Groq AI API, featuring a React frontend, Node.js backend, Nginx proxy, and Docker deployment with SSL support.

## Features

- **Modern React Frontend**: Clean, responsive chat interface with real-time messaging
- **Node.js Backend**: Secure API proxy to Groq AI with rate limiting and error handling
- **Nginx Proxy**: Production-ready reverse proxy with SSL/TLS support
- **Docker Deployment**: Complete containerization with development and production configurations
- **SSL/TLS Support**: Let's Encrypt integration with automatic HTTPS redirection
- **Security**: Helmet.js, CORS, rate limiting, and security headers
- **Scalable**: Docker Compose orchestration with network isolation

## Prerequisites

- Docker and Docker Compose
- Groq API key (get one at [console.groq.com](https://console.groq.com))
- Domain name (for production SSL setup)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd groq-chat-app
```

### 2. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
GROQ_API_KEY=your_groq_api_key_here
DOMAIN=yourdomain.com          # For production
EMAIL=admin@yourdomain.com     # For SSL certificates
```

### 3. Development Mode

Start the development environment:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Health check: http://localhost:5000/api/health

### 4. Production Mode

For production deployment with SSL:

```bash
# Setup SSL certificates
chmod +x setup-ssl.sh
./setup-ssl.sh

# Start production services
docker-compose -f docker-compose.prod.yml up --build -d
```

## SSL Configuration

### Option 1: Self-Signed Certificate (Development)

The setup script automatically generates a self-signed certificate for testing.

### Option 2: Custom Certificates

Place your certificates in the `ssl/` directory:
- `ssl/cert.pem` - Certificate file
- `ssl/key.pem` - Private key file

### Option 3: Let's Encrypt (Production)

1. Set your domain and email in `.env`
2. Ensure your domain points to your server
3. Run Let's Encrypt:

```bash
# Request certificate
docker-compose -f docker-compose.prod.yml run --rm certbot \
  certonly --webroot -w /var/www/certbot \
  -d yourdomain.com --email admin@yourdomain.com \
  --agree-tos --no-eff-email

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/live/yourdomain.com/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/live/yourdomain.com/
```

## Project Structure

```
groq-chat-app/
|
client/                 # React frontend
  |-- src/
  |   |-- App.js       # Main chat component
  |   |-- App.css      # Styling
  |   |-- index.js     # Entry point
  |-- public/
  |-- package.json
  |-- Dockerfile       # Production build
  |-- Dockerfile.dev   # Development with hot reload
|
server/                 # Node.js backend
  |-- index.js         # Express server with Groq API proxy
  |-- package.json
  |-- Dockerfile       # Production
  |-- Dockerfile.dev   # Development
|
nginx/                  # Nginx configuration
  |-- nginx.conf
  |-- conf.d/
  |   |-- default.conf           # Basic configuration
  |   |-- domain.conf.template   # Domain template with SSL
|
ssl/                    # SSL certificates
  |-- live/
|
var/www/certbot/       # Let's Encrypt challenges
|
docker-compose.yml              # Basic configuration
docker-compose.dev.yml         # Development
docker-compose.prod.yml        # Production
setup-ssl.sh                   # SSL setup script
.env.example                   # Environment template
README.md
```

## API Endpoints

### Backend API

- `POST /api/chat` - Send message to Groq AI
  ```json
  {
    "message": "Hello, how are you?",
    "history": [
      {"role": "user", "content": "Previous message"},
      {"role": "assistant", "content": "Previous response"}
    ]
  }
  ```

- `GET /api/health` - Health check endpoint

### Frontend Features

- Real-time chat interface
- Message history
- Typing indicators
- Error handling
- Responsive design
- Clear chat functionality

## Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GROQ_API_KEY` | Groq API authentication key | Required |
| `DOMAIN` | Domain name for SSL setup | localhost |
| `EMAIL` | Email for Let's Encrypt | admin@domain |
| `NODE_ENV` | Environment mode | development |
| `PORT` | Backend server port | 5000 |

### Groq Model Configuration

Edit `server/index.js` to change the AI model:

```javascript
model: 'mixtral-8x7b-32768',  // Change to other Groq models
```

Available models:
- `mixtral-8x7b-32768`
- `llama2-70b-4096`
- `gemma-7b-it`

## Security Features

- **Rate Limiting**: 100 requests per 15 minutes per IP
- **CORS Protection**: Configurable origin whitelist
- **Security Headers**: Helmet.js middleware
- **Input Validation**: Request sanitization
- **SSL/TLS**: HTTPS enforcement in production
- **API Key Protection**: Server-side only storage

## Monitoring and Logs

### View Logs

```bash
# View all services logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f client
docker-compose logs -f server
docker-compose logs -f nginx
```

### Health Checks

```bash
# Check backend health
curl http://localhost:5000/api/health

# Check nginx status
curl http://localhost/health
```

## Development

### Local Development

For local development without Docker:

```bash
# Install dependencies
npm install

# Start backend
cd server && npm install && npm run dev

# Start frontend (new terminal)
cd client && npm install && npm start
```

### Hot Reload

Development containers support hot reload:
- Frontend changes auto-reload
- Backend changes restart the server

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 443, 3000, and 5000 are available
2. **SSL errors**: Verify certificate paths and permissions
3. **API errors**: Check Groq API key in environment variables
4. **Build failures**: Clear Docker cache with `docker system prune`

### Reset Application

```bash
# Stop and remove containers
docker-compose down -v

# Remove images
docker rmi $(docker images -q groq-chat-app_*) 2>/dev/null || true

# Rebuild and start
docker-compose -f docker-compose.dev.yml up --build
```

## Production Deployment

### System Requirements

- **RAM**: Minimum 2GB, recommended 4GB
- **CPU**: 2+ cores recommended
- **Storage**: 10GB minimum
- **Network**: Stable internet connection for Groq API

### Performance Optimization

1. **Enable Nginx caching** for static assets
2. **Use CDN** for frontend assets
3. **Monitor resources** and scale as needed
4. **Configure log rotation** for production logs

### Backup Strategy

- Backup SSL certificates regularly
- Export environment configurations
- Monitor Groq API usage and costs

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
1. Check this README and troubleshooting section
2. Review Docker logs for error messages
3. Verify Groq API status and key validity
4. Check network connectivity and DNS settings
