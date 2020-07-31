# Request Tracker

[![Build Status](https://jenkins.ocf.berkeley.edu/buildStatus/icon?job=ocf/rt/master)](https://jenkins.ocf.berkeley.edu/job/ocf/job/rtjob/master/)

`rt` is the OCF's ticketing system, used both for internal tickets as well as
for our public email lists.

This repo is designed to be an example of a simple OCF service running on
Mesos. RT is an ideal service to start with because:

* All state is isolated into the database, so assuming each instance can access
  the same DB, they don't need to coordinate in any way.

* Okay to run multiple instances at once and kill them at any time (unlike
  other services like IRC which can only tolerate one instance, and don't cope
  well with that instance randomly dying).


## Upgrading

Deploying new major releases of RT involves more work than just building a new
Docker image and deploying that on Marathon. Here are some general instructions
for updating Request Tracker:

1.  Read the release notes to find out what you might need to change in the RT
    configuration. In particular, you'll want to read the `README` and
    `UPGRADING-x.y` files in the RT documentation.

2.  Make any necesary configuration changes. Most configuration changes will go
    into the `99-ocf.pm` file. You may also have to change other files as well.

3.  Run `make test` to perform a smoke test. This will test to ensure that the
    Docker image can be built and database setup works. Just because you passed
    the test, though, doesn't mean it necessarily works yet.

4.  Backup and upgrade the database. First, backup the RT database with

        mysqldump -u ocfrt ocfrt > ocfrt.sql

    This gives you a backup of the RT database at `ocfrt.sql`, in case
    something goes very wrong.

    Next, upgrade the RT database with

        rt-setup-database --action upgrade --dba ocfrt

    You'll need the password for the `ocfrt` account, which you can find under
    `/opt/share/docker/secrets/rt` on the hypervisors.

5.  Push your changes to GitHub and let Marathon deploy them. Test to make sure
    everything is working, and go back and make any changes as necessary.
