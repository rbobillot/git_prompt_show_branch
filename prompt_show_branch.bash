#!/bin/bash

# Installation/update (one-liner):
# curl -s https://raw.githubusercontent.com/rbobillot/git_prompt_show_branch/main/install.bash | bash

export SHOW_BRANCH=yes

function git_working_status {

  if [[ $(git status 2>/dev/null) != "" && $(echo $SHOW_BRANCH) == "yes" ]]; then
    CURRENT_STATUS=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git status 2>/dev/null)
    CURRENT_BRANCH_FULL=$(echo "$CURRENT_STATUS" | head -n 1)
    current_branch=$(echo -n $CURRENT_BRANCH_FULL | rev | cut -d ' ' -f1 | rev)
    # current_branch=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git status 2>/dev/null | head -1 | rev | cut -d ' ' -f1 | rev)
    conlict_status=$(echo $CURRENT_STATUS | egrep -i "conflict")
    current_unt_status=$(echo $CURRENT_STATUS | egrep -i "untracked files|changes not staged")
    current_add_status=$(echo $CURRENT_STATUS | egrep -i "changes to be committed|git commit\" to conclude merge")
    current_untracked_rebase_status=$(echo $CURRENT_STATUS | egrep -i "both modified")
    current_continue_rebase_status=$(echo $CURRENT_STATUS | egrep -i "git rebase --continue")
    current_log_origin_status=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git log origin/$current_branch.. 2>/dev/null)
    current_log_local_status=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git log -n 1 --oneline 2>/dev/null | grep 'origin/')
    current_diff=$(LANG=en_US.UTF-8 LANGUAGE=en_US:en git diff origin/$current_branch 2>&1)

    color="\001\033[92m\002"

    if [[ -n $conlict_status ]]; then
      conflict="\001\033[93;1m\002 !!\001\033[0m\002"
    fi

    if [[ -n $current_unt_status || -n $current_untracked_rebase_status ]]; then
      color="\001\033[31m\002" # repository modif / conflict resolution: [branch name in RED]
    elif [[ -n $current_add_status ]]; then
      color="\001\033[33m\002" # files added to git: [branch name in YELLOW]
    elif [[ -n $current_continue_rebase_status ]]; then
      color="\001\033[93;1m\002 **\001\033[92m\002" # files commited / need to continue conflict resulution: [YELLOW star + branch name in LIGHT GREEN]
    elif [[ -n $current_log_origin_status ]]; then
      color="\001\033[93;1m\002 *\001\033[92m\002" # files commited: [YELLOW star + branch name in LIGHT GREEN]
    fi

    if [[ $TERM == xterm* ]]; then
      git_icon="\ue725"
      # git_icon="\u2387 "

      detached_tag="\033[96m\uf02b\033[0m"
      detached_rebase="\033[93m\ue654\033[0m"
      # detached_rebase="\uf4db"

      detached_local="local"
      detached_other="detached"
    fi

    local_diff_msg="fatal: ambiguous argument 'origin/"
    if [[ ! -z $(echo $current_diff | head -1 | egrep "^$local_diff_msg") ]]; then
      if [[ ! -z $(git tag | grep $current_branch) ]]; then
        git_icon=$detached_tag
      elif [[ ! -z $(echo $CURRENT_BRANCH_FULL | grep "detached") ]]; then
        local=" \001\033[96m\002${detached_other}\001\033[0m\002/"
      elif [[ -z $(echo $CURRENT_STATUS | grep -i "conflict") ]]; then
        local=" \001\033[96m\002${detached_local}\001\033[0m\002/"
      fi

    fi

    if [[ -n $conlict_status ]]; then
      git_icon=$detached_rebase
    fi

    status="[${git_icon}${local}${color} ${current_branch}\001\033[0m\002]"
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
