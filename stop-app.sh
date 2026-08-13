#!/bin/bash
echo "=========================================="
echo "Stopping app ..."
echo "=========================================="

if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    docker compose stop
else
    docker stop student-notes-web student-notes-db 2>/dev/null || true
fi

echo "=========================================="
echo "Application stopped. Persistent data in volume 'student_notes_data' is preserved."
echo "You can restart using ./start-app.sh"
echo "=========================================="
