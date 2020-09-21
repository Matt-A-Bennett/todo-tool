# dates must be in dd-mm-yy format
import subprocess
from os import listdir
from os.path import isfile, isdir, join, dirname, abspath
import argparse
from datetime import datetime

parser = argparse.ArgumentParser(description='''Collects various todo list
                                 items scattered around around different
                                 directories and files  into a single master
                                 todo list.''')

parser.add_argument('-t', metavar='int', dest='complete', type=int, nargs='+', help='which items to tick')
parser.add_argument('-u', metavar='int', dest='incomplete', type=int, nargs='+', help='which items to untick')
parser.add_argument('-d', metavar='int', dest='delete', type=int, nargs='+', help='which items to delete')
# parser.add_argument('-r', metavar='int', dest='restore', type=int, nargs='+', help='which items to restore')

args = parser.parse_args()

path = dirname(abspath(__file__)) + '/'
tasks = []
with open(f'{path}todo_master.md', 'r') as todo:
    tasks.append(todo.read())
    tasks = tasks[0].split('\n')
    tasks.pop()

removed = []
with open(f'{path}todo_removed.md', 'r') as todo_removed:
    removed.append(todo_removed.read())
    removed = removed[0].split('\n')
    removed.pop()

if args.complete is not None:
    tasks = [task.replace('- [ ]', '- [x]') if idx+1 in args.complete else task for idx, task in enumerate(tasks)]
if args.incomplete is not None:
    tasks = [task.replace('- [x]', '- [ ]') if idx+1 in args.incomplete else task for idx, task in enumerate(tasks)]
if args.delete is not None:
    # move to the remove list
    for idx, task in enumerate(tasks):
        if idx+1 in args.delete:
            removed.append(task)
    # apply removal to tasks
    tasks = [task for idx, task in enumerate(tasks) if idx+1 not in args.delete]
# if args.restore is not None:
    # delete from the remove list

# gather tasks from all files in dirs
with open(f'{path}todo_dirs.txt') as todo_dirs:
    for todo_dir in todo_dirs:
        todo_dir=todo_dir.strip()
        if isdir(todo_dir):
            files = [f for f in listdir(todo_dir) if isfile(join(todo_dir, f)) and f.endswith('.md') and f[0]!='.']
            for document in files:
                document = join(todo_dir, document)

                # grep through found file for potential tasks to add to master
                query = subprocess.run(["grep", "-n", "(deadline:", f"{document}"], stdout=subprocess.PIPE).stdout.decode('utf-8')
                query = query.split('\n')
                query.pop()

                # figure out what to do with each potential new task (i.e. query)
                for query_idx, query_inst in enumerate(query):
                    query_task = query_inst.split(']', 1)[-1].rstrip()
                    query_task = query_inst.split('(deadline:', 1)[0].rstrip()

                    for task in tasks:
                        # if the query is already listed in master
                        if (query_inst.split(']', 1)[-1].rstrip() == task.split(']', 1)[-1].rstrip()):
                            # remove from query list
                            query[query_idx] = ''
                        # if the query is already listed in removed
                        for remove in removed:
                            if (query_inst.split(']', 1)[-1].rstrip() == remove.split(']', 1)[-1].rstrip()):
                                # remove from query list
                                query[query_idx] = ''
                        # if the task query is ticked differently in master
                        if (query_inst.split('[', 1)[-1].rstrip() != task.split('[', 1)[-1].rstrip()):

                            # synch original with master
                            with open(f'{document}', 'r') as doc:
                                data = doc.readlines()
                                data[int(query_inst.split(':',1)[0])-1] = task+'\n'
                            with open(f'{document}', 'w') as doc:
                                doc.writelines(data)
                        break

                query = [query_inst.split(':',1)[-1] for query_inst in query]
                query = str.join('\n', query)
                tasks.append(query)

tasks = [task+'\n' for task in tasks if task]

# remove duplicate entries
tasks = list(set(tasks))
tasks = str.join('', tasks)
tasks = tasks.split('\n')
tasks = [task.rstrip() for task in tasks if task]

# sort tasks based on date
dates = [date.split('(deadline: ')[-1][:-1] for date in tasks]
dts = [datetime.strptime(date, '%d-%m-%y') for date in dates]
ordered_tasks = [x for _,x in sorted(zip(dts, tasks))]
ordered_tasks = str.join('\n', ordered_tasks)

with open(f'{path}todo_removed.md', 'w') as todo_removed:
    removed = str.join('\n', removed)
    todo_removed.write(f'{removed}\n')

with open(f'{path}todo_master.md', 'w') as todo:
    todo.write(f'{ordered_tasks}\n')
