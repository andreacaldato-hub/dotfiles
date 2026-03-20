# AGENTS.md

This file provides coding guidelines for agentic coding assistants working in Andrea's repository.

## Repository Structure

```
/home/andrea/
├── dotfiles/                    # Git-tracked configuration files
│   └── .config/                 # Desktop/terminal configs
│       ├── nvim/                # Neovim (Lua)
│       ├── tmux/                # Tmux
│       ├── ghostty/              # Ghostty terminal
│       └── ...
├── projects/                    # C projects
│   ├── my_cat/                  # Unix cat utility
│   ├── my_grep/                 # Recursive file search
│   ├── bouncing_ball/           # SDL3 graphics demo
│   ├── https_server/            # SSL server (uses Makefile)
│   └── image_viewer/            # Image viewer
├── leetcode/                    # C algorithm solutions
├── HTML_CSS-course/             # HTML/CSS learning
└── Javascript-course/          # JavaScript learning
```

## Build Commands

### C Programs (Simple)

```bash
# Compile single C file
gcc filename.c -o output

# Compile with SDL3 (graphics)
gcc -o program program.c -lSDL3 -lm

# Compile with math library
gcc -o program program.c -lm

# Run program
./program [args]
```

### C Programs (with Makefile)

```bash
cd projects/https_server
make              # Build
make run          # Run (requires cert.pem, key.pem)
make dev          # Dev mode (auto-generates certs)
make clean        # Clean build artifacts
```

### Running Tests

```bash
# Manual testing for my_cat
cd projects/my_cat
gcc cat.c -o cat
./cat test_files/test.txt

# Manual testing for my_grep
cd projects/my_grep
gcc grep.c -o grep
./grep
```

### Web Projects

```bash
# Open HTML in browser
firefox index.html
```

## Code Style

### C Programming

#### Indentation & Formatting
- **2 spaces** for indentation
- Opening brace on same line
- One blank line between function definitions
- Max line length: ~100 characters

```c
void draw_circle(SDL_Renderer *renderer, struct Circle circle) {
  double x_low = circle.x_center - circle.radius;
  // ...
}
```

#### Naming Conventions
- **Functions**: `snake_case` (e.g., `draw_circle`, `step_forward`)
- **Variables**: `snake_case` (e.g., `x_center`, `circle_radius`)
- **Structs**: `PascalCase` (e.g., `struct Circle`, `struct Node`)
- **Constants/Macros**: `UPPER_SNAKE_CASE` (e.g., `BUFFER_SIZE`)
- **Global variables**: descriptive names

#### Includes
- Group: system headers first, then local headers
- Sort alphabetically within groups
- Angle brackets for system, quotes for local

```c
#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <stdio.h>
#include "my_header.h"
```

#### Error Handling
- Check return values immediately
- Use `perror()` for system errors
- Print user-friendly messages with context
- Return early on errors

```c
FILE *file = fopen(path, "r");
if (!file) {
  perror("Could not open file");
  return -1;
}
```

#### Memory Management
- Always check `malloc()` return values
- Free memory before returning
- Set pointers to `NULL` after freeing

```c
int *ptr = malloc(sizeof(int));
if (!ptr) {
  perror("malloc failed");
  return -1;
}
free(ptr);
ptr = NULL;
```

### HTML

- Use `<!doctype html>`
- Include charset and viewport meta tags
- Use semantic elements (`<header>`, `<main>`, `<nav>`)
- Lowercase tags and attributes
- Attributes order: `type`, `id`, `class`, `src`, `href`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Page Title</title>
  </head>
  <body>
    <header>Title</header>
    <main><!-- content --></main>
  </body>
</html>
```

### CSS

- Use **kebab-case** for class names (e.g., `.video-preview`, `.sidebar-link`)
- Group related styles together
- Sort properties alphabetically within rules

```css
.youtube-button {
  background-color: #CC0001;
  border-radius: 2px;
  color: white;
  cursor: pointer;
  height: 36px;
}
```

### Lua (Neovim Config)

- **2 spaces** indentation
- Use `pcall(require, ...)` for optional modules
- Local variables for module-scoped state
- Group related settings together

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  -- clone repo
end
vim.opt.rtp:prepend(lazypath)
```

### General Principles

1. **Simplicity first**: Clear, straightforward code
2. **Document "why"**: Comments should explain intent, not mechanics
3. **Consistency**: Match existing code style in each project
4. **No magic numbers**: Use named constants
5. **Early returns**: Handle error cases first
6. **Resource cleanup**: Close files, free memory, release resources

### Project-Specific Notes

#### SDL3 Graphics
- Include `<SDL3/SDL_oldnames.h>` for compatibility
- Use `SDL_FRect` for floating-point rectangles
- Call `SDL_Init()` before creating windows
- Process events with `SDL_PollEvent()`

#### Socket Programming
- Always check `socket()`, `bind()`, `listen()`, `accept()` return values
- Use `perror()` for error reporting
- Free `malloc()`'d socket structures

#### Unix Utilities
- Follow POSIX conventions for flags (e.g., `-n` for line numbers)
- Support stdin when no files specified
- Handle file errors gracefully

## Neovim Configuration

The Neovim config uses lazy.nvim plugin manager with modular structure:

```
lua/
├── config/
│   ├── lazy.lua      # Plugin manager bootstrap
│   ├── options.lua    # Global settings
│   ├── keymaps.lua   # Keybindings
│   └── autocmds.lua  # Autocommands
└── plugins/
    ├── colorscheme.lua
    ├── lsp/          # Language Server Protocol
    ├── git/          # Git integration
    ├── utils/        # Utility plugins
    └── ui/           # UI plugins
```

When editing Lua files, reference `lua/config/lazy.lua` for the plugin spec structure.

## Tmux Configuration

- Prefix: `C-Space` (not default `C-b`)
- Uses tpm plugin manager
- Configuration: `~/.config/tmux/tmux.conf`
- Reload with `tmux source-file ~/.config/tmux/tmux.conf`
