# Where should we write the GIF?
Output demo.gif

# Set up a 960x540 terminal with 24px font.
Set Shell bash
Set FontSize 20
Set Width 960
Set Height 540
Set Padding 0

# Type a command in the terminal.
Hide

Type 'NVIM_DEMO_CONFIG="$(pwd)/demo.lua"'
Enter
Type 'nvim() { command nvim -u "$NVIM_DEMO_CONFIG"; }'
Enter
Type 'cd ..'
Enter
Type 'clear'
Enter

Show

Sleep 500ms

Type "nvim"
Sleep 1000ms
Enter
Sleep 1000ms
Type ":e lua/yank-git-remote-url/init.lua"
Sleep 1000ms
Enter
Sleep 1000ms
Type ":lua require('yank-git-remote-url').yank(2, 11, 15)"
Sleep 1000ms
Enter
Sleep 1000ms

Sleep 500ms

