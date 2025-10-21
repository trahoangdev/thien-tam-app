export const env = {
  port: process.env.PORT || 4000,
  mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/buddhist_readings',
  nodeEnv: process.env.NODE_ENV || 'development',
};

