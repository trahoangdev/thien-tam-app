#!/bin/bash
# Script to setup both backend and frontend

echo "🚀 Setting up Thiền Tâm App..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ Flutter version: $(flutter --version | head -1)"
echo ""

# Setup Backend
echo "📦 Setting up Backend..."
cd backend_thien_tam_app

echo "Installing backend dependencies..."
npm install

echo "Creating .env file..."
cp .env.example .env 2>/dev/null || echo "PORT=4000
MONGO_URI=mongodb://localhost:27017/buddhist_readings
TZ=Asia/Ho_Chi_Minh
NODE_ENV=development" > .env

echo "✅ Backend setup complete!"
echo ""

# Setup Frontend
echo "📱 Setting up Flutter App..."
cd ../thien_tam_app

echo "Getting Flutter dependencies..."
flutter pub get

echo "✅ Flutter app setup complete!"
echo ""

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start MongoDB: mongod"
echo "2. Seed backend data: cd backend_thien_tam_app && npm run seed"
echo "3. Start backend: npm run dev"
echo "4. Start Flutter app: cd ../thien_tam_app && flutter run"

