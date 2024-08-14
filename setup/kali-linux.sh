#!/bin/bash

# This script sets up a Kali Linux environment for AIS3 Junior 2024 Classes
# with specific user configurations, permissions, and challenges.

set -e # Exit immediately if a command exits with a non-zero status.

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to install packages
install_packages() {
    log "Installing packages: $*"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# Update and upgrade the system
log "Updating and upgrading the system..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get autoremove -y

# Install basic tools
install_packages vim git curl wget burpsuite whois nmap sqlmap dirb dirsearch gobuster hashcat hydra

# Install Visual Studio Code
log "Installing Visual Studio Code..."
if $(dpkg --print-architecture | grep -q "arm"); then
    log "Install Arm version of Visual Studio Code"
    VSCODE_URL="https://update.code.visualstudio.com/1.92.1/linux-deb-arm64/stable"
else
    log "Install x64 version of Visual Studio Code"
    VSCODE_URL="https://update.code.visualstudio.com/1.92.1/linux-deb-x64/stable"
fi
curl -L "$VSCODE_URL" -o vscode.deb
sudo dpkg -i vscode.deb
rm vscode.deb

# Setup users
setup_user() {
    local username="$1"
    local password="$2"
    local is_sudo="$3"

    log "Setting up $username user..."
    if ! id "$username" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$username"
    fi
    echo "$username:$password" | sudo chpasswd
    if [ "$is_sudo" = true ]; then
        sudo usermod -aG sudo "$username"
    fi
}

setup_user "kali" "kali" true
setup_user "ais3" "ais3" false

# Create challenge directories and files
create_challenge_files() {
    local base_dir="/home/ais3/challenge"
    sudo -u ais3 mkdir -p "$base_dir/here_you_go"

    echo "This is a README file for AIS3 Junior 2024 Classes. You get the flag AIS3_Junior{CAT_is_VERY_powerful}" | sudo -u ais3 tee "$base_dir/README" >/dev/null
    echo "AIS3_Junior{CD_is_VERY_useful}" | sudo -u ais3 tee "$base_dir/here_you_go/flag" >/dev/null
    echo "AIS3_Junior{ls-al_is_ALL_YoU_nEEd~}" | sudo -u ais3 tee "$base_dir/here_you_go/.flag" >/dev/null
    echo "ls is a good command. But sometimes you need to find the flag in a hidden file. Try to find the flag in this directory." | sudo -u ais3 tee "$base_dir/here_you_go/README" >/dev/null
}

create_challenge_files

# Setup example files and logs
log "Setting up example files and logs..."
echo "AIS3_Junior{Secret_is_Not_that_Secret_HA}" | sudo -u kali tee /home/kali/secret.txt >/dev/null
echo 'echo "Hello AIS3, AIS3_Junior{Job_Works_PerfecT}"' | sudo -u kali tee /home/kali/welcome.sh >/dev/null
sudo -u kali chmod +x /home/kali/welcome.sh

# Create example logs
sudo bash -c 'echo "$(date) : kali logged in" >> /var/log/auth.log'
sudo bash -c 'echo "$(date) : ais3 failed login attempt" >> /var/log/auth.log'

# Setup cron job
echo "*/5 * * * * /home/kali/welcome.sh" | sudo -u kali crontab -

# Set ais3 as default login user
sudo sed -i 's/^autologin-user=.*/autologin-user=ais3/' /etc/lightdm/lightdm.conf

# Create additional challenge files
KALI_PASS_MD5=$(echo -n "kali" | md5sum | awk '{print $1}')
echo "$KALI_PASS_MD5" | sudo tee /home/ais3/.hidden_password >/dev/null
sudo chmod 600 /home/ais3/.hidden_password

sudo -u kali mkdir -p /home/kali/.s/.e/.c/.r/.e/.t
echo "AIS3_Junior{FIND_ME_IF_YOU_CAN}" | sudo -u kali tee /home/kali/.s/.e/.c/.r/.e/.t/.secret_flag >/dev/null
echo "Hint: Use find command to search for files with names containing secret in kali home directory" | sudo -u kali tee /home/kali/find_challenge.txt >/dev/null

echo "AIS3_Junior{ROOT_POWER_ACTIVATED}" | sudo tee /root/.root_flag >/dev/null
sudo chmod 600 /root/.root_flag

sudo -u ais3 mkdir -p /home/ais3/challenge/where/am/i/now
echo "AIS3_Junior{YOU_KNOW_WHERE_YOU_ARE}" | sudo -u ais3 tee /home/ais3/challenge/where/am/i/now/pwd_flag >/dev/null

# Create challenge description file
cat <<EOF | sudo tee /home/ais3/CHALLENGES.txt >/dev/null
歡迎來到 AIS3 Junior 2024 Linux 挑戰！

1. kali 使用者的密碼已經被藏在你的家目錄下。試著找出這個文件並嘗試找出密碼！

2. kali 使用者的家目錄下藏了一個秘密旗幟。使用 find 命令來尋找它。提示在 find_challenge.txt 文件中。

3. 系統中有一個只有 root 才能讀取的旗幟。你需要想辦法提升權限來讀取它。

4. 進入 challenge 目錄，並找出你的確切位置來獲得旗幟。

5. 系統中設置了一個定時任務，每5分鐘執行一次。試著找出這個任務並獲得旗幟。

祝你好運！記得使用你學到的 Linux 命令來解決這些挑戰。
EOF

sudo chmod 644 /home/ais3/CHALLENGES.txt

log "Setup completed successfully!"
