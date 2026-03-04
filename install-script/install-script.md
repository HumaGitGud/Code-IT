# Easy setup using one script

## 1. Connect to Your Server
Log in to your server via SSH as root or a user with sudo privileges:
```bash
ssh root@<YOUR_SERVER_IP>
```

## 2. Create the Deployment Script
Open a new file using the nano text editor:
```bash
nano setup.sh
```

## 3. Make the Script Executable
Run in the server:
```bash
chmod +x setup.sh
```

## 4. Execute with Parameters
Run the script by providing your admin username, the project room name, and the list of student usernames.
Syntax Warning: The list of team members must be wrapped in single quotes, with each individual name wrapped in double quotes, exactly as formatted below.
```bash
sudo ./setup.sh <admin_user> <project_name> '"student1", "student2", "student3"'
```

## 5. Initialize the Shared Room (Admin Only)
The script takes approximately 5–10 minutes to run. Once it says DEPLOYMENT COMPLETE, the shared server exists but is "asleep"
1. Navigate to http://<YOUR_SERVER_IP>/hub/admin and log in with your <admin_user> credentials
2. Locate the shared project user (e.g., the_project-collab) in the roster
3. Click the blue Start Server button
4. Once the server is running, students can log in with their own accounts and navigate to the shared workspace at: http://<YOUR_SERVER_IP>/hub/user/<project_name>-collab/lab