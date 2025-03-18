const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // Load the JSON file

router.get('/:personId', async (req, res) => {
    const personId = req.params.personId;
    console.log(`personId: ${personId}`);

    res.status(200).json(data.zweitmitgliedschaften);

});

module.exports = router;