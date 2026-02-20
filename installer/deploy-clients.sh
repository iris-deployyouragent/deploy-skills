#!/bin/bash

# Deploy Your Agent - Client Manager
# List and manage client installations

set -e

LOG_DIR="$HOME/.deploy/clients"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

show_help() {
    echo "Deploy Your Agent - Client Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  list              List all clients"
    echo "  show <client>     Show client details"
    echo "  skills <client>   List skills installed for client"
    echo "  help              Show this help"
    echo ""
}

list_clients() {
    if [ ! -d "$LOG_DIR" ] || [ -z "$(ls -A "$LOG_DIR" 2>/dev/null)" ]; then
        echo "No clients installed yet."
        echo "Run deploy-install.sh to install for a client."
        exit 0
    fi
    
    echo -e "${BOLD}Installed Clients:${NC}\n"
    
    for file in "$LOG_DIR"/*.json; do
        [ -f "$file" ] || continue
        
        client=$(jq -r '.client' "$file")
        installed=$(jq -r '.installed' "$file" | cut -d'T' -f1)
        skill_count=$(jq '.skills | length' "$file")
        workspace=$(jq -r '.workspace' "$file")
        
        echo -e "${GREEN}$client${NC}"
        echo -e "  Installed: $installed"
        echo -e "  Skills: $skill_count"
        echo -e "  Workspace: ${CYAN}$workspace${NC}"
        echo ""
    done
}

show_client() {
    local search="$1"
    local file="$LOG_DIR/$(echo "$search" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').json"
    
    if [ ! -f "$file" ]; then
        echo "Client not found: $search"
        exit 1
    fi
    
    echo -e "${BOLD}Client Details:${NC}\n"
    jq '.' "$file"
}

list_skills() {
    local search="$1"
    local file="$LOG_DIR/$(echo "$search" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').json"
    
    if [ ! -f "$file" ]; then
        echo "Client not found: $search"
        exit 1
    fi
    
    client=$(jq -r '.client' "$file")
    echo -e "${BOLD}Skills for $client:${NC}\n"
    
    jq -r '.skills | to_entries[] | "\(.key) (\(.value.variant)) v\(.value.version)"' "$file"
}

# Main
case "${1:-list}" in
    list)
        list_clients
        ;;
    show)
        if [ -z "$2" ]; then
            echo "Usage: $0 show <client-name>"
            exit 1
        fi
        show_client "$2"
        ;;
    skills)
        if [ -z "$2" ]; then
            echo "Usage: $0 skills <client-name>"
            exit 1
        fi
        list_skills "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
