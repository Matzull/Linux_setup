#!/bin/bash

# --- CONFIGURACIÓN ---
# Sustituye este enlace por el link "Raw" de tu archivo .p10k.zsh en GitHub
URL_P10K="https://raw.githubusercontent.com/tu_usuario/tu_repo/main/.p10k.zsh"

echo "🚀 Iniciando instalación de entorno..."

# 1. Dependencias del sistema
sudo apt-get update
sudo apt-get install -y zsh git curl ripgrep fzf neovim

# 2. Oh My Zsh (Instalación silenciosa)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Tema Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 4. Plugins de ZSH (Autosuggestions y Syntax Highlighting)
mkdir -p ~/.zsh
[ ! -d ~/.zsh/zsh-autosuggestions ] && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
[ ! -d ~/.zsh/zsh-syntax-highlighting ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# 5. Herramientas Modernas (Zoxide y Atuin)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
source $HOME/.atuin/bin/env

# 6. Descargar tu configuración visual personalizada
echo "🎨 Descargando configuración visual de GitHub..."
curl -fsSL "$URL_P10K" -o ~/.p10k.zsh

sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# 7. Crear .custom_aliases
cat <<EOT > ~/.custom_aliases
# Navegación
alias cd='z'
alias ..='cd ..'

# Sistema
alias update='sudo apt update && yes | sudo apt upgrade'
alias vi='nvim'
alias vim='nvim'

# Gestión de Alias
alias calias='nvim ~/.custom_aliases && source ~/.zshrc'
alias walias='calias'
EOT

# 8. Generar el .zshrc final
cat <<EOT > ~/.zshrc
# Powerlevel10k instant prompt
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)
source \$ZSH/oh-my-zsh.sh

# Herramientas
export PATH="\$HOME/.atuin/bin:\$PATH"
eval "\$(zoxide init zsh)"
eval "\$(atuin init zsh)"
source <(fzf --zsh)

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Cargar archivos externos
[[ -f ~/.custom_aliases ]] && source ~/.custom_aliases
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOT

# Cambiar shell
sudo chsh -s $(which zsh) $USER

echo "✅ ¡Todo listo! Reinicia la terminal."