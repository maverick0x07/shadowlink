#!/bin/bash

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
GOLD=$(tput setaf 3)
NC=$(tput sgr0)

UUID=""
XUI_DB="/etc/3x-ui/x-ui.db"
XUI_JSON="/opt/shadowlink/3x-ui.json"
SQLITE_BIN="/opt/shadowlink/sqlite3/sqlite3"
TUNNEL_JSON="/opt/shadowlink/xray-core/tunnel_server.json"
IPV4=$(hostname -I | awk '{print $1}')

check_root_user() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as ${RED}root!${NC}"
    exit 1
  fi
}

shadowlink_check() {
    if systemctl list-units --full -all | grep -q "shadowlink.service"; then
        return 1
    fi
    return 0
}

extract_files() {
    if [ ! -d "/opt/shadowlink" ]; then
        mkdir -p /opt/shadowlink || { echo -e "${RED}Failed to create /opt/shadowlink directory!${NC}"; exit 1; }
    fi

    if [ ! -d "/etc/3x-ui" ]; then
        mkdir -p /etc/3x-ui || { echo -e "${RED}Failed to create /etc/3x-ui directory!${NC}"; exit 1; }
    fi

    CPU_ARCH=$(uname -m)
    case $CPU_ARCH in
        "x86_64")
            tar -xzf assets/3x-ui-amd64.tar.gz -C /opt/shadowlink
            tar -xzf assets/xray-core-amd64.tar.gz -C /opt/shadowlink
            tar -xzf assets/sqlite3-amd64.tar.gz -C /opt/shadowlink
			cp -f assets/x-ui.db.sample /etc/3x-ui/x-ui.db
			cp -f assets/3x-ui.json.sample /opt/shadowlink/3x-ui.json
			cp -f assets/tunnel_server.json.sample /opt/shadowlink/xray-core/tunnel_server.json
			cp -f assets/shadowlink_service.sh /opt/shadowlink/shadowlink_service.sh
			chmod -R +x /opt/shadowlink
			
            ;;
        "aarch64")
			tar -xzf assets/3x-ui-arm64.tar.gz -C /opt/shadowlink
            tar -xzf assets/xray-core-arm64.tar.gz -C /opt/shadowlink
            tar -xzf assets/sqlite3-arm64.tar.gz -C /opt/shadowlink
			cp -f assets/x-ui.db.sample /etc/3x-ui/x-ui.db
			cp -f assets/3x-ui.json.sample /opt/shadowlink/3x-ui.json
			cp -f assets/tunnel_server.json.sample /opt/shadowlink/xray-core/tunnel_server.json
			cp -f assets/shadowlink_service.sh /opt/shadowlink/shadowlink_service.sh
			chmod -R +x /opt/shadowlink
			
            ;;
        *)
            echo "${RED}Unsupported CPU architecture: $CPU_ARCH${NC}"
            exit 1
            ;;
    esac
}

db_update() {
    
    # Read the JSON file into a variable
    JSON_CONTENT=$(cat "$XUI_JSON" | tr -d "'") # Remove single quotes to prevent SQL issues

    # Check if xrayTemplateConfig exists
    KEY_EXISTS=$($SQLITE_BIN "$XUI_DB" "SELECT COUNT(*) FROM settings WHERE key='xrayTemplateConfig';")

    if [ "$KEY_EXISTS" -eq 0 ]; then
        # Insert if it does not exist
        $SQLITE_BIN "$XUI_DB" "INSERT INTO settings (key, value) VALUES ('xrayTemplateConfig', '$JSON_CONTENT');"
    else
        # Update if it exists
        $SQLITE_BIN "$XUI_DB" "UPDATE settings SET value='$JSON_CONTENT' WHERE key='xrayTemplateConfig';"
    fi
}

shadowlink_service() {
    cat <<EOL > /etc/systemd/system/shadowlink.service
[Unit]
Description=Shadowlink Service (3x-ui + Xray-Core)
After=network.target

[Service]
ExecStart=/opt/shadowlink/shadowlink_service.sh
WorkingDirectory=/opt/shadowlink
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

    if [ $? -ne 0 ]; then
        echo "${RED}Failed to create shadowlink.service!${NC}"
        exit 1
    fi

    systemctl daemon-reload || { echo "${RED}Failed to reload systemd daemon!${NC}"; exit 1; }

    systemctl enable shadowlink.service || { echo "${RED}Failed to enable shadowlink service!${NC}"; exit 1; }
}

shadowlink_remover() {
    systemctl stop shadowlink.service
    systemctl disable shadowlink.service
    rm /etc/systemd/system/shadowlink.service
    systemctl daemon-reload
    rm -r /opt/shadowlink
    rm -r /etc/3x-ui

}
uuid_setup() {
  UUID=$( /opt/shadowlink/xray-core/xray uuid )

  sed -i "s/\"uuid\"/\"$UUID\"/g" "$TUNNEL_JSON"
  sed -i "s/\"uuid\"/\"$UUID\"/g" "$XUI_JSON"

}

check_root_user
clear
echo
echo
echo "${RED}   ▄▄▄▄▄    ▄  █ ██   ██▄   ████▄   ▄ ▄   █    ▄█    ▄   █  █▀ "
echo "  █     ▀▄ █   █ █ █  █  █  █   █  █   █  █    ██     █  █▄█   "
echo "▄  ▀▀▀▀▄   ██▀▀█ █▄▄█ █   █ █   █ █ ▄   █ █    ██ ██   █ █▀▄   "
echo " ▀▄▄▄▄▀    █   █ █  █ █  █  ▀████ █  █  █ ███▄ ▐█ █ █  █ █  █   "
echo "              █     █ ███▀         █ █ █      ▀ ▐ █  █ █   █   "
echo "             ▀     █                ▀ ▀           █   ██  ▀    "
echo "                  ▀                                            ${NC}"
echo
echo
echo "Please choose an option:"
echo
echo "1. ${GOLD}Setup${NC}"
echo "2. ${GOLD}Reset Setup${NC}"
echo "3. ${GOLD}Uninstall${NC}"
echo
while true; do
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            shadowlink_check
            if [ $? -eq 1 ]; then
				echo "${RED}Shadowlink${NC} is already installed on this system. You can choose Reset or Uninstall."
                continue
            fi
			echo
			echo "Extracting Assets..."
            extract_files
			echo "${GREEN}DONE!${NC}"
			echo "Generating new UUID..."
			uuid_setup
			echo "${GREEN}DONE!${NC}"
			echo "Updating DB file with the new UUID..."
			db_update
			echo "${GREEN}DONE!${NC}"
			echo "Creating new systemd service..."
			shadowlink_service
			echo "${GREEN}DONE!${NC}"
			echo "Starting ${RED}Shadowlink${NC}..."
			systemctl restart shadowlink.service
			echo "${GREEN}DONE!${NC}"
			echo
			echo "${GOLD}Panel Info${NC}:"
			echo "${GREEN}Address${NC}: http://$IPV4:7092/shadowlink"
			echo "${GREEN}Username${NC}: shadowlink"
			echo "${GREEN}Password${NC}: shadowlink021"
			echo 
			echo "${RED}Important Note: Please change the username, password, port, and web path for a safer approach${NC}" 
            echo 
			echo "Please save the ${RED}UUID${NC} and pass it to the client (PC with the ${GOLD}STARLINK${NC}):"
			echo "${RED}UUID${NC}= ${GREEN}$UUID${NC}"
			echo
            break
            ;;
        2)
			shadowlink_check
			if [ $? -eq 0 ]; then
				echo "${RED}Shadowlink${NC} is not installed!"
				continue
				echo
			else
				read -p "This will remove ${RED}Shadowlink${NC} and its associated files (DB included)? (y/n): " confirm
				if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
					shadowlink_remover
					echo
					echo "Extracting Assets..."
					extract_files
					echo "${GREEN}DONE!${NC}"
					echo "Generating new UUID..."
					uuid_setup
					echo "${GREEN}DONE!${NC}"
					echo "Updating DB file with the new UUID..."
					db_update
					echo "${GREEN}DONE!${NC}"
					echo "Creating new systemd service..."
					shadowlink_service
					echo "${GREEN}DONE!${NC}"
					echo "Starting ${RED}Shadowlink${NC}..."
					systemctl restart shadowlink.service
					echo "${GREEN}DONE!${NC}"
					echo
					echo "${GOLD}Panel Info${NC}:"
					echo "${GREEN}Address${NC}: http://$IPV4:7092/shadowlink"
					echo "${GREEN}Username${NC}: shadowlink"
					echo "${GREEN}Password${NC}: shadowlink021"
					echo 
					echo "${RED}Important Note: Please change the username, password, port, and web path for a safer approach${NC}" 
					echo 
					echo "Please save the ${RED}UUID${NC} and pass it to the client (PC with the ${GOLD}STARLINK${NC}):"
					echo "${RED}UUID${NC}= ${GREEN}$UUID${NC}"
					echo
					break
				else
					echo
					echo "${GREEN}Aborted!${NC} ${RED}Shadowlink${NC} has not been removed."
					echo
				fi
			fi
			break
			;;
        3)
			shadowlink_check
			if [ $? -eq 0 ]; then
				echo "${RED}Shadowlink${NC} is not installed!"
				continue
				echo
			else
				read -p "Are you sure you want to remove ${RED}Shadowlink${NC} and its associated files (DB included)? (y/n): " confirm
				if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
					shadowlink_remover
					echo
					echo "${RED}Shadowlink${NC} has been ${RED}REMOVED!${NC}"
					echo
				else
					echo
					echo "${GREEN}Aborted!${NC} ${RED}Shadowlink${NC} has not been removed."
					echo
				fi
			fi
			break
			;;
        *)
            echo "Invalid option. Please enter a number between 1 and 3."
            ;;
    esac
done
