#!/bin/bash
# Make autocompletion case insesitive
inputrc_path="/etc/inputrc"
if grep -q set completion-ignore-case $inputrc_path; then 
  echo 'found'; 
  new_file=$(sed -e "s/set completion-ignore-case off/set completion-ignore-case on/g" $inputrc_path)
  echo "$new_file" > $inputrc_path
  echo "DONE: value was changed"
else 
  echo 'not found'; 
  echo "set completion-ignore-case on" >> $inputrc_path
  echo "DONE autocompletion is now case insesitive"
fi;
