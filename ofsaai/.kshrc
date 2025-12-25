# Create .kshrc if it doesn't exist
if [ ! -f "$HOME/.kshrc" ]; then
    cat > "$HOME/.kshrc" << 'EOF'
# ksh initialization file
# Set interactive shell options
set -o emacs        # emacs line editing mode
HISTSIZE=1000       # history size
EOF
fi
