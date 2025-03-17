const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // Load the JSON file

router.get('/:personId', (req, res) => {
    // Extract the ID from the route parameters
    const personId = req.params.personId;
    console.log(`personId: ${personId}`);

    // Find the user's passdaten based on personId
    const foundUser = Object.values(data.passdaten).find(user => user.PERSONID === parseInt(personId));

    if (foundUser) {
        // Send the found user's passdaten as a response
        res.status(200).json(foundUser);
    } else {
        // Send a 404 if the user is not found
        res.status(404).json({ message: "User not found" });
    }
});

module.exports = router;