const express = require('express');
const cors = require('cors');
const app = express();
const port = 3001; // Or any port you choose

const allowedOrigins = ['http://0.0.0.0:3000'];

app.use(cors({
    origin: function (origin, callback) {
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true)
        } else {
            callback(new Error('Not allowed by CORS'))
        }
    }
}));

app.use(express.json());

// Import route handlers
const loginRoutes = require('./routes/login');
const passdatenRoutes = require('./routes/passdaten');
const angemeldeteSchulungenRoutes = require('./routes/angemeldeteSchulungen');
const registerMyBSSBRoutes = require('./routes/registerMyBSSB');
const schutzenausweisRoutes = require('./routes/schutzenausweis');
const schuetzenausweisPdfJpgRoutes = require('./routes/schuetzenausweis_pdf_jpg');
const zweitmitgliedschaftenRoutes = require('./routes/zweitmitgliedschaften');
const passdatenZVERoutes = require('./routes/passdatenZVE');
const passwordresetRoutes = require('./routes/PasswordReset');
const kontakteRoutes = require('./routes/Kontakte');
const schulungstermineRoutes = require('./routes/schulungstermine');
const oktoberfestlandesschiessenRoutes = require('./routes/oktoberfestlandesschiessen');
const gewinneAbrufenRoutes = require('./routes/gewinneAbrufen');


// Use route handlers
app.use('/LoginMyBSSB', loginRoutes);
app.use('/Passdaten', passdatenRoutes);
app.use('/AngemeldeteSchulungen', angemeldeteSchulungenRoutes);
app.use('/RegisterMyBSSB', registerMyBSSBRoutes);
app.use('/schutzenausweis', schutzenausweisRoutes);
app.use('/Schuetzenausweis', schuetzenausweisPdfJpgRoutes); 
app.use('/Zweitmitgliedschaften', zweitmitgliedschaftenRoutes); 
app.use('/PassdatenZVE', passdatenZVERoutes); 
app.use('/Passwordreset', passwordresetRoutes); 
app.use('/Schulungstermine', schulungstermineRoutes); 
app.use('/Oktoberfestlandesschiessen', oktoberfestlandesschiessenRoutes); 
app.use('/GewinneAbrufen', gewinneAbrufenRoutes); 



app.listen(port, () => {
    console.log(`Mock server listening at http://localhost:${port}`);
});