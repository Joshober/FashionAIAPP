import sharp from 'sharp';

/**
 * Simple hue bucket label from image buffer when ML omits color.
 * @param {Buffer} buffer
 * @returns {Promise<string>}
 */
export async function roughColorFromBuffer(buffer) {
  try {
    const { data, info } = await sharp(buffer)
      .resize(48, 48, { fit: 'cover' })
      .raw()
      .toBuffer({ resolveWithObject: true });

    const channels = info.channels || 3;
    let r = 0;
    let g = 0;
    let b = 0;
    let n = 0;
    for (let i = 0; i < data.length; i += channels) {
      r += data[i];
      g += data[i + 1];
      b += data[i + 2];
      n++;
    }
    if (!n) return '';
    r /= n;
    g /= n;
    b /= n;
    if (r > g && r > b && r > 140) return 'red';
    if (g > r && g > b && g > 140) return 'green';
    if (b > r && b > g && b > 140) return 'blue';
    if (r > 200 && g > 200 && b > 200) return 'white';
    if (r < 80 && g < 80 && b < 80) return 'black';
    if (Math.abs(r - g) < 25 && Math.abs(g - b) < 25) return 'gray';
    if (r > 180 && g > 100 && b < 120) return 'coral';
    if (r > 160 && g > 140 && b < 100) return 'gold';
    return 'multicolor';
  } catch {
    return '';
  }
}
