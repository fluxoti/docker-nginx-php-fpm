#!/bin/bash

# starting supervisor programs
/usr/bin/supervisorctl reread
/usr/bin/supervisorctl update
/usr/bin/supervisorctl start all

exec /usr/bin/supervisord --nodaemon -u root