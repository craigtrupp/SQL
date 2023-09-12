## Linux CLI Crash Course 🐧
The command line is a must for any real programmer and since data practitioners are writing software programs - it only makes sense that you need to learn it, and learn it well you shall!

Great skill in the command line is highly sought after in data science roles and is a hard requirement for any Data or ML Engineer roles.

#### `Pre-Flight Checks`
**Strict Rules**
* DO NOT copy paste commands blindly
* Do not EVER blindly copy and paste commands into the terminal - you can actually destroy your machine and there is no ctrl-z!!!

**Run all the commands**

Learning the CLI is done by doing - you will not learn it successfully unless you run commands!

I recommend you type all of the commands to start getting used to it - you will use these commands A LOT!

This tutorial is sequential and is meant to be consumed as a continuous thread of commands - if you choose to jump around, please be sure to keep an eye out for files or folders created in above steps!

#### `Device Safety`
Because I don’t want you accidentally deleting your entire computer and turning it into a brick - we will be completing this tutorial in virtual machines where there is low to zero risk that you will accidentally delete files that you didn’t want to!

There are 2 options for where you can run all the following commands in this tutorial:

1. locally via Docker using a virtual machine or
2. online via some third party websites that provide Linux virtual machines

### **Local Docker**
You can spin up a totally independent container using Alpine Linux which is the most popular base for many Docker images that are currently used widely.

Firstly fire up a CLI or terminal on your computer and type hostname and hit enter to confirm the hostname of your local computer.

```sh
Last login: Tue Sep 12 11:20:09 on ttys002
(base) ➜  ~ hostname
Craigs-MacBook-Pro.local
```

Next run `docker run -it --rm alpine` in the local command line to spin up the docker container - you need to have Docker installed for this step which we cover in the initial introduction section of the Serious SQL course so this should work fine!

Straight after running the docker run command, type hostname again in the terminal and confirm that the printed output is different to that of your local computer’s hostname

```sh
(base) ➜  ~ docker run -it --rm alpine
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
7264a8db6415: Pull complete 
Digest: sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a
Status: Downloaded newer image for alpine:latest
/ # hostname
72c510bac445
/ # 
```

Once you confirm that the hostnames are different from the Docker container to your local computer - you can continue with this tutorial.

Always be sure that you are inside this Docker instance for the rest of the tutorial - and if you are unsure at any point in time, simply type hostname and hit enter inside the terminal to confirm exactly where you are!

Although this tutorial is relatively safe and there is a really low risk of you accidentally deleting files from your computer - we want to minimize the chance of this as much as possible!

### `Overview`
In this CLI Crash Course based off Learn the CLI The Hard Way by Zed Shaw we will cover almost everything you need to start using the command line with confidence!

We focus on a core set of CLI keywords which you will use very regularly once you get familiar with everything.

---

<br>

### **Command Line Keywords 🤖**
* I'm also using a Github Workspace just for access to a terminal away from my local machine too

#### **`pwd`**
Once you are inside the correct the terminal - you can use pwd to identify where you are inside the filesystem

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ pwd
/workspaces/linux-ghubspaces
```

#### **`hostname`**
Ever wondered what your computer name was? You can run hostname to find out!

This also works when you are working on a remote server via ssh access - more on this later!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ hostname
codespaces-596d5b
```
```sh
# docker image
/ # hostname
72c510bac445
```

#### **`mkdir`**
You know how normally when you are clicking around in Finder or in the Explorer and you need to hit the “New Folder” button to create a new folder?

Well in the shell, you can simply use mkdir to make a directory i.e. a folder inside your current location

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ mkdir temp
```

#### **`cd`**
Ok so you have created a temp folder, cool. Let’s navigate to this new folder, or in other words change directory.

Let’s cd into this temp folder now and also run pwd to make sure we are where we need to be

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cd temp/
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ pwd
/workspaces/linux-ghubspaces/temp
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ 
```

Remember the directory where your terminal entered? That is usually your home directory and we can usually refer to this in the shell by typing ~

So to go home - we can simply run the following (be sure to check where you are in the end!):

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cd -
/workspaces/linux-ghubspaces
```

#### **`ls`**
So if you’ve already got a few things in your home directory, we can easily list out the contents using the ls command

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  temp
```
Let’s move into the temp folder we created before and confirm that there is nothing in there shall we?

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cd temp/
```

#### **`rmdir`**
So now that we are in the temp folder - let’s create a new folder with the name of your enemy. I’m going to use The-Joker for mine because I’m Batman.

Let’s also check just exactly where we are using pwd and also that this new folder has actually been created by using ls

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mkdir The-JOker
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ pwd
/workspaces/linux-ghubspaces/temp
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
The-JOker
```

Ok awesome - now let’s delete that directory that we’ve just created using the `rmdir`
command and check the contents of our current directory again using ls - there should be nothing!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ rmdir The-JOker/
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ 
```

#### **`touch`**
Let’s learn how to create empty files - there are many reasons why we might want to do this but we will cover these reasons later so we can stay on track now!

Firstly do you remember where we are? Also let’s create a new file called sushi because it’s my favourite food - then let’s also check that this new file is in the directory.

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ touch sushi
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
sushi
```

#### **`cp`**
So since I love sushi so much - I want to copy it and create a new file called sushi-copy - feel free to call your copied food whatever you like.

Let’s check whether our files exist too - you know the drill!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cp sushi sushi-copy
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
sushi  sushi-copy
```

#### **`mv`**
So mv is a funny command because we can use this not only to move files and folders around, but we can also use it rename them - weird right!

Firstly - let’s rename the copy of our favourite food with -1 after it - I’m going to change my copy to sushi-1

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv sushi-copy sushi-l
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
sushi  sushi-l
```

Ok let’s now try moving our file too!

Let’s say we want to move sushi into a new favourite_foods folder.

We can use the mv command to do this, let’s also cd into the fav_foods folder so we can check what’s inside using ls

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv sushi fav_foods
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
fav_foods  sushi-l
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cd fav_foods
bash: cd: fav_foods: Not a directory
```

Wait….what just happened? Didn’t we just move sushi into our fav_foods folder?

Oh yeah - we didn’t create the folder first, D’oh! Let’s rename our dodgy fav_foods file back to sushi using mv

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv fav_foods sushi
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls 
sushi  sushi-l
```

Now let’s try that again - let’s create a new folder called `fav_foods` first to avoid that mistake we just made. Let’s try to cd into fav_foods and check out what’s inside.

Also one more thing to note - when we mv items to a folder - we want to be explicit with our commands, to specify that we indeed want to move sushi into the fav_foods folder - we can append a / to the end of fav_foods to explicitly state this path. This is very important when we are moving files around different locations!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mkdir fav_foods
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv sushi fav_foods/
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cd fav_foods/
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp/fav_foods (main) $ ls
sushi
```

Also instead of always having to cd into folders to find out what’s inside - we can also use ls with a target folder or path to see what’s inside without changing directory.

Let’s first move up one level - oh we haven’t covered this one also…

We can cd up one level by running the following:

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp/fav_foods (main) $ cd ..
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ 
```

Ok now that we’re back in the temp folder - we can try running the ls with fav_foods as the target and confirm that we haven’t changed our location by re-running pwd after

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv fav_foods/ ..
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
sushi-l
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cd ..
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  fav_foods  temp
```
* Moved the fav_foods folder one file back so it's now on the same level as the temp folder previously created

#### **`echo`**
echo is the equivalent of print in any other language like Python where it can be used to print statements to stdout

Let’s do the print("Hello World!") example in the command line!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ echo "Vamos Arsenal"
Vamos Arsenal
```

#### **`less`**
For this section we will create a new file called menu.txt using any text editor you like.

You can copy and paste this following text into the file and save it directly inside the temp folder.

OR if you want to try hard-mode you can use the > redirection command with echo to redirect the printed output from stdout to a new file menu.txt

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ echo "This is a sushi menu" > menu.txt
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  fav_foods  menu.txt  temp
```

Ok now onto the main course the less command - we can use this to view the contents of a file…but there is a catch!

When you run the following in the terminal - it will take you into a different type of console

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ less menu.txt 
```

To exit this less console - you simply need to hit the q key and get back into the regular terminal - phew!

So less is one way we can view file contents - but what if there was a better way…
* you can also switch the mode with the **:** then hit q to exit `vim`

#### **`cat`**
cat is an alternative to view the file contents - however the contents are streamed to stdout just like when we use echo to print something.

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  fav_foods  menu.txt  temp
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu.txt 
This is a sushi menu
```

We can also use cat and the append version of the redirect command `>>` to add additional lines to the menu.txt file.

Firstly, let’s create a menu_item.txt file with the following contents using echo on hard-mode and cat the contents to verify what text we have

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ echo Very yummy sushi > menu_item.txt
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu_item.txt 
Very yummy sush
```
Now let’s use that redirect command and append the contents of menu_item.txt to the original menu.txt file.

We need to make sure to use >> and not the single > as the latter will overwrite the file - just like we showed in the previous less tutorial.

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu_item.txt >> menu.txt 
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu.txt 
This is a sushi menu
Very yummy sushi
```

#### **`rm`**
**Warning - Here be Dangerous Waters!!!**

Ok - let me preface this section: DO NOT BLINDLY COPY PASTA HERE - seriously bad things will happen if you do…`there is no undo in the command line!!!`

Repeat - be super careful here - I don’t want you to destroy your machine!!!

We can remove files with the rm command. For example - let’s delete that menu_item.txt file we created in the previous cat tutorial.

Oh let’s also remind ourselves where we are again in the directory and also check that indeed the menu_item.txt file is deleted

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  fav_foods  menu.txt  menu_item.txt  temp
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ rm menu_item.txt 
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  fav_foods  menu.txt  temp
```

Ok here is where things get a bit more dicey - we are going to now recursively remove the fav_foods folder. Reminder - this could go seriously wrong so be super careful!!!

When we want to remove folders, previously we used the rmdir command - which works quite well when the folder is empty - but it will not work when there are contents inside the target folder!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ rmdir fav_foods/
rmdir: failed to remove 'fav_foods/': Directory not empty
```

Instead we will need to use the recursive option with `rm -r` to remove the file contents also. Again - be careful!!!!!!

Now let’s try again to carefully delete that fav_foods folder and list the contents of our current directory again

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ rm -r fav_foods/
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  menu.txt  temp
```

Phew - hope nothing went wrong with that! Please be careul with the `recursive remove` command as you could very easily delete things which should not be deleted! PLEASE KEEP THIS IN MIND WHENEVER YOU USE **`rm`** in the future!!!

#### **`Pipes`**
So we learnt about redirects > and >> earlier where we redirect stdout to a target file and either replace or append respectively.

Now let’s learn about the pipe operator | which allows us to pass stdout to another command.

For example let’s say we would like to cat the contents of menu.txt and use grep to only return the lines which include the word “yummy” - more on grep later!

```sh
# reminder where we are what we got
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  menu.txt  temp
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu.txt 
This is a sushi menu
Very yummy sushi
```

```sh
# yummy is highlighted in the output from the command
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat menu.txt | grep yummy
Very yummy sushi
```

#### **`Redirects`**
Before we learnt redirects from left to right - but we can also redirect from right to left using <

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cat < menu.txt 
This is a sushi menu
Very yummy sushi
```
It might seem a trivial usage for now - but in time we will see some more useful examples of this other directional redirect!

#### **`Wildcards`**
Using the asterisk symbol * in a command represents anything!

For example - let’s list all .txt files in our directory

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls *.txt
menu.txt
```

We can also use this * wildcard to delete files too - BE SUPER CAREFUL HERE!!!

In the next block, we delete all .txt files in our current directory and verify that indeed we only delete the text files!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ rm *.txt
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ ls
README.md  temp
```

One FINAL thing - you can probably see that you can also delete everything in your folder too…let’s do this together but remember - YOU NEED TO BE SUPER CAREFUL!!!!!!!!!!

First of all - let’s make sure we are where we want to be, inside the temp folder!!!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces (main) $ cd temp/
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ pwd
/workspaces/linux-ghubspaces/temp
```

So I probably don’t need to tell you this - but if you are in any other location - YOU WILL DELETE SOMETHING IF YOU RUN THE NEXT COMMANDS!!!

PLEASE BE SUPER CAREFUL AND DOUBLE/TRIPLE CHECK WHERE YOU ARE!!!

Ok great - now let’s CAREFULLY run the delete command and validate that indeed that final is blown away from the temp folder!

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ rm *
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ pwd
/workspaces/linux-ghubspaces/temp
```

Ok phew - let’s move on! Please again - anytime you run the **`rm`** command be SUPER CAREFUL, especially when you are using `wildcards *` - this is super important! I seriously cannot stress this enough - the last thing you want to do when working on an actual server is to delete EVERYTHING!!!!!!!!!!!


#### **`find`**
In the Finder or Windows Explorer you may have noticed a search box where you can enter filenames and the search utility will do it’s thing and return you the closest items. In the background, the find command is doing all the heavy lifting!

First off let’s create a few empty .txt files inside the temp directory that we can search through - do you remember how to do that?

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ touch foods.txt drinks.txt appetizers.txt
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
appetizers.txt  drinks.txt  foods.txt
```
* You can pass in multiple arguments to `touch` to create multiple files all at once. Let’s create a few more files, but this time we’ll use .csv instead.

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ touch customers.csv transactions.csv
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
appetizers.txt  customers.csv  drinks.txt  foods.txt  transactions.csv
```

Now that we have a combination of .txt and .csv files - we can demonstrate how this find command works!

Let’s say we would like to only list out files with a .txt file ending with the use of the wildcard * (notice how everything ties in!) - we use the -name parameter with the find command to do this.

```sh
# requires str encapsulation 
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ find -name *.txt
find: paths must precede expression: `drinks.txt'
find: possible unquoted pattern after predicate `-name'?
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ find -name "*.txt"
./appetizers.txt
./foods.txt
./drinks.txt
```

Notice how there is the ./ in front of the file names when using find? This is because the find command defaults the search space to . which refers to the current directory

We can also use find to search for file names within a target folder - let’s demonstrate this by moving all the files in temp into a subfolder called restaurant

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mkdir restaurant
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls
appetizers.txt  customers.csv  drinks.txt  foods.txt  restaurant  transactions.csv
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ mv * restaurant/
mv: cannot move 'restaurant' to a subdirectory of itself, 'restaurant/restaurant'
```

Oh is that an error? Not quite - the CLI is just letting you know that it didn’t move the restaurant folder inside itself recursively, which is exactly what we want!

```sh
# We can see the other files from the current directory moved into our folder however
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ ls restaurant/
appetizers.txt  customers.csv  drinks.txt  foods.txt  transactions.csv
```

Finally let’s try to find only the .csv files in the new restaurant path

```sh
# preface the route so from temp we need to specify the location to find
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ find restaurant/ -name "*.csv"
restaurant/transactions.csv
restaurant/customers.csv
```

#### **`grep`**
We can also filter lines with target words from a file using grep

First let’s show you a trick to quickly type text into a file using the cat and a > redirect!

Say we would like to start adding some data into the customer.csv file we created in the last step.

```sh
# enter data or write into csv
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cat > restaurant/customers.csv 
Danny Ma,Male,dannyma@email.com
Joe Blow,Male,joeblow@email.com
Jane Smith,Female,janesmith@email.com
# command d to exit edit and then cat to review file contents
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ cat restaurant/customers.csv 
Danny Ma,Male,dannyma@email.com
Joe Blow,Male,joeblow@email.com
Jane Smith,Female,janesmith@email.com
```
Now let’s use grep to only return us lines in the customer.csv where Female is present.

```sh
# Female is highlighted in the standard output 
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ grep Female restaurant/customers.csv 
Jane Smith,Female,janesmith@email.com
```
We can also ignore case sensitivity using the `-i` option with grep

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ grep -i female restaurant/customers.csv 
Jane Smith,Female,janesmith@email.com
```

#### **`man`**
So now we reach the part of the tutorial where we learn how to learn more and also how to read the manual - the most important thing we should ALWAYS do when learning something new!

What we’ve covered so far is just the simple usage of the main CLI commands - you can find out more details, parameters and options by running man in front of any command.

Note that this will take you into a different type of prompt where you can scroll up and down using the mouse or the arrow keys. When you are finished reading, simply hit q to take you back to the original command prompt.

```sh
# list arguments of function (think help function from python)
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ man grep
```

```sh
GREP(1)                                                                                  User Commands                                                                                 GREP(1)

NAME
       grep, egrep, fgrep, rgrep - print lines that match patterns

SYNOPSIS
       grep [OPTION...] PATTERNS [FILE...]
       grep [OPTION...] -e PATTERNS ... [FILE...]
       grep [OPTION...] -f PATTERN_FILE ... [FILE...]

DESCRIPTION
       grep  searches  for  PATTERNS  in  each  FILE.  PATTERNS is one or more patterns separated by newline characters, and grep prints each line that matches a pattern.  Typically PATTERNS
       should be quoted when grep is used in a shell command.

       A FILE of “-” stands for standard input.  If no FILE is given, recursive searches examine the working directory, and nonrecursive searches read standard input.

       In addition, the variant programs egrep, fgrep and rgrep are the same as grep -E, grep -F, and grep -r, respectively.  These variants are deprecated, but  are  provided  for  backward
       compatibility.

OPTIONS
   Generic Program Information
       --help Output a usage message and exit.

       -V, --version
              Output the version number of grep and exit.

   Pattern Syntax
 Manual page grep(1) line 1 (press h for help or q to quit)
```

#### **`env`**
Environment variables are also known as “hidden variables” which often impact how some underlying programs work.

This concept is super important when working in the CLI for actual projects within the data space and it is not always very straightforward to learn without actually trying and failing many times!

For now - we will simply show you a few simple commands to inspect the env and also how you can inspect individual variables using the $ notation - this will look VASTLY different to your env so just keep this in mind!

In general, you will see a new KEY=VALUE on each new line like so:

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ env
SHELL=/bin/bash
NUGET_XMLDOC_MODE=skip
COLORTERM=truecolor
CLOUDENV_ENVIRONMENT_ID=2f519f46-9351-4945-aca3-f4f321f2ad99
NVM_INC=/usr/local/share/nvm/versions/node/v20.6.0/include/node
TERM_PROGRAM_VERSION=1.82.1
GITHUB_USER=craigtrupp
rvm_prefix=/usr/local
CODESPACE_NAME=improved-space-fortnight-5jq4xvjwpv4cpx
HOSTNAME=codespaces-596d5b
JAVA_ROOT=/home/codespace/java
JAVA_HOME=/usr/local/sdkman/candidates/java/current
DOTNET_ROOT=/usr/local/dotnet/current
CODESPACES=true
PYTHON_ROOT=/home/codespace/.python
GRADLE_HOME=/usr/local/sdkman/candidates/gradle/current
NVS_DIR=/usr/local/nvs
NVS_OS=linux
DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-3.2.2
NVS_USE_XZ=1
SDKMAN_CANDIDATES_DIR=/usr/local/sdkman/candidates
RUBY_VERSION=ruby-3.2.2
PWD=/workspaces/linux-ghubspaces/temp
PIPX_BIN_DIR=/usr/local/py-utils/bin
rvm_version=1.29.12 (latest)
ORYX_DIR=/usr/local/oryx
ContainerVersion=13
VSCODE_GIT_ASKPASS_NODE=/vscode/bin/linux-x64/6509174151d557a81c9d0b5f8a5a1e9274db5585/node
HUGO_ROOT=/home/codespace/.hugo
GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN=app.github.dev
NPM_GLOBAL=/home/codespace/.npm-global
HOME=/home/codespace
GITHUB_API_URL=https://api.github.com
LANG=C.UTF-8
GITHUB_TOKEN=ghu_2sc2nyPyDs8bGoupmWio4iaDExeWLy1Bq65R
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
DYNAMIC_INSTALL_ROOT_DIR=/opt
NVM_SYMLINK_CURRENT=true
PHP_PATH=/usr/local/php/current
DEBIAN_FLAVOR=focal-scm
GIT_ASKPASS=/vscode/bin/linux-x64/6509174151d557a81c9d0b5f8a5a1e9274db5585/extensions/git/dist/askpass.sh
PHP_ROOT=/home/codespace/.php
ORYX_ENV_TYPE=vsonline-present
HUGO_DIR=/usr/local/hugo/bin
DOCKER_BUILDKIT=1
GOROOT=/usr/local/go
INTERNAL_VSCS_TARGET_URL=https://westus3.online.visualstudio.com
SHELL_LOGGED_IN=true
PYTHON_PATH=/usr/local/python/current
NVM_DIR=/usr/local/share/nvm
VSCODE_GIT_ASKPASS_EXTRA_ARGS=
rvm_bin_path=/usr/local/rvm/bin
GEM_PATH=/usr/local/rvm/gems/ruby-3.2.2:/usr/local/rvm/gems/ruby-3.2.2@global
GEM_HOME=/usr/local/rvm/gems/ruby-3.2.2
GITHUB_CODESPACE_TOKEN=AZKU2IR34FDASBWW3BONX5LFAF2MFANCNFSM4AE22BCA
LESSCLOSE=/usr/bin/lesspipe %s %s
NVS_ROOT=/usr/local/nvs
GITHUB_GRAPHQL_URL=https://api.github.com/graphql
TERM=xterm-256color
LESSOPEN=| /usr/bin/lesspipe %s
USER=codespace
NODE_ROOT=/home/codespace/nvm
VSCODE_GIT_IPC_HANDLE=/tmp/vscode-git-786df69fe6.sock
PYTHONIOENCODING=UTF-8
GITHUB_SERVER_URL=https://github.com
NVS_HOME=/usr/local/nvs
PIPX_HOME=/usr/local/py-utils
CONDA_SCRIPT=/opt/conda/etc/profile.d/conda.sh
MAVEN_HOME=/usr/local/sdkman/candidates/maven/current
SDKMAN_DIR=/usr/local/sdkman
SHLVL=2
NVM_CD_FLAGS=
ORYX_SDK_STORAGE_BASE_URL=https://oryx-cdn.microsoft.io
GIT_EDITOR=code --wait
CONDA_DIR=/opt/conda
PROMPT_DIRTRIM=4
SDKMAN_CANDIDATES_API=https://api.sdkman.io/2
ENABLE_DYNAMIC_INSTALL=true
MAVEN_ROOT=/home/codespace/.maven
ORYX_PREFER_USER_INSTALLED_SDKS=true
JUPYTERLAB_PATH=/home/codespace/.local/bin
RVM_PATH=/usr/local/rvm
GITHUB_REPOSITORY=craigtrupp/linux-ghubspaces
RAILS_DEVELOPMENT_HOSTS=.githubpreview.dev,.preview.app.github.dev,.app.github.dev
VSCODE_GIT_ASKPASS_MAIN=/vscode/bin/linux-x64/6509174151d557a81c9d0b5f8a5a1e9274db5585/extensions/git/dist/askpass-main.js
RUBY_ROOT=/home/codespace/.ruby
RUBY_HOME=/usr/local/rvm/rubies/default
BROWSER=/vscode/bin/linux-x64/6509174151d557a81c9d0b5f8a5a1e9274db5585/bin/helpers/browser.sh
PATH=/usr/local/rvm/gems/ruby-3.2.2/bin:/usr/local/rvm/gems/ruby-3.2.2@global/bin:/usr/local/rvm/rubies/ruby-3.2.2/bin:/vscode/bin/linux-x64/6509174151d557a81c9d0b5f8a5a1e9274db5585/bin/remote-cli:/home/codespace/.local/bin:/home/codespace/.dotnet:/home/codespace/nvm/current/bin:/home/codespace/.php/current/bin:/home/codespace/.python/current/bin:/home/codespace/java/current/bin:/home/codespace/.ruby/current/bin:/home/codespace/.local/bin:/usr/local/python/current/bin:/usr/local/py-utils/bin:/usr/local/oryx:/usr/local/go/bin:/go/bin:/usr/local/sdkman/bin:/usr/local/sdkman/candidates/java/current/bin:/usr/local/sdkman/candidates/gradle/current/bin:/usr/local/sdkman/candidates/maven/current/bin:/usr/local/sdkman/candidates/ant/current/bin:/usr/local/rvm/gems/default/bin:/usr/local/rvm/gems/default@global/bin:/usr/local/rvm/rubies/default/bin:/usr/local/share/rbenv/bin:/usr/local/php/current/bin:/opt/conda/bin:/usr/local/nvs:/usr/local/share/nvm/versions/node/v20.6.0/bin:/usr/local/hugo/bin:/usr/local/dotnet/current:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin
CODESPACE_VSCODE_FOLDER=/workspaces/linux-ghubspaces
SDKMAN_PLATFORM=linuxx64
NVM_BIN=/usr/local/share/nvm/versions/node/v20.6.0/bin
IRBRC=/usr/local/rvm/rubies/ruby-3.2.2/.irbrc
rvm_path=/usr/local/rvm
OLDPWD=/workspaces/linux-ghubspaces
GOPATH=/go
TERM_PROGRAM=vscode
VSCODE_IPC_HOOK_CLI=/tmp/vscode-ipc-e6130158-6ad8-4edc-8f98-1c6bb4d1c597.sock
_=/usr/bin/env
```

Note: one environment variable which changes OFTEN is the `PATH` variable - this is the actual path where program binaries or execution files need to be found to actually run on your machine.

#### **`export`**
We can also add new variables or amend existing ones in the env by using the export command - please use this with care, I’m sure you can see how altering something like your PATH and breaking your system is not ideal…

Let’s first create a new environment variable called TEST_VARIABLE using export and try using echo to see if this has worked

```sh
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ export TEST_VARIABLE="abra-kadabra"
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ echo $TEST_VARIABLE 
abra-kadabra
```

```sh
# can change the value of the variable with the same command
@craigtrupp ➜ /workspaces/linux-ghubspaces/temp (main) $ echo $TEST_VARIABLE 
hoookie-dokie
```

#### **`exit`**
Finally to get out of the terminal, we can simply click on the X in the window but sometimes if we’re in a terminal inside a remote server, there might not actually be a mouse cursor to click on anything with!

We can exit the prompt by using CTRL-d which we learnt before when exiting the cat text prompt. We can also type exit directly in the CLI to get out of the terminal also.

* ctrl-d exited from the docker host I opted not to use as was using the github codespace
* [IBM Linux Reference Items - your google drive](https://docs.google.com/document/d/1T4TiOeuuvhbsltS5pBK7MPXK83KrkMaM3odaOL9rbzc/edit#heading=h.4kdmjwq238ir)

**🏁**