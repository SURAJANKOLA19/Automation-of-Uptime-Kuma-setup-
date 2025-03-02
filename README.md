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