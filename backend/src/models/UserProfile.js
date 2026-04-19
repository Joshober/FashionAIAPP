import mongoose from 'mongoose';

const defaultPreferences = () => ({
  style_preference: '',
  formality: 'smart_casual',
  palette: '',
  climate: '',
  notes: '',
  avoid: '',
});

const userProfileSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true, index: true },
    preferences: { type: mongoose.Schema.Types.Mixed, default: defaultPreferences },
    mirror_notes: { type: String, default: '' },
  },
  { timestamps: true }
);

export const UserProfile =
  mongoose.models.UserProfile || mongoose.model('UserProfile', userProfileSchema);
