#!/bin/bash

proj="${1:-myproject}"

sudo apt-get update
sudo apt-get -y install python3-pip python3-dev nginx
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv

mkdir ~/$proj
cd ~/$proj
virtualenv $proj
source venv/bin/activate
pip install gunicorn flask

cat > ~/$proj/$proj.py <<EOL
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == '__main__':
    app.run(host='0.0.0.0')
EOL

cat > ~/$proj/wsgi.py <<EOL
from ${proj} import app

if __name__ == '__main__':
    app.run()
EOL

deactivate

sudo bash -c "cat > /etc/systemd/system/${proj}.service" <<EOL
[Unit]
Description=Gunicorn instance to serve ${proj}
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/${proj}
Environment="PATH=/home/ubuntu/${proj}/venv/bin"
ExecStart=/home/ubuntu/${proj}/venv/bin/gunicorn --workers 3 --bind unix:${proj}.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl start $proj
sudo systemctl enable $proj

sudo bash -c "cat > /etc/nginx/sites-available/${proj}" <<EOL
server {
    listen 80;
    server_name server_domain_or_IP;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/${proj}/${proj}.sock;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/$proj /etc/nginx/sites-enabled
sudo nginx -t
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
