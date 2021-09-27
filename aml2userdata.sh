#!/bin/bash
# Setting up an Amazon Linux 2 Instance with the Deep Learning AMI
set -e -x

DIR=/home/ec2-user

get_dotfiles () {

    echo "(1/4): GETTING DOTFILES..."

    git clone https://github.com/aws-samples/ec2-data-science-vim-tmux-zsh.git $DIR/dotfiles

    ln -s $DIR/dotfiles/.tmux.conf $DIR/.tmux.conf
    ln -s $DIR/dotfiles/.vimrc $DIR/.vimrc

    chown -R ec2-user:ec2-user $DIR/dotfiles $DIR/.vimrc $DIR/.tmux.conf

}

setup_vim () {

    echo "(2/4) SETTING UP VIM..."

    apt-get -y install python3-pip

    # Install black for formatting
    pip3 install black

    # Install vim plug for package management
    curl -fLo $DIR/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    chown -R ec2-user:ec2-user $DIR/.vim

    # Install packages
    runuser -l ec2-user -c 'vim +PlugInstall +qall'

}

setup_tmux () {

    echo "(3/4) SETTING UP TMUX..."

    # Install tmux dependencies
    apt-get -y install automake libncurses5-dev libncursesw5-dev libevent-dev 

    # Get the latest version
    git clone https://github.com/tmux/tmux.git

    cd tmux

    sh autogen.sh

    ./configure && make install

    cd ..

    # Get a simple startup script
    mv /home/ec2-user/dotfiles/stm.sh /bin/stm 
    chmod +x /bin/stm

    # Install htop
    apt -y install htop
}

setup_zsh () {

    echo "(4/4) SETTING UP ZSH..."

    apt -y install zsh

    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh

    chown -R ec2-user:ec2-user $DIR/install.sh
    cd $DIR
    echo pwd
    runuser -l ec2-user 'install.sh'

    # Change the default shell to zsh
    chsh -s /bin/zsh ec2-user

    # Add conda to end of zshrc
    echo "source ~/.dlamirc" >> $DIR/.zshrc

}

apt update 
get_dotfiles
setup_vim
setup_tmux
setup_zsh
unset DIR