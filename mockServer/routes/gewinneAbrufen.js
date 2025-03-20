const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // mock-data.json laden

router.post('/rest/zmi/api7/GewinneAbrufen', (req, res) => {
    console.log(req.body);
    const { IBAN, Passnummer } = req.body;

    // Empfangene Parameter protokollieren
    console.log("IBAN:", IBAN);
    console.log("Passnummer:", Passnummer);

    // Mock-Daten als Antwort senden
    res.status(200).json({result: true});
});

module.exports = router;