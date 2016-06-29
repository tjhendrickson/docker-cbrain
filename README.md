# Docker instructions

* To build the container:
```
docker build -f Docker/Dockerfile .
```

* To run a CBRAIN portal on local port 3000 using the container:
```
MODE=development PORT=3000 SSH_PORT=2222 USERID=`id -u` GROUPID=`id -g` docker-compose up
```
