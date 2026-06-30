const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config({ path: require('path').join(__dirname, '.env') });

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const audioRoutes = require('./routes/audios');
const mlRoutes = require('./routes/ml');

const app = express();
app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected successfully'))
  .catch((err) => console.error('MongoDB connection error:', err));

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/audios', audioRoutes);
// ML/OCR stub routes — mounted at root so Flutter hits /getData, /getEmotion, etc.
app.use('/', mlRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Tellie server running on port ${PORT}`));
