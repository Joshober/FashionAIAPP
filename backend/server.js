import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { createApp } from './src/app.js';
import { connectDb } from './src/db.js';
import { loadConfig } from './src/config.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, '..', '.env') });
dotenv.config({ path: path.resolve(__dirname, '.env') });

const uploadsRoot = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsRoot)) {
  fs.mkdirSync(uploadsRoot, { recursive: true });
}

const config = loadConfig();
await connectDb(config);

const app = createApp(config);
app.listen(config.port, () => {
  console.log(`Fashion AI API listening on port ${config.port}`);
});
