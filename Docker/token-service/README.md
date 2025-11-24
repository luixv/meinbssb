# Token Service

A Node.js microservice that securely fetches authentication tokens from an external API server.

## Purpose

This service acts as a secure proxy between the Flutter application and the external token server. Instead of storing sensitive credentials in the client app, they are kept as environment variables on the server side.

## Architecture

```
Flutter App → Token Service → External Token Server
                (Docker)        (webintern.bssb.bayern)
```

## Endpoints

### POST /

Fetches a new authentication token from the external token server.

**Note:** When accessed through Caddy, the full path is `/zmi-token`.

**Request:**
- Method: `POST`
- Headers: `Content-Type: application/json`
- Body: None required (credentials are stored in environment variables)

**Response:**
```json
{
  "Token": "your-authentication-token-here"
}
```

**Error Response:**
```json
{
  "error": "Failed to fetch token",
  "details": "error message"
}
```

### GET /health

Health check endpoint to verify the service is running.

**Response:**
```json
{
  "status": "ok",
  "service": "token-service",
  "tokenServerConfigured": true
}
```

## Environment Variables

Required environment variables (defined in Docker Compose):

- `TOKEN_SERVER_URL` - The URL of the external token server
- `USERNAME_WEB_USER` - Username for authentication
- `PASSWORD_WEB_USER` - Password/hash for authentication

## Configuration

### In Docker Compose

The service is configured in `docker-compose.{prod|test}.yml`:

```yaml
token-service:
  build: ./token-service
  container_name: token-service
  restart: always
  environment:
    - TOKEN_SERVER_URL=${TOKEN_SERVER_URL}
    - USERNAME_WEB_USER=${USERNAME_WEB_USER}
    - PASSWORD_WEB_USER=${PASSWORD_WEB_USER}
```

### In Caddyfile

The service is exposed via Caddy reverse proxy on the `/zmi-token` path:

```
https://meinprod.bssb.de {
  handle /zmi-token* {
    reverse_proxy token-service:3002
    header {
      Access-Control-Allow-Origin "*"
      Access-Control-Allow-Methods "POST, OPTIONS"
      Access-Control-Allow-Headers "Authorization, Content-Type"
    }
  }
}
```

### In Flutter App

The app configuration files (`config.json`, `config.prod.json`, `config.test.json`, `config.dev.json`) now use:

```json
{
  "tokenProtocol": "https",
  "tokenServer": "meinprod.bssb.de",
  "tokenPort": "443",
  "tokenPath": "zmi-token"
}
```

## Security Features

1. **Credentials isolation**: Sensitive credentials are stored only on the server side as environment variables
2. **SSL/TLS**: The service ignores certificate validation for the external server (required for internal servers)
3. **CORS enabled**: Allows the Flutter web app to make requests
4. **No client-side secrets**: The Flutter app never has access to the credentials

## Development

### Local Testing

```bash
cd Docker/token-service
npm install

# Set environment variables
export TOKEN_SERVER_URL="https://webintern.bssb.bayern:56400/rest/zmi/token"
export USERNAME_WEB_USER="webUser"
export PASSWORD_WEB_USER="your-password-here"

# Run the service
node index.js
```

### Docker Build

```bash
cd Docker
docker-compose build token-service
docker-compose up token-service
```

## Dependencies

- `express` - Web framework
- `axios` - HTTP client
- `form-data` - For multipart form requests

## Port

The service runs on port **3002** internally and is exposed via Caddy at the path **/zmi-token** on the main domain (port 443).

