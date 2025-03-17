const express = require('express');
const router = express.Router();

const passdaten = {
    PASSNUMMER: "41299999",
    VEREINNR: 412013,
    NAMEN: "Mandel",
    VORNAME: "Luis",
    TITEL: "Dr.",
    GEBURTSDATUM: "1961-03-18T00:00:00.000+01:00",
    GESCHLECHT: 1,
    EINTRITTBSSB: "1981-06-01T00:00:00.000+02:00",
    VEREINNAME: "KK Gut Schuss e.V.",
    STRASSE: "Musterstrasse 18",
    PLZ: 99999,
    ORT: "Musterhausen",
    LAND: "DEU",
    NATIONALITAET: "DEU",
    PASSSTATUS: 1,
    PASSDATENID: 2000010534,
    EINTRITTVEREIN: "2019-06-01T00:00:00.000+02:00",
    AUSTRITTVEREIN: "",
    MITGLIEDSCHAFTID: 1513000003034,
    TELEFON: "0999/55555",
    PERSONID: 4711,
    ERSTLANDESVERBANDID: 0,
    PRODUKTIONSDATUM: "2023-08-14T00:00:00.000+02:00",
    ERSTVEREINID: 1963,
    DIGITALERPASS: 1
};

router.get('/:personId', (req, res) => {
    // Extract the ID from the route parameters
    const personId = req.params.personId;
    console.log(`personId: ${personId}`);

    // Send the mock data as a response
    res.status(200).json(passdaten);
});

module.exports = router;