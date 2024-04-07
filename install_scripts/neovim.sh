sudo apt-get install git -y

downloads_path="$HOME/Downloads/Neovim"

if [[ -d $downloads ]]; then
    true
else
    mkdir -p $downloads_path
fi;

git clone https://github.com/neovim/neovim $downloads_path

sudo apt-get install ninja-build gettext cmake unzip curl build-essential -y




# NvChad
# git clone https://github.com/cyrillus31/NvChad ~/.config/nvim

