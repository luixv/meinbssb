const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // Load the JSON file

router.get('/', async (req, res) => {
    const { username } = req.query;

    // Simulate Passdaten retrieval
    const passdatenForUser = data.passdaten[username] || null;

    // Simulate Zweitmitgliedschaften retrieval
    const zweitmitgliedschaftenForUser = data.zweitmitgliedschaften[username] || [];

    // Simulate Pass-Zweitvereinseintraege retrieval
    const passZweitvereinseintraegeForUser = data.passZweitvereinseintraege[username] || [];

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