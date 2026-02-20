#!/bin/bash

# Deploy Your Agent - Skill Updater
# Update skills for existing clients

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"
LOG_DIR="$HOME/.deploy/clients"

show_help() {
    echo "Deploy Your Agent - Skill Updater"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --client <name>   Update specific client"
    echo "  --skill <id>      Update specific skill only"
    echo "  --all             Update all clients"
    echo "  --dry-run         Show what would be updated"
    echo "  --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --client \"Acme Corp\""
    echo "  $0 --client \"Acme Corp\" --skill email-management"
    echo "  $0 --all"
    echo ""
}

update_skill() {
    local skill_id="$1"
    local variant="$2"
    local workspace="$3"
    local dry_run="$4"
    
    local skill_source="$SKILLS_DIR/$skill_id"
    local skill_target="$workspace/skills/$skill_id"
    
    if [ ! -d "$skill_source" ]; then
        echo -e "${RED}  ✗ Skill not found in repo: $skill_id${NC}"
        return 1
    fi
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}  Would update: $skill_id ($variant)${NC}"
        return 0
    fi
    
    # Backup existing
    if [ -d "$skill_target" ]; then
        cp -r "$skill_target" "${skill_target}.bak"
    fi
    
    # Update main SKILL.md
    mkdir -p "$skill_target"
    cp "$skill_source/SKILL.md" "$skill_target/"
    
    # Update variant reference
    if [ -n "$variant" ] && [ -f "$skill_source/references/$variant.md" ]; then
        mkdir -p "$skill_target/references"
        cp "$skill_source/references/$variant.md" "$skill_target/references/"
    fi
    
    # Update scripts if they exist
    if [ -d "$skill_source/scripts" ]; then
        cp -r "$skill_source/scripts" "$skill_target/"
    fi
    
    # Remove backup on success
    rm -rf "${skill_target}.bak"
    
    echo -e "${GREEN}  ✓ Updated: $skill_id ($variant)${NC}"
}

update_client() {
    local client_file="$1"
    local skill_filter="$2"
    local dry_run="$3"
    
    local client=$(jq -r '.client' "$client_file")
    local workspace=$(jq -r '.workspace' "$client_file")
    
    echo -e "\n${BOLD}Updating: $client${NC}"
    echo -e "Workspace: ${CYAN}$workspace${NC}\n"
    
    if [ ! -d "$workspace" ]; then
        echo -e "${RED}Workspace not found. Skipping.${NC}"
        return 1
    fi
    
    # Get skills
    local skills=$(jq -r '.skills | to_entries[] | "\(.key):\(.value.variant)"' "$client_file")
    
    while IFS= read -r skill_entry; do
        [ -z "$skill_entry" ] && continue
        
        skill_id="${skill_entry%%:*}"
        variant="${skill_entry#*:}"
        
        # Filter if specified
        if [ -n "$skill_filter" ] && [ "$skill_id" != "$skill_filter" ]; then
            continue
        fi
        
        update_skill "$skill_id" "$variant" "$workspace" "$dry_run"
    done <<< "$skills"
    
    # Update log file version
    if [ "$dry_run" != "true" ]; then
        local temp_file=$(mktemp)
        jq --arg date "$(date -Iseconds)" '.updated = $date' "$client_file" > "$temp_file"
        mv "$temp_file" "$client_file"
    fi
}

# Parse arguments
CLIENT=""
SKILL=""
ALL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --client)
            CLIENT="$2"
            shift 2
            ;;
        --skill)
            SKILL="$2"
            shift 2
            ;;
        --all)
            ALL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate arguments
if [ "$ALL" = false ] && [ -z "$CLIENT" ]; then
    echo "Error: Specify --client <name> or --all"
    show_help
    exit 1
fi

# Check log directory
if [ ! -d "$LOG_DIR" ] || [ -z "$(ls -A "$LOG_DIR" 2>/dev/null)" ]; then
    echo "No clients installed yet."
    exit 0
fi

# Run updates
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}=== DRY RUN ===${NC}\n"
fi

if [ "$ALL" = true ]; then
    for file in "$LOG_DIR"/*.json; do
        [ -f "$file" ] || continue
        update_client "$file" "$SKILL" "$DRY_RUN"
    done
else
    client_file="$LOG_DIR/$(echo "$CLIENT" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').json"
    if [ ! -f "$client_file" ]; then
        echo "Client not found: $CLIENT"
        exit 1
    fi
    update_client "$client_file" "$SKILL" "$DRY_RUN"
fi

echo -e "\n${GREEN}Update complete!${NC}\n"
