sudo apt-get install bash-completion -y


cat << _EOF_ >> ~/.bashrc

# Bash autocompletion enabled
if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi
_EOF_


echo "SUCCESS: bash-completion successfully installed!"
