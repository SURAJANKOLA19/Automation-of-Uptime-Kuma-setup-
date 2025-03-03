import os
import subprocess
 
# Constants
DOMAIN = "shrihari.zapto.org"
NGINX_CONFIG_PATH = "/etc/nginx/sites-available/kuma"
 
def run_command(command, check=True):
    """Run a shell command and handle errors."""
    try:
        subprocess.run(command, shell=True, check=check)
        print(f"✅ Command executed successfully: {command}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error executing command: {command}\n{e}")
        exit(1)
 
def install_packages():
    """Install required system packages."""
    print("🔹 Updating system and installing required packages...")
    run_command("sudo apt update && sudo apt upgrade -y")
    run_command("sudo apt install -y nodejs git nginx certbot python3-certbot-nginx")
 
def install_node():
    """Install Node.js LTS version."""
    print("🔹 Installing Node.js...")
    run_command("curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -")
    run_command("sudo apt install -y nodejs")
    run_command("node -v")
    run_command("npm -v")
 
def clone_uptime_kuma():
    """Clone the Uptime Kuma repository."""
    if not os.path.exists("/opt/uptime-kuma"):
        print("🔹 Cloning Uptime Kuma...")
        run_command("sudo git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma")
        run_command("sudo git config --global --add safe.directory /opt/uptime-kuma")
        run_command("sudo chown -R $USER:$USER /opt/uptime-kuma")
    else:
        print("✅ Uptime Kuma is already cloned. Skipping.")
 
def install_kuma():
    """Install and start Uptime Kuma using PM2."""
    print("🔹 Installing Uptime Kuma...")
    os.chdir("/opt/uptime-kuma")
    run_command("npm run setup")
    run_command("sudo npm install -g pm2")
 
    # Check if PM2 is installed correctly
    pm2_version = subprocess.run("pm2 -v", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if pm2_version.returncode != 0:
        print("❌ PM2 installation failed. Reinstalling...")
        run_command("sudo npm remove -g pm2")
        run_command("sudo npm install -g pm2")
 
    # Check if Uptime Kuma is already running in PM2
    existing_pm2_process = subprocess.run("pm2 list | grep kuma", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if "kuma" in existing_pm2_process.stdout:
        print("✅ Uptime Kuma is already running in PM2. Skipping start command.")
    else:
        print("🔹 Starting Uptime Kuma with PM2...")
        run_command("pm2 start server/server.js --name kuma")
 
    run_command("pm2 save")
 
    # Try different PM2 startup commands
    pm2_startup_cmds = [
        "pm2 startup systemd",
        f"sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u {os.getenv('USER')} --hp {os.getenv('HOME')}",
        "pm2 unstartup && pm2 startup systemd"
    ]
 
    for cmd in pm2_startup_cmds:
        try:
            print(f"🔹 Trying command: {cmd}")
            run_command(cmd)
            break  # If one command works, stop trying
        except SystemExit:
            continue  # If it fails, try the next one
 
    print("✅ PM2 setup completed successfully.")
 
def setup_nginx():
    """Configure Nginx for Uptime Kuma."""
    if not os.path.exists(NGINX_CONFIG_PATH):
        print("🔹 Configuring Nginx...")
        nginx_config = f"""
server {{
    listen 80;
    server_name {DOMAIN};
 
    location / {{
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
"""
        with open("/tmp/kuma_nginx", "w") as f:
            f.write(nginx_config)
 
        run_command(f"sudo mv /tmp/kuma_nginx {NGINX_CONFIG_PATH}")
        run_command(f"sudo ln -s {NGINX_CONFIG_PATH} /etc/nginx/sites-enabled/")
        run_command("sudo unlink /etc/nginx/sites-enabled/default")
 
    print("🔹 Restarting Nginx...")
    run_command("sudo systemctl restart nginx")
    run_command("sudo systemctl enable nginx")
 
def setup_ssl():
    """Install and configure an SSL certificate using Certbot."""
    print("🔹 Obtaining an SSL certificate for HTTPS...")
 
    # Ensure Certbot is installed
    run_command("sudo apt install -y certbot python3-certbot-nginx")
 
    # Obtain and apply SSL certificate
    run_command(f"sudo certbot --nginx -d {DOMAIN} --non-interactive --agree-tos -m admin@{DOMAIN}")
 
    # Set up auto-renewal
    run_command("echo '0 3 * * * root certbot renew --quiet' | sudo tee /etc/cron.d/certbot-renew")
 
    # Modify Nginx config for HTTPS
    nginx_ssl_config = f"""
server {{
    listen 80;
    server_name {DOMAIN};
    return 301 https://$host$request_uri;
}}
 
server {{
    listen 443 ssl;
    server_name {DOMAIN};
 
    ssl_certificate /etc/letsencrypt/live/{DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
 
    location / {{
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
"""
    # Update Nginx config with SSL
    with open("/tmp/kuma_nginx_ssl", "w") as f:
        f.write(nginx_ssl_config)
 
    run_command(f"sudo mv /tmp/kuma_nginx_ssl {NGINX_CONFIG_PATH}")
    run_command("sudo systemctl restart nginx")
 
    print("✅ SSL setup completed successfully.")
 
def main():
    """Main function to orchestrate the setup."""
    install_packages()
    install_node()
    clone_uptime_kuma()
    install_kuma()
    setup_nginx()
    setup_ssl()  # Setup SSL after Nginx is configured
 
    print("🎉 Uptime Kuma setup with SSL completed successfully!")
 
if __name__ == "__main__":
    main()