const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

// ── /getData ──────────────────────────────────────────────────────────────────
// Receives: multipart/form-data with field "image"
// Returns:  { audioText, fileName }
// Real impl: run OCR on the image and return extracted text + a file ID.
router.post('/getData', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No image uploaded' });
  }
  // Stub — replace with actual OCR call
  res.json({
    audioText: 'This is a stub OCR result. Replace with real ML processing.',
    fileName: `file_${Date.now()}`,
  });
});

// ── /getImageLabel ────────────────────────────────────────────────────────────
// Receives: multipart/form-data with field "image"
// Returns:  { images }
router.post('/getImageLabel', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No image uploaded' });
  }
  res.json({
    images: 'Stub image label. Replace with real ML caption.',
  });
});

// ── /getEmotion ───────────────────────────────────────────────────────────────
// Receives: { sentence }
// Returns:  { Emotion } — one of: joy, sadness, anger, fear, surprise
router.post('/getEmotion', express.json(), (req, res) => {
  const { sentence } = req.body || {};
  if (!sentence) return res.status(400).json({ message: 'sentence required' });
  // Stub — return a fixed emotion; replace with real emotion-detection model
  res.json({ Emotion: 'joy' });
});

// ── /getEmotionAudio ──────────────────────────────────────────────────────────
// Receives: { sentence, emotion }
// Returns:  { url }
router.post('/getEmotionAudio', express.json(), (req, res) => {
  const { sentence, emotion } = req.body || {};
  if (!sentence || !emotion) {
    return res.status(400).json({ message: 'sentence and emotion required' });
  }
  // Stub — return a placeholder audio URL
  res.json({
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  });
});

// ── /getAudioWithOutEmotion ───────────────────────────────────────────────────
// Receives: { sentence }
// Returns:  { url }
router.post('/getAudioWithOutEmotion', express.json(), (req, res) => {
  const { sentence } = req.body || {};
  if (!sentence) return res.status(400).json({ message: 'sentence required' });
  res.json({
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  });
});

// ── /createMultiAudio ─────────────────────────────────────────────────────────
// Receives: { id, url }
// Returns:  { Message: 'Successfully Created' }
router.post('/createMultiAudio', express.json(), (req, res) => {
  const { id, url } = req.body || {};
  if (!id || !url) return res.status(400).json({ message: 'id and url required' });
  res.json({ Message: 'Successfully Created' });
});

// ── /mergingAudioFiles ────────────────────────────────────────────────────────
// Receives: { id }
// Returns:  { response: { id } }
router.post('/mergingAudioFiles', express.json(), (req, res) => {
  const { id } = req.body || {};
  if (!id) return res.status(400).json({ message: 'id required' });
  res.json({ response: { id } });
});

// ── /finalOutputVideo ─────────────────────────────────────────────────────────
// Receives: { id }
// Returns:  { url }
router.post('/finalOutputVideo', express.json(), (req, res) => {
  const { id } = req.body || {};
  if (!id) return res.status(400).json({ message: 'id required' });
  res.json({
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  });
});

module.exports = router;
