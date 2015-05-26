#!/bin/bash

echo "sourcing .bashrc ..."
source .bashrc

echo "executing bundle exec 'rake db:migrate' ..."
bundle exec 'rake db:migrate'
echo "done!"
