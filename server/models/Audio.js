const mongoose = require('mongoose');

const audioSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true },
    date: { type: String, required: true },
    audiourl: { type: [String], default: [] },
    title: { type: String, default: 'Title...' },
  },
  { timestamps: true }
);

audioSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('Audio', audioSchema);
