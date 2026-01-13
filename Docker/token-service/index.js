const express = require('express');
const axios = require('axios');
const FormData = require('form-data');
const https = require('https');
const app = express();

app.use(express.json());

// Get credentials from environment variables
const ZMI_USERNAME = process.env.ZMI_USERNAME;
const ZMI_PASSWORD = process.env.ZMI_PASSWORD;
const ZMI_TOKEN_URL = process.env.ZMI_TOKEN_URL || 'https://webintern.bssb.bayern:50211/rest/zmi/token';

// Validate environment variables
if (!ZMI_USERNAME || !ZMI_PASSWORD) {
  console.error('ERROR: ZMI_USERNAME and ZMI_PASSWORD environment variables must be set');
  process.exit(1);
}

console.log(`Token service initialized with ZMI_TOKEN_URL: ${ZMI_TOKEN_URL}`);

app.post('/get-token', async (req, res) => {
  try {
    console.log('Fetching token from ZMI server...');
    
    // Create form data with credentials
    const formData = new FormData();
    formData.append('username', ZMI_USERNAME);
    formData.append('password', ZMI_PASSWORD);

    // Configure axios to allow self-signed certificates (similar to Flutter's badCertificateCallback)
    const httpsAgent = new https.Agent({
      rejectUnauthorized: false
    });

    // Make request to ZMI token endpoint
    const response = await axios.post(ZMI_TOKEN_URL, formData, {
      headers: {
        ...formData.getHeaders(),
      },
      httpsAgent: httpsAgent,
      timeout: 30000 // 30 second timeout
    });

    console.log('Successfully fetched token from ZMI server');
    console.log('Response status:', response.status);

    // Return the token response
    if (response.status === 200 && response.data) {
      res.status(200).json(response.data);
    } else {
      console.error('Unexpected response from ZMI server:', response.status);
      res.status(500).json({ error: 'Failed to fetch token from ZMI server' });
    }
  } catch (err) {
    console.error('Error fetching token from ZMI server:', err.message);
    if (err.response) {
      console.error('Response status:', err.response.status);
      console.error('Response data:', err.response.data);
    }
    res.status(500).json({ 
      error: 'Failed to fetch token',
      message: err.message 
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

const PORT = 3002;
app.listen(PORT, () => {
  console.log(`Token service running on port ${PORT}`);
});
