const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // mock-data.json laden

router.get('/:AbDatum/:flag', (req, res) => {
    // Routenparameter extrahieren
    const abDatum = req.params.AbDatum; // Format: DD.MM.YYYY
    const flag = req.params.flag; // Format: DD.MM.YYYY

    // Empfangene Parameter protokollieren
    console.log("AbDatum:", abDatum);
    console.log("flag:", flag);


    // Validate the date and flag 
    if (!abDatum || !flag) {
        return res.status(400).json({ error: 'Invalid parameters' });
    }

    // Check if flag is 'false'
    if (flag !== 'false') {
        return res.status(400).json({ error: 'Flag must be "false"' });
    }

    // AbDatum-Format validieren (DD.MM.YYYY)
    if (!/^\d{2}\.\d{2}\.\d{4}$/.test(abDatum)) {
        return res.status(400).json({
            success: false,
            message: "Ungültiges Datumsformat. Verwenden Sie DD.MM.YYYY.",
        });
    }

    // Mock-Daten als Antwort senden
    res.status(200).json(data.schulungstermine); // schulungen aus mock-data.json verwenden
});

module.exports = router;