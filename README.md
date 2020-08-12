VNC+Firefox functionality forked from jlesage/docker-firefox

Usage:

docker run -d --name=firefox -p [your port]:5800 -v /docker/appdata/firefox:/config:rw --shm-size 2g docker-ff-esr

VNC ui will be availiable at http://[your host]:5800
