# Docker PostgreSQL images for Continous Integration

Current distributions available:

* CentOS 7
* Ubuntu 18.04

Current PostgreSQL versions available:

* 9.3
* 9.4
* 9.5
* 9.6
* 10
* 11
* 12

# Building images

Run:

```
./manage_images -h
```

# Running the images

Tu run, for example PostgreSQL 9.2 under CentOS6:

```
docker run -t --name test -e "DB_NAME=mydbname" -e "DB_PASS=mydbpassword" juliogonzalez/centos6-postgresql9.2
```

Use *-e "DB_NAME=mydbname"* if you want to create a database when the container is created

Use *-e "DB_PASS=mydbpassword"* if you want an specific password for the superuser *postgresql*, otherwise a random password will be created.

By default the container will expose port TCP *5432*, and you will be able to access with the user *postgresql*
