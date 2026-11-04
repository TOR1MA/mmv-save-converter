#!/usr/bin/env bash

# Variables
count=0
newExtension="test"
declare -A targetExtensions=(
    [dbb]="Daybreak Beta Save"
    [co2]="Seamless co-op save (mmv 2.1.8 and older)"
    [sl2]="Save file from Vanilla"
    [dev]="Dev testing branch"
)

steamCandidates="
$HOME/.steam/steam
$HOME/.local/share/Steam
$HOME/snap/steam/common/.local/share/Steam
$HOME/.var/app/com.valvesoftware.Steam/data/Steam
"

steam_path=""
clear
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
            echo "Can't find the folder. Please try again."
            continue
        fi

        if [ ! -d "$user_input/Game" ]; then
            echo "Can't find a Game folder in selected folder. Please try again."
            continue
        fi

        steam_path=$(dirname -- "$(dirname -- "$(dirname -- "$user_input")")")
        break
    done
fi

save_folder="$steam_path/steamapps/compatdata/2622380/pfx/drive_c/users/steamuser/AppData/Roaming/Nightreign"

temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

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
        read -rp "Enter a number: " choice
 
        if [[ ! $choice =~ ^[1-9][0-9]*$ ]]; then
            echo ""
            echo "Please enter a valid number, use a single digit, e.g. 1 or 2."
            continue
        fi
 
        if (( choice > count )); then
            echo ""
            echo "Number out of range, use a single digit, e.g. 1 or 2."
            continue
        fi
 
        break
    done
    clear
}

save_selection() {
    local choice

    while true; do
        echo ""
        read -rp "Enter a save file extension: " choice
        choice=${choice,,}
        if [[ -n $choice && -v targetExtensions[$choice] ]]; then
            if [[ ! -f "$selected/NR0000.$choice" ]]; then
                echo ""
                echo "Save file with $choice extension doesn't exists, please select another one."
                continue
            fi
            targetExtension=$choice
            clear
            break
        fi
        echo ""
        echo "Wrong save file extension (co2, sl2 and etc.)."
    done
}

save_confirmation() {
    local choice
    
    while true; do
        echo "Y - create a backup and convert the save file"
        echo "N - cancel and exit"
        read -rp "" choice
        choice=${choice,,}

        case $choice in 
            y|yes) return 0 ;;
            n|no) stop_script ;;
            *)
                echo ""
                echo "Invalid choice"
                echo ""
                ;;
        esac
    done
}

stop_script() {
    echo ""
    printf "The script was stopped, press Enter to close the window..."
    read -r _
    exit 1
}


if [ "$count" -gt 1 ]; then
    echo "Select Steam ID to convert save."
    echo ""
    n=0
    while read -r line; do
        n=$((n + 1))
        echo "Enter $n to select - $line"
    done < "$temp_file"
 
    select_steam_id
    selected=$(sed -n "${choice}p" "$temp_file")
else
    selected=$(head -n 1 "$temp_file")
fi

echo "Selected SteamID folder - $selected"
echo ""

# Get current date and time
datetime=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$selected/Backups"

# List of saves
for ext in "${!targetExtensions[@]}"; do
    if [ -f "$selected/NR0000.$ext" ]; then
        echo "$ext - ${targetExtensions[$ext]}"
    fi
done

save_selection

# Create backup files and converts targetExtension save to newExtension
echo "Selected SteamID folder - $selected"
echo "NR0000.$targetExtension will be copied as NR0000.$newExtension."
if [[ -f $selected/NR0000.$newExtension ]]; then
    echo ""
    echo "Save file with this extension \"$newExtension\" already exists, if u want to replace it with new save confirm it."
    echo "(previous save would be saved as NR0000.$newExtension.bk file, in case u would want to revert it)"
    echo ""
    save_confirmation
    if [ -f "$selected/NR0000.$newExtension.bk" ]; then
        cp "$selected/NR0000.$newExtension.bk" "$selected/Backups/NR0000_$datetime.$newExtension.bk"
    fi
    cp "$selected/NR0000.$newExtension" "$selected/NR0000.$newExtension.bk"
fi

if ! cp "$selected/NR0000.$targetExtension" "$selected/NR0000.$newExtension"; then
    echo ""
    echo "Error, something went wrong."
    stop_script
fi
 
echo ""
echo "Success"
echo ""
printf "Press Enter to exit..."
read -r _
exit 0
