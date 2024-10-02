#!/bin/bash

# Hardcoded ZeroTier Network ID
ZEROTIER_NETWORK_ID="8286ac0e471e47fd"

# Function to install ZeroTier and join a network on Ubuntu
install_zerotier_ubuntu() {
    echo "Detected Ubuntu. Installing ZeroTier..."

    # Install ZeroTier
    curl -s https://install.zerotier.com | sudo bash

    # Verify installation
    if command -v zerotier-cli &> /dev/null
    then
        echo "ZeroTier installed successfully."
    else
        echo "ZeroTier installation failed."
        exit 1
    fi

    # Join the specified ZeroTier network
    sudo zerotier-cli join $ZEROTIER_NETWORK_ID

    # Verify if joined successfully
    if sudo zerotier-cli listnetworks | grep $ZEROTIER_NETWORK_ID &> /dev/null
    then
        echo "Joined ZeroTier network successfully."
    else
        echo "Failed to join ZeroTier network."
        exit 1
    fi
}

# Function to install ZeroTier and join a network on RedHat-based systems
install_zerotier_redhat() {
    echo "Detected RedHat-based system. Installing ZeroTier..."

    # Install ZeroTier repository and GPG key
    curl -s https://install.zerotier.com/ | sudo bash

    # Install ZeroTier
    sudo yum install -y zerotier-one

    # Verify installation
    if command -v zerotier-cli &> /dev/null
    then
        echo "ZeroTier installed successfully."
    else
        echo "ZeroTier installation failed."
        exit 1
    fi

    # Start and enable the ZeroTier service
    sudo systemctl enable zerotier-one
    sudo systemctl start zerotier-one

    # Join the specified ZeroTier network
    sudo zerotier-cli join $ZEROTIER_NETWORK_ID

    # Verify if joined successfully
    if sudo zerotier-cli listnetworks | grep $ZEROTIER_NETWORK_ID &> /dev/null
    then
        echo "Joined ZeroTier network successfully."
    else
        echo "Failed to join ZeroTier network."
        exit 1
    fi
}

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Detect the OS type
if [ -f /etc/os-release ]; then
    . /etc/os-release

    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_zerotier_ubuntu
    elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" || "$ID" == "ol" || "$ID" == "rocky" ]]; then
        install_zerotier_redhat
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
else
    echo "Cannot detect OS type. Exiting."
    exit 1
fi
