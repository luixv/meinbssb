const express = require('express');
const axios = require('axios');
const FormData = require('form-data');
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

app.post('/', async (req, res) => {
  try {
    console.log('Received token request');

    // Create form data
    const formData = new FormData();
    formData.append('username', USERNAME_WEB_USER);
    formData.append('password', PASSWORD_WEB_USER);

    console.log(`Fetching token from: ${TOKEN_SERVER_URL}`);

    // Make request to external token server
    const response = await axios.post(TOKEN_SERVER_URL, formData, {
      headers: {
        ...formData.getHeaders()
      },
      httpsAgent: httpsAgent,
      timeout: 30000 // 30 second timeout
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
    console.error('Error fetching token:', err.message);
    if (err.response) {
      console.error('Response status:', err.response.status);
      console.error('Response data:', err.response.data);
    }
    res.status(500).json({
      error: 'Failed to fetch token',
      details: err.message
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
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

