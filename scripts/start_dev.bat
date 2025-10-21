@echo off
REM Script to start development environment on Windows

echo 🚀 Starting Development Environment...
echo.

REM Check if Docker is installed
where docker-compose >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Starting MongoDB with Docker...
    docker-compose up -d mongodb
    echo ✅ MongoDB started on port 27017
) else (
    echo ⚠️  Docker not found. Please start MongoDB manually:
    echo    mongod --dbpath ^<your-db-path^>
)

echo.
echo Waiting for MongoDB to be ready...
timeout /t 3 /nobreak >nul

REM Start backend
echo Starting Backend API...
cd backend_thien_tam_app

REM Check if .env exists
if not exist .env (
    echo Creating .env file...
    (
        echo PORT=4000
        echo MONGO_URI=mongodb://localhost:27017/buddhist_readings
        echo TZ=Asia/Ho_Chi_Minh
        echo NODE_ENV=development
    ) > .env
)

REM Seed data
echo Checking if data needs to be seeded...
call npm run seed

REM Start backend
echo.
echo ✅ Starting backend on http://localhost:4000
echo.
echo 📱 Open another terminal and run:
echo    cd thien_tam_app
echo    flutter run
echo.
echo Press Ctrl+C to stop the backend...
echo.

call npm run dev

cd ..

