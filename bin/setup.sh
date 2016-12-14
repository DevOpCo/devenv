#!/usr/bin/env bash

bundler_version="`cat .bundler-version`"
ruby_version="`cat .ruby-version`"
ruby_gemset="`cat .ruby-gemset`"

if [[ $_ != $0 ]]
 then
   if [ -n "$(type -t rvm)" ] && [ "$(type -t rvm)" = function ]
     then
       [[ $_ != $0 ]] && echo "Script is being sourced" || echo "Script is a subshell"
       echo "rvm is already installed"
     else
       gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 &&
       \curl -sSL https://get.rvm.io | bash -s stable --without-gems="rvm rubygems-bundler" &&
       source ~/.bashrc &&
       rvm list rubies|grep "=>"|grep $ruby_version || rvm install $ruby_version &&
       rvm gemset use $ruby_version &&
       rvm gemset create $ruby_gemset &&
       rvm gemset use $ruby_gemset &&
       gem install bundler -v $bundler_version &&
       bundle install &&
       echo "rvm installed and bundler installed and configured" &&
       echo "rvm using ruby $ruby_version with gemset $ruby_gemset"
   fi
 else
   echo "Script cannot be run as a subshell"
   echo "Ensure script is being sourced by running the following:"
   echo "source bin/setup.sh"
   exit 3
 fi

# TODO: turn below into thor task
# for f in examples/default/*
# do
  # cp $f config/$( basename $f .yml.example ).yml
# done
