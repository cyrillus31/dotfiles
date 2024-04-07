#! /bin/sh
# General update
sudo dnf groupinstall "Development Tools" "Development Libraries" -y
sudo dnf update -y
sudo yum update -y

# Node.js + npm
sudo dnf install nodejs -y

sudo dnf install fzf -y
sudo dnf install ripgrep -y
sudo dnf isntall tmux -y

# Install python and git
sudo yum install -y python3.11 git
git config --global credential.helper store

# Install neovim
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum install -y neovim python3-neovim


# Install other programms
source ./install_nginx.sh
source ./install_docker.sh
source ./install_nvchad.sh

# Make the time not interfere with Windows in dualboot
source ./time_fix.sh


# Setup .bashrc

read -p "Do you want to setup .bashrc? [y/n]   " answer

if [ $answer = "y" ]; then
  if [ -f $HOME/.bashrc ]; then
    cat ./my_bash_config/.bashrc-part >> $HOME/.bashrc
  else
    cp ./my_bash_config/.bashrc $HOME/
  fi;
  
  if [ -d $HOME/.bashrc.d/ ]; then
    cp -t $HOME/.bashrc.d/ ./my_bash_config/.bashrc.d/*
  else
    cp -r -t $HOME/ ./my_bash_config/.bashrc.d/
  fi;
fi;


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

















