/**
 * @param {string} url
 * @returns {boolean}
 */
export function isAllowedMirrorImageRef(url) {
  if (!url || typeof url !== 'string') return false;
  if (url.startsWith('data:image/jpeg;base64,')) return true;
  if (url.startsWith('data:image/jpg;base64,')) return true;
  if (url.startsWith('data:image/png;base64,')) return true;
  if (url.startsWith('data:image/webp;base64,')) return true;
  return false;
}
