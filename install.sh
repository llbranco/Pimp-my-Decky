#!/usr/bin/env bash
## by LLBRANCO github.com/llbranco

# Verifica se o script está sendo executado como root
check_root_or_prompt() {
    if [[ "$EUID" -ne 0 ]]; then
        zenity --password --title="Autenticação Necessária" --window-icon="pimp-my-decky" --text="Este script requer permissões de root para ser executado." | sudo -S true
        if [[ $? -ne 0 ]]; then
            zenity --error --title="Erro de Autenticação" --window-icon="pimp-my-decky" --text="Falha ao autenticar como root. Saindo do script."
            exit 1
        fi
    fi
}

# verificar se o zenity está instalado
check_zenity() {
    if ! command -v zenity &> /dev/null; then
        echo "Zenity is not installed. Installing..."
        sudo pacman -S --noconfirm zenity
    else
        echo "Zenity is already installed."
    fi
}


# Função para mostrar notificações
show_notification() {
    zenity --notification \
        --window-icon="pimp-my-decky" \
        --text="$1"
}
#payload show_notification "sua msg aqui."

# Listas de aplicativos essenciais e recomendados
ESSENTIAL_APPS=(
    "net.davidotek.pupgui2:ProtonUp-Qt"
    "org.winehq.Wine:WineHQ"
)

RECOMMENDED_APPS=(
    "ru.linux_gaming.PortProton:PortProton"
    "com.anydesk.Anydesk:AnyDesk"
    "com.github.tchx84.Flatseal:Flatseal"
    "io.github.philipk.boilr:Boilr"
    "com.usebottles.bottles:Bottles"
    "net.lutris.Lutris:Lutris"
)

# Função para criar lista de aplicativos essenciais
ask_essential_apps() {
    local checklist=()
    for app in "${ESSENTIAL_APPS[@]}"; do
        IFS=":" read -r id name <<< "$app"
        checklist+=("TRUE" "$id" "$name")
    done

    zenity --list \
        --title="Aplicativos Essenciais" \
        --window-icon="pimp-my-decky" \
        --text="Selecione os aplicativos essenciais para instalar:" \
        --checklist \
        --column="Selecionar" --column="Flatpak ID" --column="Nome do Aplicativo" \
        "${checklist[@]}" \
        --separator="|"
}

# Função para criar lista de aplicativos recomendados
ask_recommended_apps() {
    local checklist=()
    for app in "${RECOMMENDED_APPS[@]}"; do
        IFS=":" read -r id name <<< "$app"
        checklist+=("FALSE" "$id" "$name")
    done

    zenity --list \
        --title="Aplicativos Recomendados" \
        --window-icon="pimp-my-decky" \
        --text="Selecione os aplicativos recomendados para instalar:" \
        --checklist \
        --column="Selecionar" --column="Flatpak ID" --column="Nome do Aplicativo" \
        "${checklist[@]}" \
        --separator="|"
}

# Função para instalar aplicativos via Flatpak
install_flatpak_apps() {
    local selected_apps="$1"
    if [[ -z "$selected_apps" ]]; then
        show_notification "Nenhum aplicativo selecionado para instalação."
        return
    fi

    IFS="|" read -ra apps <<< "$selected_apps"
    for app in "${apps[@]}"; do
        show_notification "Instalando $app..."
        flatpak install -y flathub "$app"
    done
}


# Função para exibir opções de instalação ao usuário
ask_install_options() {
    zenity --list \
        --title="Instalação do Pimp My Decky" \
        --width=250 \
        --height=500 \
        --window-icon="pimp-my-decky" \
        --text="Selecione o que deseja instalar/configurar:" \
        --checklist \
        --column="Selecionar" --column="Opção" \
        TRUE  "SteamOS-BTRFS (compressão de dados)" \
        TRUE  "Aplicativos essenciais (via Flatpak)" \
        TRUE  "Aplicativos recomendados (via Flatpak)" \
        TRUE  "EmuDeck" \
        TRUE  "CryoUtilities" \
        TRUE  "Spotify com Spicetify e Marketplace" \
        FALSE "Todos os itens acima" \
        --separator="|"
}

# Função para escolher nível de compressão
ask_compression_level() {
    zenity --list \
        --title="Configuração de Compressão" \
        --window-icon="pimp-my-decky" \
        --text="Escolha o nível de compressão desejado para o SteamOS-BTRFS:" \
        --radiolist \
        --column="Selecionar" --column="Nível" --column="Descrição" \
        TRUE  "1" "Sem compressão" \
        FALSE "2" "Compressão padrão (zstd:3)" \
        FALSE "3" "Compressão média (zstd:5)" \
        FALSE "4" "Compressão recomendada (zstd:7)" \
        FALSE "5" "Compressão alta (zstd:9)"
}

# Função para instalar o SteamOS-BTRFS
install_steamos_btrfs() {
    compression_choice=$(ask_compression_level)
    case "$compression_choice" in
        1) zenity --notification --window-icon="pimp-my-decky" --text="Sem compressão selecionada."; return ;;
        2) compressratio=""; zenity --notification --window-icon="pimp-my-decky" --text="Compressão padrão selecionada." ;;
        3) compressratio="5"; zenity --notification --window-icon="pimp-my-decky" --text="Compressão média selecionada." ;;
        4) compressratio="7"; zenity --notification --window-icon="pimp-my-decky" --text="Compressão recomendada selecionada." ;;
        5) compressratio="9"; zenity --notification --window-icon="pimp-my-decky" --text="Compressão alta selecionada." ;;
        *) zenity --error --text="Opção inválida ou operação cancelada."; return ;;
    esac

    show_notification "Instalando SteamOS-BTRFS..."
    bash -c "if [[ -f /usr/share/steamos-btrfs/install.sh ]] ; then /usr/share/steamos-btrfs/install.sh ; else t=\$(mktemp -d) ; curl -fsSL https://gitlab.com/popsulfr/steamos-btrfs/-/archive/main/steamos-btrfs-main.tar.gz | tar -xzf - -C \$t --strip-components=1 ; \$t/install.sh ; rm -rf \$t ; fi"

    if [[ -n "$compressratio" ]]; then
        show_notification "Configurando compressão com zstd:$compressratio..."
        STEAMOS_BTRFS_HOME_MOUNT_OPTS="defaults,nofail,x-systemd.growfs,noatime,lazytime,compress-force=zstd:$compressratio,space_cache=v2,autodefrag,nodiscard" \
        /usr/share/steamos-btrfs/install.sh
    fi
}

# Função para instalar aplicativos via Flatpak
install_flatpak_apps() {
    local selected_apps="$1"
    if [[ -z "$selected_apps" ]]; then
        show_notification "Nenhum aplicativo selecionado para instalação."
        return
    fi

    IFS="|" read -ra apps <<< "$selected_apps"
    for app in "${apps[@]}"; do
        show_notification "Instalando $app..."
        flatpak install -y flathub "$app"
    done
}


# Função para instalar o EmuDeck
install_emudeck() {
    show_notification "Instalando EmuDeck..."
    sh -c 'curl -fsSL https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash'
}

# Função para instalar o CryoUtilities
install_cryoutilities() {
    show_notification "Instalando CryoUtilities..."
    curl -fsSL https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
}

# Função para configurar Spotify com Spicetify e Marketplace
setup_spotify_spicetify() {
    show_notification "Verificando instalação do Spotify Flatpak..."
    if ! flatpak list | grep -q "com.spotify.Client"; then
        show_notification "Spotify não instalado. Instalando..."
        flatpak install -y flathub com.spotify.Client
    fi

    show_notification "Instalando Spicetify CLI..."
    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh

    show_notification "Ajustando permissões para Spicetify..."
    sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
    sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps

    CONFIG_DIR="/home/deck/.config/spicetify"
    CONFIG_FILE="$CONFIG_DIR/config-xpui.ini"

    show_notification "Atualizando configuração do Spicetify..."
    mkdir -p "$CONFIG_DIR"
    [[ ! -f "$CONFIG_FILE" ]] && spicetify backup create-config

    sed -i '/prefs_path/d' "$CONFIG_FILE"
    echo "prefs_path = /home/deck/.var/app/com.spotify.Client/config/spotify/prefs" >> "$CONFIG_FILE"
    sed -i 's/^sidebar_config = .*/sidebar_config = 0/' "$CONFIG_FILE"
    sed -i '/custom_apps/d' "$CONFIG_FILE"
    echo "custom_apps = marketplace" >> "$CONFIG_FILE"
    sed -i '/current_theme/d' "$CONFIG_FILE"
    echo "current_theme = marketplace" >> "$CONFIG_FILE"

    mkdir -p "$CONFIG_DIR/themes/marketplace"
    echo "[Marketplace]" > "$CONFIG_DIR/themes/marketplace/color.ini"

    show_notification "Aplicando configuração do Spicetify..."
    spicetify apply

    show_notification "Instalando Spicetify Marketplace..."
    curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh

    show_notification "Spotify com Spicetify configurado!"
}

# Execução principal
main() {
    check_zenity
    check_root_or_prompt

zenity --text-info \
       --title="Pimp my Decky" \
       --URL=https://github.com/llbranco/Pimp-my-Decky \
       --checkbox="Declaro que sou responsável por instalar"

case $? in
    0)
        echo "iniciar instalação!"
    # next step
    ;;
    1)
        echo "parar instalação!"
    ;;
    -1)
        echo "um erro ocorreu!"
    ;;
esac

    # Install Pimp my Decky Icon
curl -fsSL -o "$HOME/.pimp-my-decky/pimp-my-decky.png" https://github.com/llbranco/Pimp-my-Decky/blob/main/assets/Icon.png
xdg-icon-resource install pimp-my-decky.png --size 64

    user_choices=$(ask_install_options)
    if [[ -z "$user_choices" ]]; then
        zenity --error --text="Nenhuma opção selecionada. Saindo."
        exit 1
    fi

    IFS="|" read -ra choices <<< "$user_choices"
    for choice in "${choices[@]}"; do
        case "$choice" in
            "SteamOS-BTRFS (compressão de dados)") install_steamos_btrfs ;;
            "Aplicativos essenciais (via Flatpak)") install_flatpak_apps ;;
            "Aplicativos recomendados (via Flatpak)") install_flatpak_apps ;;
            "EmuDeck") install_emudeck ;;
            "CryoUtilities") install_cryoutilities ;;
            "Spotify com Spicetify e Marketplace") setup_spotify_spicetify ;;
            "Todos os itens acima")
                install_steamos_btrfs
                install_flatpak_apps
                install_emudeck
                install_cryoutilities
                setup_spotify_spicetify
                ;;
            *) zenity --error --text="Opção inválida: $choice" ;;
        esac
    done

    show_notification "Instalações concluídas. Aproveite!"
}

main
