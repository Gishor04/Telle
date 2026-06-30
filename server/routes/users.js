const express = require('express');
const router = express.Router();
const User = require('../models/User');
const auth = require('../middleware/authMiddleware');

router.get('/:userId', auth, async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/:userId', auth, async (req, res) => {
  try {
    const { voice, language, name } = req.body;
    const update = {};
    if (voice !== undefined) update.voice = voice;
    if (language !== undefined) update.language = language;
    if (name !== undefined) update.name = name;

    const user = await User.findByIdAndUpdate(
      req.params.userId,
      { $set: update },
      { new: true }
    ).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
