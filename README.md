# Docker PostgreSQL images for Continous Integration

Current distributions available:

* openSUSE Leap 15.6
* Rocky Linux 8
* CentOS 7
* Ubuntu 18.04
* Ubuntu 20.04

Current PostgreSQL versions available:

* 9.3
* 9.4
* 9.5
* 9.6
* 10
* 11
* 12
* 13
* 14
* 15
* 16 (Unavailable for CentOS 7)

# Building images

Run:

```
./manage_images -h
```

# Running the images

Tu run, for example PostgreSQL 15 under CentOS7:

```
docker run -t --name test -e "DB_NAME=mydbname" -e "DB_PASS=mydbpassword" juliogonzalez/centos7-postgresql15
```

Use *-e "DB_NAME=mydbname"* if you want to create a database when the container is created

Use *-e "DB_PASS=mydbpassword"* if you want an specific password for the superuser *postgresql*, otherwise a random password will be created.

By default the container will expose port TCP *5432*, and you will be able to access with the user *postgresql*
