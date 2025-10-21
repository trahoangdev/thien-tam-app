@echo off
REM Script to setup both backend and frontend for Windows

echo 🚀 Setting up Thiền Tâm App...
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    exit /b 1
)

echo ✅ Node.js version:
node --version
echo ✅ Flutter version:
flutter --version | findstr /C:"Flutter"
echo.

REM Setup Backend
echo 📦 Setting up Backend...
cd ..\backend_thien_tam_app

echo Installing backend dependencies...
call npm install

echo Creating .env file...
if not exist .env (
    (
        echo PORT=4000
        echo MONGO_URI=mongodb://localhost:27017/buddhist_readings
        echo TZ=Asia/Ho_Chi_Minh
        echo NODE_ENV=development
    ) > .env
)

echo ✅ Backend setup complete!
echo.

REM Setup Frontend
echo 📱 Setting up Flutter App...
cd ..
cd thien_tam_app

echo Getting Flutter dependencies...
call flutter pub get

echo ✅ Flutter app setup complete!
echo.

echo 🎉 Setup complete!
echo.
echo Next steps:
echo 1. Start MongoDB: mongod
echo 2. Seed backend data: cd backend_thien_tam_app ^&^& npm run seed
echo 3. Start backend: npm run dev
echo 4. Start Flutter app: cd ..\thien_tam_app ^&^& flutter run

cd ..

