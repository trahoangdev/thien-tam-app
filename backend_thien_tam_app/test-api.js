#!/usr/bin/env node

/**
 * API Testing Script for ThienTam App
 * 
 * This script tests all API endpoints to ensure they work correctly
 * Run with: node test-api.js
 */

const axios = require('axios');

// Configuration
const BASE_URL = 'http://localhost:4000';
const ADMIN_EMAIL = 'admin@thientam.local';
const ADMIN_PASSWORD = 'ThienTam@2025';
const TEST_USER_EMAIL = 'test@example.com';
const TEST_USER_PASSWORD = 'password123';

// Test results
let testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  errors: []
};

// Helper function to make requests
async function makeRequest(method, endpoint, data = null, headers = {}) {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    return { success: true, data: response.data, status: response.status };
  } catch (error) {
    return { 
      success: false, 
      error: error.response?.data || error.message,
      status: error.response?.status || 500
    };
  }
}

// Test function
async function runTest(testName, testFunction) {
  testResults.total++;
  console.log(`\n🧪 Testing: ${testName}`);
  
  try {
    await testFunction();
    testResults.passed++;
    console.log(`✅ PASSED: ${testName}`);
  } catch (error) {
    testResults.failed++;
    testResults.errors.push({ test: testName, error: error.message });
    console.log(`❌ FAILED: ${testName} - ${error.message}`);
  }
}

// Individual test functions
async function testHealthCheck() {
  const result = await makeRequest('GET', '/healthz');
  if (!result.success || result.status !== 200) {
    throw new Error(`Health check failed: ${result.error}`);
  }
}

async function testGetTodayReadings() {
  const result = await makeRequest('GET', '/readings/today');
  if (!result.success) {
    throw new Error(`Get today readings failed: ${result.error}`);
  }
}

async function testSearchReadings() {
  const result = await makeRequest('GET', '/readings?query=phật&page=1&limit=5');
  if (!result.success) {
    throw new Error(`Search readings failed: ${result.error}`);
  }
}

async function testTTSStatus() {
  const result = await makeRequest('GET', '/tts/status');
  if (!result.success) {
    throw new Error(`TTS status check failed: ${result.error}`);
  }
}

async function testTTSVoices() {
  const result = await makeRequest('GET', '/tts/voices');
  if (!result.success) {
    throw new Error(`Get TTS voices failed: ${result.error}`);
  }
}

async function testAdminLogin() {
  const result = await makeRequest('POST', '/auth/login', {
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD
  });
  
  if (!result.success || !result.data.access) {
    throw new Error(`Admin login failed: ${result.error}`);
  }
  
  // Store token for other tests
  global.adminToken = result.data.access;
}

async function testAdminProfile() {
  if (!global.adminToken) {
    throw new Error('Admin token not available');
  }
  
  const result = await makeRequest('GET', '/auth/me', null, {
    'Authorization': `Bearer ${global.adminToken}`
  });
  
  if (!result.success) {
    throw new Error(`Get admin profile failed: ${result.error}`);
  }
}

async function testUserRegister() {
  const result = await makeRequest('POST', '/user-auth/register', {
    email: TEST_USER_EMAIL,
    password: TEST_USER_PASSWORD,
    name: 'Test User'
  });
  
  if (!result.success && result.status !== 400) { // 400 if user already exists
    throw new Error(`User register failed: ${result.error}`);
  }
  
  if (result.success && result.data.tokens) {
    global.userToken = result.data.tokens.accessToken;
  }
}

async function testUserLogin() {
  const result = await makeRequest('POST', '/user-auth/login', {
    email: TEST_USER_EMAIL,
    password: TEST_USER_PASSWORD
  });
  
  if (!result.success || !result.data.tokens) {
    throw new Error(`User login failed: ${result.error}`);
  }
  
  global.userToken = result.data.tokens.accessToken;
}

async function testUserProfile() {
  if (!global.userToken) {
    throw new Error('User token not available');
  }
  
  const result = await makeRequest('GET', '/user-auth/me', null, {
    'Authorization': `Bearer ${global.userToken}`
  });
  
  if (!result.success) {
    throw new Error(`Get user profile failed: ${result.error}`);
  }
}

async function testUpdateUserProfile() {
  if (!global.userToken) {
    throw new Error('User token not available');
  }
  
  const result = await makeRequest('PUT', '/user-auth/profile', {
    name: 'Updated Test User',
    preferences: {
      theme: 'dark',
      fontSize: 'large',
      lineHeight: 1.8
    }
  }, {
    'Authorization': `Bearer ${global.userToken}`
  });
  
  if (!result.success) {
    throw new Error(`Update user profile failed: ${result.error}`);
  }
}

async function testGetTopicsStats() {
  if (!global.adminToken) {
    throw new Error('Admin token not available');
  }
  
  const result = await makeRequest('GET', '/admin/topics/stats', null, {
    'Authorization': `Bearer ${global.adminToken}`
  });
  
  if (!result.success) {
    throw new Error(`Get topics stats failed: ${result.error}`);
  }
  
  // Verify response structure
  if (!result.data.totalTopics && result.data.totalTopics !== 0) {
    throw new Error('Invalid topics stats response structure');
  }
}

async function testGetAllReadings() {
  if (!global.adminToken) {
    throw new Error('Admin token not available');
  }
  
  const result = await makeRequest('GET', '/admin/readings?page=1&limit=10', null, {
    'Authorization': `Bearer ${global.adminToken}`
  });
  
  if (!result.success) {
    throw new Error(`Get all readings failed: ${result.error}`);
  }
}

async function testCreateTopic() {
  if (!global.adminToken) {
    throw new Error('Admin token not available');
  }
  
  const result = await makeRequest('POST', '/admin/topics', {
    slug: 'test-topic',
    name: 'Test Topic',
    description: 'A test topic for API testing',
    color: '#FF5722',
    icon: 'test',
    sortOrder: 999
  }, {
    'Authorization': `Bearer ${global.adminToken}`
  });
  
  if (!result.success && result.status !== 409) { // 409 if topic already exists
    throw new Error(`Create topic failed: ${result.error}`);
  }
  
  if (result.success) {
    global.testTopicId = result.data.topic._id;
  }
}

async function testCreateReading() {
  if (!global.adminToken) {
    throw new Error('Admin token not available');
  }
  
  const result = await makeRequest('POST', '/admin/readings', {
    title: 'Test Reading',
    body: 'This is a test reading content for API testing.',
    date: new Date().toISOString().split('T')[0], // Today's date
    topicSlugs: ['test-topic'],
    keywords: ['test', 'api'],
    source: 'Test Script',
    lang: 'vi'
  }, {
    'Authorization': `Bearer ${global.adminToken}`
  });
  
  if (!result.success) {
    throw new Error(`Create reading failed: ${result.error}`);
  }
  
  global.testReadingId = result.data.reading._id;
}

// Main test runner
async function runAllTests() {
  console.log('🚀 Starting ThienTam API Tests...\n');
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`Admin Email: ${ADMIN_EMAIL}`);
  console.log(`Test User Email: ${TEST_USER_EMAIL}\n`);
  
  // Public endpoints
  await runTest('Health Check', testHealthCheck);
  await runTest('Get Today Readings', testGetTodayReadings);
  await runTest('Search Readings', testSearchReadings);
  await runTest('TTS Status Check', testTTSStatus);
  await runTest('Get TTS Voices', testTTSVoices);
  
  // Authentication
  await runTest('Admin Login', testAdminLogin);
  await runTest('Admin Profile', testAdminProfile);
  await runTest('User Register', testUserRegister);
  await runTest('User Login', testUserLogin);
  await runTest('User Profile', testUserProfile);
  await runTest('Update User Profile', testUpdateUserProfile);
  
  // Admin endpoints
  await runTest('Get All Topics', testGetAllTopics);
  await runTest('Get Topics Stats', testGetTopicsStats);
  await runTest('Get All Readings', testGetAllReadings);
  await runTest('Create Topic', testCreateTopic);
  await runTest('Create Reading', testCreateReading);
  
  // Print results
  console.log('\n📊 Test Results:');
  console.log(`Total Tests: ${testResults.total}`);
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log(`Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);
  
  if (testResults.errors.length > 0) {
    console.log('\n❌ Failed Tests:');
    testResults.errors.forEach(error => {
      console.log(`  - ${error.test}: ${error.error}`);
    });
  }
  
  if (testResults.failed === 0) {
    console.log('\n🎉 All tests passed! API is working correctly.');
  } else {
    console.log('\n⚠️  Some tests failed. Please check the errors above.');
    process.exit(1);
  }
}

// Run tests
if (require.main === module) {
  runAllTests().catch(error => {
    console.error('💥 Test runner failed:', error.message);
    process.exit(1);
  });
}

module.exports = { runAllTests, makeRequest };
