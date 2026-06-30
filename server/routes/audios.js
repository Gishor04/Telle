const express = require('express');
const router = express.Router();
const Audio = require('../models/Audio');
const auth = require('../middleware/authMiddleware');

// Get all audio dates for a user
router.get('/:userId/bydate', auth, async (req, res) => {
  try {
    const audios = await Audio.find({ userId: req.params.userId }).sort({ date: -1 });
    res.json(audios);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Get audio for a specific date
router.get('/:userId/bydate/:date', auth, async (req, res) => {
  try {
    const audio = await Audio.findOne({ userId: req.params.userId, date: req.params.date });
    if (!audio) return res.status(404).json({ message: 'Not found' });
    res.json(audio);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Create audio document for a date (idempotent)
router.post('/:userId/bydate/:date', auth, async (req, res) => {
  try {
    let audio = await Audio.findOne({ userId: req.params.userId, date: req.params.date });
    if (!audio) {
      audio = new Audio({ userId: req.params.userId, date: req.params.date });
      await audio.save();
    }
    res.json(audio);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Add an audio URL to a date
router.put('/:userId/bydate/:date/addurl', auth, async (req, res) => {
  try {
    const { url } = req.body;
    const audio = await Audio.findOneAndUpdate(
      { userId: req.params.userId, date: req.params.date },
      { $addToSet: { audiourl: url } },
      { new: true, upsert: true }
    );
    res.json(audio);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Remove an audio URL from a date
router.put('/:userId/bydate/:date/removeurl', auth, async (req, res) => {
  try {
    const { url } = req.body;
    const audio = await Audio.findOneAndUpdate(
      { userId: req.params.userId, date: req.params.date },
      { $pull: { audiourl: url } },
      { new: true }
    );
    res.json(audio);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Update title for a date
router.put('/:userId/bydate/:date/title', auth, async (req, res) => {
  try {
    const { title } = req.body;
    const audio = await Audio.findOneAndUpdate(
      { userId: req.params.userId, date: req.params.date },
      { $set: { title } },
      { new: true }
    );
    res.json(audio);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
