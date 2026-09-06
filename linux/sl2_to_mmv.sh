#!/bin/sh

# Variables
count=0
newExtension="mmv"
targetExtension="sl2"

steamCandidates="
$HOME/.steam/steam
$HOME/.local/share/Steam
$HOME/snap/steam/common/.local/share/Steam
$HOME/.var/app/com.valvesoftware.Steam/data/Steam
"

steam_path=""
for p in $steamCandidates; do
    if [ -d "$p" ]; then
        steam_path="$p"
        break
    fi
done

if [ -z "$steam_path" ]; then
    echo "Steam is not found in default installation folders"
    echo ""
    while true; do
        printf "Enter the path to the Nightreign folder (steamapps/common/ELDEN RING NIGHTREIGN): "
        read -r user_input

        if [ ! -d "$user_input" ]; then
        	echo $user_input
            	echo "Can't find the folder. Please try again."
            	continue
        fi

        if [ ! -d "$user_input/Game" ]; then
            echo "Can't a Game folder in selected folder. Please try again."
            continue
        fi

        steam_path=$(dirname -- "$(dirname -- "$(dirname -- "$user_input")")")
        break
    done
fi

save_folder="$steam_path/steamapps/compatdata/2622380/pfx/drive_c/users/steamuser/AppData/Roaming/Nightreign"

temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

for dir in "$save_folder"/*; do
    if [ -d "$dir" ]; then
        count=$((count + 1))
        echo "$dir" >> "$temp_file"
    fi
done

if [ "$count" -eq 0 ]; then
    echo "Can't find any Steam ID folders."
    echo ""
    printf "Press Enter to exit..."
    read -r _
    exit 1
fi

select_steam_id() {
    while true; do
        echo ""
        printf "Enter number: "
        read -r choice
 
        if ! echo "$choice" | grep -Eq '^[1-9][0-9]*$'; then
            echo ""
            echo "Please enter a valid number."
            continue
        fi
 
        if [ "$choice" -gt "$count" ]; then
            echo ""
            echo "Number out of range."
            continue
        fi
 
        break
    done
}

if [ "$count" -gt 1 ]; then
    echo "Select Steam ID to convert save."
    echo ""
    n=0
    while read -r line; do
        n=$((n + 1))
        echo "$n. $line"
    done < "$temp_file"
 
    select_steam_id
    selected=$(sed -n "${choice}p" "$temp_file")
else
    selected=$(head -n 1 "$temp_file")
fi

echo ""
echo "$selected"
echo ""

datetime=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$selected/Backups"
 
if [ -f "$selected/NR0000.$newExtension.bk" ]; then
    cp "$selected/NR0000.$newExtension.bk" "$selected/Backups/NR0000_$datetime.$newExtension.bk"
fi
if [ -f "$selected/NR0000.$newExtension" ]; then
    cp "$selected/NR0000.$newExtension" "$selected/NR0000.$newExtension.bk"
fi
 
if ! cp "$selected/NR0000.$targetExtension" "$selected/NR0000.$newExtension"; then
    echo ""
    echo "Error, something went wrong."
    echo ""
    printf "Press Enter to exit..."
    read -r _
    exit 1
fi
 
echo ""
echo "Success"
echo ""
printf "Press Enter to exit..."
read -r _
exit 0
