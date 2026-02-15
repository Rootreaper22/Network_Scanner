clear

cleanup() {
    echo ""
    echo "[+] Cleaning up..."
    sudo airmon-ng stop "$monitor" 2>/dev/null
    sudo systemctl restart NetworkManager
    exit 0
}

trap cleanup INT

figlet "Network Scanner"
echo "Created by RootReaper"

sudo ip link show

read -p "Enter the network interface to change it to monitor mode: " card

sudo airmon-ng check kill
sudo airmon-ng start "$card"

monitor="${card}mon"

echo "$monitor is now in monitor mode!"

read -p "Would you like to scan for networks? (Y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    
    read -p "Would you like the results to be exported? (Y/N): " option
    
    if [[ "$option" =~ ^[Yy]$ ]]; then
        read -p "Enter the file name for the exported results: " name
        
        mkdir -p exports
        
        sudo airodump-ng -w "exports/$name" "$monitor" &
        
    else
        echo "Results not exported."
        sudo airodump-ng "$monitor" &
    fi

    AIRO_PID=$!
    wait $AIRO_PID
    cleanup

elif [[ "$choice" =~ ^[Nn]$ ]]; then
    cleanup
else
    echo "Invalid option"
    cleanup
fi
