const express = require('express');
const router = express.Router();

const data = require('../mock-data.json'); // Load the JSON file

router.post('/', (req, res) => {
    console.log(req.body);
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({
            success: false,
            message: "Email and password are required.",
        });
    }

    if (data.users[email.toLowerCase()]) {
        const userData = data.users[email.toLowerCase()];
        res.status(200).json(userData);
    } else {
        res.status(401).json({ success: false, message: "Invalid email or password" });
    }
});

module.exports = router;