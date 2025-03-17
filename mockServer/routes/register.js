const express = require('express');
const router = express.Router();
const data = require('../mock-data.json'); // Load the JSON file

const registrations = []; // Corrected line

router.post('/', (req, res) => {
    const registrationData = req.body;

    console.log("Received registration request:", req.body);

    console.log("Vorname:", registrationData.vorname);
    console.log("Nachname:", registrationData.nachname);
    console.log("Email:", registrationData.email);

    if (registrations.find(user => user.email === registrationData.email)) {
        console.log("Duplicate email:", registrationData.email);
        return res.status(400).json({ message: "Email already exists" });
    }

    registrations.push(registrationData);

    console.log("New registration:", registrationData);

    res.status(200).json({ message: "Registration successful" });
});

module.exports = router;