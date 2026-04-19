import mongoose from 'mongoose';

const prendaSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },
    imagen_url: { type: String, default: '' },
    tipo: { type: String, default: 'superior' },
    clase_nombre: { type: String, default: '' },
    color: { type: String, default: '' },
    confianza: { type: Number, default: 0 },
    ocasion: { type: [String], default: [] },
  },
  { timestamps: true }
);

export const Prenda = mongoose.models.Prenda || mongoose.model('Prenda', prendaSchema);
