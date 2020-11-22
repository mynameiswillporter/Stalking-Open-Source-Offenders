# Stalking Known Open Source Offenders for Novel CVEs
This repository contains a methodology for finding novel vulnerabilities in open source projects that have CVEs that have already been discovered.

The talk was presented at BSidesCT and BSidesDayton in 2020.

BSidesCT: https://www.youtube.com/watch?v=wSvlhFQzUNg

This repository contains information describing the methodology, and has some tooling built around the methodology herein described.

## Hypothesis
By examining CVE references containing links to Git commits that patch security vulnerabilities, it is possible to determine the commits that introduced the errors. By identifying the author of the vulnerable commit, and examining all commits produced by that individual, it is possible to discover novel CVEs that had previously been undiscovered.

## Methodology
Given a CVE containing a link to a git commit fixing the vulnerability, the following steps can be taken to identify other commits written by the individual who introduced the known vulnerability.
1. Go to the commit that fixed the vulnerability. Take note of the vulnerable file and the line number that best illustrates the vulnerability.
2. Navigate to the commit that fixed the vulnerability's parent commit. This commit represents a point of time during which the codebase was still vulnerable.
3. View the vulnerable file as it was while it was still vulnerable.
4. Run blame on the vulnerable file to identify the commit that introduced the vulnerable line of code.
5. Identify the author that introduced the vulnerability into the codebase. Note that the author is different than the committer, who could have merely been merging a merge request.
6. Grab all of the commits by the author of the known vulnerability.
7. Inspect the commits for additional vulnerabilities.

## Scripts
The presentation recording covers how to perform each of the steps in detail. Additionally there are scripts to automate some of the tasks with a degree of success. Failure cases may arise if there are certain whitespace changes committed over the vulnerable lines. In this case, the manual methodology can still succeed, but some of the scripts may produce erroneous results.

1. `identify_vuln_introduction.sh`

This script is the first step. Inputs to the script will need to include the commit hash for a commit that fixed a known vulnerability, the vulnerable file, the line number of the vulnerability fix, and a path containing a local git repository for the project in question.

This script will output a commit hash of the commit that introduced the vulnerability into the codebase.

2. `identify_author.sh`

Given the commit hash of the commit that introduced the vulnerability into the database, this script will output the commit's author.

3. `get_commits_by_author.sh`

Given the username of the author of the vulnerable commit, this script will output the commit hashes of all of that user's commits.

## Demo
