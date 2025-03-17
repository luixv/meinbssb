const express = require('express');
const router = express.Router();

// Mock user data (using email as key)
const users = {
    "luis@mandel.pro": {
        ResultType: 1,
        ResultMessage: "MyBSSB Login Erfolgreich",
        PersonID: 4711,
        WebLoginID: 27
    },
    "luismandel@gmail.com": {
        ResultType: 1,
        ResultMessage: "MyBSSB Login Erfolgreich",
        PersonID: 4711,
        WebLoginID: 27
    },
    // Add more mock users as needed
};

router.post('/', (req, res) => {
    console.log(req.body);
    const { email, password } = req.body; // username will be email

    if (!email || !password) {
        return res.status(400).json({
            success: false,
            message: "Email and password are required.",
        });
    }

    if (users[email.toLowerCase()]) { // Case-insensitive check (important!)
        const userData = users[email.toLowerCase()]; // Retrieve data using lowercase
        res.status(200).json(userData);
    } else {
        res.status(401).json({ success: false, message: "Invalid email or password" });
    }
});

module.exports = router;