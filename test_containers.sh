#!/bin/bash

echo "=== Testing Todo App Services ==="
echo

# Check if docker-compose file exists
if [ -f "docker-compose.prod.yml" ]; then
    echo "✅ Found docker-compose.prod.yml"
    COMPOSE_FILE="docker-compose.prod.yml"
elif [ -f "docker-compose.yml" ]; then
    echo "✅ Found docker-compose.yml"
    COMPOSE_FILE="docker-compose.yml"
elif [ -f "docker-compose.yaml" ]; then
    echo "✅ Found docker-compose.yaml"
    COMPOSE_FILE="docker-compose.yaml"
else
    echo "❌ No docker-compose file found in current directory"
    echo "Current directory: $(pwd)"
    echo "Files in current directory:"
    ls -la *.yml *.yaml 2>/dev/null || echo "No .yml or .yaml files found"
    exit 1
fi

echo "Current directory: $(pwd)"
echo

echo "1. Testing Frontend (React)..."
frontend_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:90)
if [ "$frontend_response" = "200" ]; then
    echo "✅ Frontend is responding (HTTP $frontend_response)"
else
    echo "❌ Frontend failed (HTTP $frontend_response)"
fi
echo

echo "2. Testing Backend (API)..."
backend_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/)
if [ "$backend_response" = "200" ]; then
    echo "✅ Backend is responding (HTTP $backend_response)"
else
    echo "❌ Backend failed (HTTP $backend_response)"
fi
echo

echo "3. Checking MongoDB status..."
mongo_status=$(docker-compose -f "$COMPOSE_FILE" exec -T mongodb mongosh --quiet --eval "db.runCommand('ping').ok" 2>/dev/null)
if [ "$mongo_status" = "1" ]; then
    echo "✅ MongoDB is running and responding"
    echo "MongoDB stats:"
    docker-compose -f "$COMPOSE_FILE" exec -T mongodb mongosh --quiet --eval "db.stats()" 2>/dev/null
else
    echo "❌ MongoDB is not responding"
    echo "MongoDB container status:"
    docker-compose -f "$COMPOSE_FILE" ps mongodb
fi
echo

echo "4. Testing Mongo Express..."
mongo_express_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
if [ "$mongo_express_response" = "200" ] || [ "$mongo_express_response" = "401" ]; then
    echo "✅ Mongo Express is responding (HTTP $mongo_express_response)"
    if [ "$mongo_express_response" = "401" ]; then
        echo "   (401 is expected - authentication required)"
    fi
else
    echo "❌ Mongo Express failed (HTTP $mongo_express_response)"
fi
echo

echo "5. Container Status Overview:"
docker-compose -f "$COMPOSE_FILE" ps
echo

echo "6. Recent logs (last 10 lines per service):"
echo "--- MongoDB logs ---"
docker-compose -f "$COMPOSE_FILE" logs --tail=10 mongodb
echo
echo "--- Mongo Express logs ---"
docker-compose -f "$COMPOSE_FILE" logs --tail=10 mongo-express