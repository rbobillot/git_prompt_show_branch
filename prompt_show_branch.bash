#!/bin/bash

# Installation/update (one-liner):
# curl -s https://raw.githubusercontent.com/rbobillot/git_prompt_show_branch/main/install.bash | bash

export SHOW_BRANCH=yes

function git_working_status {
	if [[ $(git status 2>/dev/null) != "" && $(echo $SHOW_BRANCH) == "yes" ]]; then
		current_branch=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git status 2>/dev/null | head -1 | cut -d ' ' -f3)
		current_unt_status=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git status | egrep -i "untracked files|changes not staged")
		current_add_status=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git status | egrep -i "changes to be committed")
		current_log_status=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git log origin/$current_branch.. 2>/dev/null)
		current_diff=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git diff origin/$current_branch 2>&1)
		color="\001\033[92m\002"

		local_diff_msg="fatal: ambiguous argument 'origin/"
		if [[ ! -z `echo $current_diff | head -1 | egrep "^$local_diff_msg"` ]]; then local="\001\033[96m\002local\001\033[0m\002/"; fi

		if   [[ -n $current_unt_status ]]; then color="\001\033[31m\002"                    # repository modif:   [branch name in RED]
		elif [[ -n $current_add_status ]]; then color="\001\033[33m\002"                    # files added to git: [branch name in YELLOW]
		elif [[ -n $current_log_status ]]; then	color="\001\033[93;1m\002*\001\033[92m\002" # files commited:     [YELLOW star + branch name in LIGHT GREEN]
		fi

		status="[\u2387  ${local}${color}${current_branch}\001\033[0m\002]"
		echo -en "$status" >/tmp/git_status.txt
		echo -en "$status"
		# TODO: detect if branch is up to date
		# TODO: detect commits to push on local branch
		# TODO: detect deleted remote branch
	fi
}

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[0m\]`git_working_status`\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\[`git_working_status`\]\$ '
fi

unset color_prompt force_color_prompt
