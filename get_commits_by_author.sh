#!/usr/bin/env bash


# exit when any command fails
set -e

script_name=`basename "$0"`
VERBOSE="false"

function usage {
	echo "usage: $script_name -a <author> -d <repository_dir> [-v]"
	echo "  -a <author>: The git username of the author"
	echo "  -d <repository_directory>: An absolute or relative filepath to the local directory containing the git repository to examine"
	echo "  -v: toggle verbose output"
	echo ""
	exit 1
}

function redirect_cmd {
	if [[ "${VERBOSE}" == "true" ]]; then
		"$@"
	else
		"$@" &> /dev/null
	fi
}

function verbose_log {
	if [[ "${VERBOSE}" == "true" ]]
	then
		echo $1
	fi
}

# Check to make sure git is installed
if ! command -v git &> /dev/null
then
    echo "ERROR: git command could not be found, please install git" 1>&2
    exit
fi

# set the default repository directory to .
# this will work if you are running this script in the git repo
repository_directory='.'


# Get the command line arguments
while getopts ":a:d:v" opt
do
	case $opt in
		a) 
			author=${OPTARG}
			;;
		d) 
			repository_directory=${OPTARG}
			;;
		v)
			VERBOSE="true"
			;;
			
		:) 
			echo "Option -$OPTARG requires an argument." >&2
			echo ""
			usage
			exit 1
			;;
		\?)
			echo "Invalid option -$OPTARG"
			echo ""
			usage
			exit 1
			;;
	esac
done

if [ ! "$author" ] || [ ! "$repository_directory" ]; then
	echo "error: arguments -a and -d must be supplied."
	echo ""
	usage
fi

# Output the configuration information
verbose_log "Using author: $author"
verbose_log "Using repository directory: $repository_directory"

# get the initial working directory
INITIAL_WORKING_DIRECTORY=$(pwd)

######################################
#   REPOSITORY COMMANDS
######################################

verbose_log "switching to repository directory..."
cd $repository_directory

# git blame on the file and figure out the commit that introduced the vulnerability
verbose_log "identifying author's commits"
commits=$(git --no-pager log --author=$author --pretty='format:%H')

#####################################
#      POST EXECUTION CLEANUP
#####################################
# switch back to the initial working directory
cd $INITIAL_WORKING_DIRECTORY


# Print the result of the script
echo "$commits"
