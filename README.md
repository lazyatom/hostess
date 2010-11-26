# Hostess

A simple tool for adding local directories as virtual hosts in a local apache installation. It probably only works well on a Mac, but we're scratching our own itch here.

## Usage

    $ hostess create mysite.local /Users/myuser/Sites/mysite

This will create a new virtual host in your Apache configuration, setup your Mac's DNS to respond to that domain name, and restart Apache to make the new virtual host live.

    $ hostess help
    Usage:
    hostess create domain directory - create a new virtual host
    hostess delete domain           - delete a virtual host
    hostess list                    - list hostess virtual hosts
    hostess help                    - this info
