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
	echo -e "${BOLD}▶ CONFIGURATION: $1${NC}"
	echo -e "${BLUE}==================================================${NC}"
	read -p "Do you want to execute this section? (y/n): " choice
	case "$choice" in
	[yY][eE][sS] | [yY]) return 0 ;;
	*) return 1 ;;
	esac
}

# ==========================================
# GATHER USER CONFIGURATION FIRST
# ==========================================
echo -e "${BOLD}${GREEN}==================================================${NC}"
echo -e "${BOLD}          VPS SETUP CONFIGURATION PHASE           ${NC}"
echo -e "${BOLD}${GREEN}==================================================${NC}"

DO_UPDATE=false
if ask_section "System Update & Upgrade"; then
	DO_UPDATE=true
fi

DO_CREATE_USER=false
TARGET_USER="user1"
if ask_section "Create New System User"; then
	DO_CREATE_USER=true
	read -p "Enter the username you want to create [default: user1]: " custom_user
	TARGET_USER=${custom_user:-user1}
fi

DO_DESKTOP=false
if ask_section "Desktop Environment (XFCE4) & Remote Desktop (XRDP)"; then
	DO_DESKTOP=true
fi

DO_BROWSERS=false
BROWSER_CHOICES=""
if ask_section "Software Installation (Browsers)"; then
	DO_BROWSERS=true
	echo -e "\nWhich browsers would you like to install?"
	echo -e "Enter numbers separated by spaces (e.g., ${GREEN}1 3 4${NC}):"
	echo "1) Google Chrome"
	echo "2) Microsoft Edge"
	echo "3) Chromium"
	echo "4) Brave Browser"
	echo "5) Skip/None"

	read -p "Your selection: " BROWSER_CHOICES
fi

DO_ZIP=false
if ask_section "Zip Utilities (Thunar Archive Plugin)"; then
	DO_ZIP=true
fi

DO_REBOOT=false
echo -e "\n${BOLD}${BLUE}==================================================${NC}"
echo -e "${BOLD}▶ CONFIGURATION: System Reboot${NC}"
echo -e "${BLUE}==================================================${NC}"
read -p "Would you like to reboot the VPS automatically after setup is complete? (y/n): " choice
case "$choice" in
[yY][eE][sS] | [yY]) DO_REBOOT=true ;;
*) DO_REBOOT=false ;;
esac

# ==========================================
# EXECUTION PHASE
# ==========================================
echo -e "\n${BOLD}${GREEN}==================================================${NC}"
echo -e "${BOLD}          STARTING AUTOMATED SETUP PHASE          ${NC}"
echo -e "${BOLD}${GREEN}==================================================${NC}"

# ==========================================
# 1. System Update & Upgrade
# ==========================================
echo -e "\n${BOLD}▶ RUNNING SECTION: System Update & Upgrade${NC}"
if [ "$DO_UPDATE" = true ]; then
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
echo -e "\n${BOLD}▶ RUNNING SECTION: Create New System User${NC}"
if [ "$DO_CREATE_USER" = true ]; then
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
echo -e "\n${BOLD}▶ RUNNING SECTION: Desktop Environment (XFCE4) & Remote Desktop (XRDP)${NC}"
if [ "$DO_DESKTOP" = true ]; then
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
# 4. Software Section (Browser Multi-Selection)
# ==========================================
echo -e "\n${BOLD}▶ RUNNING SECTION: Software Installation (Browsers)${NC}"
if [ "$DO_BROWSERS" = true ]; then
	browser_selected=false

	for choice in $BROWSER_CHOICES; do
		case $choice in
		1)
			echo -e "${YELLOW}[RUNNING] Installing Google Chrome...${NC}"
			wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
			if sudo apt install ./google-chrome-stable_current_amd64.deb -y; then
				log_status "  - Google Chrome" "COMPLETED"
			else
				log_status "  - Google Chrome" "FAILED"
			fi
			rm -f ./google-chrome-stable_current_amd64.deb
			browser_selected=true
			;;
		2)
			echo -e "${YELLOW}[RUNNING] Installing Microsoft Edge...${NC}"
			wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
			echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
			sudo apt update
			if sudo apt install microsoft-edge-stable -y; then
				log_status "  - Microsoft Edge" "COMPLETED"
			else
				log_status "  - Microsoft Edge" "FAILED"
			fi
			browser_selected=true
			;;
		3)
			echo -e "${YELLOW}[RUNNING] Installing Chromium...${NC}"
			if sudo apt install chromium-browser -y; then
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
# 5. Zip & Utilities
# ==========================================
echo -e "\n${BOLD}▶ RUNNING SECTION: Zip Utilities (Thunar Archive Plugin)${NC}"
if [ "$DO_ZIP" = true ]; then
	echo -e "${YELLOW}[RUNNING] Installing Archive Utilities...${NC}"
	if sudo apt update && sudo apt install thunar-archive-plugin -y; then
		log_status "Zip Utilities" "COMPLETED"
	else
		log_status "Zip Utilities" "FAILED"
	fi
else
	log_status "Zip Utilities" "SKIPPED"
fi

# ==========================================
# 6. Final Summary Report
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
# 7. System Reboot
# ==========================================
if [ "$DO_REBOOT" = true ]; then
	echo -e "${GREEN}Rebooting VPS now...${NC}"
	sudo reboot
else
	echo -e "${YELLOW}Reboot skipped. Please manually reboot later if needed to finalize updates.${NC}"
fi
