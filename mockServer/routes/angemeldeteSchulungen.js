const express = require('express');
const router = express.Router();

const schulungen = [
    {
        DATUM: "2025-04-12T00:00:00.000+02:00",
        BEZEICHNUNG: "Digitale Evolution 2.0: Deine Reise in die digitale Zukunft der neuen Medien",
        SCHULUNGENTEILNEHMERID: 27203,
        SCHULUNGENTERMINID: 1570,
        SCHULUNGSARTID: 2000000326,
        STATUS: 0,
        DATUMBIS: "",
        FUERVERLAENGERUNGEN: true
    },
    {
        DATUM: "2025-05-03T00:00:00.000+02:00",
        BEZEICHNUNG: "ZMI Client für Vereine",
        SCHULUNGENTEILNEHMERID: 27204,
        SCHULUNGENTERMINID: 1632,
        SCHULUNGSARTID: 2000000001,
        STATUS: 0,
        DATUMBIS: "",
        FUERVERLAENGERUNGEN: true
    }
];

router.get('/:PersonID/:AbDatum', (req, res) => {
    // Extract route parameters
    const personId = req.params.PersonID;
    const abDatum = req.params.AbDatum; // Format: DD.MM.YYYY

    // Log the received parameters
    console.log("Received request for AngemeldeteSchulungen with:");
    console.log("PersonID:", personId);
    console.log("AbDatum:", abDatum);

    // Validate AbDatum format (DD.MM.YYYY)
    if (!/^\d{2}\.\d{2}\.\d{4}$/.test(abDatum)) {
        return res.status(400).json({
            success: false,
            message: "Invalid date format. Use DD.MM.YYYY.",
        });
    }

    // Send the mock data as a response
    res.status(200).json(schulungen);
});

module.exports = router;