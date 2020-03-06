#!/bin/bash

#######################################################
#               Parameters                            #
#######################################################
SRC=/usr/local/src

#######################################################
#               Change PATH                           #
#######################################################
sed -i -e 's/PATH=\$PATH:\$HOME\/.local\/bin:$HOME\/bin/PATH=\/usr\/local\/lib\/bin:\/usr\/local\/bin:\/usr\/bin\/:\/usr\/sbin:$PATH/g' ~/.bash_profile
source ~/.bash_profile
sudo sed -i -e 's/PATH=\$PATH:\$HOME\/bin/PATH=\/usr\/local\/lib\/bin:\/usr\/local\/bin:\/usr\/bin:\/usr\/sbin:$PATH/g' /root/.bash_profile
sudo bash -c "source /root/.bash_profile"

#######################################################
#                Change timezone                      #
#######################################################
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#######################################################
#                Disable SELinux                      #
#######################################################
sudo -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config

#######################################################
#                 Update                              #
#######################################################
sudo yum -y update

#######################################################
#                 Libraries                           #
#######################################################
sudo yum -y install epel-release
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sudo yum -y install wget unzip gcc gcc-c++ bzip2 make kernel-devel curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel autoconf asciidoc xmlto docbook2X ncurses-devel expect readline-devel zlib-devel sqlite-devel re2c libxml2 libxml2-devel bzip2-devel libjpeg-devel libpng-devel libicu-devel readline-devel libtidy libtidy-devel libxslt-devel automake libffi-devel httpd httpd-devel iptables-services ffmpeg ffmpeg-devel oniguruma oniguruma-devel
sudo yum -y install http://packages.psychotic.ninja/7/base/x86_64/RPMS/psychotic-release-1.0.0-1.el7.psychotic.noarch.rpm
sudo yum -y --enablerepo=psychotic-plus install libzip libzip-devel

#######################################################
#                 git install                         #
#######################################################
cd $SRC
sudo git clone git://git.kernel.org/pub/scm/git/git.git
cd $SRC/git
sudo make prefix=/usr/local all
sudo make prefix=/usr/local install

#######################################################
#                  git flow install                   #
#######################################################
cd $SRC
sudo wget https://github.com/nvie/gitflow/raw/develop/contrib/gitflow-installer.sh
sudo sed -i -e 's/git clone/\/usr\/local\/bin\/git clone/g' gitflow-installer.sh
sudo sh gitflow-installer.sh
sudo rm -rf *.sh

#######################################################
#                   Vim install                       #
#######################################################
cd $SRC
sudo git clone https://github.com/vim/vim.git
cd $SRC/vim
sudo make prefix=/usr/local
sudo make install

############################################################
#                 NeoBundle install                        #
############################################################
cd
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > ~/install.sh
sh ./install.sh
sudo bash -c "cp install.sh /root/install.sh"
sudo bash -c "sh /root/install.sh"

#######################################################
#                   Remove yum git                    #
#######################################################
sudo yum -y remove git

#######################################################
#                  MySQL install                      #
#######################################################
sudo yum -y remove mariadb-libs
sudo rm -rf /var/lib/mysql

#MySQL5.7
sudo rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

sudo yum -y install mysql-community-devel mysql-community-server

############################################################
#                 Start MySQL                              #
############################################################
sudo systemctl start mysqld
sudo systemctl enable mysqld

############################################################
#                 Start Apache                             #
############################################################
sudo systemctl start httpd
sudo systemctl enable httpd

############################################################
#                 Add chanin for iptables                  #
############################################################
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 80 -j ACCEPT
sudo service iptables save

############################################################
#                   Vim colorscheme                        #
############################################################
cd 
git clone https://github.com/joshdick/onedark.vim.git
cp -a onedark.vim/colors/ .vim/
cp -a onedark.vim/autoload/ .vim/
rm -rf ~/onedark.vim
sudo bash -c 'cp -a .vim /root/'

############################################################
#                          .vimrc                          #
############################################################
echo -e '
" カラースキーム
" colorscheme onedark

" 自動コメントアウト無効化
autocmd FileType * setlocal formatoptions-=r
autocmd FileType * setlocal formatoptions-=o

"バックスペースの有効化
set backspace=indent,eol,start

" ========== Character code =======
" 文字コードをUFT-8に設定
set fenc=utf-8
set encoding=utf-8
scriptencoding utf-8
" ========== Base Config ==========
" ファイルを上書きする前にバックアップを作ることを無効化
set nobackup

" ファイルを上書きする前にバックアップを作ることを無効化
set nowritebackup

" undofileを取らない
set noundofile

" スワップファイルをとらない
set noswapfile

" バッファが編集中でもその他のファイルを開けるように
set hidden

" 改行時自動インデント
set smartindent

" オートインデント
set autoindent

" 括弧入力時の対応する括弧を表示
set showmatch

" 編集中のファイルのタイトル表示
set title

" タブ幅
set tabstop=2
set shiftwidth=2

" PHPファイルはインデント幅を4にする
autocmd FileType setlocal *.php tabstop=4 shiftwidth=4

" 大文字小文字無視
set smartcase

" シンタックスハイライト
" syntax on

" ハイライト
set hlsearch

" 行頭、行末で次の行頭、行末に行けるようにする
set whichwrap=h,l,<,>,[,]

" ========== Key Map ==============
" 入力モード中に素早くJJと入力した場合はESCとみなす
inoremap jj <Esc>

" Escの2回押しでハイライト消去
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>

" HTML/XMLの自動タグ閉じ
autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
			
" nerdTree
nnoremap <silent><C-e> :NERDTreeToggle<CR>
			
" ========== NeoBundle ==============
set nocompatible
filetype plugin indent off
			
if has("vim_starting")
" 初回起動時のみneobundleのパスを指定
set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
				
" NeoBundleを初期化
call neobundle#begin(expand("~/.vim/bundle"))
				
" NeoBundleをNeoBundle自体で管理
NeoBundleFetch "Shougo/neobundle.vim"
				
" インストールするプラグイン
NeoBundle "scrooloose/nerdtree"
				
call neobundle#end()
				
" 未インストールプラグインを起動時にインストール
NeoBundleCheck
				
" ファイルタイプ別のプラグイン/インデントを有効にする
filetype plugin indent on' >> ~/.vimrc
sudo bash -c "cp .vimrc /root/.vimrc"

############################################################
#                 terminal color                           #
############################################################
echo -e '
# ターミナルの色設定
# root or other
if [ $UID -eq 0 ]; then
  PS1="\[\e[1;35m\][\u@\h \W]:\[\e[35m\]\`parse_git_branch\`\[\e[37m\]\\\\$ "
else
  PS1="\[\e[1;36m\][\u@\h \W]:\[\e[35m\]\`parse_git_branch\`\[\e[37m\]\\\\$ "
fi

# get current branch in git repo
function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/"`
  if [ ! "${BRANCH}" == "" ]; then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=""
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}' >> ~/.bashrc

############################################################
#                       Alias                              #
############################################################
echo -e "
# エイリアス設定
# Linux Command
alias mk='touch'
alias la='ls -a'
alias ..='cd ..'
alias su='su -'
alias vi='vim'

# MySQL Command
alias msr='mysql -u root -p'" >> ~/.bashrc
sudo bash -c "cat .bashrc >> /root/.bashrc"

############################################################
#                 .gitconfig                               #
############################################################
echo -e '
	a = add
  aa = add .
	c = commit
  cm = commit -m

	b = branch
	co = checkout
  cob = checkout -b
	m = merge
	f = fetch

	st = status
  d = diff

  ra = remote add origin
	pu = push
	pl = pull
  cl = clone

	fi = flow init

	ffs = flow feature start
	fff = flow feature finish
	ffpu = flow feature publish
	ffpl = flow feature pull

	frs = flow release start
	frpu = flow release publish
	frt = flow release track
	frf = flow release finish 

	fhs = flow hotfix start
	fhf = flow hotfix finish' >> ~/.gitconfig
sudo bash -c "cp .gitconfig /root/.gitconfig"

rm *.sh
