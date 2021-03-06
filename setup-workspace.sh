echo 'Fetching the latest version of Zen Workspace'
echo -e "git clone ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}"

cd /
git clone -q --progress ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}
cd ${WORKSPACE_ROOT_FOLDER}

if [[ ! -f ${WORKSPACE_ROOT_FOLDER}/readme.md ]]
then
    echo "${RED}[ERROR]${WHITE} There was an error fetching the repo. Please check for errors and make sure that your SSH key has been added to github.${NC}"
    exit 1
fi

echo "checking out branch: ${WORKSPACE_REPO_BRANCH}"
git checkout ${WORKSPACE_REPO_BRANCH}
echo 'Installing workspace scripts'
install_workspace_scripts
echo 'completed installing workspace scripts'
echo 'Setting up default hosts'

# add windows_host with the clients connected IP address to ubuntu hosts file
manage-hosts updatehost windows.host ${HOST_IP_ADDRESS}

# add ubuntu servers IP address to windows under the selected ubuntu hostname
manage-hosts win-addhost ${HOSTNAME} ${LOCAL_IP_ADDRESS}
manage-hosts win-addhost workspace ${LOCAL_IP_ADDRESS}
manage-hosts win-updatehost workspace.zen ${LOCAL_IP_ADDRESS}


echo 'Setting up workspace links to windows volumes'
echo " -> linking workspace to ${WHITE}~/workspace${NC}"
ln -s ${WORKSPACE_ROOT_FOLDER} ~/workspace
echo " -> linking workspace to ${WHITE}/var/www${NC}"
sudo ln -s ${WORKSPACE_ROOT_FOLDER} /var/www
echo " -> linking windows hosts file folder to ${WHITE}/etc/win_hosts${NC}"
sudo ln -s ${WORKSPACE_WIN_HOSTS_FOLDER}/hosts /etc/win_hosts

# LINK WORKSPACE BASH ALIASES TO USERS HOME FOLDER
if [[ -f ~/.bash_aliases ]]
then
    mv ~/.bash_aliases ~/_bash_aliases
fi

if [[ -f ~/.bash_helpers ]]
then
    mv ~/.bash_helpers ~/_bash_helpers
fi

if [[ -f ~/.bash_profile ]]
then
    mv ~/.bash_profile ~/_bash_profile
fi

if [[ -f ~/.docker_stacks ]]
then
    mv ~/.docker_stacks ~/_docker_stacks
fi

if [[ -f ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_helpers ]]
then
    ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_helpers ~/.bash_helpers
fi

if [[ -f ${WORKSPACE_ROOT_FOLDER}/config/bash/.docker_stacks ]]
then
    ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/.docker_stacks ~/.docker_stacks
fi

if [[ -f ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_aliases ]]
then
    ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_aliases ~/.bash_aliases
fi

if [[ -f ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_profile ]]
then
    ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_profile ~/.bash_profile
fi

#if [ -n "$(grep 'unset color_prompt force_color_prompt' ~/.bashrc)" ]
#then
#    echo 'Removing unsetting of color vars in bashrc which are required in .bash_aliases.'
#    sudo sed -i".bak" "/unset color_prompt force_color_prompt/d" ~/.bashrc
#fi

source ~/.bash_profile

echo -e "${GREEN}New bash prompt successfully installed"
echo
