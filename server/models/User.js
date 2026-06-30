const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    password: { type: String, required: true },
    voice: { type: Boolean, default: false },
    language: { type: String, default: 'English' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
