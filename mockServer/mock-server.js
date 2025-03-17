const express = require('express');
const cors = require('cors');
const app = express();
const port = 3001; // Or any port you choose

const allowedOrigins = ['http://localhost:3000'];

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
const registerRoutes = require('./routes/register');
const schutzenausweisRoutes = require('./routes/schutzenausweis');
const schuetzenausweisPdfJpgRoutes = require('./routes/schuetzenausweis_pdf_jpg'); 

// Use route handlers
app.use('/LoginMyBSSB', loginRoutes);
app.use('/Passdaten', passdatenRoutes);
app.use('/AngemeldeteSchulungen', angemeldeteSchulungenRoutes);
app.use('/mock-register', registerRoutes);
app.use('/schutzenausweis', schutzenausweisRoutes);
app.use('/Schuetzenausweis', schuetzenausweisPdfJpgRoutes); 


app.listen(port, () => {
    console.log(`Mock server listening at http://localhost:${port}`);
});