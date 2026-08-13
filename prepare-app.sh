#!/bin/bash
echo "=========================================="
echo "Preparing Student Notes Application..."
echo "=========================================="

# 1. Create named persistent volume if it doesn't exist
echo "[1/3] Creating Docker persistent volume 'student_notes_data'..."
docker volume create student_notes_data

# 2. Create custom bridge network if it doesn't exist
echo "[2/3] Creating Docker network 'student_notes_net'..."
docker network create student_notes_net 2>/dev/null || echo "Network 'student_notes_net' already exists."

# 3. Build custom web service Docker image
echo "[3/3] Building custom application Docker image..."
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    docker compose build
else
    docker build -t student-notes-web .
fi

echo "=========================================="
echo "Preparation complete! Run ./start-app.sh to launch."
echo "=========================================="
