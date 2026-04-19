const DEFAULT_TIPO = 'superior';

/** Map ViT / Spanish class labels to wardrobe slot */
const KEYWORDS = [
  { tipo: 'zapatos', keys: ['zapato', 'shoe', 'sneaker', 'boot', 'sandal', 'calzado'] },
  { tipo: 'inferior', keys: ['pant', 'jean', 'short', 'skirt', 'falda', 'trouser', 'bottom'] },
  { tipo: 'abrigo', keys: ['coat', 'jacket', 'blazer', 'abrigo', 'chaqueta', 'cardigan'] },
  { tipo: 'vestido', keys: ['dress', 'vestido'] },
  { tipo: 'superior', keys: ['shirt', 'top', 'blouse', 'camisa', 'camiseta', 'sweater', 'jersey', 'superior'] },
];

/**
 * @param {string} claseNombre
 * @returns {string}
 */
export function vitClassToTipo(claseNombre) {
  if (!claseNombre || typeof claseNombre !== 'string') return DEFAULT_TIPO;
  const lower = claseNombre.toLowerCase();
  for (const { tipo, keys } of KEYWORDS) {
    if (keys.some((k) => lower.includes(k))) return tipo;
  }
  return DEFAULT_TIPO;
}
