#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

CHECKMARK="✅"
ERROR="❌"
PROGRESS="⏳"
INSTALL="🛠️"
STOP="⏹️"
RESTART="🔄"
LOGS="📄"
EXIT="🚪"
INFO="ℹ️"

# ----------------------------
# Function to display ASCII logo and Telegram link
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}    ____  __ __    _   ______  ____  ___________${RESET}"
    echo -e "    ${GREEN}   / __ \\/ //_/   / | / / __ \\/ __ \\/ ____/ ___/${RESET}"
    echo -e "    ${BLUE}  / / / / ,<     /  |/ / / / / / / / __/  \\__ \\ ${RESET}"
    echo -e "    ${YELLOW} / /_/ / /| |   / /|  / /_/ / /_/ / /___ ___/ / ${RESET}"
    echo -e "    ${MAGENTA}/_____/_/ |_|  /_/ |_/\____/_____/_____//____/  ${RESET}"
    echo -e "    ${MAGENTA}🚀 Follow us on Telegram: https://t.me/dknodes${RESET}"
    echo -e "    ${MAGENTA}📢 Follow us on Twitter: https://x.com/dknodes${RESET}"
    echo -e ""
    echo -e "    ${GREEN}Welcome to the Nexus Node Installation Wizard!${RESET}"
    echo -e ""
}

# ----------------------------
# Install Docker and Docker Compose
# ----------------------------
install_docker() {
    echo -e "${INSTALL} Installing Docker and Docker Compose...${RESET}"
    sudo apt update && sudo apt upgrade -y
    if ! command -v docker &> /dev/null; then
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    echo -e "${CHECKMARK} Docker and Docker Compose installed successfully.${RESET}"
}

# ----------------------------
# Install the Nexus Node
# ----------------------------
install_node() {
    echo -e "${INSTALL} Installing Nexus Node...${RESET}"
    install_docker
    
    read -p "Do you want to import an existing Prover ID? (y/n): " import_choice
    if [[ "$import_choice" == "y" || "$import_choice" == "Y" ]]; then
        mkdir -p "./nexus-data"
        read -p "Enter your PROVER ID: " PROVER_ID
        echo "$PROVER_ID" > "./nexus-data/prover-id"
        echo -e "${CHECKMARK} Prover ID saved in ./nexus-data/prover-id.${RESET}"
    else
        echo -e "${INFO} New Prover ID created.${RESET}"
    fi

    if [ ! -f docker-compose.yml ]; then
        echo -e "${ERROR} docker-compose.yml file not found. Please make sure it is in the current directory.${RESET}"
        exit 1
    fi

    docker-compose up -d
    echo -e "${CHECKMARK} Nexus Node installed and running.${RESET}"
    read -p "Press enter to return to the main menu..."
}

# ----------------------------
# Display the Prover ID
# ----------------------------
display_prover_id() {
    echo -e "${INFO} Displaying Prover ID...${RESET}"
    if [ -f "./nexus-data/prover-id" ]; then
        PROVER_ID=$(cat "./nexus-data/prover-id")
        echo -e "${GREEN}ℹ️  Prover ID: ${CYAN}$PROVER_ID${RESET}"
    else
        echo -e "${ERROR} Prover ID file not found at ./nexus-data/prover-id.${RESET}"
    fi
    read -p "Press enter to return to the main menu..."
}

# ----------------------------
# Stop the Nexus Node
# ----------------------------
stop_node() {
    echo -e "${STOP} Stopping Nexus Node...${RESET}"
    docker-compose down
    echo -e "${CHECKMARK} Nexus Node stopped.${RESET}"
    read -p "Press enter to return to the main menu..."
}

# ----------------------------
# Restart the Nexus Node
# ----------------------------
restart_node() {
    echo -e "${RESTART} Restarting Nexus Node...${RESET}"
    docker-compose down
    docker-compose up -d
    echo -e "${CHECKMARK} Nexus Node restarted successfully.${RESET}"
    read -p "Press enter to return to the main menu..."
}

# ----------------------------
# View Nexus Node Logs
# ----------------------------
view_logs() {
    echo -e "${LOGS} Streaming logs in real-time... Press Ctrl+C to stop.${RESET}"
    docker-compose logs -f
    read -p "Press enter to return to the main menu..."
}

# ----------------------------
# Draw Menu Borders
# ----------------------------
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    display_ascii
    draw_top_border
    echo -e "    ${YELLOW}Choose an option:${RESET}"
    draw_middle_border
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install Nexus Node"
    echo -e "    ${CYAN}2.${RESET} ${INFO} View Prover ID"
    echo -e "    ${CYAN}3.${RESET} ${STOP} Stop Nexus Node"
    echo -e "    ${CYAN}4.${RESET} ${RESTART} Restart Nexus Node"
    echo -e "    ${CYAN}5.${RESET} ${LOGS} View Nexus Node Logs"
    echo -e "    ${CYAN}6.${RESET} ${EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter your choice [1-6]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1)
            install_node
            ;;
        2)
            display_prover_id
            ;;
        3)
            stop_node
            ;;
        4)
            restart_node
            ;;
        5)
            view_logs
            ;;
        6)
            echo -e "${EXIT} Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press enter to continue..."
            ;;
    esac
done
