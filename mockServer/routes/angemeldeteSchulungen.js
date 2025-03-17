const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // mock-data.json laden

router.get('/:PersonID/:AbDatum', (req, res) => {
    // Routenparameter extrahieren
    const personId = req.params.PersonID;
    const abDatum = req.params.AbDatum; // Format: DD.MM.YYYY

    // Empfangene Parameter protokollieren
    console.log("Anfrage für AngemeldeteSchulungen erhalten mit:");
    console.log("PersonID:", personId);
    console.log("AbDatum:", abDatum);

    // AbDatum-Format validieren (DD.MM.YYYY)
    if (!/^\d{2}\.\d{2}\.\d{4}$/.test(abDatum)) {
        return res.status(400).json({
            success: false,
            message: "Ungültiges Datumsformat. Verwenden Sie DD.MM.YYYY.",
        });
    }

    // Mock-Daten als Antwort senden
    res.status(200).json(data.schulungen); // schulungen aus mock-data.json verwenden
});

module.exports = router;