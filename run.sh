#!/bin/bash -e

# TODO: This should not be needed in future when SCL collections will be enabled
#       by default.
echo "Enabling SCL collections ..."
source .bashrc

echo "Executing bundle exec 'rake db:migrate' ..."
bundle exec 'rake db:migrate'
