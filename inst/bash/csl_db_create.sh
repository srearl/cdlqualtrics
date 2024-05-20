#!/bin/bash

if [ ! -e cslobsdb.db ] ; then
  sqlite3 cslobsdb.db < create_tables.sql
else
  echo "could not create database"
fi
