const express = require('express');
const router = express.Router();

const passdaten = {
    "luis@mandel.pro": {
        // Your passdaten object here
    }
};

const zweitmitgliedschaften = {
    "luis@mandel.pro": [
        { "club": "Zweitverein A", "right": "Luftgewehr" },
        { "club": "Zweitverein B", "right": "Pistole" }
    ]
};

const passZweitvereinseintraege = {
    "luis@mandel.pro": [
        { "club": "Zweitverein A", "entry": "Eintrag 1" },
        { "club": "Zweitverein B", "entry": "Eintrag 2" }
    ]
};

router.get('/', async (req, res) => {
    const { username } = req.query;

    // Simulate Passdaten retrieval
    const passdatenForUser = passdaten[username] || null;

    // Simulate Zweitmitgliedschaften retrieval
    const zweitmitgliedschaftenForUser = zweitmitgliedschaften[username] || [];

    // Simulate Pass-Zweitvereinseintraege retrieval
    const passZweitvereinseintraegeForUser = passZweitvereinseintraege[username] || [];

    // Combine the results into a single JSON object
    const combinedResult = {
        passdaten: passdatenForUser,
        zweitmitgliedschaften: zweitmitgliedschaftenForUser,
        passZweitvereinseintraege: passZweitvereinseintraegeForUser
    };

    if (passdatenForUser) {
        res.status(200).json(combinedResult);
    } else {
        res.status(404).json({ message: "User not found" });
    }
});

module.exports = router;