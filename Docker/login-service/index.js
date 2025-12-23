const express = require('express');
const axios = require('axios');
const FormData = require('form-data');
const https = require('https');

const app = express();
app.use(express.json());

// Configuration from environment variables with sensible defaults
const TOKEN_SERVER_URL = process.env.TOKEN_SERVER_URL || 'https://webintern.bssb.bayern:56400/rest/zmi/token';
const USERNAME_WEB_USER = process.env.USERNAME_WEB_USER || 'webUser';
const PASSWORD_WEB_USER = process.env.PASSWORD_WEB_USER || '';
const API1_BASE_URL = process.env.API1_BASE_URL || 'https://webintern.bssb.bayern:56400/rest/zmi/api1';
const LOGIN_ENDPOINT = 'LoginMeinBSSBApp';

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

app.post('/bssb-token', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({
      ResultType: 0,
      ResultMessage: 'Email und Passwort sind erforderlich',
    });
  }

  try {
    const token = await getToken();
    const loginData = { Email: email, Passwort: password };

    const loginResponse = await axios.post(
      `${API1_BASE_URL}/${LOGIN_ENDPOINT}`,
      loginData,
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        httpsAgent,
        timeout: 40000,
      },
    );

    return res.status(200).json(loginResponse.data);
  } catch (error) {
    // If unauthorized, try to refresh token once
    if (error.response && (error.response.status === 401 || error.response.status === 403)) {
      try {
        cachedToken = null;
        const newToken = await fetchToken();
        const loginData = { Email: email, Passwort: password };
        const retryResponse = await axios.post(
          `${API1_BASE_URL}/${LOGIN_ENDPOINT}`,
          loginData,
          {
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${newToken}`,
            },
            httpsAgent,
            timeout: 40000,
          },
        );
        return res.status(200).json(retryResponse.data);
      } catch (retryError) {
        return res.status(error.response.status).json(retryError.response?.data || {
          ResultType: 0,
          ResultMessage: 'Anmeldung fehlgeschlagen',
        });
      }
    }

    if (error.response) {
      return res.status(error.response.status).json(error.response.data || {
        ResultType: 0,
        ResultMessage: 'Anmeldung fehlgeschlagen',
      });
    }

    if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT' || `${error.message}`.includes('timeout')) {
      return res.status(500).json({
        ResultType: 0,
        ResultMessage: 'Netzwerkfehler: Bitte überprüfen Sie Ihre Internetverbindung.',
      });
    }

    return res.status(500).json({
      ResultType: 0,
      ResultMessage: error.message || 'Anmeldung fehlgeschlagen',
    });
  }
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`Login service running on port ${PORT}`);
});
