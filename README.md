# What is this?

All you need to build container images to be used later for Continuous Integration systems that require PostgreSQL.

For example they are used as a base to build [container images for tds_fdw Countinous Integration](https://github.com/tds-fdw/ci-setup)

# Supported distributions and PostgreSQL versions

Current distributions available:

* openSUSE Leap 15.6
* Rocky Linux 8
* Ubuntu 24.04

Current PostgreSQL versions available:

* 13
* 14
* 15
* 16
* 17
* 18

# Building images

Run:

```
./manage_images -h
```

# Running the images

Tu run, for example PostgreSQL 18 under Rocky Linux 8:

```
docker run -t --name test -e "DB_NAME=mydbname" -e "DB_PASS=mydbpassword" juliogonzalez/rockylinux8-postgresql:18
```

Use `-e "DB_NAME=mydbname"` if you want to create a database when the container is created

Use `-e "DB_PASS=mydbpassword` if you want a specific password for the superuser *postgresql*, otherwise a random password will be created.

By default the container will expose port TCP *5432*, and you will be able to access with the user *postgresql*
