#!/bin/bash
# Script to start development environment

echo "🚀 Starting Development Environment..."
echo ""

# Check if Docker is installed
if command -v docker-compose &> /dev/null; then
    echo "Starting MongoDB with Docker..."
    docker-compose up -d mongodb
    echo "✅ MongoDB started on port 27017"
else
    echo "⚠️  Docker not found. Please start MongoDB manually:"
    echo "   mongod --dbpath <your-db-path>"
fi

echo ""
echo "Waiting for MongoDB to be ready..."
sleep 3

# Start backend
echo "Starting Backend API..."
cd backend_thien_tam_app

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env 2>/dev/null || echo "PORT=4000
MONGO_URI=mongodb://localhost:27017/buddhist_readings
TZ=Asia/Ho_Chi_Minh
NODE_ENV=development" > .env
fi

# Check if data is seeded
echo "Checking if data needs to be seeded..."
npm run seed

# Start backend in background
npm run dev &
BACKEND_PID=$!

echo "✅ Backend started on http://localhost:4000 (PID: $BACKEND_PID)"
echo ""
echo "📱 You can now run the Flutter app:"
echo "   cd thien_tam_app"
echo "   flutter run"
echo ""
echo "Press Ctrl+C to stop all services..."

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID 2>/dev/null; docker-compose down 2>/dev/null; echo '✅ All services stopped'; exit 0" INT

wait

