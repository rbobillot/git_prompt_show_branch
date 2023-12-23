#!/bin/bash

echo "Checking and updating ~/.bashrc..."

LINE_TO_COMMENT='unset color_prompt force_color_prompt'
if [[ ! -z $(cat ~/.bashrc | egrep "^$LINE_TO_COMMENT") ]]; then
        sed -i "s/$LINE_TO_COMMENT/#$LINE_TO_COMMENT/g" ~/.bashrc
fi

SOURCE_TOOL_INSTRUCTION='[[ -f ~/.prompt_show_branch ]] && source ~/.prompt_show_branch'
if [[ -z $(cat ~/.bashrc | egrep "$SOURCE_TOOL_INSTRUCTION") ]]; then
        echo >>~/.bashrc
        echo $SOURCE_TOOL_INSTRUCTION >>~/.bashrc
fi

TOOL_FILE_PATH=~/.prompt_show_branch
TOOL_SOURCE='https://raw.githubusercontent.com/rbobillot/git_prompt_show_branch/main/prompt_show_branch.bash'

curl -s $TOOL_SOURCE >$TOOL_FILE_PATH || exit 1

if [[ $? -eq 0 ]]; then
        echo -e "Installation \033[92msuccessful\033[0m ! You're all set !"
        echo -e "Please source your bashrc (\033[92msource ~/.bashrc\033[0m) or restart your terminal."
else
        echo -e "\033[91mInstallation failed\033[0m: Curl error ? Write error ?\nPlease check this installation script souerce code for more info)"
        if [[ -f $TOOL_FILE_PATH ]]; then
                rm $TOOL_FILE_PATH
        fi
        # clean bashrc
        sed -i "s/#$LINE_TO_COMMENT/$LINE_TO_COMMENT/g" ~/.bashrc
        sed -i "/$(echo -n $SOURCE_TOOL_INSTRUCTION | sed 's/\//\\\//g')/d" ~/.bashrc
        cat ~/.bashrc | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' >/tmp/.bashrc # clean last empty lines
        mv /tmp/.bashrc ~/.bashrc
        exit 1
fi
