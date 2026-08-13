# Student Note Management System

**Course**: CCS3308 - Virtualization and Containers  
**Assignment**: Assignment 1 - Docker-based Web Application Deployment

---

## 📌 Application Description

The **Student Note Management System** is a lightweight, 2-service Dockerized web application designed for students to create, manage, categorize, and search course notes. 

The application consists of a modern web interface powered by Python Flask and a MongoDB backend for persistent data storage. Students can tag notes by category (*Lecture Note*, *Assignment*, *Exam Prep*, *Quick Idea*), attach course codes, search notes dynamically, and delete notes.

---

## 🛠️ Deployment Requirements

To run this application, ensure the following tools are installed on your machine:

- **Docker Engine**: Version 20.10.0 or higher
- **Docker Compose**: Version 2.0.0 or higher (or `docker-compose` CLI)
- **Bash Shell**: For executing setup, start, stop, and removal scripts (`./prepare-app.sh`, `./start-app.sh`, etc.)
- **Web Browser**: Chrome, Firefox, Edge, or Safari to interact with the web interface.

---

## 🌐 Network and Volume Details

### 1. Virtual Network
- **Name**: `student_notes_net`
- **Driver**: Bridge
- **Purpose**: Provides isolated, secure inter-container communication allowing the web application container (`student-notes-web`) to communicate with the MongoDB container (`student-notes-db`) using container hostname resolution (`mongodb:27017`).

### 2. Named Persistent Volume
- **Name**: `student_notes_data`
- **Mount Path**: `/data/db` (inside MongoDB container)
- **Purpose**: Persists all student notes on the host disk even when containers are stopped (`./stop-app.sh`) or restarted.

---

## ⚙️ Container Configuration

| Service Name | Container Name | Image Source | Port Mapping | Environment Variables | Restart Policy | Volume Mounts |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `web` | `student-notes-web` | Custom (`Dockerfile`) | `5000:5000` | `MONGO_URI=mongodb://mongodb:27017/studentdb` | `unless-stopped` | None |
| `mongodb` | `student-notes-db` | `mongo:latest` | `27017:27017` | None | `unless-stopped` | `student_notes_data:/data/db` |

---

## 📦 Container List

1. **`student-notes-web`**:
   - **Role**: Serves the user interface on port `5000` and processes API endpoints (`/api/notes`, `/api/health`).
2. **`student-notes-db`**:
   - **Role**: MongoDB database listening on port `27017` to store student notes data.

---

## 📖 Instructions

### 1. Prepare Application Resources
Builds the custom web image, initializes the `student_notes_net` network, and creates the `student_notes_data` volume:
```bash
chmod +x *.sh
./prepare-app.sh
```

### 2. Run the Application
Launches all container services in detached mode with restart policies:
```bash
./start-app.sh
```

### 3. Accessing the Application
Open your web browser and navigate to:
```
http://localhost:5000
```

### 4. Pause / Stop the Application
Stops running service containers without deleting persistent note data:
```bash
./stop-app.sh
```

### 5. Delete Application Resources
Stops containers and completely removes created containers, networks, custom images, and persistent volumes:
```bash
./remove-app.sh
```

---

## 🔄 Example Workflow

```bash
# Create application resources
./prepare-app.sh
Preparing app ...

# Run the application
./start-app.sh
Running app ...
The app is available at http://localhost:5000

# Open a web browser and interact with the application

# Pause the application
./stop-app.sh
Stopping app ...

# Delete all application resources
./remove-app.sh
Removed app.
```

---

## 🧪 Testing State Persistence

1. Run `./start-app.sh` and access `http://localhost:5000`.
2. Add a new note (e.g. *Title: Docker Containers*, *Course: CCS3308*).
3. Run `./stop-app.sh` to stop the containers.
4. Run `./start-app.sh` to start the application again.
5. Refresh `http://localhost:5000` — your saved notes will still be preserved because state is saved in the `student_notes_data` volume!
