import mongoose from 'mongoose';

/** @param {import('./config.types.js').AppConfig} config */
export async function connectDb(config) {
  const opts = {};
  if (config.mongodbDbName) opts.dbName = config.mongodbDbName;
  await mongoose.connect(config.mongodbUri, opts);
}
