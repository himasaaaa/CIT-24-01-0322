import os
import time
from datetime import datetime
from flask import Flask, render_template, request, jsonify
from pymongo import MongoClient, errors
from bson.objectid import ObjectId

app = Flask(__name__)

# Configuration
MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongodb:27017/studentdb")

# Persistent database connection helper
def get_db():
    retries = 5
    while retries > 0:
        try:
            client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=2000)
            client.admin.command('ping')
            return client.studentdb
        except errors.ConnectionFailure:
            retries -= 1
            time.sleep(2)
    # Return client anyway for runtime attempts
    client = MongoClient(MONGO_URI)
    return client.studentdb

db = get_db()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/health", methods=["GET"])
def health_check():
    try:
        db.command('ping')
        db_status = "connected"
    except Exception as e:
        db_status = f"disconnected ({str(e)})"
    return jsonify({
        "status": "online",
        "service": "student-notes-web",
        "database": db_status
    })

@app.route("/api/notes", methods=["GET"])
def get_notes():
    try:
        notes_cursor = db.notes.find().sort("created_at", -1)
        notes = []
        for note in notes_cursor:
            notes.append({
                "id": str(note["_id"]),
                "title": note.get("title", ""),
                "course": note.get("course", "General"),
                "content": note.get("content", ""),
                "category": note.get("category", "Lecture"),
                "created_at": note.get("created_at", datetime.now().strftime("%Y-%m-%d %H:%M"))
            })
        return jsonify({"success": True, "notes": notes, "count": len(notes)})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/notes", methods=["POST"])
def add_note():
    try:
        data = request.get_json() or {}
        title = data.get("title", "").strip()
        course = data.get("course", "").strip() or "General"
        content = data.get("content", "").strip()
        category = data.get("category", "Lecture")

        if not title or not content:
            return jsonify({"success": False, "error": "Title and content are required."}), 400

        new_note = {
            "title": title,
            "course": course,
            "content": content,
            "category": category,
            "created_at": datetime.now().strftime("%Y-%m-%d %H:%M")
        }

        result = db.notes.insert_one(new_note)
        new_note["id"] = str(result.inserted_id)
        del new_note["_id"]

        return jsonify({"success": True, "note": new_note}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/notes/<note_id>", methods=["DELETE"])
def delete_note(note_id):
    try:
        result = db.notes.delete_one({"_id": ObjectId(note_id)})
        if result.deleted_count > 0:
            return jsonify({"success": True, "message": "Note deleted successfully."})
        else:
            return jsonify({"success": False, "error": "Note not found."}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
