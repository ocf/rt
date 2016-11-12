# Request Tracker

[![Build Status](https://jenkins.ocf.berkeley.edu/buildStatus/icon?job=rt/master)](https://jenkins.ocf.berkeley.edu/job/rt/job/master/)

`rt` is the OCF's ticketing system, used both for internal tickets as well as
for our public email lists.

This repo is designed to be an example of a simple OCF service running on
Mesos. RT is an ideal service to start with because:

* All state is isolated into the database, so assuming each instance can access
  the same DB, they don't need to coordinate in any way.

* Okay to run multiple instances at once and kill them at any time (unlike
  other services like IRC which can only tolerate one instance, and don't cope
  well with that instance randomly dying).
