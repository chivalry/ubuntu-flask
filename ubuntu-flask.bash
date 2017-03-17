#!/bin/bash

sudo apt-get update
sudo apt-get install python3-pip python3-dev nginx
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv

mkdir ~/myproject
cd ~/myproject
virtualenv myprojectenv
source myprojectenv/bin/activate
pip install gunicorn flask

cat > ~/myproject/myproject.py <<EOL
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == '__main__':
    app.run(host='0.0.0.0')
EOL

cat > ~/myproject/wsgi.py <<EOL
from myproject import app

if __name__ == '__main__':
    app.run()
EOL

deactivate

sudo bash -c "cat > /etc/systemd/system/myproject.service" <<EOL
[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/myproject
Environment="PATH=/home/ubuntu/myproject/myprojectenv/bin"
ExecStart=/home/ubuntu/myproject/myprojectenv/bin/gunicorn --workers 3 --bind unix:myproject.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl start myproject
sudo systemctl enable myproject

sudo bash -c "cat > /etc/nginx/sites-available/myproject" <<EOL
server {
    listen 80;
    server_name server_domain_or_IP;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/ubuntu/myproject/myproject.sock;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled
sudo nginx -t
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
