# Todo List
This is a bash script that collects my various todo list items scattered
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
Clone the repo like so:
```bash
git clone https://github.com/Matt-A-Bennett/todo.git
```

Now create the following file in the repo directory:

```console
user@host:~$ cd path/to/repo 
user@host:~$ touch dirs_to_search.txt
```

In dirs_to_search.txt, put one or more absolute paths (one path per line, no
trailing slash) to directories that may contain .md files which may contain a
todo list item that you wish to track.
 
For example:\
/home/\<user\>/Documents/meeting_notes\
/home/\<user\>/Documents/talks\
/home/\<user\>/projects

Put the following code in your .bashrc (and do not put a trailing slash!):

```bash
export TODO_PATH=/home/<user>/path/to/repo
```
and:

```bash
todo () {
~/todo/./todo.sh "$@"
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
5 has not actually been completed yet, and that our holiday is cancelled. We can tick off tasks 2 and 3, and untick
task 5, and remove tasks 4 and 6 from the list like so:

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

## Features to be added
- Argument to increase/deadline of particular items by specified number of days
