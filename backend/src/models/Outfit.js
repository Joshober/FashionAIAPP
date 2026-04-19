import mongoose from 'mongoose';

const outfitSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },
    superior_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Prenda', default: null },
    inferior_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Prenda', default: null },
    zapatos_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Prenda', default: null },
    abrigo_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Prenda', default: null },
    vestido_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Prenda', default: null },
    puntuacion: { type: Number, default: 0 },
    explicacion: { type: String, default: '' },
  },
  { timestamps: true }
);

export const Outfit = mongoose.models.Outfit || mongoose.model('Outfit', outfitSchema);
