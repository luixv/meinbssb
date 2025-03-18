const express = require('express');
const router = express.Router();
const data = require('../mock-data.json');

const registrations = [];

router.post('/', (req, res) => {
    const registrationData = req.body;

    console.log("Received registration request:", req.body);

    console.log("firstName:", registrationData.firstName);
    console.log("lastName:", registrationData.lastName);
    console.log("passNumber:", registrationData.passNumber);
    console.log("email:", registrationData.email);
    console.log("birthDate:", registrationData.birthDate);
    console.log("zipCode:", registrationData.zipCode);

    if (registrations.find(user => user.email === registrationData.email)) {
        console.log("Duplicate email:", registrationData.email);
        return res.status(400).json({
            ResultType: 0,
            ResultMessage: "Email already exists"
        });
    }

    registrations.push(registrationData);

    console.log("New registration:", registrationData);

    res.status(200).json({
        ResultType: 1,
        ResultMessage: "Registration successful"
    });
});

module.exports = router;