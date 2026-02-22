#!/bin/bash

# Deploy Your Agent - Skill Installer v2
# Install curated skill packages for different business types

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"

# ============================================
# SKILL PACKAGES BY BUSINESS TYPE
# ============================================

# Core skills every client gets
CORE_SKILLS=(
    "self-improvement"
    "proactive-agent"
    "memory-setup"
    "gog"
    "remind-me"
    "summarize"
    "agent-browser"
)

# Service business (plumber, electrician, cleaner, etc.)
SERVICE_SKILLS=(
    "calendar"
    "invoicing"
    "customer-service"
    "email-management"
    "morning-email-rollup"
    "apple-reminders"
)

# E-commerce business
ECOMMERCE_SKILLS=(
    "stripe"
    "inventory"
    "shopping-expert"
    "pinch-to-post"
    "invoice-generator"
    "customer-service"
    "n8n"
)

# Agency / Consulting
AGENCY_SKILLS=(
    "hubspot"
    "crm"
    "linkedin-monitor"
    "linkedin-inbox"
    "pptx-creator"
    "ai-pdf-builder"
    "marketing-mode"
    "daily-review"
)

# Content Creator
CREATOR_SKILLS=(
    "twitter"
    "instagram"
    "youtube-watcher"
    "marketing-mode"
    "de-ai-ify"
    "deep-research"
)

# Professional Services (lawyer, accountant, consultant)
PROFESSIONAL_SKILLS=(
    "calendar"
    "document-management"
    "excel"
    "ai-pdf-builder"
    "ga4-analytics"
    "todoist"
    "linear"
    "focus-deep-work"
)

# All skills
ALL_SKILLS=(
    "agentmail"
    "ai-pdf-builder"
    "apple-reminders"
    "agent-browser"
    "calendar"
    "compound-engineering"
    "crm"
    "customer-service"
    "daily-review"
    "de-ai-ify"
    "deep-research"
    "document-management"
    "email-management"
    "event-planner"
    "excel"
    "focus-deep-work"
    "ga4-analytics"
    "gog"
    "hubspot"
    "instagram"
    "inventory"
    "invoice-generator"
    "invoicing"
    "linear"
    "linkedin-inbox"
    "linkedin-monitor"
    "marketing-mode"
    "memory-setup"
    "morning-email-rollup"
    "n8n"
    "pinch-to-post"
    "pptx-creator"
    "proactive-agent"
    "remind-me"
    "self-improvement"
    "shopping-expert"
    "stripe"
    "summarize"
    "todoist"
    "twitter"
    "youtube-watcher"
)

# ============================================
# FUNCTIONS
# ============================================

print_banner() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║        🚀 Deploy Your Agent - Skill Installer v2 🚀           ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

install_skills() {
    local target_dir="$1"
    shift
    local skills=("$@")
    
    mkdir -p "$target_dir/skills"
    
    for skill in "${skills[@]}"; do
        if [ -d "$SKILLS_DIR/$skill" ]; then
            cp -r "$SKILLS_DIR/$skill" "$target_dir/skills/"
            echo -e "  ${GREEN}✓${NC} $skill"
        else
            echo -e "  ${YELLOW}⚠${NC} $skill (not found)"
        fi
    done
}

generate_env_template() {
    local target_dir="$1"
    shift
    local skills=("$@")
    
    local env_file="$target_dir/.env.template"
    
    cat > "$env_file" << 'EOF'
# ============================================
# Deploy Your Agent - Environment Variables
# ============================================
# Fill in the values and rename to .env

# Client Info
CLIENT_NAME=
CLIENT_EMAIL=

EOF

    # Add skill-specific env vars
    for skill in "${skills[@]}"; do
        case "$skill" in
            "gog")
                cat >> "$env_file" << 'EOF'
# Google Workspace (gog)
# Setup: gog auth credentials /path/to/client_secret.json
# Then: gog auth add email@gmail.com --services gmail,calendar,drive

EOF
                ;;
            "stripe")
                cat >> "$env_file" << 'EOF'
# Stripe
STRIPE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

EOF
                ;;
            "hubspot")
                cat >> "$env_file" << 'EOF'
# HubSpot
HUBSPOT_API_KEY=pat-na1-...

EOF
                ;;
            "openai"|"summarize"|"deep-research")
                cat >> "$env_file" << 'EOF'
# OpenAI (for summarize, research, etc.)
OPENAI_API_KEY=sk-...

EOF
                ;;
            "twitter")
                cat >> "$env_file" << 'EOF'
# Twitter/X
TWITTER_API_KEY=
TWITTER_API_SECRET=
TWITTER_ACCESS_TOKEN=
TWITTER_ACCESS_SECRET=

EOF
                ;;
            "instagram")
                cat >> "$env_file" << 'EOF'
# Instagram
INSTAGRAM_SESSION_ID=

EOF
                ;;
            "n8n")
                cat >> "$env_file" << 'EOF'
# n8n Automation
N8N_API_URL=http://localhost:5678
N8N_API_KEY=

EOF
                ;;
            "linear")
                cat >> "$env_file" << 'EOF'
# Linear
LINEAR_API_KEY=lin_api_...

EOF
                ;;
            "todoist")
                cat >> "$env_file" << 'EOF'
# Todoist
TODOIST_API_KEY=

EOF
                ;;
            "ga4-analytics")
                cat >> "$env_file" << 'EOF'
# Google Analytics
GA4_PROPERTY_ID=
# Uses same OAuth as gog

EOF
                ;;
        esac
    done
    
    echo -e "\n${GREEN}✓${NC} Generated .env.template"
}

# ============================================
# MAIN
# ============================================

print_banner

# Get target directory
echo -e "${CYAN}Where should we install the skills?${NC}"
echo -e "  ${YELLOW}[1]${NC} Current directory (./skills)"
echo -e "  ${YELLOW}[2]${NC} Custom path"
echo ""
read -p "$(echo -e ${BOLD}"> "${NC})" dir_choice

case "$dir_choice" in
    1)
        TARGET_DIR="$(pwd)"
        ;;
    2)
        read -p "Enter path: " TARGET_DIR
        TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
        ;;
    *)
        TARGET_DIR="$(pwd)"
        ;;
esac

mkdir -p "$TARGET_DIR"
echo -e "\n${GREEN}Installing to:${NC} $TARGET_DIR\n"

# Select business type
echo -e "${CYAN}Select client business type:${NC}"
echo -e "  ${YELLOW}[1]${NC} 🔧 Service Business (plumber, electrician, cleaner)"
echo -e "  ${YELLOW}[2]${NC} 🛒 E-commerce (online store, dropshipping)"
echo -e "  ${YELLOW}[3]${NC} 📊 Agency / Consulting"
echo -e "  ${YELLOW}[4]${NC} 🎨 Content Creator"
echo -e "  ${YELLOW}[5]${NC} 💼 Professional Services (lawyer, accountant)"
echo -e "  ${YELLOW}[6]${NC} 📦 All Skills (41 skills)"
echo -e "  ${YELLOW}[7]${NC} ⚙️  Custom Selection"
echo ""
read -p "$(echo -e ${BOLD}"> "${NC})" biz_choice

# Combine core + business-specific skills
INSTALL_SKILLS=("${CORE_SKILLS[@]}")

case "$biz_choice" in
    1)
        INSTALL_SKILLS+=("${SERVICE_SKILLS[@]}")
        BIZ_TYPE="Service Business"
        ;;
    2)
        INSTALL_SKILLS+=("${ECOMMERCE_SKILLS[@]}")
        BIZ_TYPE="E-commerce"
        ;;
    3)
        INSTALL_SKILLS+=("${AGENCY_SKILLS[@]}")
        BIZ_TYPE="Agency"
        ;;
    4)
        INSTALL_SKILLS+=("${CREATOR_SKILLS[@]}")
        BIZ_TYPE="Content Creator"
        ;;
    5)
        INSTALL_SKILLS+=("${PROFESSIONAL_SKILLS[@]}")
        BIZ_TYPE="Professional Services"
        ;;
    6)
        INSTALL_SKILLS=("${ALL_SKILLS[@]}")
        BIZ_TYPE="Full Install"
        ;;
    7)
        echo -e "\n${CYAN}Available skills:${NC}"
        for i in "${!ALL_SKILLS[@]}"; do
            printf "  ${YELLOW}[%2d]${NC} %s\n" "$((i+1))" "${ALL_SKILLS[$i]}"
        done
        echo ""
        echo -e "Enter skill numbers separated by spaces (e.g., 1 5 12 18):"
        read -p "> " selections
        INSTALL_SKILLS=("${CORE_SKILLS[@]}")
        for num in $selections; do
            idx=$((num-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#ALL_SKILLS[@]} ]; then
                INSTALL_SKILLS+=("${ALL_SKILLS[$idx]}")
            fi
        done
        BIZ_TYPE="Custom"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Remove duplicates
INSTALL_SKILLS=($(echo "${INSTALL_SKILLS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo -e "\n${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Installing ${#INSTALL_SKILLS[@]} skills for: $BIZ_TYPE${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}\n"

# Install skills
install_skills "$TARGET_DIR" "${INSTALL_SKILLS[@]}"

# Generate .env template
echo ""
generate_env_template "$TARGET_DIR" "${INSTALL_SKILLS[@]}"

# Summary
echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✅ Installation Complete!${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Installed ${GREEN}${#INSTALL_SKILLS[@]}${NC} skills to: ${CYAN}$TARGET_DIR/skills/${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review .env.template and add credentials"
echo "  2. Rename .env.template to .env"
echo "  3. Set up OAuth for Google (gog auth credentials ...)"
echo "  4. Test with: clawdbot skills list"
echo ""
echo -e "${PURPLE}Happy deploying! 🚀${NC}"
