const express = require('express');
const axios = require('axios');
const FormData = require('form-data');
const https = require('https');

const app = express();
app.use(express.json());

// Configuration from environment variables with sensible defaults
const TOKEN_SERVER_URL =
  process.env.TOKEN_SERVER_URL ||
  'https://webintern.bssb.bayern:56400/rest/zmi/token';
const USERNAME_WEB_USER = process.env.USERNAME_WEB_USER || 'webUser';
const PASSWORD_WEB_USER = process.env.PASSWORD_WEB_USER || '';

// Simple in-memory cache for the token
let cachedToken = null;
let tokenExpiration = null;
const TOKEN_CACHE_DURATION = 55 * 60 * 1000; // 55 minutes

const httpsAgent = new https.Agent({ rejectUnauthorized: false });

async function fetchToken() {
  const formData = new FormData();
  formData.append('username', USERNAME_WEB_USER);
  formData.append('password', PASSWORD_WEB_USER);

  const response = await axios.post(TOKEN_SERVER_URL, formData, {
    headers: formData.getHeaders(),
    httpsAgent,
  });

  if (response.status === 200 && response.data && response.data.Token) {
    cachedToken = response.data.Token;
    tokenExpiration = Date.now() + TOKEN_CACHE_DURATION;
    return cachedToken;
  }

  throw new Error('Invalid token response from token server');
}

async function getToken() {
  if (cachedToken && tokenExpiration && Date.now() < tokenExpiration) {
    return cachedToken;
  }
  return fetchToken();
}

// Public endpoint for returning the current service token
app.post('/bssb-token', async (_req, res) => {
  try {
    const token = await getToken();
    return res.status(200).json({ Token: token });
  } catch (error) {
    console.error('Error in /bssb-token:', error);
    return res.status(500).json({
      ResultType: 0,
      ResultMessage: 'Tokenabruf fehlgeschlagen',
    });
  }
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Login service running on port ${PORT}`);
});
