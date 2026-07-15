#!/bin/bash

# ==========================================
# Color Schemes for UI Feedback
# ==========================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Arrays to keep track of section statuses
SECTION_NAMES=()
SECTION_STATUSES=()

# Helper function to log final status
log_status() {
	SECTION_NAMES+=("$1")
	SECTION_STATUSES+=("$2")
}

# Helper function to prompt user for Execution/Skip
ask_section() {
	echo -e "\n${BOLD}${BLUE}==================================================${NC}"
	echo -e "${BOLD}▶ SECTION: $1${NC}"
	echo -e "${BLUE}==================================================${NC}"
	read -p "Do you want to execute this section? (y/n): " choice
	case "$choice" in
	[yY][eE][sS] | [yY]) return 0 ;;
	*) return 1 ;;
	esac
}

# Helper function to create an optimized browser launcher and desktop shortcut
create_browser_launcher() {
	local b_name="$1"
	local b_exec="$2"
	local b_disp="$3"
	local b_icon="$4"

	echo -e "${YELLOW}[RUNNING] Creating optimized launcher for ${b_disp}...${NC}"

	# Wrapper script
	cat <<EOF | sudo tee /usr/local/bin/${b_name}-launcher >/dev/null
#!/bin/bash
taskset -c 0-3 ${b_exec} --no-sandbox --disable-gpu --disable-dev-shm-usage --renderer-process-limit=2 "\$@"
EOF
	sudo chmod +x /usr/local/bin/${b_name}-launcher

	# Desktop shortcut
	sudo mkdir -p /home/"$TARGET_USER"/Desktop
	cat <<EOF | sudo tee /home/"$TARGET_USER"/Desktop/${b_name}.desktop >/dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=${b_disp} (Optimized)
Exec=/usr/local/bin/${b_name}-launcher
Icon=${b_icon}
Terminal=false
StartupNotify=true
EOF
	sudo chmod +x /home/"$TARGET_USER"/Desktop/${b_name}.desktop
	sudo chown "$TARGET_USER":"$TARGET_USER" /home/"$TARGET_USER"/Desktop/${b_name}.desktop
}

# Default Target User (will update if Section 2 runs)
TARGET_USER="user1"

# ==========================================
# 1. System Update & Upgrade
# ==========================================
if ask_section "System Update & Upgrade"; then
	echo -e "${YELLOW}[RUNNING] Updating and upgrading system packages...${NC}"
	if sudo apt update && sudo apt upgrade -y; then
		log_status "System Update & Upgrade" "COMPLETED"
	else
		log_status "System Update & Upgrade" "FAILED"
	fi
else
	log_status "System Update & Upgrade" "SKIPPED"
fi

# ==========================================
# 2. Create User
# ==========================================
if ask_section "Create New System User"; then
	read -p "Enter the username you want to create [default: user1]: " custom_user
	TARGET_USER=${custom_user:-user1}

	echo -e "${YELLOW}[RUNNING] Creating user '$TARGET_USER'...${NC}"
	if sudo adduser --gecos "" "$TARGET_USER"; then
		sudo usermod -aG sudo "$TARGET_USER"
		log_status "Create User ($TARGET_USER)" "COMPLETED"
	else
		log_status "Create User ($TARGET_USER)" "FAILED"
	fi
else
	log_status "Create User ($TARGET_USER)" "SKIPPED"
fi

# ==========================================
# 3. Desktop Environment & XRDP
# ==========================================
if ask_section "Desktop Environment (XFCE4) & Remote Desktop (XRDP)"; then
	echo -e "${YELLOW}[RUNNING] Installing XFCE4 and XRDP...${NC}"
	if sudo apt install xfce4 xrdp -y; then
		sudo systemctl enable xrdp
		sudo systemctl start xrdp

		# Configure the environment session for the created user
		echo "startxfce4" | sudo tee /home/"$TARGET_USER"/.xsession
		sudo chown "$TARGET_USER":"$TARGET_USER" /home/"$TARGET_USER"/.xsession

		sudo systemctl restart xrdp
		log_status "XFCE4 & XRDP Setup" "COMPLETED"
	else
		log_status "XFCE4 & XRDP Setup" "FAILED"
	fi
else
	log_status "XFCE4 & XRDP Setup" "SKIPPED"
fi

# ==========================================
# 4. System Settings Change
# ==========================================
if ask_section "System Settings Change (TasksMax Limit)"; then
	echo -e "${YELLOW}[RUNNING] Applying systemd TasksMax fix...${NC}"

	sudo systemctl set-property user-1000.slice TasksMax=infinity 2>/dev/null || true
	sudo mkdir -p /etc/systemd/system/user-.slice.d

	if cat <<EOF | sudo tee /etc/systemd/system/user-.slice.d/override.conf >/dev/null; then
[Slice]
TasksMax=infinity
EOF
		sudo systemctl daemon-reload
		log_status "System Settings (TasksMax)" "COMPLETED"
	else
		log_status "System Settings (TasksMax)" "FAILED"
	fi
else
	log_status "System Settings (TasksMax)" "SKIPPED"
fi

# ==========================================
# 5. Software Section (Browser Multi-Selection)
# ==========================================
if ask_section "Software Installation (Browsers)"; then
	echo -e "\nWhich browsers would you like to install?"
	echo -e "Enter numbers separated by spaces (e.g., ${GREEN}1 3 4${NC}):"
	echo "1) Google Chrome"
	echo "2) Microsoft Edge"
	echo "3) Chromium"
	echo "4) Brave Browser"
	echo "5) Skip/None"

	read -p "Your selection: " choices

	browser_selected=false

	for choice in $choices; do
		case $choice in
		1)
			echo -e "${YELLOW}[RUNNING] Installing Google Chrome...${NC}"
			wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
			if sudo apt install ./google-chrome-stable_current_amd64.deb -y; then
				create_browser_launcher "google-chrome" "/usr/bin/google-chrome" "Google Chrome" "google-chrome"
				log_status "  - Google Chrome" "COMPLETED"
			else
				log_status "  - Google Chrome" "FAILED"
			fi
			rm ./google-chrome-stable_current_amd64.deb
			browser_selected=true
			;;
		2)
			echo -e "${YELLOW}[RUNNING] Installing Microsoft Edge...${NC}"
			wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
			echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
			sudo apt update
			if sudo apt install microsoft-edge-stable -y; then
				create_browser_launcher "microsoft-edge" "/usr/bin/microsoft-edge" "Microsoft Edge" "microsoft-edge"
				log_status "  - Microsoft Edge" "COMPLETED"
			else
				log_status "  - Microsoft Edge" "FAILED"
			fi
			browser_selected=true
			;;
		3)
			echo -e "${YELLOW}[RUNNING] Installing Chromium...${NC}"
			if sudo apt install chromium-browser -y; then
				create_browser_launcher "chromium" "/usr/bin/chromium-browser" "Chromium" "chromium-browser"
				log_status "  - Chromium" "COMPLETED"
			else
				log_status "  - Chromium" "FAILED"
			fi
			browser_selected=true
			;;
		4)
			echo -e "${YELLOW}[RUNNING] Installing Brave Browser...${NC}"
			sudo apt install curl -y
			sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
			sudo apt update
			if sudo apt install brave-browser -y; then
				create_browser_launcher "brave-browser" "/usr/bin/brave-browser" "Brave Browser" "brave-browser"
				log_status "  - Brave Browser" "COMPLETED"
			else
				log_status "  - Brave Browser" "FAILED"
			fi
			browser_selected=true
			;;
		5)
			break
			;;
		*)
			echo -e "${RED}[INVALID CHOICE]: $choice${NC}"
			;;
		esac
	done

	if [ "$browser_selected" = true ]; then
		log_status "Browsers Deployment" "COMPLETED"
	else
		log_status "Browsers Deployment" "SKIPPED/NO SELECTION"
	fi
else
	log_status "Browsers Deployment" "SKIPPED"
fi

# ==========================================
# 6. Zip & Utilities
# ==========================================
if ask_section "Zip & Utilities Installation"; then
	echo -e "\nWhich utilities would you like to install?"
	echo -e "Enter numbers separated by spaces (e.g., ${GREEN}1 2${NC}):"
	echo "1) Thunar Archive Plugin (Zip Utilities)"
	echo "2) Terminator (Terminal Emulator)"
	echo "3) Skip/None"

	read -p "Your selection: " utility_choices

	utility_selected=false

	for choice in $utility_choices; do
		case $choice in
		1)
			echo -e "${YELLOW}[RUNNING] Installing Archive Utilities (Thunar Archive Plugin)...${NC}"
			if sudo apt update && sudo apt install thunar-archive-plugin -y; then
				log_status "  - Thunar Archive Plugin" "COMPLETED"
			else
				log_status "  - Thunar Archive Plugin" "FAILED"
			fi
			utility_selected=true
			;;
		2)
			echo -e "${YELLOW}[RUNNING] Installing Terminator...${NC}"
			if sudo apt update && sudo apt install terminator -y; then
				log_status "  - Terminator" "COMPLETED"
			else
				log_status "  - Terminator" "FAILED"
			fi
			utility_selected=true
			;;
		3)
			break
			;;
		*)
			echo -e "${RED}[INVALID CHOICE]: $choice${NC}"
			;;
		esac
	done

	if [ "$utility_selected" = true ]; then
		log_status "Zip & Utilities Deployment" "COMPLETED"
	else
		log_status "Zip & Utilities Deployment" "SKIPPED/NO SELECTION"
	fi
else
	log_status "Zip & Utilities Deployment" "SKIPPED"
fi

# ==========================================
# 7. Final Summary Report
# ==========================================
echo -e "\n${BOLD}${GREEN}==================================================${NC}"
echo -e "${BOLD}          FINAL VPS SETUP SUMMARY STATUS          ${NC}"
echo -e "${BOLD}${GREEN}==================================================${NC}"

for i in "${!SECTION_NAMES[@]}"; do
	NAME="${SECTION_NAMES[$i]}"
	STATUS="${SECTION_STATUSES[$i]}"

	case "$STATUS" in
	"COMPLETED")
		echo -e " ✅ $NAME : ${GREEN}${BOLD}$STATUS${NC}"
		;;
	"SKIPPED" | "SKIPPED/NO SELECTION")
		echo -e " 🟡 $NAME : ${YELLOW}$STATUS${NC}"
		;;
	"FAILED")
		echo -e " ❌ $NAME : ${RED}${BOLD}$STATUS${NC}"
		;;
	esac
done
echo -e "${BOLD}${GREEN}==================================================${NC}\n"

# ==========================================
# 8. System Reboot Prompt
# ==========================================
read -p "Setup finished. Would you like to reboot the VPS now? (y/n): " reboot_choice
case "$reboot_choice" in
[yY][eE][sS] | [yY])
	echo -e "${GREEN}Rebooting VPS now...${NC}"
	sudo reboot
	;;
*)
	echo -e "${YELLOW}Reboot skipped. Please manually reboot later if needed to finalize updates.${NC}"
	;;
esac
