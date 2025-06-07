# path

## basic
typeset -U path PATH
path=(
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
)


# zsh

## basic settings
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
setopt correct               # コマンドのスペルミスを指摘
zmodload zsh/datetime        # EPOCHREALTIMEを利用可能に

## cd
setopt auto_cd               # cdなしでディレクトリ移動可能
setopt cdable_vars           # ~省略で変数定義のパスにcd可能
setopt auto_name_dirs        # 名前付きディレクトリを有効化


## alias

### basic
# NOTE: ls系はezaを使用
#alias ls='ls --color=auto'
#alias ll='ls -la --color=auto'
#alias la='ls -a --color=auto'
#alias l='ls -CF --color=auto'
### [NOTE] eza: icon出ない場合 @see https://github.com/eza-community/eza/issues/1275
alias ls='eza --icons'
alias ll='eza --icons -alh -s time --time-style iso --git'
alias la='eza --icons -a -s name'
alias llt='eza --icons -alh -s time -T --level=3 --time-style iso --git'
alias rm='rm -i'                   # 削除確認を有効化
alias cp='cp -i'                   # 上書き確認を有効化
alias mv='mv -i'                   # 移動時の上書き確認
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias history='history -t "%F %T"' # historyに時間表記を追加
alias cdd='cd ..'                  #親ディレクトリに移動
alias cds='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"' # ディレクトリスタックを表示し、番号指定で移動可能

### shell
alias relogin="echo 'Respawning...' && exec $SHELL -l"

### git
alias gs="git status"
alias gps="git push -u origin HEAD"
alias git-push="gps"
alias git-pull="gpl"
alias gb="git branch"
alias gco="git checkout"
alias gl="git log"

### docker
alias dcu="docker compose up -d"
alias dce="docker compose exec"
alias dcs="docker compose stop"
alias dcd="docker compose down"
alias dps="docker ps"

### gcp
alias gc-config-list="gcloud config configurations list"
alias gc-config-activate="gcloud config configurations activate"
alias gc-proj-list="gcloud projects list"

#### NOTE: alias は定義時に $(...) を展開してしまうため、gitリポジトリが存在しない箇所でgitの実行エラーを防ぐ
gpl() {
  git pull origin "$(git rev-parse --abbrev-ref HEAD)"
}

## color
autoload colors && colors

### ls
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

## history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory         # ヒストリを追加保存
setopt sharehistory          # 複数の zsh 間でヒストリ共有
#setopt hist_ignore_all_dups  # 重複を記録しない
setopt hist_ignore_space     # スペースで始まるコマンドは記録しない
setopt inc_append_history    # 実行ごとに即座に履歴を保存

## autosuggestions NOTE: install方法によってパスを調整
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

## syntax-highlighting NOTE: install方法によってパスを調整
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh       # auto_pushdで重複するディレクトリは記録しない

## completion
# autoload predict-on && predict-on                            # ヒストリからの入力予測を有効化（リアルタイム補完） NOTE: 補完が自動で入力済みになってしまうケースがある
autoload -Uz compinit && compinit                              # 補完機能（TAB補完など）を有効化
zstyle ':completion:*' menu select=2                           # 補完候補を選択可能に
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'      # 補完候補がなければより曖昧に候補を探す:大文字小文字を区別しない
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"        # 補完候補一覧に色反映
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'  # プロセス名を補完
zstyle ':completion:*' use-cache yes                           # 補完候補をキャッシュする
zstyle ':completion:*' cache-path ~/.zsh/cache                 # 補完候補のキャッシュパス
setopt auto_list                                               # 候補が複数ある場合に、自動で一覧表示
setopt auto_menu                                               # 補完キー連打で順に補完候補を自動で補完
setopt list_packed                                             # 候補が多い場合は詰めて表示
setopt magic_equal_subst                                       # コマンドラインの引数でも補完を有効にする（--prefix=/userなど）
setopt auto_pushd                                              # cd -<tab>で以前移動したディレクトリを表示
setopt pushd_ignore_dups                                       # pushdから重複を削除
setopt print_eight_bit                                         # 日本語ファイル名等8ビットを通す
setopt hist_verify                                             # ヒストリ補完時に、タブを押すまでは確定させない
setopt globdots                                                # ドットなしでドットファイルも補完候補に入れる
setopt hist_expand

### 上下キーでの補完
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

### 単語単位で削除
tcsh-backward-delete-word() {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey "^W" tcsh-backward-delete-word

## git-prompt
source ~/.zsh/git-prompt.sh

## git-completion
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash

## プロンプト表示設定
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
REPORTTIME=3 # 所要時間

## functions

### プロンプトにgitのステータスを表示

function git_prompt_info() {
  local branch base_branch commit_hash commit_msg commit_elapsed_time current_unix_time commit_elapsed_seconds git_status dirty staged unstaged untracked stashed conflicted upstream

  # Git管理下かどうかを確認
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    return
  fi

  # ブランチ名
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "DETACHED")

  # ブランチの派生元を取得
  base_branch=""
  for base in main master develop; do
    if git show-ref --verify --quiet refs/heads/$base; then
      if git merge-base --is-ancestor $base $branch; then
        base_branch=$base
        break
      fi
    fi
  done
  [[ -n $base_branch ]] && base_branch="%F{blue} <- $base_branch%f"

  # 直近のコミット情報
  commit_hash=$(git rev-parse --short HEAD 2>/dev/null)
  commit_msg=$(git log -1 --pretty=format:"%s" 2>/dev/null)
  local COMMIT_MSG_LIMIT=40
  if [[ ${#commit_msg} -gt $COMMIT_MSG_LIMIT ]]; then
    commit_msg="${commit_msg:0:$COMMIT_MSG_LIMIT}…"
  fi

  ## 経過時間を計算
  commit_unix_time=$(git log -1 --pretty=format:%ct 2>/dev/null)
  current_unix_time=$(date +%s)
  commit_elapsed_seconds=$((current_unix_time - commit_unix_time))

  ### 経過時間のフォーマット
  if [[ -z $commit_unix_time ]]; then
    commit_elapsed_time="no commits"
  elif [[ $commit_elapsed_seconds -lt 60 ]]; then
    commit_elapsed_time="${commit_elapsed_seconds}s ago"
  elif [[ $commit_elapsed_seconds -lt 3600 ]]; then
    commit_elapsed_time="$((commit_elapsed_seconds / 60))m ago"
  elif [[ $commit_elapsed_seconds -lt 86400 ]]; then
    commit_elapsed_time="$((commit_elapsed_seconds / 3600))h ago"
  else
    commit_elapsed_time="$((commit_elapsed_seconds / 86400))d ago"
  fi

  # ステータス取得
  staged=$(git diff --cached --numstat | wc -l | tr -d ' ')
  unstaged=$(git diff --numstat | wc -l | tr -d ' ')
  untracked=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
  stashed=$(git stash list | wc -l | tr -d ' ')
  conflicted=$(git ls-files -u | awk '{print $2}' | sort -u | wc -l | tr -d ' ')

  ## ステータス表示
  git_status=""

  [[ $staged -gt 0 ]] && git_status+="%F{green}+$staged%f"           # ステージング済みファイル数
  [[ $unstaged -gt 0 ]] && git_status+="%F{magenta}~$unstaged%f"       # 変更ファイル数
  [[ $untracked -gt 0 ]] && git_status+="%F{red}?$untracked%f"     # 未追跡ファイル数
  [[ $stashed -gt 0 ]] && git_status+="%F{cyan}^$stashed%f"         # スタッシュ数
  [[ $conflicted -gt 0 ]] && git_status+="%F{yellow}!${conflicted}%f" # コンフリクトファイル数

  # 派生元ブランチを含めて表示
  echo "%F{blue}(%f%F{green}$branch%f$base_branch%F{blue})%f$git_status [(%F{magenta}$commit_elapsed_time%f) <%F{yellow}$commit_hash%f> %F{gray}$commit_msg%f]"
}

### プロンプト実行毎に所要時間表示
ELAPSED_TIME= # プロンプト表示に利用

start_cmd_timer() { 
  TIMER_START=$EPOCHREALTIME
}

end_cmd_timer() {
  unset ELAPSED_TIME
  if [[ -n "$TIMER_START" ]]; then
    local TIMER_END=$EPOCHREALTIME
    ELAPSED_TIME=$(awk "BEGIN {printf \"%.3f\", $TIMER_END - $TIMER_START}")
    unset TIMER_START
  fi
}

add-zsh-hook preexec start_cmd_timer
add-zsh-hook precmd end_cmd_timer

### カレントディレクトリ変更時にファイル一覧を表示
ls_abbrev() {
  if [[ ! -r $PWD ]]; then
    return
  fi
  # -C : Force multi-column output.
  # local cmd_ls='ls'
  local cmd_ls='eza'
  local -a opt_ls
  # opt_ls=('-A' '-C' '--color=always')
  opt_ls=('--icons')
  # case ${OSTYPE} in
  #   freebsd*|darwin*)
  #     if (( $+commands[gls] )); then
  #       cmd_ls='gls'
  #     else
  #       # -G : Enable colorized output.
  #       opt_ls=('-aCFG')
  #     fi
  #     ;;
  # esac

  local ls_result
  # ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]}| sed $'/^\e\[[0-9;]*m$/d')
  ls_result=$(command $cmd_ls ${opt_ls[@]})

  local ls_lines=$(echo "$ls_result"| wc -l| tr -d ' ')
  if [[ "$ls_lines" -gt 10 ]]; then
    echo "$ls_result"| head -n 5
    echo '...'
    echo "$ls_result"| tail -n 5
    echo "$(command ls -1 -A| wc -l| tr -d ' ') files exist"
  else
    # echo "$ls_result"
    command $cmd_ls ${opt_ls[@]} # XXX 2回実行するのをやめたいが、ezaのアイコン情報を保持できていない
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd ls_abbrev # chpwd(カレントディレクトリが変更したとき)にls_abbrevを実行

## プロンプト表示内容
setopt PROMPT_SUBST
PS1='
%F{magenta}%~%f $(git_prompt_info)
%# '
RPROMPT='%F{yellow}${ELAPSED_TIME:+(${ELAPSED_TIME}s)}%f %F{blue}$(date "+%Y-%m-%d %H:%M:%S")%f'


## ログ出力向け色付け関数
colorlog() {
  if [[ $# -gt 0 ]]; then
    set -m  # ジョブ制御を有効化
    
    unbuffer "$@" | sed -E '
      s/INFO/\x1b[1;32mINFO\x1b[0m/g
      s/ERROR/\x1b[1;31mERROR\x1b[0m/g
      s/WARN/\x1b[1;33mWARN\x1b[0m/g
      s/DEBUG/\x1b[1;36mDEBUG\x1b[0m/g
    ' &
    
    local job_pid=$!
    
    # シグナルハンドラでstopを実行
    trap '
      echo "Stopping containers..." >&2
      kill -TERM -'$job_pid' 2>/dev/null
      docker compose stop
      return 130
    ' INT TERM
    
    wait $job_pid
    local exit_code=$?
    
    trap - INT TERM
    set +m
    
    return $exit_code
  else
    echo "Error: No command specified" >&2
    echo "Usage: colorlog <command> [args...]" >&2
    echo "Example: colorlog docker compose logs --tail=0 -f app" >&2
    return 1
  fi
}

