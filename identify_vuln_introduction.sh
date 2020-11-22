#!/usr/bin/env bash


# exit when any command fails
set -e

script_name=`basename "$0"`
VERBOSE="false"

function usage {
	echo "usage: $script_name -c <commit_hash> -f <filepath> -l <line_number> -d <repository_dir> [-v]"
	echo "  -c <commit_hash>: The hash string associated with the commit that fixes the vulnerability in question"
	echo "  -f <filepath>: The filepath of the vulnerable file relative to the repository"
	echo "  -l <line_number>: The line number containing the vulnerability. If multiple line numbers contain the vulnerability, pick the most important one"
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
while getopts ":c:f:l:d:v" opt
do
	case $opt in
		c) 
			commit_hash=${OPTARG}
			;;
		f)
			filepath=${OPTARG}
			;;
		l) 
			line_number=${OPTARG}
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

if [ ! "$commit_hash" ] || [ ! "$filepath" ] || [ ! "$line_number" ] || [ ! "$repository_directory" ]; then
	echo "error: arguments -c, -f, -l, and -d must be supplied."
	echo ""
	usage
fi

# Output the configuration information
verbose_log "Using commit hash: $commit_hash"
verbose_log "Using vulnerable filepath: $filepath"
verbose_log "Using vulnerable line number: $line_number"
verbose_log "Using repository directory: $repository_directory"

# get the initial working directory
INITIAL_WORKING_DIRECTORY=$(pwd)

######################################
#   REPOSITORY COMMANDS
######################################

verbose_log "switching to repository directory..."
cd $repository_directory

# get the current head and branch so we can revert the repository after we get the info we want
verbose_log "parsing current revision..."
INITIAL_HEAD_REV=$(git rev-parse HEAD)
INITIAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
verbose_log "initial head revision: $INITIAL_HEAD_REV"

# get the parent commit of the commit in question
verbose_log "identifying parent commit..."
parent_commit_hash=$(git rev-parse "$commit_hash"^)
verbose_log "parent commit identified as: $parent_commit_hash"

# checkout the parent commit, this is where the file in question is reverted to its vulnerable state.
verbose_log "checking out parent commit..."
redirect_cmd git checkout $parent_commit_hash

# git blame on the file and figure out the commit that introduced the vulnerability
verbose_log "identifying commit that introduced vulnerability..."
vulnerability_introduced_commit=$(git --no-pager blame -l -s $filepath | awk '{print $1, $2}' | sed 's/.$//' | awk -v linenum="$line_number" '$2==linenum' | awk '{print $1}')
verbose_log "Vulnerability Introduced in commit: $vulnerability_introduced_commit"


#####################################
#      POST EXECUTION CLEANUP
#####################################
# revert the git repository to how it was before the script ran
if [ "$INITIAL_BRANCH" = "HEAD" ]; then
	redirect_cmd git checkout $INITIAL_HEAD_REV
else
	redirect_cmd git checkout $INITIAL_BRANCH
fi


# switch back to the initial working directory
cd $INITIAL_WORKING_DIRECTORY


# Print the result of the script
echo "$vulnerability_introduced_commit"
