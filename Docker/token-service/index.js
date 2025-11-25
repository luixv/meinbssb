const express = require('express');
const axios = require('axios');
const https = require('https');
const app = express();

app.use(express.json());

// Configure axios to ignore SSL certificate validation
const httpsAgent = new https.Agent({
  rejectUnauthorized: false
});

// Get environment variables
const TOKEN_SERVER_URL = process.env.TOKEN_SERVER_URL;
const USERNAME_WEB_USER = process.env.USERNAME_WEB_USER;
const PASSWORD_WEB_USER = process.env.PASSWORD_WEB_USER;

// Validate required environment variables
if (!TOKEN_SERVER_URL || !USERNAME_WEB_USER || !PASSWORD_WEB_USER) {
  console.error('ERROR: Missing required environment variables');
  console.error('Required: TOKEN_SERVER_URL, USERNAME_WEB_USER, PASSWORD_WEB_USER');
  process.exit(1);
}

console.log(`Token service configured to fetch from: ${TOKEN_SERVER_URL}`);

app.post('/zmi-token', async (req, res) => {
  try {
    console.log('Received token request from Flutter app');

    // Use URLSearchParams for application/x-www-form-urlencoded format
    // This is more compatible with standard REST APIs than multipart/form-data
    const params = new URLSearchParams();
    params.append('username', USERNAME_WEB_USER);
    params.append('password', PASSWORD_WEB_USER);

    console.log(`Fetching token from: ${TOKEN_SERVER_URL}`);
    console.log(`Sending credentials - Username: ${USERNAME_WEB_USER}`);
    console.log(`Sending credentials - Password: ${PASSWORD_WEB_USER.substring(0, 10)}...`);

    // Make POST request to external token server
    // URLSearchParams sends Content-Type: application/x-www-form-urlencoded
    const response = await axios.post(TOKEN_SERVER_URL, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      httpsAgent: httpsAgent, // Allow self-signed certificates
      timeout: 60000, // 60 second timeout
      maxRedirects: 5, // Follow redirects if needed
      validateStatus: (status) => status >= 200 && status < 300, // Only 2xx is success
    });

    console.log(`Token server response status: ${response.status}`);

    if (response.status === 200 && response.data && response.data.Token) {
      console.log('Token fetched successfully');
      res.status(200).json({
        Token: response.data.Token
      });
    } else {
      console.error('Token not found in response');
      res.status(500).json({
        error: 'Token not found in response'
      });
    }
  } catch (err) {
    console.error('=== Error fetching token ===');
    console.error('Error message:', err.message);
    console.error('Error code:', err.code);
    
    if (err.response) {
      // External server responded with error
      console.error('External server response status:', err.response.status);
      console.error('External server response data:', JSON.stringify(err.response.data));
      
      return res.status(err.response.status).json({
        error: 'External token server error',
        status: err.response.status,
        details: err.response.data || err.message
      });
    } else if (err.request) {
      // Request was sent but no response received
      console.error('No response from external token server');
      console.error('Error code:', err.code);
      console.error('Error cause:', err.cause);
      
      // Provide more specific error information
      let errorDetail = 'No response from external server';
      if (err.code === 'ECONNREFUSED') {
        errorDetail = 'Connection refused - server may be down or port blocked';
      } else if (err.code === 'ETIMEDOUT' || err.code === 'ECONNABORTED') {
        errorDetail = 'Connection timed out - server may be unreachable';
      } else if (err.code === 'ENOTFOUND') {
        errorDetail = 'DNS lookup failed - hostname could not be resolved';
      } else if (err.code === 'CERT_HAS_EXPIRED' || err.code === 'UNABLE_TO_VERIFY_LEAF_SIGNATURE') {
        errorDetail = 'SSL certificate error';
      }
      
      return res.status(503).json({
        error: 'Token server unreachable',
        code: err.code,
        details: errorDetail
      });
    } else {
      // Error setting up the request
      console.error('Request setup error:', err.message);
      
      return res.status(500).json({
        error: 'Failed to fetch token',
        details: err.message
      });
    }
  }
});

// Health check endpoint
app.get('/zmi-token/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'token-service',
    tokenServerConfigured: !!TOKEN_SERVER_URL
  });
});

const PORT = 3002;
app.listen(PORT, () => {
  console.log(`Token service running on port ${PORT}`);
  console.log('Environment variables loaded:');
  console.log(`- TOKEN_SERVER_URL: ${TOKEN_SERVER_URL ? 'Set' : 'Missing'}`);
  console.log(`- USERNAME_WEB_USER: ${USERNAME_WEB_USER ? 'Set' : 'Missing'}`);
  console.log(`- PASSWORD_WEB_USER: ${PASSWORD_WEB_USER ? 'Set' : 'Missing'}`);
});

