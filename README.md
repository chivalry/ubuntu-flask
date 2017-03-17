# ubuntu-flask
A bash script to automate the process of setting up Flask on Ubuntu 16

## Introduction

This script automates the process of setting up a Flask-based web server on Ubuntu 16.04, as described by [DigitalOcean][ubuntu]'s article. I used AWS for all instances of Ubuntu 16.04, and am new to setting up Flask, using Ngnix, using Gunicorn, and honestly, just about everything this script does. I don't actually understand most of it. It works for me, but I make no guarantees for you.

## Usage

Create an AWS Ubuntu 16.04 instance and ssh into it. Run the following commands, where `project_name` is the name of your Flask project. If you omit this, `myproject` will be used by default.

    wget https://raw.githubusercontent.com/chivalry/ubuntu-flask/master/ubuntu-flask.bash
    chmod +x ubuntu-flask.bash
    ./ubuntu-flask.bash [project_name]

## Acknowledgements

A big thank you to the extremely helpful participants of the [pocoo][irc] channel, without whom I would never have been able to get this working as far as I have.

[ubuntu]: https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-16-04
[irc]: http://www.pocoo.org/irc/
