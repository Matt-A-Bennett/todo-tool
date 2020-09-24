# Todo List
This is a bash script that collects my various todo list items scattered
around my system in different files and directories (from meetings, talks,
various projects etc.) into a single master todo list. I can consult and tick
off completed items in the master todo list and these updates will also be
propagated back to the individual todo list items in the files from where they
came. I can also remove items from the master todo list and they will not
reappear later (the original files are not changed in this case). The items in
the master todo list are ordered according to their associated deadlines.
Keeping track of your todo list from the command line is then as simple as:

```console
user@host:~$ todo 

1 - [x] Make todo list script (deadline: 19-01-20) 
2 - [ ] Add some features (deadline: 21-01-20) 
3 - [ ] Test new features (deadline: 22-01-20) 
4 - [ ] Adjust features (deadline: 25-01-20) 
5 - [x] Upload latest version (deadline: 27-01-20) 
6 - [ ] Book holiday flights (deadline: 04-07-20)
``` 

## Table of Contents
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Maintaining todo list across multiple devices](#maintaining-todo-list-across-multiple-devices)
* [Features to be added](#features-to-be-added)

## Getting Started

*Steps marked with \* are slightly different if you're setting up to maintain a
todo list across multiple devices, so consult [that
section below](#maintaining-todo-list-across-multiple-devices) as well.*

Clone the repo like so:

```bash
git clone https://github.com/Matt-A-Bennett/todo-tool.git
```

\* Now create the following file in the repo directory:

```console
user@host:~$ cd /path/to/repo 
user@host:~$ touch dirs_to_search.txt
```

In dirs_to_search.txt, put one or more absolute paths (one path per line, no
trailing slash) to directories that may contain .md files which may contain a
todo list item that you wish to track.
 
For example:\
/home/\<user\>/Documents/meeting_notes\
/home/\<user\>/Documents/talks\
/home/\<user\>/projects

\* Put the following code in your .bashrc (and do not put a trailing slash!):

```bash
export TODO_PATH='/home/<user>/path/to/repo'
```
Lastly, add a wrapper function to your .bashrc to call the script and show the
updated list:

```bash
todo () {
/path/to/repo/./todo.sh "$@"
cat -n ${TODO_PATH}master_todo.md
}
```

## Usage
To print your todo list, simply run from the command line like this (you'll
have to first restart your terminal or source your .bashrc if you haven't done
so since modifying your .bashrc file in the steps above):

Any lines in any .md file (in those directories on the list in
dirs_to_search.txt) that take the form of a 'todo list item' will be copied
into master_todo.md. A 'todo list item' takes the following form:

```console
- [ ] <task description here> (deadline: <dd-mm-yy>)
```

To modify existing items in your todo list, you have the following options:

```console
usage: todo [-h] [-t int [int,int ...]] [-u int [int,int ...]] 
            [-d int [int,int ...]]

Function description: Collects various todo list items scattered around
different files and directories into a single master todo list.

optional arguments:
  -h, show this help message and exit
  -t int [int,int...]  which items to tick (comma,separated)
  -u int [int,int...]  which items to untick (comma,separated)
  -d int [int,int...]  which items to delete (comma,separated)
```
  
For example, assume that todo outputs the following list:

```console
     1  - [x] Make todo list script (deadline: 19-01-20)
     2  - [ ] Add some features (deadline: 21-01-20)
     3  - [ ] Test new features (deadline: 22-01-20)
     4  - [ ] Adjust features (deadline: 25-01-20)
     5  - [x] Upload latest version (deadline: 27-01-20)
     6  - [ ] Book holiday flights (deadline: 04-07-20)
```

Let's now assume that we created a new todo list item about making a phone call
in some .md file in a directory that is listed in dirs_to_search.txt. Let's
also assume that we have completed tasks 2 and 3, and that we realise that task
5 has not actually been completed yet, and that our holiday is cancelled. We
can tick off tasks 2 and 3, and untick task 5, and remove tasks 4 and 6 from
the list like so:

```console
user@host:~$ todo -t3,4 -u5 -d4,6
```

The output will be:

```console
     1  - [x] Make todo list script (deadline: 19-01-20)
     2  - [x] Add some features (deadline: 21-01-20)
     3  - [x] Test new features (deadline: 22-01-20)
     4  - [ ] Make a phone call (deadline: 27-01-20)
     5  - [ ] Upload latest version (deadline: 29-01-20)
```

Notice that the original tasks 2 and 3 have been ticked, the uploading task has
been unticked, and a new task about making a phone call has been inserted into
the list according to its deadline. Also what were formally tasks 4 and 6 have
been removed.

## Maintaining todo list across multiple devices
If you want to be able to make notes on a laptop, or if you work on more than
one machine, and want a single master todo list which collects and integrates
your todo list items, this is possible without too much extra hassle in the
following way:

First you must create a directory **somewhere outside of the todo repo** and in
the same location on each machine. This directory and its contents should be
synched regularly among your devices (e.g. with Google Drive, or by making a
git repo). Personally I created a hidden directory inside a git repo I'd
already been using for general work-related stuff and which I synch often. For
example: 

```bash
mkdir ~/Documents/my_work_repository/.todo_files
```

Next, create a 'dirs_to_search.txt' file [like before](#getting-started) with
one or more absolute paths (one path per line, no trailing slash) to
directories that may contain .md files which may contain a todo list item that
you wish to track. It's no problem to have non-existent directories in this
file (and this may well be the case if you have different directories that you
want to search on your machines). In my case it would be:
 
```console
user@host:~$ cd ~/Documents/my_work_repository/.todo_files 
user@host:~$ touch dirs_to_search.txt
```

Lastly, in your .bashrc, set the TODO_PATH to point to this directory. In my
case that would be:

```bash
export TODO_PATH='~/Documents/my_work_repository/.todo_files'
```
That's it! Now every time you run the todo command, the master todo list will
accumulate and retain todo items found on any machine.

## Features to be added
- Argument to increase/deadline of particular items by specified number of days
