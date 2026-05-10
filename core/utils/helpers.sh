#!/bin/bash

repeat_char() {
    local char="$1"
    local count="$2"
    local result=""
    local i
    for ((i=0; i<count; i++)); do
        result+="$char"
    done
    echo -n "$result"
}

check_status() {
    local all_found=true
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            all_found=false
            break
        fi
    done
    [[ "$all_found" == true ]] && printf "\033[1;32m✔\033[0m" || printf "\033[1;31m✘\033[0m"
}

check_path() {
    local all_found=true
    local p
    for p in "$@"; do
        if [[ ! -d "$p" && ! -f "$p" ]]; then
            all_found=false
            break
        fi
    done
    [[ "$all_found" == true ]] && printf "\033[1;32m✔\033[0m" || printf "\033[1;31m✘\033[0m"
}

is_promptify_installed() {
    [[ -f "$HOME/.zshrc" ]] && grep -q "# --- Promptify Config ---" "$HOME/.zshrc" 2>/dev/null
}

check_setup() {
    if [[ ! -d "$SYS_DIR/oh-my-zsh" ]]; then
        echo -e " \e[1;31m[!] Error: Run Quick Setup first.\e[0m"
        press_enter
        return 1
    fi
    return 0
}

draw_separator() {
    local width="$1"
    local spacer="$2"
    local char="${3:-━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━}"
    # If width is provided, use repeat_char to make a precise line
    if [[ -n "$width" ]]; then
        local line
        line=$(repeat_char "━" "$width")
        printf '\033[2K\r%b\e[1;30m%s\e[0m\n' "$spacer" "$line"
    else
        printf '\033[2K\r%b\e[1;30m%s\e[0m\n' "$spacer" "$char"
    fi
}

get_spacer() {
    local width="$1"
    local term_w
    term_w=$(tput cols)
    local offset=$(( (term_w - width) / 2 ))
    [[ $offset -lt 0 ]] && offset=0
    printf "%${offset}s" ""
}

center_print() {
    local text="$1"
    local clean_len
    clean_len=$(get_clean_len "$text")
    local spacer
    spacer=$(get_spacer "$clean_len")
    printf "\r%b%b\033[0m\033[K\n" "$spacer" "$text"
}

get_clean_len() {
    # Remove ANSI escape sequences
    local clean_str
    clean_str=$(printf "%b" "$1" | sed "s/\x1B\[\([0-9]\{1,3\}\(;[0-9]\{1,3\}\)*\)\?[mGK]//g")
    echo -n "${#clean_str}"
}

# Portable sed -i
sed_i() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

draw_line() {
    local content="$1"
    local box_w="$2"
    local b_clr="$3"
    local r_clr="$4"
    local offset_spacer="$5"
    
    local clean_len
    clean_len=$(get_clean_len "$content")
    local pad_len=$((box_w - clean_len - 4)) # -4 for "║ " and " ║"
    
    # If content is exactly the width or slightly more, avoid negative padding
    [[ $pad_len -lt 0 ]] && pad_len=0
    
    local padding=""
    [[ $pad_len -gt 0 ]] && padding=$(printf "%${pad_len}s" "")

    # Use %b for content to interpret escapes and colors
    printf "%b%b║ %b%s %b║%b\n" "$offset_spacer" "$b_clr" "$content" "$padding" "$b_clr" "$r_clr"
}
