const express = require('express');
const router = express.Router();
const data = require('../mock-data.json'); // mock-data.json laden

// https://bssb.bayern:50211/rest/zmi/api7/Gewinne/2024/Gewinne/{Jahr}/{Passnummer}

router.get('/rest/zmi/api7/Gewinne/:jahr/:passnummer', (req, res) => {
	console.log("Oktoberfestlandesschiessen:");

    // Routenparameter extrahieren
    const jahr = req.params.jahr; 
    const passnummer = req.params.passnummer; 

	// Oktoberfestlandesschiessen
    // Empfangene Parameter protokollieren
    console.log("jahr:", jahr);
    console.log("passnummer:", passnummer);


    // Mock-Daten als Antwort senden
    res.status(200).json(data.oktoberfestlandesschiessen); // oktoberfestlandesschiessen aus mock-data.json verwenden
});

module.exports = router;