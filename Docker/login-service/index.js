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

// Log configuration on startup (without exposing password)
console.log('=== Login Service Starting ===');
console.log(`TOKEN_SERVER_URL: ${TOKEN_SERVER_URL}`);
console.log(`USERNAME_WEB_USER: ${USERNAME_WEB_USER}`);
console.log(`PASSWORD_WEB_USER: ${PASSWORD_WEB_USER ? '[SET]' : '[NOT SET - EMPTY!]'}`);
console.log(`PORT: ${process.env.PORT || 3002}`);
console.log(`TOKEN_CACHE_DURATION: ${TOKEN_CACHE_DURATION}ms (${TOKEN_CACHE_DURATION / 60000} minutes)`);
console.log('============================');

async function fetchToken() {
  console.log('[fetchToken] Starting token fetch from server...');
  console.log(`[fetchToken] Target URL: ${TOKEN_SERVER_URL}`);
  console.log(`[fetchToken] Username: ${USERNAME_WEB_USER}`);
  console.log(`[fetchToken] Password: ${PASSWORD_WEB_USER ? '[PROVIDED]' : '[MISSING - EMPTY!]'}`);
  
  if (!PASSWORD_WEB_USER) {
    console.error('[fetchToken] ERROR: PASSWORD_WEB_USER is empty! Cannot authenticate.');
    throw new Error('PASSWORD_WEB_USER is not configured');
  }

  const formData = new FormData();
  formData.append('username', USERNAME_WEB_USER);
  formData.append('password', PASSWORD_WEB_USER);

  const formHeaders = formData.getHeaders();
  console.log(`[fetchToken] Request headers:`, formHeaders);

  try {
    console.log('[fetchToken] Sending POST request to token server...');
    const response = await axios.post(TOKEN_SERVER_URL, formData, {
      headers: formHeaders,
      httpsAgent,
    });

    console.log(`[fetchToken] Response status: ${response.status}`);
    console.log(`[fetchToken] Response headers:`, JSON.stringify(response.headers, null, 2));
    console.log(`[fetchToken] Response data:`, JSON.stringify(response.data, null, 2));

    if (response.status === 200 && response.data && response.data.Token) {
      const token = response.data.Token;
      console.log(`[fetchToken] Token received successfully (length: ${token.length})`);
      cachedToken = token;
      tokenExpiration = Date.now() + TOKEN_CACHE_DURATION;
      console.log(`[fetchToken] Token cached until: ${new Date(tokenExpiration).toISOString()}`);
      return cachedToken;
    } else {
      console.error('[fetchToken] Invalid response structure:');
      console.error(`  - Status: ${response.status}`);
      console.error(`  - Has data: ${!!response.data}`);
      console.error(`  - Has Token: ${!!(response.data && response.data.Token)}`);
      if (response.data) {
        console.error(`  - Response data:`, response.data);
      }
      throw new Error('Invalid token response from token server');
    }
  } catch (error) {
    console.error('[fetchToken] Request failed:');
    console.error(`  - Error message: ${error.message}`);
    if (error.response) {
      console.error(`  - Response status: ${error.response.status}`);
      console.error(`  - Response data:`, JSON.stringify(error.response.data, null, 2));
      console.error(`  - Response headers:`, JSON.stringify(error.response.headers, null, 2));
    } else if (error.request) {
      console.error(`  - No response received`);
      console.error(`  - Request details:`, error.request);
    } else {
      console.error(`  - Error config:`, error.config);
    }
    console.error(`  - Full error:`, error);
    throw error;
  }
}

async function getToken() {
  const now = Date.now();
  console.log('[getToken] Checking for cached token...');
  console.log(`[getToken] Current time: ${new Date(now).toISOString()}`);
  console.log(`[getToken] Cached token exists: ${!!cachedToken}`);
  console.log(`[getToken] Token expiration: ${tokenExpiration ? new Date(tokenExpiration).toISOString() : 'N/A'}`);
  
  if (cachedToken && tokenExpiration && now < tokenExpiration) {
    const timeUntilExpiry = tokenExpiration - now;
    console.log(`[getToken] Using cached token (expires in ${Math.floor(timeUntilExpiry / 1000)} seconds)`);
    return cachedToken;
  }
  
  if (cachedToken && tokenExpiration && now >= tokenExpiration) {
    console.log(`[getToken] Cached token expired (${Math.floor((now - tokenExpiration) / 1000)} seconds ago), fetching new token...`);
  } else {
    console.log('[getToken] No cached token available, fetching new token...');
  }
  
  return fetchToken();
}

// Public endpoint for returning the current service token
app.post('/bssb-token', async (req, res) => {
  const requestTime = new Date().toISOString();
  console.log(`\n[POST /bssb-token] Request received at ${requestTime}`);
  console.log(`[POST /bssb-token] Request headers:`, JSON.stringify(req.headers, null, 2));
  console.log(`[POST /bssb-token] Request body:`, JSON.stringify(req.body, null, 2));
  console.log(`[POST /bssb-token] Request IP: ${req.ip}`);
  console.log(`[POST /bssb-token] Request path: ${req.path}`);
  console.log(`[POST /bssb-token] Request method: ${req.method}`);
  
  try {
    console.log('[POST /bssb-token] Calling getToken()...');
    const token = await getToken();
    console.log(`[POST /bssb-token] Token retrieved successfully (length: ${token.length})`);
    console.log(`[POST /bssb-token] Sending 200 response with token`);
    return res.status(200).json({ Token: token });
  } catch (error) {
    console.error('[POST /bssb-token] Error occurred:');
    console.error(`  - Error type: ${error.constructor.name}`);
    console.error(`  - Error message: ${error.message}`);
    console.error(`  - Error stack:`, error.stack);
    console.error(`[POST /bssb-token] Sending 500 error response`);
    return res.status(500).json({
      ResultType: 0,
      ResultMessage: 'Tokenabruf fehlgeschlagen',
      Error: error.message,
    });
  }
});

// Add health check endpoint
app.get('/health', (req, res) => {
  console.log('[GET /health] Health check requested');
  res.status(200).json({
    status: 'ok',
    service: 'login-service',
    timestamp: new Date().toISOString(),
    hasCachedToken: !!cachedToken,
    tokenExpiresAt: tokenExpiration ? new Date(tokenExpiration).toISOString() : null,
    config: {
      tokenServerUrl: TOKEN_SERVER_URL,
      username: USERNAME_WEB_USER,
      passwordSet: !!PASSWORD_WEB_USER,
    },
  });
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`\n========================================`);
  console.log(`Login service running on port ${PORT}`);
  console.log(`Service started at: ${new Date().toISOString()}`);
  console.log(`========================================\n`);
});
