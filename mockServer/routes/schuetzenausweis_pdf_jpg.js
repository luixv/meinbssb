const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

router.get('/PDF/:PersonID', (req, res) => {
    const personId = req.params.PersonID;
    console.log(`Sending schutzenausweis PDF for PersonID: ${personId}`);

    const pdfPath = path.join(__dirname, 'schutzenausweis.pdf'); // Path to your schutzenausweis PDF
    fs.readFile(pdfPath, (err, data) => {
        if (err) {
            console.error('Error reading PDF:', err);
            return res.status(500).send('Internal Server Error');
        }

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=schuetzenausweis_${personId}.pdf`);
        res.send(data);
    });
});

router.get('/JPG/:PersonID', (req, res) => {
    const personId = req.params.PersonID;
    console.log(`Sending schutzenausweis JPG for PersonID: ${personId}`);

    const jpgPath = path.join(__dirname, 'schutzenausweis.jpg'); // Path to your schutzenausweis JPG
    fs.readFile(jpgPath, (err, data) => {
        if (err) {
            console.error('Error reading JPG:', err);
            return res.status(500).send('Internal Server Error');
        }

        res.setHeader('Content-Type', 'image/jpeg');
        res.setHeader('Content-Disposition', `attachment; filename=schuetzenausweis_${personId}.jpg`);
        res.send(data);
    });
});

module.exports = router;