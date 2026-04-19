import jwt from 'jsonwebtoken';
import jwksRsa from 'jwks-rsa';

/** @param {import('../config.types.js').AppConfig} config */
export function authMiddleware(config) {
  const client =
    config.auth0Domain && config.auth0Audience
      ? jwksRsa({
          jwksUri: `https://${config.auth0Domain}/.well-known/jwks.json`,
          cache: true,
          rateLimit: true,
        })
      : null;

  return (req, res, next) => {
    req.userId = 'anonymous';
    req.auth = { sub: 'anonymous' };

    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) return next();

    const token = header.slice(7).trim();
    if (!token) return next();

    if (!client || !config.auth0Audience) {
      try {
        const decoded = jwt.decode(token);
        if (decoded && typeof decoded.sub === 'string') {
          req.userId = decoded.sub;
          req.auth = { sub: decoded.sub };
        }
      } catch {
        /* ignore */
      }
      return next();
    }

    function getKey(header, cb) {
      client.getSigningKey(header.kid, (err, key) => {
        if (err) return cb(err);
        const signingKey = key?.getPublicKey();
        cb(null, signingKey);
      });
    }

    jwt.verify(
      token,
      getKey,
      {
        audience: config.auth0Audience,
        issuer: [`https://${config.auth0Domain}/`, `https://${config.auth0Domain}`],
        algorithms: ['RS256'],
      },
      (err, decoded) => {
        if (!err && decoded && typeof decoded.sub === 'string') {
          req.userId = decoded.sub;
          req.auth = { sub: decoded.sub };
        }
        next();
      }
    );
  };
}
