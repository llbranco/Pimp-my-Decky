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

create_directory() {
    local dir="$HOME/.pimp-my-decky"
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating..."
        mkdir -p "$dir"
        # Install Pimp my Decky Icon
        curl -fsSL -o "$HOME/.pimp-my-decky/pimp-my-decky.png" https://raw.githubusercontent.com/llbranco/Pimp-my-Decky/main/assets/Icon.png
        xdg-icon-resource "$HOME/.pimp-my-decky/pimp-my-decky.png" --size 64
    else
        echo "Directory $dir already exists."
    fi
}
create_directory

# Função para mostrar notificações
show_notification() {
    zenity --notification \
        --window-icon="pimp-my-decky" \
        --text="$1"
}

# Listas de aplicativos essenciais e recomendados
ESSENTIAL_APPS=(
    "TRUE net.davidotek.pupgui2:ProtonUp-Qt"
    "TRUE org.winehq.Wine:WineHQ"
)

RECOMMENDED_APPS=(
    "ru.linux_gaming.PortProton:PortProton"
    "TRUE com.anydesk.Anydesk:AnyDesk"
    "TRUE com.github.tchx84.Flatseal:Flatseal"
    "io.github.philipk.boilr:Boilr"
    "TRUE com.usebottles.bottles:Bottles"
    "TRUE net.lutris.Lutris:Lutris"
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
        --width=450 \
        --height=350 \
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
        --width=450 \
        --height=350 \
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
        flatpak install --user -y flathub "$app"
    done
}

# Função para exibir opções de instalação ao usuário
ask_install_options() {
    zenity --list \
        --title="Instalação do Pimp My Decky" \
        --width=450 \
        --height=350 \
        --window-icon="pimp-my-decky" \
        --text="Selecione o que deseja instalar:" \
        --checklist \
        --column="Selecionar" --column="Opção" \
        TRUE  "ProtonUpQT e Wine (essencial)" \
        TRUE  "Apps recomendados" \
        FALSE  "SteamOS-BTRFS (compressão de dados)" \
        TRUE  "EmuDeck" \
        TRUE  "CryoUtilities" \
        FALSE  "Spotify com Spicetify e Marketplace" \
        FALSE  "Stremio mais torrentio" \
        FALSE "Todos os itens acima" \
        --separator="|"
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

setup_stremio() {
flatpak install --user -y flathub com.stremio.Stremio
xdg-open stremio://torrentio.strem.fun/manifest.json
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

    user_choices=$(ask_install_options)
    if [[ -z "$user_choices" ]]; then
        zenity --error --text="Nenhuma opção selecionada. Saindo."
        exit 1
    fi

    IFS="|" read -ra choices <<< "$user_choices"
    for choice in "${choices[@]}"; do
        case "$choice" in
            "SteamOS-BTRFS (compressão de dados)") install_steamos_btrfs ;;
            "ProtonUpQT e Wine (essencial)")
                selected_apps=$(ask_essential_apps)
                install_flatpak_apps "$selected_apps"
                ;;
            "Apps recomendados")
                selected_apps=$(ask_recommended_apps)
                install_flatpak_apps "$selected_apps"
                ;;
            "EmuDeck") install_emudeck ;;
            "CryoUtilities") install_cryoutilities ;;
            "Spotify com Spicetify e Marketplace") setup_spotify_spicetify ;;
            "Stremio mais torrentio") setup_stremio ;;
            "Todos os itens acima")
                install_steamos_btrfs
                selected_apps=$(ask_essential_apps)
                install_flatpak_apps "$selected_apps"
                selected_apps=$(ask_recommended_apps)
                install_flatpak_apps "$selected_apps"
                install_emudeck
                install_cryoutilities
                setup_spotify_spicetify
                setup_stremio
                ;;
            *) zenity --error --text="Opção inválida: $choice" ;;
        esac
    done

sleep 5
    show_notification "Instalações concluídas. Aproveite!"
}

main
