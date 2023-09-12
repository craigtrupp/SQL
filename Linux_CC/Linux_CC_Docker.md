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
