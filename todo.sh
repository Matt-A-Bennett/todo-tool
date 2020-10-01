#!/bin/bash

# Outline of how the script works:
# gather tasks that will be (un)ticked and convert to a regex to find the items
# in the original files later
#
# tick/untick master tasks
#
# apply regex to locate updated tasks in original files and modify
#
# grep all the orginal files and store in additions.md 
#
# remove any tasks from master_todo.md and store in removed_tasks.md as we
# delete tasks, the index of all subsequent tasks drops by one, so keep track
# of how many have been removed and adjust idices accordingly
#
# add on the tracked tasks and get rid of duplicates 
#
# sort by date

# clean up

# set path
path=$TODO_PATH
script_path=$(dirname $(realpath $0))

# set up dummy files 
touch ${script_path}/tick_propagate.md ${script_path}/untick_propagate.md ${script_path}/postpone_propagate.md ${script_path}/additions.md ${path}/removed_tasks.md ${script_path}/master_todo_tmp.md ${script_path}/tmp

# parse args in
while getopts 't:u:d:p:h' OPTION; do
    case "$OPTION" in
        t) 
            IFS=","
            tick=($OPTARG) ;;
        u) 
            IFS=","
            untick=($OPTARG) ;;
        d)
            IFS=","
            remove=($OPTARG) ;;
        p)
            IFS=","
            postpone=($OPTARG) ;;
        ?)
            echo -e "\nusage: todo [-h] [-t int [int,int ...]] [-u int [int,int ...]] [-p int [int,int ...]] [-d int [int,int ...]]\n"

            echo -e "Function description: Collects various todo list items scattered around different files and directories into a single master todo list.\n"

            echo -e "optional arguments:"
            echo -e "-h, show this help message and exit"
            echo -e "-t int [int,int ...]  which items to tick (comma,separated)"
            echo -e "-u int [int,int ...]  which items to untick (comma,separated)"
            echo -e "-d int [int,int ...]  which items to delete (comma,separated)"
            echo -e "-p int [int,int ...]  which items to postpone (comma,separated)\n"

            echo -e "usage examples:\n"
            echo -e "1) tick task 2\n"
            echo -e "   todo -t2\n"
            echo -e "2) untick task 3 and delete task 4\n"
            echo -e "   todo -u3 -d4\n"
            echo -e "3) postpone tasks 4 and 6 (by one week)\n"
            echo -e "   todo -p4,6\n"
            echo -e "4) tick tasks 3, 4 and 5 and delete tasks 1 and 2\n"
            echo -e "   todo -u3,4,5 -d1,2\n"

            # clean up and exit
            rm ${script_path}/tick_propagate.md ${script_path}/untick_propagate.md ${script_path}/postpone_propagate.md ${script_path}/additions.md ${script_path}/tmp
            exit 1 ;;
    esac
done

# gather tasks that will be (un)ticked and convert to a regex to find the items
# in the original files
for i in "${tick[@]}"; do
    sed -n "${i}"p ${path}/master_todo.md >> ${script_path}/tick_propagate.md
    sed -i "s/- \[/- \\\[/" ${script_path}/tick_propagate.md
done
for i in "${untick[@]}"; do
    sed -n "${i}"p ${path}/master_todo.md >> ${script_path}/untick_propagate.md
    sed -i "s/- \[/- \\\[/" ${script_path}/untick_propagate.md
done
for i in "${postpone[@]}"; do
    sed -n "${i}"p ${path}/master_todo.md >> ${script_path}/postpone_propagate.md
    sed -i "s/- \[/- \\\[/" ${script_path}/postpone_propagate.md
done

# tick/untick master tasks
for i in "${tick[@]}"; do
    sed -i "${i}s/- \[ ]/- \[x]/" ${path}/master_todo.md
done
for i in "${untick[@]}"; do
    sed -i "${i}s/- \[x]/- \[ ]/" ${path}/master_todo.md
done
for i in "${postpone[@]}"; do
    line=$(sed -n "${i},${i}p" ${path}/master_todo.md)
    old_date=$(echo $line | grep -oP "\d{2}-\d{2}-\d{2}")
    old_date=$(echo $old_date | awk -F - '{print $2"/"$1"/"$3}')
    new_date=$(date +%m/%d/%y -d "$old_date + 7 day")
    new_date=$(echo $new_date | awk -F / '{print $2"-"$1"-"$3}')
    sed -i "${i} s/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]/${new_date}/" ${path}/master_todo.md
done

# apply regex to locate updated tasks in original files and modify
while read dir; do
    for file in $dir/*.md; do
        while read -r line; do 
            sed -i "/${line}/ s/- \[ ]/- \[x]/" $file
        done < ${script_path}/tick_propagate.md
        while read -r line; do 
            sed -i "/${line}/ s/- \[x]/- \[ ]/" $file
        done < ${script_path}/untick_propagate.md
        while read -r line; do 
            old_date=$(echo $line | grep -oP "\d{2}-\d{2}-\d{2}")
            old_date=$(echo $old_date | awk -F - '{print $2"/"$1"/"$3}')
            new_date=$(date +%m/%d/%y -d "$old_date + 7 day")
            new_date=$(echo $new_date | awk -F / '{print $2"-"$1"-"$3}')
            sed -i "/${line}/ s/[0-9][0-9]-[0-9][0-9]-[0-9][0-9]/${new_date}/" $file
        done < ${script_path}/postpone_propagate.md
    done
done <${path}/dirs_to_search.txt

# grep all the orginal files and store in additions.md 
while read dir; do
    for file in $dir/*.md; do
        grep "(deadline:" "${file}" | while read -r task; do
        echo $task >> ${script_path}/additions.md
        done
    done
done <${path}/dirs_to_search.txt

# remove any tasks from master_todo.md and store in removed_tasks.md
# as we delete tasks, the index of all subsequent tasks drops by one, so keep
# track of how many have been removed and adjust idices accordingly
delete_count=0
for i in "${remove[@]}"; do
    sed -i "$((${i}-${delete_count})) { w ${script_path}tmp
    d }" ${path}/master_todo.md
    cat ${script_path}tmp >> ${path}/removed_tasks.md
    delete_count=$((${delete_count}+1))
done

# add on the tracked tasks and get rid of duplicates 
cat ${path}/master_todo.md ${script_path}/additions.md | sort -u | uniq > ${script_path}/master_update.md
sort -o ${path}/removed_tasks.md ${path}/removed_tasks.md

comm -23 ${script_path}/master_update.md ${path}/removed_tasks.md > ${script_path}/master_todo_tmp.md

# sort by date
cat ${script_path}/master_todo_tmp.md | sort -t: -k2 | sort -t- -k3,3 -s > ${path}/master_todo.md

# clean up
rm ${script_path}/tick_propagate.md ${script_path}/untick_propagate.md ${script_path}/postpone_propagate.md ${script_path}/additions.md ${script_path}/master_update.md ${script_path}/master_todo_tmp.md ${script_path}/tmp 
