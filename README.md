# puppet-pre-commit-script

## Description

Bash script to check various puppet code before committing to svn or git

currently support checks for
* puppet code
* puppet-lint
*  yamllint
* CRLF ( windows text files )

## Installation

git clone or download file(s) to your host
note the path to pre-commit.sh

### Requirements

installed the following software:

puppet
sudo yum install puppet -y

puppet-lint
* sudo yum install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel -y
* sudo yum install ruby-rdoc ruby-devel -y
* sudo yum install rubygems -y
* sudo gem install puppet-lint

yamllint
* wget https://bootstrap.pypa.io/get-pip.py;python get-pip.py;pip install yamllint


## Run utility

cd [to git or svn repo directory]
sh [path_to_file]/pre-commit.sh
