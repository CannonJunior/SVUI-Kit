#!/bin/bash

# SVUI-Kit Initialization Script
# This script initializes the SVUI addon development environment

set -e

echo "🚀 Initializing SVUI-Kit..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "SVUI_!Core/SVUI_!Core.toc" ]; then
    print_error "SVUI_!Core.toc not found. Please run this script from the SVUI-Kit root directory."
    exit 1
fi

print_status "Found SVUI Core addon structure"

# Check dependencies
print_status "Checking system dependencies..."

# Check for ImageMagick (for BLP conversion if needed)
if command -v convert >/dev/null 2>&1; then
    print_success "ImageMagick found"
else
    print_warning "ImageMagick not found - BLP conversion may not work"
fi

# Check for git
if command -v git >/dev/null 2>&1; then
    print_success "Git found"
    
    # Check git status
    if git status >/dev/null 2>&1; then
        print_status "Git repository detected"
        
        # Show current branch
        BRANCH=$(git branch --show-current)
        print_status "Current branch: $BRANCH"
        
        # Count untracked PNG files
        UNTRACKED_PNG=$(git status --porcelain | grep "\.png$" | wc -l)
        if [ "$UNTRACKED_PNG" -gt 0 ]; then
            print_warning "$UNTRACKED_PNG untracked PNG files detected"
        fi
    fi
else
    print_warning "Git not found"
fi

# Verify addon structure
print_status "Verifying addon structure..."

MODULES=(
    "SVUI_!Core"
    "SVUI_!Options" 
    "SVUI_ActionBars"
    "SVUI_Auras"
    "SVUI_Chat"
    "SVUI_Inventory"
    "SVUI_Maps"
    "SVUI_NamePlates"
    "SVUI_QuestTracker"
    "SVUI_Skins"
    "SVUI_Tooltip"
    "SVUI_UnitFrames"
    "SVUI_CraftOMatic"
    "SVUI_FightOMatic"
    "SVUI_TrackOMatic"
)

THEMES=(
    "SVUITheme_Simple"
    "SVUITheme_Warcraft"
)

print_status "Checking core modules..."
for module in "${MODULES[@]}"; do
    if [ -d "$module" ] && [ -f "$module/$module.toc" ]; then
        print_success "✓ $module"
    else
        print_error "✗ $module (missing or invalid)"
    fi
done

print_status "Checking themes..."
for theme in "${THEMES[@]}"; do
    if [ -d "$theme" ] && [ -f "$theme/$theme.toc" ]; then
        print_success "✓ $theme"
    else
        print_error "✗ $theme (missing or invalid)"
    fi
done

# Asset verification
print_status "Checking assets..."

# Count BLP and PNG files
BLP_COUNT=$(find . -name "*.blp" | wc -l)
PNG_COUNT=$(find . -name "*.png" | wc -l)

print_status "Found $BLP_COUNT BLP files and $PNG_COUNT PNG files"

# Check for missing PNG equivalents (optional)
print_status "Checking for BLP files without PNG equivalents..."
MISSING_PNG=0
while IFS= read -r blp_file; do
    png_file="${blp_file%.blp}.png"
    if [ ! -f "$png_file" ]; then
        ((MISSING_PNG++))
        if [ "$MISSING_PNG" -le 5 ]; then
            print_warning "Missing PNG: $png_file"
        fi
    fi
done < <(find . -name "*.blp")

if [ "$MISSING_PNG" -gt 5 ]; then
    print_warning "... and $((MISSING_PNG - 5)) more missing PNG files"
fi

# WoW Interface version check
print_status "Checking WoW interface versions..."
INTERFACE_VERSIONS=$(grep -h "## Interface:" */*.toc | sort -u | cut -d' ' -f3)
print_status "Target interface versions: $(echo $INTERFACE_VERSIONS | tr '\n' ' ')"

# Final status
echo ""
print_success "SVUI-Kit initialization complete!"
echo ""
print_status "Next steps:"
echo "  1. Ensure all required addons are present"
echo "  2. If developing, consider adding untracked PNG files to git"
echo "  3. Test in World of Warcraft"
echo ""
print_status "Development commands:"
echo "  • Stage PNG files: git add **/*.png"
echo "  • Check addon syntax: Check TOC files for errors"
echo "  • Package for distribution: Create zip with addon folders"
echo ""