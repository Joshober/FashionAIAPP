/**
 * Rule-based outfit suggestions (no OpenRouter).
 * @param {Record<string, unknown>[]} prendasLean
 * @param {Record<string, unknown>} preferences
 * @param {number} limit
 */
export function recommendOutfits(prendasLean, preferences, limit = 3) {
  const byTipo = {};
  for (const p of prendasLean) {
    const t = p.tipo || 'superior';
    if (!byTipo[t]) byTipo[t] = [];
    byTipo[t].push(p);
  }

  const vestidos = byTipo.vestido || [];
  const superiores = byTipo.superior || [];
  const inferiores = byTipo.inferior || [];
  const zapatos = byTipo.zapatos || [];
  const abrigos = byTipo.abrigo || [];

  const styleHint = String(preferences?.style_preference || '').toLowerCase();
  const formality = String(preferences?.formality || '').toLowerCase();

  const combos = [];

  const addCombo = (superior, inferior, zapato, abrigo, vestido, baseScore) => {
    const parts = [superior, inferior, zapato, abrigo, vestido].filter(Boolean);
    if (parts.length < 2) return;
    let score = baseScore + Math.random() * 4;
    for (const pr of parts) {
      const text = `${pr.clase_nombre} ${pr.color} ${(pr.ocasion || []).join(' ')}`.toLowerCase();
      if (styleHint && text.includes(styleHint.slice(0, 8))) score += 3;
      if (formality && text.includes(formality)) score += 2;
    }
    combos.push({
      superior_id: superior?._id || null,
      inferior_id: inferior?._id || null,
      zapatos_id: zapato?._id || null,
      abrigo_id: abrigo?._id || null,
      vestido_id: vestido?._id || null,
      puntuacion: Math.round(score * 10) / 10,
      explicacion: 'Rule-based match from your wardrobe.',
    });
  };

  if (vestidos.length && zapatos.length) {
    for (const v of vestidos.slice(0, 3)) {
      for (const z of zapatos.slice(0, 3)) {
        addCombo(null, null, z, null, v, 6);
      }
    }
  }

  if (superiores.length && inferiores.length && zapatos.length) {
    let count = 0;
    for (const s of superiores) {
      for (const i of inferiores) {
        for (const z of zapatos) {
          if (count++ > 40) break;
          const abrigo = abrigos.length ? abrigos[count % abrigos.length] : null;
          addCombo(s, i, z, abrigo, null, 5);
        }
      }
    }
  }

  combos.sort((a, b) => b.puntuacion - a.puntuacion);
  const seen = new Set();
  const unique = [];
  for (const c of combos) {
    const key = `${c.superior_id}-${c.inferior_id}-${c.zapatos_id}-${c.vestido_id}-${c.abrigo_id}`;
    if (seen.has(key)) continue;
    seen.add(key);
    unique.push(c);
    if (unique.length >= limit) break;
  }
  return unique;
}
