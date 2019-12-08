############################################################
#                   anyenv install                         #
############################################################
git clone https://github.com/riywo/anyenv ~/.anyenv
echo -e '
# anyenv PATH
export PATH=$HOME/.anyenv/bin:$PATH
eval "$(anyenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
anyenv install --force-init

############################################################
#                  anyenv plugin install                   #
############################################################
mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
anyenv update

############################################################
#                    rbenv install                         #
############################################################
anyenv install rbenv
source ~/.bash_profile

############################################################
#                    phpenv install                        #
############################################################
anyenv install phpenv
source ~/.bash_profile
echo -e '--with-mysqli
--with-pdo-mysql
--with-apxs2
' >> ~/.anyenv/envs/phpenv/plugins/php-build/share/php-build/default_configure_options

sudo chmod 777 /usr/lib64/httpd/modules

############################################################
#                    pyenv install                         #
############################################################
anyenv install pyenv
source ~/.bash_profile

############################################################
#                    nodenv install                        #
############################################################
anyenv install nodenv
source ~/.bash_profile
