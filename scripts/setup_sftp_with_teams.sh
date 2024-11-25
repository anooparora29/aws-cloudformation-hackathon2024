#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Define variables
GROUP="sftpusers"
BASE_DIR="/home/sftpusers"
ADMIN_USER="admin"
ADMIN_PASSWORD="g$9oqlV1*kSMEPOa" # Replace with a secure password
TEAM_LIST="team_list.txt"
MOUNT_SOURCE="$BASE_DIR/$ADMIN_USER/hackathon2024/input"
SSHD_CONFIG="/etc/ssh/sshd_config"

# Create SFTP group if it doesn't exist
if ! getent group $GROUP > /dev/null; then
    groupadd $GROUP
    echo "Group '$GROUP' created."
else
    echo "Group '$GROUP' already exists."
fi

# Create base directory if it doesn't exist
if [[ ! -d $BASE_DIR ]]; then
    mkdir -p $BASE_DIR
    chmod 755 $BASE_DIR
    echo "Base directory '$BASE_DIR' created."
fi

# Create admin user if it doesn't exist
if ! id -u $ADMIN_USER > /dev/null 2>&1; then
    useradd -g $GROUP -d $BASE_DIR/$ADMIN_USER -s /usr/sbin/nologin $ADMIN_USER
    #echo "$ADMIN_USER:$ADMIN_PASSWORD" | chpasswd
    echo "$ADMIN_USER:$ADMIN_PASSWORD" | passwd --stdin $ADMIN_USER 2>/dev/null || echo "$ADMIN_PASSWORD" | passwd $ADMIN_USER
    chown root:root $BASE_DIR/$ADMIN_USER
    echo "Admin user '$ADMIN_USER' created."

    # Set up directories for admin
    mkdir -p $BASE_DIR/$ADMIN_USER/teams
    mkdir -p $BASE_DIR/$ADMIN_USER/hackathon2024/input/sample/problem{1,2,3}
    mkdir -p $BASE_DIR/$ADMIN_USER/hackathon2024/input/final/problem{1,2,3}
	chown -R $ADMIN_USER:$GROUP $BASE_DIR/$ADMIN_USER/hackathon2024/*
    chmod -R 755 $BASE_DIR/$ADMIN_USER
else
    echo "Admin user '$ADMIN_USER' already exists."
fi

# Check if the team list file exists
if [[ ! -f $TEAM_LIST ]]; then
    echo "Team list file '$TEAM_LIST' not found. Please create it with 'username:password' per line."
    exit 1
fi

# Process team usernames and passwords from the list
while IFS=: read -r TEAM_USER TEAM_PASSWORD; do
    TEAM_DIR="$BASE_DIR/$ADMIN_USER/teams/$TEAM_USER"
    MOUNT_TARGET="$TEAM_DIR/input"

    # Validate username and password format
    if [[ -z "$TEAM_USER" || -z "$TEAM_PASSWORD" ]]; then
        echo "Skipping invalid entry: '$TEAM_USER:$TEAM_PASSWORD'"
        continue
    fi

    # Create team user if it doesn't exist
    if ! id -u $TEAM_USER > /dev/null 2>&1; then
        useradd -g $GROUP -d $TEAM_DIR -s /usr/sbin/nologin $TEAM_USER
        echo "$TEAM_USER:$TEAM_PASSWORD" | chpasswd
        echo "Team user '$TEAM_USER' created."
    else
        echo "Team user '$TEAM_USER' already exists."
    fi

    # Set up directories for the team user
    chown root:root $TEAM_DIR
    chmod 755 $TEAM_DIR
    mkdir -p $TEAM_DIR/output/problem{1,2,3}
    chown -R $TEAM_USER:$GROUP $TEAM_DIR/*
    chmod -R 775 $TEAM_DIR/*

    
    # Bind mount the admin input directory
	if mountpoint -q $MOUNT_TARGET; then
    	echo "$MOUNT_TARGET is already mounted. Skipping bind mount."
	else
    	echo "Creating and binding $MOUNT_TARGET to $MOUNT_SOURCE..."
    	mkdir -p $MOUNT_TARGET
    	mount --bind $MOUNT_SOURCE $MOUNT_TARGET
    	chmod 755 $MOUNT_TARGET
    	echo "$MOUNT_SOURCE $MOUNT_TARGET none bind 0 0" >> /etc/fstab
    	echo "Bind mount completed for '$TEAM_USER'."
	fi


    # Add Match User configuration to SSHD config
    if ! grep -q "Match User $TEAM_USER" $SSHD_CONFIG; then
        echo "Match User $TEAM_USER" >> $SSHD_CONFIG
        echo "    ChrootDirectory $BASE_DIR/$ADMIN_USER/teams/$TEAM_USER" >> $SSHD_CONFIG
        echo "SSH configuration updated for '$TEAM_USER'."
    fi
done < "$TEAM_LIST"

# Add Match Group configuration if not present
if ! grep -q "Match Group $GROUP" $SSHD_CONFIG; then
    echo "Match Group $GROUP" >> $SSHD_CONFIG
    echo "    ChrootDirectory $BASE_DIR/%u" >> $SSHD_CONFIG
    echo "    ForceCommand internal-sftp" >> $SSHD_CONFIG
    echo "    PasswordAuthentication yes" >> $SSHD_CONFIG
    echo "SSH configuration updated for group '$GROUP'."
fi

# Restart SSH service
systemctl restart sshd

echo "SFTP setup completed successfully!"
