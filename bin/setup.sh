#!/usr/bin/env sh
for f in examples/default/*
do
  cp $f config/$( basename $f .yml.example ).yml
done
