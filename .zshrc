# --------- EX ORDO CONFIGURATIONS -----------
pconsole() {
  # Default to the Ex Ordo app
  local app='exordo-app'

  if [ $PWD = '/Users/adrian/Documents/necto' ]; then
    app='necto';
  elif [ $PWD = '/Users/adrian/Documents/website' ]; then
    app='website';
  elif [ $PWD = '/Users/adrian/Documents/api' ]; then
    app='api';
  fi

  if [ -z "${DATABASE+x}" ]; then
    # No DATABASE environmental variable was set
    docker exec -it "${app}-app-1" bundle exec padrino console $@
  else
    # A DATABASE environmental variable was set
    docker exec -e DATABASE=${DATABASE} -it "${app}-app-1" bundle exec padrino console $@
  fi
}
##
# Import a database file into a named database
# Supports different app, defaults to app (the main Ex Ordo app).
#
# Usage example:
#   import_database exordo_eoc2020 ~/Downloads/eoc2020.sql
#
# Usage example (keep the database file on the host):
#   import_database -k exordo_eoc2020 ~/Downloads/eoc2020.sql
#
# Usage example (named app):
#   import_database -a necto exordo_necto ~/Downloads/exordo_necto.sql
#
import_database() {
  local usage_string="usage: ${0} [-a app] [-k] [-v] database_name /path/to/file.sql"

  local import_result=-1;

  # assume we're importing into the app by default (rather than necto, website, etc.)
  local app='exordo-app';

  # assume we aren't the database by default
  local keep_database=0;

  # assume we don't want verbose output by default
  local verbose=0;

  # find our OS
  platform='unknown'
  unamestr=$(uname)
  if [[ "$unamestr" == 'Linux' ]]; then
    platform='linux'
  elif [[ "$unamestr" == 'Darwin' ]]; then
    platform='macos'
  fi

  # use OS-specific commands
  if [[ $platform == 'linux' ]]; then
    alias dynamic_delete='shred -uz'
  else
    alias dynamic_delete='rm'
  fi

  # Process function arguments
  while getopts ":a:kvh" opts; do
    case $opts in
      # e.g. -a necto, changes the app we're importing into
      a) app=$OPTARG;;
      # keep the database file if we've been given -k
      k) keep_database=1;;
      # show more output if we've been given -k
      v) verbose=1;;
      # help
      h) echo $usage_string; return 1;;
      # an invalid argument was given, don't do anything
      \?) echo "invalid option. ${usage_string}"; return 2;
    esac
  done

  # getopts will require -a to have an argument with a:, but
  # it will seemingly happily consider -k or -v or -h to be a value
  # for our app. This will consider it a missing option
  if [[ $app = '-k' || $app = '-v' || $app = '-h' ]]; then echo $usage_string; return 2; fi

  # Remove any options from the original input so it's
  # considered the same as if we weren't given any options
  shift "$(($OPTIND -1))"

  if [ $# -ne 2 ]; then echo $usage_string; return 3; fi

  if [ ! -f $2 ]; then echo "Couldn't find any file at ${2}"; return 4; fi

  # We need to define this here since it uses data dynamically set with options
  local docker_error_string="Couldn't execute command in docker. Ensure you've run \`docker compose up\` and the ${app}-db-1 container is online."

  # This always copies into the database for app we're currently working in
  docker compose cp $2 db:/

  # Ensure we have privileges to add and work with this database
  docker exec "${app}-db-1" mysql --user="root" --password="exordo_app_password" --execute="GRANT ALL PRIVILEGES ON \`$1\`.* TO 'user'@'%'"
  if [ $? -ne 0 ]; then echo $docker_error_string; return 5; fi

  # Remove any existing version of this database and then import the SQL file
  docker exec "${app}-db-1" mysql --user="user" --password="password" --execute="DROP DATABASE IF EXISTS $1; CREATE DATABASE $1 COLLATE utf8_general_ci; USE $1; SOURCE /$(basename $2);"
  if [ $? -ne 0 ]; then echo $docker_error_string; return 5; fi

  # Rmove the file from the database container
  docker exec "${app}-db-1" dynamic_delete "$(basename $2)"

  if [ $? -ne 0 ]; then
    echo "Couldn't remove the SQL file from the ${app}-db-1 container. Please remove it manually from the container: shred -uz \"$(basename $2)\""
    return 5;
  fi

  # Remove the database from the host system unless we've been given -k
  if [ $keep_database -eq 0 ]; then
    if [ $verbose -eq 1 ]; then
      echo "Database was successfully imported. Removing SQL file ${2} from host system"
    fi

    dynamic_delete $2
  fi

  return 0;
}

# ---------------- ADRIAN CONFIGURATIONS -------------------

wiki (){
	dig +short txt ${1}.wp.dg.cx
}
# Alias for FZF git branch searching https://dev.to/hayden/optimizing-your-workflow-with-fzf-ripgrep-2eai
alias gcob='git branch | fzf | xargs git checkout'

# https://learnvim.irian.to/basics/searching_files
# note that i installed fzf and ripgrep with homebrew
# tell fzf to use ripgrep
# https://github.com/junegunn/fzf/issues/337
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git" '
  export FZF_DEFAULT_OPTS='-m'
fi
# https://voracious.dev/blog/a-guide-to-customizing-the-zsh-shell-prompt
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="awesomepanda"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	# zsh-syntax-highlighting
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# added from rbenv init instructions https://github.com/rbenv/rbenv
eval "$(rbenv init - zsh)"
