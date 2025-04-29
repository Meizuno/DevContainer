if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls='lsd -la'
alias activate='source .venv/bin/activate.fish'
alias python='python3.12'

set -gx PATH /usr/share/swift/usr/bin $HOME/.cargo/bin $PATH

source $HOME/.cargo/env.fish

set EDITOR code
set -U fish_greeting ""

if test -d ".venv/"
    source .venv/bin/activate.fish
    set_color green
    if set -q VIRTUAL_ENV
        echo -n Virtual environment is active
        set_color blue
        echo " ("$(python -V)")"
    end
    set_color normal
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

function fish_prompt
    set status_code $status

    set_color red
    echo -n " "

    set_color green
    echo -n (hostname)' '

    if set -q start_time
        set miliseconds (math $end_time - $start_time)
        set seconds (math $miliseconds / 100)
        set_color magenta
        echo -n " "$seconds"s "
    end

    if set -q VIRTUAL_ENV
        set_color blue
        echo -n " (.venv) "
    end

    # Get the current Git branch if it exists
    set git_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -n "$git_branch"
        set_color yellow
        echo -n "󰮠 "$git_branch" "
    end

    set_color green
    set path (prompt_pwd)
    if test $path != "~"
        echo -n  ' '
    end
    echo -n (prompt_pwd)

    if test $status_code -ne 0
        set_color red
        echo -n " ["$status_code"] "
    end

    set_color normal
    echo '> '
end

function fish_preexec --on-event fish_preexec
    set -g start_time (date +%s%2N)
end

function fish_postexec --on-event fish_postexec
    set -g end_time (date +%s%2N)
end
