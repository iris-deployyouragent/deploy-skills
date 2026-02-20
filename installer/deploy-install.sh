#!/bin/bash

# Deploy Your Agent - Skill Installer
# Interactive installer for client agent setups

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"
REGISTRY_FILE="$(dirname "$SCRIPT_DIR")/registry/skills.json"

# Installation tracking
INSTALLED_SKILLS=()
ENV_VARS=()

# Banner
print_banner() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║        🚀 Deploy Your Agent - Skill Installer 🚀              ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Prompt with options
prompt_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo -e "\n${CYAN}${prompt}${NC}"
    for i in "${!options[@]}"; do
        echo -e "  ${YELLOW}[$((i+1))]${NC} ${options[$i]}"
    done
    echo -e "  ${YELLOW}[0]${NC} Skip"
    
    while true; do
        read -p "$(echo -e ${BOLD}"> "${NC})" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "$choice"
            return
        fi
        echo -e "${RED}Invalid choice. Try again.${NC}"
    done
}

# Get text input
prompt_text() {
    local prompt="$1"
    local default="$2"
    
    if [ -n "$default" ]; then
        read -p "$(echo -e ${CYAN}${prompt}${NC} [${default}]: )" value
        echo "${value:-$default}"
    else
        read -p "$(echo -e ${CYAN}${prompt}${NC}: )" value
        echo "$value"
    fi
}

# Install a skill
install_skill() {
    local skill_id="$1"
    local variant="$2"
    local target_dir="$3"
    
    local skill_source="$SKILLS_DIR/$skill_id"
    local skill_target="$target_dir/skills/$skill_id"
    
    if [ ! -d "$skill_source" ]; then
        echo -e "${RED}Skill not found: $skill_id${NC}"
        return 1
    fi
    
    # Create target directory
    mkdir -p "$skill_target"
    
    # Copy main SKILL.md
    cp "$skill_source/SKILL.md" "$skill_target/"
    
    # Copy variant-specific reference
    if [ -n "$variant" ] && [ -f "$skill_source/references/$variant.md" ]; then
        mkdir -p "$skill_target/references"
        cp "$skill_source/references/$variant.md" "$skill_target/references/"
    fi
    
    # Copy scripts if they exist
    if [ -d "$skill_source/scripts" ]; then
        cp -r "$skill_source/scripts" "$skill_target/"
    fi
    
    echo -e "${GREEN}✓ Installed: $skill_id ($variant)${NC}"
    INSTALLED_SKILLS+=("$skill_id:$variant")
}

# Add environment variable
add_env_var() {
    local var_name="$1"
    local description="$2"
    ENV_VARS+=("$var_name=$description")
}

# Get credentials for a variant
get_credentials() {
    local skill_id="$1"
    local variant="$2"
    
    # Read from registry
    local creds=$(jq -r ".skills[] | select(.id==\"$skill_id\") | .requiredCredentials.$variant[]?" "$REGISTRY_FILE" 2>/dev/null)
    
    if [ -n "$creds" ]; then
        while IFS= read -r cred; do
            add_env_var "$cred" "Required for $skill_id ($variant)"
        done <<< "$creds"
    fi
}

# Main installation flow
main() {
    print_banner
    
    # Get client info
    echo -e "${BOLD}Let's set up the agent for your client.${NC}\n"
    
    CLIENT_NAME=$(prompt_text "Client name")
    WORKSPACE=$(prompt_text "Agent workspace path" "$HOME/clawd")
    
    # Validate workspace
    if [ ! -d "$WORKSPACE" ]; then
        echo -e "${YELLOW}Workspace doesn't exist. Create it? (y/n)${NC}"
        read -p "> " create
        if [ "$create" = "y" ]; then
            mkdir -p "$WORKSPACE/skills"
            echo -e "${GREEN}Created: $WORKSPACE${NC}"
        else
            echo -e "${RED}Aborted.${NC}"
            exit 1
        fi
    fi
    
    mkdir -p "$WORKSPACE/skills"
    
    echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Select skills to install:${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Email Management
    choice=$(prompt_choice "📧 EMAIL MANAGEMENT - Which provider?" "Gmail / Google Workspace" "Outlook / Microsoft 365" "Other (IMAP/SMTP)")
    case $choice in
        1) install_skill "email-management" "gmail" "$WORKSPACE"; get_credentials "email-management" "gmail" ;;
        2) install_skill "email-management" "outlook" "$WORKSPACE"; get_credentials "email-management" "outlook" ;;
        3) install_skill "email-management" "imap" "$WORKSPACE"; get_credentials "email-management" "imap" ;;
    esac
    
    # Calendar
    choice=$(prompt_choice "📅 CALENDAR - Which provider?" "Google Calendar" "Outlook Calendar")
    case $choice in
        1) install_skill "calendar" "google" "$WORKSPACE"; get_credentials "calendar" "google" ;;
        2) install_skill "calendar" "outlook" "$WORKSPACE"; get_credentials "calendar" "outlook" ;;
    esac
    
    # Customer Service
    choice=$(prompt_choice "💬 CUSTOMER SERVICE - Which platform?" "Zendesk" "Freshdesk" "Email-only (no ticketing)")
    case $choice in
        1) install_skill "customer-service" "zendesk" "$WORKSPACE"; get_credentials "customer-service" "zendesk" ;;
        2) install_skill "customer-service" "freshdesk" "$WORKSPACE"; get_credentials "customer-service" "freshdesk" ;;
        3) install_skill "customer-service" "email" "$WORKSPACE"; get_credentials "customer-service" "email" ;;
    esac
    
    # Invoicing
    choice=$(prompt_choice "💰 INVOICING - Which system?" "Xero" "QuickBooks" "Generic (PDF invoices)")
    case $choice in
        1) install_skill "invoicing" "xero" "$WORKSPACE"; get_credentials "invoicing" "xero" ;;
        2) install_skill "invoicing" "quickbooks" "$WORKSPACE"; get_credentials "invoicing" "quickbooks" ;;
        3) install_skill "invoicing" "generic" "$WORKSPACE"; get_credentials "invoicing" "generic" ;;
    esac
    
    # CRM
    choice=$(prompt_choice "📊 CRM - Which platform?" "HubSpot" "Salesforce" "Deploy CRM (Supabase)")
    case $choice in
        1) install_skill "crm" "hubspot" "$WORKSPACE"; get_credentials "crm" "hubspot" ;;
        2) install_skill "crm" "salesforce" "$WORKSPACE"; get_credentials "crm" "salesforce" ;;
        3) install_skill "crm" "deploy-crm" "$WORKSPACE"; get_credentials "crm" "deploy-crm" ;;
    esac
    
    # Inventory
    choice=$(prompt_choice "📦 INVENTORY - Which platform?" "Shopify" "WooCommerce" "Generic (Spreadsheet)")
    case $choice in
        1) install_skill "inventory" "shopify" "$WORKSPACE"; get_credentials "inventory" "shopify" ;;
        2) install_skill "inventory" "woocommerce" "$WORKSPACE"; get_credentials "inventory" "woocommerce" ;;
        3) install_skill "inventory" "generic" "$WORKSPACE"; get_credentials "inventory" "generic" ;;
    esac
    
    # Document Management
    choice=$(prompt_choice "📁 DOCUMENT MANAGEMENT - Which platform?" "Google Drive" "OneDrive / SharePoint" "Dropbox")
    case $choice in
        1) install_skill "document-management" "google-drive" "$WORKSPACE"; get_credentials "document-management" "google-drive" ;;
        2) install_skill "document-management" "onedrive" "$WORKSPACE"; get_credentials "document-management" "onedrive" ;;
        3) install_skill "document-management" "dropbox" "$WORKSPACE"; get_credentials "document-management" "dropbox" ;;
    esac
    
    # Generate .env.template
    if [ ${#ENV_VARS[@]} -gt 0 ]; then
        echo -e "\n${CYAN}Generating .env.template...${NC}"
        ENV_FILE="$WORKSPACE/.env.template"
        
        echo "# Deploy Your Agent - Environment Variables" > "$ENV_FILE"
        echo "# Client: $CLIENT_NAME" >> "$ENV_FILE"
        echo "# Generated: $(date -Iseconds)" >> "$ENV_FILE"
        echo "" >> "$ENV_FILE"
        
        current_section=""
        for var in "${ENV_VARS[@]}"; do
            var_name="${var%%=*}"
            description="${var#*=}"
            
            # Add section headers based on variable prefix
            section="${var_name%%_*}"
            if [ "$section" != "$current_section" ]; then
                echo "" >> "$ENV_FILE"
                echo "# $section" >> "$ENV_FILE"
                current_section="$section"
            fi
            
            echo "$var_name=  # $description" >> "$ENV_FILE"
        done
        
        echo -e "${GREEN}✓ Created: $ENV_FILE${NC}"
    fi
    
    # Generate installation log
    LOG_DIR="$HOME/.deploy/clients"
    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/$(echo "$CLIENT_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').json"
    
    echo "{" > "$LOG_FILE"
    echo "  \"client\": \"$CLIENT_NAME\"," >> "$LOG_FILE"
    echo "  \"installed\": \"$(date -Iseconds)\"," >> "$LOG_FILE"
    echo "  \"workspace\": \"$WORKSPACE\"," >> "$LOG_FILE"
    echo "  \"skills\": {" >> "$LOG_FILE"
    
    first=true
    for skill in "${INSTALLED_SKILLS[@]}"; do
        skill_id="${skill%%:*}"
        variant="${skill#*:}"
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$LOG_FILE"
        fi
        echo -n "    \"$skill_id\": { \"variant\": \"$variant\", \"version\": \"1.0.0\" }" >> "$LOG_FILE"
    done
    
    echo "" >> "$LOG_FILE"
    echo "  }" >> "$LOG_FILE"
    echo "}" >> "$LOG_FILE"
    
    echo -e "${GREEN}✓ Installation logged: $LOG_FILE${NC}"
    
    # Summary
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}✅ Installation Complete!${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "\n${BOLD}Installed ${#INSTALLED_SKILLS[@]} skills:${NC}"
    for skill in "${INSTALLED_SKILLS[@]}"; do
        skill_id="${skill%%:*}"
        variant="${skill#*:}"
        echo -e "  ${GREEN}•${NC} $skill_id ($variant)"
    done
    
    echo -e "\n${BOLD}📝 Next steps:${NC}"
    echo -e "  1. Fill in credentials: ${CYAN}$WORKSPACE/.env.template${NC}"
    echo -e "  2. Rename to .env: ${CYAN}mv .env.template .env${NC}"
    echo -e "  3. Restart agent: ${CYAN}clawdbot gateway restart${NC}"
    echo -e "  4. Test each skill"
    
    echo -e "\n${GREEN}Happy deploying! 🚀${NC}\n"
}

# Run
main "$@"
