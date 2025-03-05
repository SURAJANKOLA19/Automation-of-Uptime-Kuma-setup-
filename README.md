# Automation-of-Uptime-Kuma-setup-
This repository provides a fully automated setup for deploying Uptime Kuma without Docker on an Ubuntu-based server. It includes a Bash script that installs dependencies, sets up Uptime Kuma, configures it as a systemd service, and ensures it runs automatically after system reboots.

# 🚀 Uptime Kuma Auto-Setup Script  

This script automates the installation and configuration of **Uptime Kuma**, a self-hosted monitoring tool. It installs necessary dependencies, sets up **Node.js**, configures **PM2** for process management, and integrates **Nginx** as a reverse proxy.

## 📌 Features  

✅ Installs required dependencies (`nginx`, `nodejs`, `git`, `certbot`)  
✅ Clones and sets up **Uptime Kuma**  
✅ Configures **PM2** for process management  
✅ Sets up **Nginx** for domain-based access  
✅ Automatically enables **system startup** for Uptime Kuma  
✅ Supports **Let's Encrypt SSL** (manual step)  

---

## 📂 Project Structure  

```
|-- setup.py  # Main script to automate Uptime Kuma setup
```

---

## 🛠️ Prerequisites  

Before running this script, ensure you have:  

- **A Linux-based server** (Ubuntu 20.04/22.04 recommended)  
- **sudo privileges**  
- **A registered domain** (pointed to your server's public IP)  

---

## 🚀 Installation & Usage  

### 1️⃣ Clone the Repository (Optional)  
If you want to keep a local copy of this script:  
```bash
git clone https://github.com/your-repo/uptime-kuma-setup.git
cd uptime-kuma-setup
```

### 2️⃣ Run the Setup Script  
```bash
python3 app.py
```

### 3️⃣ Access Uptime Kuma  
- Open your browser and visit:  
  ```
  http://your-domain.com
  ```
- Follow the on-screen instructions to set up Uptime Kuma.  

---

## ⚙️ Configuration Details  

### 🔹 **Domain Configuration**  
By default, the script uses:  
```python
DOMAIN = "shrihari.zapto.org"
```
Modify this value in the script before running it if you need a different domain.

### 🔹 **Nginx Configuration**  
The script automatically configures an **Nginx reverse proxy** at:  
```
/etc/nginx/sites-available/kuma
```
It creates an entry that routes traffic to Uptime Kuma running on port `3001`.

Sample configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 🔹 **PM2 Process Manager**  
Uptime Kuma is managed by **PM2** to ensure it auto-starts on system boot.  

Commands to manage PM2 processes manually:
```bash
pm2 list                # View running processes
pm2 restart kuma        # Restart Uptime Kuma
pm2 logs kuma           # Check logs
pm2 delete kuma         # Remove Uptime Kuma from PM2
```

### 🔹 **Enable SSL with Let's Encrypt (Optional)**  
To secure your Uptime Kuma instance, install a free SSL certificate using **Certbot**:
```bash
sudo certbot --nginx -d your-domain.com
```
This will automatically generate and apply an SSL certificate.

---

## 🔧 Troubleshooting  

#### 🚨 PM2 Issues  
If PM2 is not starting Uptime Kuma:  
```bash
pm2 restart kuma
pm2 logs kuma
```

#### 🚨 Nginx Errors  
To check if the configuration is valid:  
```bash
sudo nginx -t
```
To restart Nginx:  
```bash
sudo systemctl restart nginx
```

#### 🚨 SSL Issues  
If SSL is not working, try:  
```bash
sudo certbot renew
sudo systemctl reload nginx
```

---
### Automated Deployment and Backup Script

This section describes the automated process for setting up a Python environment, running the Python application (`app.py`), and executing the backup (`backup.sh`) using a single script (`deploy.sh`).

#### **Overview**
The `deploy.sh` script automates the following steps to ensure smooth and efficient deployment:
1. System update and installation of required Python dependencies (`python3-venv`, `python3-pip`).
2. Creation and activation of a Python virtual environment.
3. Installation of AWS CLI within the virtual environment.
4. Running the Python application (`app.py`) in the background.
5. Triggering a backup (`backup.sh`) after 5 minutes of running the Python application.

#### **Prerequisites**
- Ubuntu system with `apt` package manager.
- Ensure that `app.py` and `backup.sh` are present in the working directory.
- The script must have executable permissions:
  ```bash
  chmod +x deploy.sh
---
### **Automated Backup & Deployment Script**

This script automates the deployment of a Python application (`app.py`), the creation of a backup, and its upload to AWS S3. It also sets up a cron job to automate the backup process.

#### **📝 Script Breakdown**

1. **Step 1: Check if `app.py` is Running**
   - The script checks if `app.py` is already running.
   - If not, it starts `app.py` and verifies if it launched successfully.

2. **Step 2: Wait Until `app.py` Has Been Running for 5 Minutes**
   - Waits until `app.py` runs for at least 5 minutes before proceeding with the next steps.

3. **Step 3: Configure AWS CLI & Create S3 Bucket**
   - Configures the AWS CLI.
   - Prompts the user to enter a name for the S3 bucket and checks if it exists.
   - If the bucket doesn't exist, the script creates it.

4. **Step 4: Uptime Kuma Backup Setup**
   - Defines backup directories, file naming convention, and retention policy (keeps the last 7 backups).
   - Creates a timestamped backup of the Uptime Kuma data directory.

5. **Step 5: Perform Backup**
   - Backs up the Uptime Kuma data directory and stores it in a `.tar.gz` file.

6. **Step 6: Clean Up Old Backups**
   - Cleans up old backups, keeping only the last 7 backups.

7. **Step 7: Upload to AWS S3**
   - Uploads the backup to the specified S3 bucket.

8. **Step 8: Automate Backup with Cron**
   - Sets up a cron job to run the backup script daily at 7 PM if it doesn't already exist.

#### **🚀 Prerequisites**

Before running this script, make sure the following are in place:

- A working Python environment with `app.py` and `backup.sh` in the current directory.
- AWS CLI is configured with appropriate permissions.
- The script has executable permissions:
  
  ```bash
  chmod +x backup.sh


---
## 🏷️ License  
This project is open-source and available under the **MIT License**.

---

## 🤝 Contributing  
Feel free to contribute by submitting pull requests or reporting issues.

---

## 📞 Support  
For any issues, open an issue in the repository or reach out via email.

Mail Id: suraj.ankola.1902@gmail.com

---

This README provides **everything** needed for a seamless setup. Let me know if you want any modifications! 🚀