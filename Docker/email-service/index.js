const express = require('express');
const nodemailer = require('nodemailer');
const app = express();
app.use(express.json());

const transporter = nodemailer.createTransport({
  host: 'postfix-relay',
  port: 25,
  secure: false, // false for port 25
  tls: {
    rejectUnauthorized: false
  }
});

app.post('/send-email', async (req, res) => {
  const { to, subject, html } = req.body;
  if (!to || !subject || (!body && !html)) {
    return res.status(400).json({ error: 'Missing to, subject, or content.' });
  }
  try {
    await transporter.sendMail({
      from: 'webportal@bssb.bayern',
      to,
      subject,
      html
    });
    res.status(200).json({ success: true });
  } catch (err) {
    console.error('Error sending email:', err);
    res.status(500).json({ error: 'Failed to send email' });
  }
});
const PORT = 3001;
app.listen(PORT, () => console.log('Email service running on port 3000'));