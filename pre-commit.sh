#!/bin/bash

#To use this file, run the command from THIS directory
#ln -sf  ../../config/hooks/pre-commit.sh ../../.git/hooks/pre-commit
global_error_flag=0

run_puppet_lint()
{
    error_flag=0
    ((i=0))

    for current_file in $1
    do
       puppet-lint ${current_file} | grep "ERROR" > /dev/null 2>&1
       if [ "$?" -eq 0 ]
       then
           if [ ${error_flag} -eq 0 ]
           then 
               echo "Errors detected in the following files:"
           fi
           echo ${current_file}
           error_flag=1
           #global_error_flag=1
       fi  
    done

    if [ "${error_flag}" -eq 0 ]
    then
        echo "no errors detected"
    else
        echo "run: puppet-lint -f [file] | grep 'ERROR'"
    fi
}

run_yaml_lint()
{
    error_flag=0
    ((i=0))

    for current_file in $1
    do
       yamllint ${current_file} | grep -v "too long" | grep "error" > /dev/null 2>&1
       if [ "$?" -eq 0 ]
       then
           if [ ${error_flag} -eq 0 ]
           then
               echo "Errors detected in the following files:"
           fi
           echo ${current_file}
           error_flag=1
           #global_error_flag=1
       fi
    done

    if [ "${error_flag}" -eq 0 ]
    then
        echo "no errors detected"
    else
        echo "run: yamllint [file] | grep -v 'too long' | grep 'error'"
    fi
}

run_parser_validate()
{
    error_flag=0

    for current_file in $1
    do
       puppet parser validate ${current_file} > /dev/null 2>&1
       if [ "$?" -ne 0 ]
       then
           if [ ${error_flag} -eq 0 ]
           then
               echo "Errors detected in the following files:"
           fi
           echo ${current_file}
           error_flag=1
           global_error_flag=1
       fi
    done

    if [ "${error_flag}" -eq 0 ]
    then
        echo "no errors detected"
    else
        echo "run:  puppet parser validate [file]"
    fi
}

run_crlf()
{
    error_flag=0

    for current_file in $1
    do
       file ${current_file} | grep 'with CRLF line terminators' > /dev/null 2>&1
       if [ "$?" -eq 0 ]
       then
           if [ ${error_flag} -eq 0 ]
           then
               echo "Errors detected in the following files:"
           fi
           echo ${current_file}
           error_flag=1
           global_error_flag=1
       fi
    done

    if [ "${error_flag}" -eq 0 ]
    then
        echo "no errors detected"
    else
        echo "ASCII text, with CRLF line terminators ( windows text file )"
    fi

}

# check for puppet-lint

which puppet-lint > /dev/null 2>&1
if [ "$?" -ne 0 ]
then
    echo "puppet-lint is not installed, cannot proceed with puppet-lint style checking"
    echo "To install, type :"
    echo "   sudo yum install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel -y"
    echo "   sudo yum install ruby-rdoc ruby-devel -y"
    echo "   sudo yum install rubygems -y"
    echo "   sudo gem install puppet-lint"
    exit 1
fi

which yamllint > /dev/null 2>&1
if [ "$?" -ne 0 ]
then
    echo "yamllint is not installed, cannot proceed with puppet-lint style checking"
    echo "To install, type :"
    echo "   wget https://bootstrap.pypa.io/get-pip.py;python get-pip.py;pip install yamllint"
    exit 1
fi

if [ -d  .svn ]
then
    echo 'use svn'
    version_control='svn'
    modified='^M'
    added='^A'
elif [ -d .git ]
then
    echo 'use git'
    version_control='git'
    modified='modified:'
    added='new file:'
fi

all_files=`${version_control} status | egrep "(${modified}|${added})" | awk '{print $2}'`

file_modified=`${version_control} status | grep "${modified}" | awk -v var=${modified} '{split($0,a,var); print a[2]}' | grep '.pp$'`
file_added=`${version_control} status | grep "${added}" | awk -v var=${add} '{split($0,a,var); print a[2]}' | grep '.pp$'`
puppet_list="${file_modified} ${file_added}"

yaml_modified=`${version_control} status | grep "${modified}" | awk -v var=${modified} '{split($0,a,var); print a[2]}' | egrep '(.yaml$|.yml$)'`
yaml_added=`${version_control} status | grep "${added}" | awk -v var=${added} '{split($0,a,var); print a[2]}' | egrep '(.yaml$|.yml$)'`
yaml_list="${yaml_modified} ${yaml_added}"

echo
echo "========= puppet-lint style check  =========="
run_puppet_lint "${puppet_list}"

# check puppet
which puppet > /dev/null 2>&1
if [ "$?" -ne 0 ]
then
    echo "puppet is not installed, skipping puppet code validate"
    echo "To install, type :"
    echo "   sudo yum install puppet"
    break
else
    echo
    echo "========= puppet parser validate =========="
    run_parser_validate "${puppet_list}"
fi

echo
echo "========= yamllint style check  =========="
run_yaml_lint "${yaml_list}"
echo

echo
echo "========= CRLF line terminators  =========="
run_crlf "${all_files}"
echo

if [ ${global_error_flag} -eq 1 ]
then
    echo
    echo "Commit failed, please fix puppet code format  and commit again"
    exit 1
fi
