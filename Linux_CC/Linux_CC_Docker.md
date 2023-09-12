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
