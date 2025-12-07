const express = require('express');
const FormData = require('form-data');
const fetch = require('node-fetch');

const app = express();
const PORT = 3002;

// Middleware to parse JSON and form data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'token-proxy' });
});

// Token proxy endpoint
app.post('/token', async (req, res) => {
  try {
    console.log('[Token Proxy] Received token request');
    
    // Get credentials from environment variables
    const username = process.env.USERNAME_WEB_USER;
    const password = process.env.PASSWORD_WEB_USER;
    const tokenServerUrl = process.env.TOKEN_SERVER_URL;

    if (!username || !password) {
      console.error('[Token Proxy] Missing credentials in environment variables');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    if (!tokenServerUrl) {
      console.error('[Token Proxy] Missing TOKEN_SERVER_URL in environment variables');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    console.log(`[Token Proxy] Forwarding to: ${tokenServerUrl}`);
    console.log(`[Token Proxy] Username: ${username}`);

    // Create form data with credentials
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    // Forward request to actual token server
    const response = await fetch(tokenServerUrl, {
      method: 'POST',
      body: formData,
      headers: formData.getHeaders(),
    });

    const responseText = await response.text();
    console.log(`[Token Proxy] Response status: ${response.status}`);
    console.log(`[Token Proxy] Response body: ${responseText}`);

    // Forward the response
    res.status(response.status);
    res.set('Content-Type', response.headers.get('content-type'));
    res.send(responseText);

  } catch (error) {
    console.error('[Token Proxy] Error:', error);
    res.status(500).json({ error: 'Failed to fetch token' });
  }
});

app.listen(PORT, () => {
  console.log(`[Token Proxy] Server running on port ${PORT}`);
  console.log(`[Token Proxy] Username configured: ${process.env.USERNAME_WEB_USER ? 'Yes' : 'No'}`);
  console.log(`[Token Proxy] Password configured: ${process.env.PASSWORD_WEB_USER ? 'Yes' : 'No'}`);
  console.log(`[Token Proxy] Target URL: ${process.env.TOKEN_SERVER_URL || 'NOT SET'}`);
});

