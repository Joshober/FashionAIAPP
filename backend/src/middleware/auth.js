import jwt from 'jsonwebtoken';

/** @param {import('../config.types.js').AppConfig} config */
export function authMiddleware(config) {
  return (req, res, next) => {
    req.userId = 'anonymous';
    req.auth = { sub: 'anonymous' };

    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ') || !config.jwtSecret) return next();

    const token = header.slice(7).trim();
    if (!token) return next();

    try {
      const decoded = jwt.verify(token, config.jwtSecret, { algorithms: ['HS256'] });
      if (decoded && typeof decoded.sub === 'string') {
        req.userId = decoded.sub;
        req.auth = {
          sub: decoded.sub,
          ...(typeof decoded.email === 'string' ? { email: decoded.email } : {}),
        };
      }
    } catch {
      /* invalid or expired token */
    }
    next();
  };
}
