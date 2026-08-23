#!/bin/bash

# Directory to search for .pl and .lua files
DIRECTORY="."

# Initialize an associative array to map item IDs to files and line numbers
declare -A item_id_matches

# Function to process Perl (.pl) files
process_perl_file() {
    local file="$1"
    local in_event_say=0
    local line_number=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number++))

        # Check if we enter an EVENT_SAY block
        if [[ "$line" =~ ^[[:space:]]*sub[[:space:]]+EVENT_SAY ]]; then
            in_event_say=1
            continue
        fi

        # Exit if we encounter another subroutine
        if [[ "$line" =~ ^[[:space:]]*sub[[:space:]]+ && $in_event_say -eq 1 ]]; then
            in_event_say=0
            continue
        fi

        # Look for quest::summonitem or quest::summonfixeditem calls only inside EVENT_SAY
        if [[ $in_event_say -eq 1 && "$line" =~ quest::(summonitem|summonfixeditem)\(([0-9]+)\) ]]; then
            # Extract the item ID using regex
            if [[ "$line" =~ \(([0-9]+)\) ]]; then
                local item_id="${BASH_REMATCH[1]}"
                # Add the file and line number to the mapping for this item ID
                item_id_matches["$item_id"]+="$file:$line_number "
            fi
        fi
    done < "$file"
}

# Function to process Lua (.lua) files
process_lua_file() {
    local file="$1"
    local in_event_say=0
    local line_number=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number++))

        # Check if we enter an event_say function
        if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+event_say\([a-zA-Z_]*\) ]]; then
            in_event_say=1
            continue
        fi

        # Exit if we encounter another function
        if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+ && $in_event_say -eq 1 ]]; then
            in_event_say=0
            continue
        fi

        # Look for SummonItem or SummonFixedItem calls only inside event_say
        if [[ $in_event_say -eq 1 && "$line" =~ (SummonItem|SummonFixedItem)\(([0-9]+)\) ]]; then
            # Extract the item ID using regex
            if [[ "$line" =~ \(([0-9]+)\) ]]; then
                local item_id="${BASH_REMATCH[1]}"
                # Add the file and line number to the mapping for this item ID
                item_id_matches["$item_id"]+="$file:$line_number "
            fi
        fi
    done < "$file"
}

# Loop through all .pl and .lua files in the directory
while IFS= read -r -d '' file; do
    if [[ "$file" == *.pl ]]; then
        process_perl_file "$file"
    elif [[ "$file" == *.lua ]]; then
        process_lua_file "$file"
    fi
done < <(find "$DIRECTORY" -type f \( -name "*.pl" -o -name "*.lua" \) -print0)

# Output the mapping of item IDs to files with line numbers
echo
echo "Mapping of Item IDs to Files with Line Numbers:"
for item_id in "${!item_id_matches[@]}"; do
    echo "Item ID: $item_id"
    echo "Matches:"
    echo "${item_id_matches[$item_id]}"
    echo
done

# Generate a SQL-friendly list of unique item IDs
unique_ids=$(printf "%s\n" "${!item_id_matches[@]}" | sort -nu | paste -sd, -)
echo "SQL-friendly list: ( $unique_ids )"