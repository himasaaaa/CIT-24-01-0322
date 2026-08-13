#!/bin/bash
echo "=========================================="
echo "Removing app and cleaning up resources..."
echo "=========================================="

# 1. Stop and remove containers and compose resources
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    docker compose down -v --rmi all 2>/dev/null || true
fi

# 2. Explicit fallback cleanup for standalone resources
docker stop student-notes-web student-notes-db 2>/dev/null || true
docker rm -f student-notes-web student-notes-db 2>/dev/null || true
docker volume rm student_notes_data 2>/dev/null || true
docker network rm student_notes_net 2>/dev/null || true
docker rmi student-notes-web 2>/dev/null || true

echo "=========================================="
echo "Removed app."
echo "=========================================="
