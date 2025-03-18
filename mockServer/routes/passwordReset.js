const express = require('express');
const router = express.Router();

router.post('/:passNumber', (req, res) => {
    const passNumber = req.params.passNumber;
    console.log(`Password reset request for passNumber: ${passNumber}`);


    res.status(200).json({
        ResultType: 1,
        ResultMessage: "Password reset successful."
    });
});

module.exports = router;