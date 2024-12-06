const express = require('express');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config();

const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/config', (req, res) => {
    res.json({ mapboxAccessToken: process.env.MAPBOX_ACCESS_TOKEN });
});

app.use(express.static(path.join(__dirname)));

app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
