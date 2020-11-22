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

**1. identify_vuln_introduction.sh**

This script is the first step. Inputs to the script will need to include the commit hash for a commit that fixed a known vulnerability, the vulnerable file, the line number of the vulnerability fix, and a path containing a local git repository for the project in question.

This script will output a commit hash of the commit that introduced the vulnerability into the codebase.

**2. identify_author.sh**

Given the commit hash of the commit that introduced the vulnerability into the database, this script will output the commit's author.

**3. get_commits_by_author.sh**

Given the username of the author of the vulnerable commit, this script will output the commit hashes of all of that user's commits.

## Demo
This demo will use [CVE-2018-17179](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17179). To start we visit the CVE page and then navigate to the reference link that is a [commit that fixes the vulnerability](https://github.com/openemr/openemr/commit/3e22d11c7175c1ebbf3d862545ce6fee18f70617).

From this page we note the following information before beginning:
* The commit hash: `3e22d11c7175c1ebbf3d862545ce6fee18f70617`
* The file containing the vulnerability: `interface/forms/eye_mag/php/taskman_functions.php`
* The line number containing the vulnerability before it was fixed: `97`

That information will be fed to our scripts later. *Note: the filename is expressed as relative to the repository*

From there, we can run the following commands to download this tool and the repository, and identify commits written by the person who introduced this vulnerability:
```
will@localhost:~# mkdir demo
will@localhost:~# cd demo
will@localhost:~/demo# git clone https://github.com/mynameiswillporter/Stalking-Open-Source-Offenders.git
Cloning into 'Stalking-Open-Source-Offenders'...
remote: Enumerating objects: 16, done.
remote: Counting objects: 100% (16/16), done.
remote: Compressing objects: 100% (13/13), done.
remote: Total 16 (delta 6), reused 10 (delta 3), pack-reused 0
Unpacking objects: 100% (16/16), done.
will@localhost:~/demo# git clone https://github.com/openemr/openemr.git
Cloning into 'openemr'...
remote: Enumerating objects: 23, done.
remote: Counting objects: 100% (23/23), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 138400 (delta 4), reused 8 (delta 1), pack-reused 138377
Receiving objects: 100% (138400/138400), 454.75 MiB | 23.08 MiB/s, done.
Resolving deltas: 100% (89068/89068), done.
Checking out files: 100% (4477/4477), done.
will@localhost:~/demo# cd Stalking-Open-Source-Offenders/
will@localhost:~/demo/Stalking-Open-Source-Offenders# ./identify_vuln_introduction.sh -c 3e22d11c7175c1ebbf3d862545ce6fee18f70617 -f interface/forms/eye_mag/php/taskman_functions.php -l 97 -d ../openemr/
00aa8a6f2cd12e668532c313fa028a56144bf62e
will@localhost:~/demo/Stalking-Open-Source-Offenders# ./identify_author.sh -c 00aa8a6f2cd12e668532c313fa028a56144bf62e -d ../openemr/
ophthal
will@localhost:~/demo/Stalking-Open-Source-Offenders# ./get_commits_by_author.sh -a ophthal -d ../openemr/
9a70d54ee4928aa6e0dba2ad6b5e844d311100b5
3a876955b7b4eef79e39805f0c618cb342ccf98b
1b020696171f09a0ffaaf5cdfba9a2939f3f534c
3e412486ba5415207737a9e713975ea6267bf5f9
77f8aca722bd09cfd1801717fc5fba88d07395be
748b4bff647f67a41fadee03b1c4ea4bedf61830
7a8334daf39b078dfa38b9ab221701018e18079d
b780170f06c84d758bfcd87647d9c9c8b77becdd
053f6e3939f8f9ba49cc19ef154654ffcd8326fc
da853261af1045a443da7b85bf629d4ce8e91d53
8184b8d36b44c13c1b48db4b1d7b2ef26bc2cdc8
b523ce87ea7cf3c5cb0523758a3ffd9db34c6112
627980f46b8be210791b0408080e72b35fa4400d
0718350fadb42293a4d4599f087e9cc52d81aca0
af0826796c579bd673c7bec5710011ba42d6da17
e02c7b648ec3eecf5420f80576ba63aa7bf3a40e
f124ae631aa36bc74456a6edeefcb75acf1998c4
e61c743d06b75ae14358a0c6c8c737da00d99408
89a5ba29d3fd88b87a454b7f8aa9349a7dbaea48
8506a3e7e072cc6ca52d9735d4039111477496fd
912c89f54e5b79bbae59470458d8f5440f629f8e
ecfe106ad11c2642a862fcd22add49ccfdcaf09c
2012f1def5182722edffba316a92f37f21bb795b
7bd8cbab8b7dab575def96550716a2584b7476cb
6a5d164ab1987aaac1f49d77bda4671a0e0f0202
b0ab6fd47eb5a1a3df4e80d60df0f07116c18bf7
59857d05d952adb1f4980ceda808fd6473c15a3e
277bc727a0895eb610f39a16fa19db70fd29fac7
b1375c59ca8be0982541653ac8c3d744806c1025
b607a8d7877b8a33da2e1ccb7841c894845b2a65
17e7fe06e516c0deb1db3eb35ad4b504a902a1be
7f7e51ab37ed05aa5af0d554bfd93a1bbf34dc21
2ea89324cadf12123c1014d05da5767c2e71687e
e97f5252e6281d2d8ccbe22babef9006bc9dacc7
620c9a07bbe92087815dc4d469c777a7ca2b05f0
18cbaab75295df9dc3bfdc0d3608727ff602bb65
88683cef6e865efd9d18e9ded4e8988032d5612c
e6ed30370665e9135985d761df49f7ed49cbfa3a
fe5a07bef409cac794651e76bdaa69152a8449e3
fe7c0d77e4fc21a090ab26c2ecde84bfcc04581c
3c19b5354c4a5c10b0a1f523f04c55b0dd1010c5
883cae926c1e65f902664d839e70725f413bdd94
1ed7ce62def356a3ef56c6c139bbab8a07b3e974
61ed9a97a3c3650105ef2ec69cc940552c3b9750
53853f4822461d0fd0612132d9f24a937a057c0f
ebb8aad8fed783870e6de39c06093b4ac34f1285
4e7183eb34fdb65fe4ba2f0f94fc5a79272cf494
174d2a9b0d61d1943dd1252c8f5c2e5b65456b8e
533c5c3ac20a05b4b14d9a6cf56f35ab9357aeab
ba576a2444f7d0b03a1503aafca6340b6933ddea
7b7c26a7eda9ed87e00c5c3073a9eb9d228dd35b
ef7bd5f15945b285d0a85c85a65e24c69d9dd71f
14ab0d0a1ac5e882f0588683cd6d28bc1e7090ca
aa5f5e32537b759e83f590063911b6c648f79dca
bd894c8939b3ba4ffd3f20b2204605fb4ad92683
1563a5a99fbc00ec242075d3055410f23979b323
a0fa8ad581611b071839bcaffe88816434a09780
9f2680749eacdaf837ed78a8667df346dc40161a
1806bb736f309920f33d6bf92da159deb622358b
79861ef916ea69fdc2adb4b8c99dc3190af502c4
ea7018ae342c8ea13914bb8d716b34ad1f796794
7c702dc8111a739167cf06b38f6e2f363f9672c6
022a77e1f1a3ac583b98a256461fd92510f475b9
b03855186c3f6d16e0b5483cf4d7fc6b2aac0eb8
6fd59135fe551aed36bdfc5a898faa93f564db8c
5f5c0148ee2f1461d02b8c5afba39eaf33204e34
eb11791cd6e7c16eb516ee92d914c8ba88558329
bd4870033839b0ca9a3978bf8b361c0a4f991c32
77b9291e5763c03178dc334f2060dda7e30c50c7
64b46b2e69fd90cb536d5467cc71c5c4e31e4c76
2ffdaa3a0252b29172f7acf45a3fedfdcf592471
03cce810654f586cd498a02284ffa8178bd4477f
e6361266b750657d80c221bfea4cd0f30e41401c
f2d553deece37d6ccea48b409bfde048d1ccf82e
51128c501cda664940f94ead864b69fcddab4d6f
1777f22b9728c1d0d5d47710c136a9a5a732f7ff
88d608dc41afda643840d9830e2078e8c485d80d
dda0de2d02d6b0d84a7e849e70ed2070bf3b921e
65df56b9aae6127b999049d8013f8cbe7317ba1a
bcdaff8151ad6ea113c8585c000643d6662654d5
bf8b1c4da4fa8fd1953510504a351c1feb3ee50b
c8849cd1c7aee7958f359ddd7f382c9371961374
438e3ea5419fbf56c90d4d993961b083617aaf3e
b8499934bf24bb9fb136a2cc971381706001e583
ffd0e4c1e8ad3acaa7bb6d610d489e3c851063a0
81f10acabaf63394a1ffbf1fe837884457527488
00aa8a6f2cd12e668532c313fa028a56144bf62e
5e549790e22ee97efecb9049fa3ca4afcbcaebf8
6c5c19739831af41cfa29186a1813018dc0c6ef0
0cb2dcadaadf56fcebf7b985367a6401092a1a6e
5b7f2793dfbf36f85d2188d3fdd9c19a996cc11d
2c28aa863c9ed31a4a45306a3124de64dd255d3b
9bc96103f339b017274caba8e68636a1022de34d
ab0adbc465a5aa9708eca0fad9df544c009ffe20
bd9ff7a64c534108d0630249c6b2d676da630d11
8df3230bd85fb6ee94415e1927235f5dede6dc07
9abaab7794eae75c6a2cfc949dbd0ae5f6f352be
a0e3f8dcc09334a2a79293cc4f60a65973cd1d46
8cad823405370ea9f6407892fa2018fbcbac221b
```

This last command can be bashfoo'd into whatever you want. I chose to turn them into GitHub links that let me view the diff in the browser.
