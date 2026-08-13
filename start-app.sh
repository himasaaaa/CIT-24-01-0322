#!/bin/bash
echo "=========================================="
echo "Starting Student Notes Application Services..."
echo "=========================================="

if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    docker compose up -d
else
    # Fallback to direct docker run commands if compose is unavailable
    echo "Starting MongoDB Container..."
    docker run -d \
      --name student-notes-db \
      --network student_notes_net \
      -p 27017:27017 \
      -v student_notes_data:/data/db \
      --restart unless-stopped \
      mongo:latest

    echo "Starting Web Application Container..."
    docker run -d \
      --name student-notes-web \
      --network student_notes_net \
      -p 5000:5000 \
      -e MONGO_URI=mongodb://student-notes-db:27017/studentdb \
      --restart unless-stopped \
      student-notes-web
fi

echo "=========================================="
echo "Running app ..."
echo "The app is available at http://localhost:5000"
echo "=========================================="
