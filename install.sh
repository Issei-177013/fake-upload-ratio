#!/bin/bash

# Function to delete and replace cron job
delete_and_replace_cron_job() {
  local cron_job_name="@reboot /bin/bash $script_dir/install.sh"
  sudo crontab -l | grep -v -F "$cron_job_name" | sudo crontab -
  (sudo crontab -l ; echo "$cron_job_name") | sudo crontab -
}

# Function to add a three-minute cron job
add_three_minute_cron_job() {
  local cron_job_name="*/3 * * * * /bin/bash $script_dir/delete_and_replace_cron_job.sh"
  sudo crontab -l | grep -v -F "$cron_job_name" | sudo crontab -
  (sudo crontab -l ; echo "$cron_job_name") | sudo crontab -
}

# Function to setup Apache and files
setup_apache_and_files() {
  echo "Setting up Apache2 and files..."
  
  # Install and configure Apache2
  sudo apt update
  sudo apt install -y apache2

  # Navigate to HTML directory
  cd /var/www/html || exit

  # Create files
  sudo dd if=/dev/zero of=COD.part01.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part02.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part03.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part04.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part05.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part06.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part07.rar bs=100M count=1
  sudo dd if=/dev/zero of=COD.part08.rar bs=100M count=1

  # Set file permissions
  sudo chmod 644 COD.part01.rar
  sudo chmod 644 COD.part02.rar
  sudo chmod 644 COD.part03.rar
  sudo chmod 644 COD.part04.rar
  sudo chmod 644 COD.part05.rar
  sudo chmod 644 COD.part06.rar
  sudo chmod 644 COD.part07.rar
  sudo chmod 644 COD.part08.rar
}

# Determine script directory
script_dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ask user for server location
echo "Please select your server location:"
echo "1. Iran"
echo "2. Kharej"

read -p "Enter your choice (1 or 2): " choice

# Case statement based on user input
case $choice in
  1)
    setup_apache_and_files
    ;;
  2)
    echo "Server location is not Iran. Skipping Apache2 setup."
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Update package list and install necessary packages
sudo apt update
sudo apt install -y python3 python3-pip

# Install Python dependencies
sudo pip3 install requests==2.26.0
sudo pip3 install tqdm==4.66.4

# Check if url.txt exists, create it if not
url_file="$script_dir/url.txt"
if [ ! -f "$url_file" ]; then
    echo "$url_file not found. Creating it..."
    read -p "Enter the IP address: " ip_address
    echo "http://$ip_address/COD.part01.rar" > "$url_file"
    echo "http://$ip_address/COD.part02.rar" >> "$url_file"
    echo "http://$ip_address/COD.part03.rar" >> "$url_file"
    echo "http://$ip_address/COD.part04.rar" >> "$url_file"
    echo "http://$ip_address/COD.part05.rar" >> "$url_file"
    echo "http://$ip_address/COD.part06.rar" >> "$url_file"
    echo "http://$ip_address/COD.part07.rar" >> "$url_file"
    echo "http://$ip_address/COD.part08.rar" >> "$url_file"
    echo "File urls added to $url_file"
fi

# Run Python script
python3 "$script_dir/fake-upload/fakeup.py"

# Set up cron jobs
delete_and_replace_cron_job
add_three_minute_cron_job

echo "Setup and cron jobs configured successfully."
