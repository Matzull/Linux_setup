#!/bin/bash

# --- CONFIGURATION ---
# Replace this link with the "Raw" link of your .p10k.zsh file on GitHub
URL_P10K="https://raw.githubusercontent.com/Matzull/Linux_setup/refs/heads/master/.p10k.zsh"

# Function to install system dependencies
install_dependencies() {
    echo "📦 Installing system dependencies..."
    sudo apt-get update
    sudo apt-get install -y zsh git curl ripgrep neovim
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

# Function to install Oh My Zsh
install_omz() {
    echo "zz Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "   Oh My Zsh is already installed."
    fi
}

# Function to install Powerlevel10k theme
install_p10k() {
    echo "⚡ Installing Powerlevel10k..."
    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$P10K_DIR" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    else
        echo "   Powerlevel10k is already installed."
    fi
}

# Function to install ZSH plugins
install_plugins() {
    echo "🔌 Installing ZSH plugins (Autosuggestions & Syntax Highlighting)..."
    mkdir -p ~/.zsh
    [ ! -d ~/.zsh/zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    [ ! -d ~/.zsh/zsh-syntax-highlighting ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
}

# Function to install modern tools (Zoxide, Atuin)
install_modern_tools() {
    echo "🚀 Installing modern tools (Zoxide & Atuin)..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
    source $HOME/.atuin/bin/env
    atuin import bash
}

# Function to install Eza and download visual config
install_visuals_and_eza() {
    echo "🎨 Downloading visual configuration and installing Eza..."
    curl -fsSL "$URL_P10K" -o ~/.p10k.zsh

    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
}

# Function to create custom aliases
create_aliases() {
    echo "🔗 Creating .custom_aliases..."
    cat <<EOT > ~/.custom_aliases
# Navigation
alias cd='z'
alias ..='cd ..'

# System
alias update='sudo apt update && yes | sudo apt upgrade'
alias vi='nvim'
alias vim='nvim'

# Alias Management
alias calias='nvim ~/.custom_aliases && source ~/.zshrc'
alias walias='calias'
EOT
}

# Function to generate .zshrc
create_zshrc() {
    echo "📝 Generating final .zshrc..."
    cat <<EOT > ~/.zshrc
# Powerlevel10k instant prompt
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
export PATH=$PATH:$HOME/.local/bin


plugins=(git)
source \$ZSH/oh-my-zsh.sh

# Tools
export PATH="\$HOME/.atuin/bin:\$PATH"
eval "\$(zoxide init zsh)"
eval "\$(atuin init zsh)"
source <(fzf --zsh)

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load external files
[[ -f ~/.custom_aliases ]] && source ~/.custom_aliases
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOT
}

# Function to change default shell
change_shell() {
    echo "🐚 Changing default shell to ZSH..."
    sudo chsh -s $(which zsh) $USER
}

# Menu Function
function show_menu() {
    echo "========================================="
    echo "      Linux Environment Setup Menu       "
    echo "========================================="
    echo "1. Install Everything"
    echo "2. Install System Dependencies"
    echo "3. Install Oh My Zsh"
    echo "4. Install Powerlevel10k"
    echo "5. Install ZSH Plugins"
    echo "6. Install Modern Tools (Zoxide, Atuin)"
    echo "7. Install Visual Config & Eza"
    echo "8. Create Custom Aliases"
    echo "9. Generate .zshrc"
    echo "10. Change Default Shell"
    echo "0. Exit"
    echo "========================================="
    read -p "Select an option: " choice
}

# Main Loop
while true; do
    show_menu
    case $choice in
        1)
            install_dependencies
            install_omz
            install_p10k
            install_plugins
            install_modern_tools
            install_visuals_and_eza
            create_aliases
            create_zshrc
            change_shell
            echo "✅ All done! Please restart your terminal."
            break
            ;;
        2) install_dependencies ;;
        3) install_omz ;;
        4) install_p10k ;;
        5) install_plugins ;;
        6) install_modern_tools ;;
        7) install_visuals_and_eza ;;
        8) create_aliases ;;
        9) create_zshrc ;;
        10) change_shell ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo "❌ Invalid option, please try again." ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
