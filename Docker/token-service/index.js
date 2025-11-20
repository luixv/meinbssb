const express = require('express');
const axios = require('axios');
const multer = require('multer');
const jwt = require('jsonwebtoken');
const app = express();

// Support both JSON and form-data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const upload = multer();

// JWT configuration for PostgREST tokens
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
const JWT_EXPIRY = process.env.JWT_EXPIRY || '24h';

// Credentials for ZMI server (stored on server, not in client)
const ZMI_CREDENTIALS = {
  username: process.env.ZMI_USERNAME || '',
  password: process.env.ZMI_PASSWORD || ''
};

// Configuration for the actual token server
const TOKEN_SERVER_CONFIG = {
  protocol: process.env.TOKEN_SERVER_PROTOCOL || 'https',
  host: process.env.TOKEN_SERVER_HOST || 'webintern.bssb.bayern',
  port: process.env.TOKEN_SERVER_PORT || '50211',
  path: process.env.TOKEN_SERVER_PATH || 'rest/zmi/token'
};

// Build the token server URL
const getTokenServerUrl = () => {
  const { protocol, host, port, path } = TOKEN_SERVER_CONFIG;
  return `${protocol}://${host}:${port}/${path}`;
};

app.post('/token', async (req, res) => {
  // Credentials are stored on server in environment variables
  const username = ZMI_CREDENTIALS.username;
  const password = ZMI_CREDENTIALS.password;
  
  if (!username || !password) {
    console.error('ZMI credentials not configured in environment variables');
    return res.status(500).json({ error: 'Server configuration error: credentials not set.' });
  }

  const tokenServerUrl = getTokenServerUrl();
  console.log(`Token request to ${tokenServerUrl} (using server-side credentials)`);
  console.log(`Username: ${username}, Password: ${password ? '***' : 'NOT SET'}`);

  try {
    // Create form data with server-side credentials
    // ZMI server expects multipart/form-data with username and password in body
    const FormData = require('form-data');
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    const formHeaders = formData.getHeaders();
    console.log(`Sending request with Content-Type: ${formHeaders['content-type']}`);

    // Make request to actual token server
    const response = await axios.post(tokenServerUrl, formData, {
      headers: formHeaders,
      // Allow self-signed certificates for internal server
      httpsAgent: new (require('https').Agent)({
        rejectUnauthorized: false
      }),
      timeout: 30000 // 30 second timeout
    });

    console.log(`Token request successful, status: ${response.status}`);
    // Forward the response from the token server
    res.status(response.status).json(response.data);
  } catch (err) {
    console.error('Error fetching token:', err.message);
    if (err.response) {
      console.error(`ZMI server responded with status ${err.response.status}:`, err.response.data);
      // Forward error response from token server
      res.status(err.response.status).json(err.response.data);
    } else if (err.code === 'ECONNABORTED') {
      console.error('Request timeout - ZMI server did not respond in time');
      res.status(504).json({ error: 'Gateway timeout', details: 'ZMI server did not respond in time' });
    } else {
      console.error('Network error:', err.code, err.message);
      res.status(500).json({ error: 'Failed to fetch token', details: err.message });
    }
  }
});

// PostgREST JWT token endpoint
app.post('/postgrest-token', async (req, res) => {
  // Credentials are stored on server in environment variables
  const username = ZMI_CREDENTIALS.username;
  const password = ZMI_CREDENTIALS.password;
  
  if (!username || !password) {
    console.error('ZMI credentials not configured in environment variables');
    return res.status(500).json({ error: 'Server configuration error: credentials not set.' });
  }

  console.log(`PostgREST JWT token request (using server-side credentials)`);

  try {
    // First verify credentials with ZMI server
    const tokenServerUrl = getTokenServerUrl();
    const FormData = require('form-data');
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    const formHeaders = formData.getHeaders();
    console.log(`Sending ZMI request with Content-Type: ${formHeaders['content-type']}`);

    const response = await axios.post(tokenServerUrl, formData, {
      headers: formHeaders,
      httpsAgent: new (require('https').Agent)({
        rejectUnauthorized: false
      }),
      timeout: 30000 // 30 second timeout
    });

    // If ZMI authentication succeeds, generate PostgREST JWT
    if (response.status === 200) {
      // Generate JWT token for PostgREST
      // The role should match a PostgreSQL role that has appropriate permissions
      const payload = {
        role: 'bssbuser', // PostgreSQL role with database access
        username: username,
        exp: Math.floor(Date.now() / 1000) + (24 * 60 * 60) // 24 hours expiry
      };

      const postgrestToken = jwt.sign(payload, JWT_SECRET);
      
      console.log('PostgREST JWT token generated successfully');
      res.status(200).json({
        token: postgrestToken,
        expiresIn: JWT_EXPIRY,
        role: 'bssbuser'
      });
    }
  } catch (err) {
    console.error('Error generating PostgREST token:', err.message);
    if (err.response) {
      // Authentication failed
      res.status(err.response.status).json({ error: 'Authentication failed' });
    } else {
      res.status(500).json({ error: 'Failed to generate token', details: err.message });
    }
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'token-service' });
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => console.log(`Token service running on port ${PORT}`));

