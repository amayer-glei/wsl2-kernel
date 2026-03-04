#!/bin/bash

# Script to apply Docker, Android Binder, and vidtv compatibility settings to WSL2 kernel config
# Usage: ./patch-wsl2-kernel-config.sh <config-file-path>

set -e

# Check if config file path is provided
if [ $# -eq 0 ]; then
    echo "Error: Config file path is required"
    echo "Usage: $0 <config-file-path>"
    exit 1
fi

CONFIG_FILE="$1"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' does not exist"
    exit 1
fi

# Create a backup of the original config file
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Docker compatibility configs
DOCKER_CONFIGS=(
    "CONFIG_BRIDGE=y"
    "CONFIG_BRIDGE_NETFILTER=y"
    "CONFIG_NFT_COMPAT=y"
    "CONFIG_NETFILTER_XT_NAT=y"
    "CONFIG_NETFILTER_XT_TARGET_MASQUERADE=y"
    "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y"
    "CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y"
    "CONFIG_NETFILTER_XT_MARK=y"
    "CONFIG_IP_NF_IPTABLES=y"
    "CONFIG_IP_NF_FILTER=y"
    "CONFIG_IP_NF_NAT=y"
    "CONFIG_IP_NF_TARGET_MASQUERADE=y"
    "CONFIG_IP_NF_MANGLE=y"
    "CONFIG_IP_VS=y"
    "CONFIG_NETFILTER_XT_MATCH_IPVS=y"
    "CONFIG_XFRM_USER=y"
    "CONFIG_XFRM_ALGO=y"
    "CONFIG_INET_ESP=y"
    "CONFIG_IP_VS_RR=y"
    "CONFIG_NET_CLS_CGROUP=y"
    "CONFIG_IP_NF_TARGET_REDIRECT=y"
    "CONFIG_IPVLAN=y"
    "CONFIG_MACVLAN=y"
    "CONFIG_DUMMY=y"
    "CONFIG_NF_NAT_FTP=y"
    "CONFIG_NF_CONNTRACK_FTP=y"
    "CONFIG_NF_NAT_TFTP=y"
    "CONFIG_NF_CONNTRACK_TFTP=y"
    "CONFIG_BTRFS_FS=y"
)

# Android Binder configs
ANDROID_BINDER_CONFIGS=(
    "CONFIG_ANDROID_BINDER_IPC=y"
    "CONFIG_ANDROID_BINDERFS=y"
    "CONFIG_ANDROID_BINDER_DEVICES=\"binder,hwbinder,vndbinder\""
)

# vidtv (virtual DVB test driver) configs
VIDTV_CONFIGS=(
    "CONFIG_DVB_TEST_DRIVERS=y"
    "CONFIG_DVB_VIDTV=m"
)

# Combine all configs
ALL_CONFIGS=("${DOCKER_CONFIGS[@]}" "${ANDROID_BINDER_CONFIGS[@]}" "${VIDTV_CONFIGS[@]}")

# Create a temporary file for processing
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

# First, remove all existing lines for configs we want to set
# Copy the file and remove matching lines
cp "$CONFIG_FILE" "$TMP_FILE"

for config in "${ALL_CONFIGS[@]}"; do
    config_name="${config%%=*}"
    # Remove lines matching: CONFIG_XXX=anything or # CONFIG_XXX is not set
    # Use different sed syntax for macOS (BSD sed) vs Linux (GNU sed)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS/BSD sed
        sed -i '' "/^# ${config_name} is not set$/d" "$TMP_FILE"
        sed -i '' "/^${config_name}=/d" "$TMP_FILE"
    else
        # Linux/GNU sed
        sed -i "/^# ${config_name} is not set$/d" "$TMP_FILE"
        sed -i "/^${config_name}=/d" "$TMP_FILE"
    fi
done

# Add all the new config lines at the end
for config in "${ALL_CONFIGS[@]}"; do
    echo "$config" >> "$TMP_FILE"
done

# Replace original file with the modified one
mv "$TMP_FILE" "$CONFIG_FILE"

echo "Successfully applied Docker, Android Binder, and vidtv compatibility settings to $CONFIG_FILE"
echo "Applied ${#DOCKER_CONFIGS[@]} Docker compatibility configs"
echo "Applied ${#ANDROID_BINDER_CONFIGS[@]} Android Binder configs"
echo "Applied ${#VIDTV_CONFIGS[@]} vidtv configs"
