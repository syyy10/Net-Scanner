#!/bin/bash

# Colors
BLUE='\033[1;34m'
ORANGE='\033[38;2;255;140;0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# print logo
print_logo() {
    echo -e "${BLUE}  _   _      _     ____                                  "
    echo -e " | \ | | ___| |_  / ___|  ___ ____ ____  ____   ___ ____ "
    echo -e " |  \| |/ _ \ __| \___ \ / __/ _  |  _ \|  _ \ / _ \  __|"
    echo -e " | |\  |  __/ |_   ___) | (_| (_| | | | | | | |  __/ |   "
    echo -e " |_| \_|\___|\__| |____/ \___\____|_| |_|_| |_|\___|_|   ${NC}"
}

# menu function
print_menu() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${ORANGE}   [ NetScanner Control Panel ]${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${ORANGE}1) Scan for open ports${NC}"
    echo -e "${ORANGE}2) Manage firewall${NC}"
    echo -e "${ORANGE}3) Exit${NC}"
    echo -ne "${GREEN}>> ${NC}"
}

# main menu
clear
print_logo

while true; do
    print_menu
    read input

    if [[ -z "${input//[[:space:]]/}" ]]; then
        echo -e "${ORANGE}[!] No input detected${NC}"
        sleep 1
        clear
        print_logo

    elif [[ "$input" == "1" ]]; then
        echo -e "${GREEN}[*] Scanning localhost for open ports...${NC}"
        sleep 0.5

        LOGFILE="logfile.txt"
        echo "==============================================" >> "$LOGFILE"
        echo "Scan started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
        echo "Target: localhost" >> "$LOGFILE"
        echo "==============================================" >> "$LOGFILE"

        # header
        printf "%-8s %-8s %-8s\n" PORT STATE SERVICE | tee -a "$LOGFILE"

        # process output
        nmap -Pn -p- -oG - localhost | awk -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v NC="$NC" -v LOG="$LOGFILE" '
        /Ports:/ {
            split($0,a,"Ports: ");
            n = split(a[2], ports, ", ");
            for (i=1;i<=n;i++) {
                split(ports[i], p, "/");
                port=p[1];
                state=p[2];
                service=p[5];

                if (state == "open") {
                    if (service == "" || service == "-")
                        service="unknown"

                    warning=""
                    if (service == "telnet")
                        warning=" (WARNING: Security risks in telnet)"
                    if (service == "ssh")
                        warning=" (WARNING: Make sure you have a secure password)"

                    common_ports="21 22 23 25 53 67 68 69 80 110 123 143 161 162 194 443 445 465 587 993 995 3306 3389 5900 8080"
                    if (index(" " common_ports " ", " " port " ") > 0)
                        color=GREEN
                    else
                        color=YELLOW

                    # colored output
                    printf color "%-8s %-8s %-8s%s" NC "\n", port, state, service, warning

                    # log plain text
                    printf "%-8s %-8s %-8s%s\n", port, state, service, warning >> LOG
                }
            }
        }'

        echo "Scan finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
        echo "==============================================" >> "$LOGFILE"

        sleep 1
        clear
        print_logo

    elif [[ "$input" == "2" ]]; then
        # ufw submenu
        while true; do
            echo
            echo -e "${GREEN}--- Firewall Control ---${NC}"
            echo -e "${ORANGE}1) Enable firewall${NC}"
            echo -e "${ORANGE}2) Disable firewall${NC}"
            echo -e "${ORANGE}3) Home${NC}"
            echo -ne "${GREEN}>> ${NC}"
            read fw_input

            if [[ -z "${fw_input//[[:space:]]/}" ]]; then
                echo -e "${ORANGE}[!] No input detected${NC}"
                sleep 1
                clear
                print_logo
            elif [[ "$fw_input" == "1" ]]; then
                echo -e "${GREEN}[*] Enabling firewall...${NC}"
                sudo ufw enable
                sleep 1
                clear
                print_logo
                break
            elif [[ "$fw_input" == "2" ]]; then
                echo -e "${GREEN}[*] Disabling firewall...${NC}"
                sudo ufw disable
                sleep 1
                clear
                print_logo
                break
            elif [[ "$fw_input" == "3" ]]; then
                clear
                print_logo
                break
            else
                echo -e "${ORANGE}[!] Invalid option${NC}"
                sleep 1
                clear
                print_logo
            fi
        done

    elif [[ "$input" == "3" ]]; then
        echo -e "${GREEN}[*] Shutting down NetScanner...${NC}"
        sleep 0.5
        break

    else
        echo -e "${ORANGE}[!] Invalid option${NC}"
        sleep 1
        clear
        print_logo
    fi
done
