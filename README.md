# Todo List
This is a Python 3 script that collects my various todo list items scattered
around my system in different directories and files (from meetings, talks,
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
## Getting Started
Create the following three files in the repo directory:

```console
user@host:~$ cd path/to/repo 
user@host:~$ touch todo_dirs.txt todo_master.md todo_removed.md
```

In todo_dirs.txt, put one or more absolute paths (one path per line, no
trailing slash) to directories that may contain .md files which may contain a
todo list item that you wish to track.
 
For example:\
/home/user/Documents/meeting_notes\
/home/user/Documents/talks\
/home/user/projects

Put this code in your .bashrc or .bash_aliases file:

```bash
todo () {
    python3 ~/path/to/repo/todo.py "$@"
    cat -n ~/path/to/repo/todo_master.md
}
```
### Prerequisites
Tested on Python 3.6.9

## Usage
To print your todo list, simply run from the command line like this (you'll
have to first restart your terminal or source your .bashrc if you haven't done
so since modifying your .bashrc or bash_aliases files in the steps above):

```console
user@host:~$ todo
```
(N.B. I've noticed that the very first time I run it, the master list has many
entries of the same item... running it again resolves this issue). 

Any lines in any .md file (in those directories on the list in todo_dirs.txt)
that take the form of a 'todo list item' will be copied into todo_maser.md. A
'todo list item' takes the following form:

```console
- [ ] <task description here> (deadline: <dd-mm-yy>)
```

To modify existing items in your todo list, you have the following options:

```console
usage: todo [-h] [-t int [int ...]] [-u int [int ...]]

todo list

optional arguments:
  -h, --help        show this help message and exit
  -t int [int ...]  which items to tick
  -u int [int ...]  which items to untick
  -d int [int ...]  which items to delete
```
  
For example, assume that todo ouputs the following list:

```console
     1  - [x] Make todo list script (deadline: 19-01-20)
     2  - [ ] Add some features (deadline: 21-01-20)
     3  - [ ] Test new features (deadline: 22-01-20)
     4  - [ ] Adjust features (deadline: 25-01-20)
     5  - [x] Upload latest version (deadline: 27-01-20)
     6  - [ ] Book holiday flights (deadline: 04-07-20)
```

Let's now assume that we created a new todo list item about making a phone call
in some .md file in a directory that is listed in todo_dirs.txt. Let's also
assume that we have completed tasks 2 and 3, and that we realise that task 5
has not actually been completed yet. We can tick off tasks 2 and 3 and untick
task 5 like so:

```console
user@host:~$ todo -t 3 4 -u 5
```

The output will be:

```console
     1  - [x] Make todo list script (deadline: 19-01-20)
     2  - [x] Add some features (deadline: 21-01-20)
     3  - [x] Test new features (deadline: 22-01-20)
     4  - [ ] Adjust features (deadline: 25-01-20)
     5  - [ ] Make a phone call (deadline: 27-01-20)
     6  - [ ] Upload latest version (deadline: 29-01-20)
     7  - [ ] Book holiday flights (deadline: 04-07-20)
```

Notice that the original tasks 2 and 3 have been ticked, the uploading task has
been unticked, and a new task about making a phone call has been inserted into
the list according to its deadline.

## Features to be added
- Automatically remove completed items once their deadline is over a few days
  old
- Argument to increase/deadline of items by specified number of days

## Bug fixes needed
- On first time running, with empty todo_master.md and todo_removed.md, the
  master list has many entries of the same item (running it again resolves
  this issue). 
- When trying to synch original files with master.md, the whole line in
  original is replaced with the wrong task!

