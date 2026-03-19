# AGENTS.md

This file provides coding guidelines and instructions for agentic coding assistants working in this repository.

## Repository Overview

This is Andrea's home directory containing personal projects:
- **C projects**: SDL graphics, socket programming, Unix utilities (cat, grep)
- **Web projects**: HTML/CSS/JavaScript applications
- **LeetCode practice**: C solutions for algorithm problems
- **Configuration**: Dotfiles (zsh, tmux)

## Build Commands

### C Programs

```bash
# Compile single C file
gcc filename.c -o output

# Compile with SDL3 (graphics programs)
gcc -o program program.c -lSDL3 -lm

# Compile with math library
gcc -o program program.c -lm

# Run compiled program
./program [args]
```

### Web Projects

```bash
# Open HTML file directly in browser (Firefox)
firefox index.html

# Or use any browser to open the HTML file
```

### Testing Individual Programs

```bash
# For C programs with test files
cd projects/my_cat
gcc cat.c -o cat
./cat test_files/test.txt

# For grep
cd projects/my_grep
gcc grep.c -o grep
./grep

# For http_server
cd projects/http_server
gcc main.c -o main
./main
```

## Code Style Guidelines

### C Programming

#### Indentation and Formatting
- Use **2 spaces** for indentation
- Opening brace on same line for functions/control structures
- One blank line between function definitions
- Max line length: ~80-100 characters

```c
// Good
void draw_circle(SDL_Renderer *renderer, struct Circle circle) {
  double x_low = circle.x_center - circle.radius;
  // ...
}

// Bad - no spacing
void bad_func(){
    int x=0;
}
```

#### Naming Conventions
- **Functions**: `snake_case` (e.g., `draw_circle`, `step_forward`)
- **Variables**: `snake_case` (e.g., `x_center`, `circle_radius`)
- **Structs**: `PascalCase` (e.g., `struct Circle`, `struct Node`)
- **Constants/Macros**: `UPPER_SNAKE_CASE` (e.g., `BUFFER_SIZE`, `MAX_WIDTH`)
- **Global variables**: descriptive names, avoid generic names like `tmp`

#### Includes
- Group by type: system headers, then local headers
- Sort alphabetically within groups
- Use angle brackets for system headers, quotes for local headers

```c
#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_video.h>
#include <stdio.h>
#include <stdlib.h>
```

#### Error Handling
- Use `perror()` for system-level errors (file operations, sockets)
- Print user-friendly error messages with context
- Return early on errors rather than deeply nesting
- Free allocated memory before returning on error

```c
// Good
FILE *file = fopen(path, "r");
if (!file) {
  perror("Could not open file");
  return -1;
}

// Bad - missing error handling
FILE *file = fopen(path, "r");
// continue without checking...
```

#### Memory Management
- Always check `malloc()` return values
- Free memory before returning from functions when done
- Set pointers to `NULL` after freeing

```c
int *ptr = malloc(sizeof(int));
if (!ptr) {
  perror("malloc failed");
  return -1;
}
// ... use ptr ...
free(ptr);
ptr = NULL;
```

### HTML

#### Structure
- Use HTML5 doctype: `<!doctype html>`
- Include charset and viewport meta tags
- Use semantic HTML elements (`<header>`, `<main>`, `<nav>`)
- Keep attributes in consistent order: `type`, `id`, `class`, `src`, `href`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Page Title</title>
    <link href="style.css" rel="stylesheet" />
  </head>
  <body>
    <header>Title</header>
    <main>
      <!-- content -->
    </main>
    <script src="app.js"></script>
  </body>
</html>
```

### CSS

#### Naming and Organization
- Use **kebab-case** for class names (e.g., `.task-div`, `#add-button`)
- Group related styles together
- Use CSS custom properties (variables) for repeated values
- Sort properties alphabetically within rules

```css
/* Good */
.task-div {
  align-items: center;
  display: flex;
  padding: 8px 12px;
}

/* Bad - inconsistent naming */
.taskDiv {
  display: flex;
  padding: 8px 12px;
}
```

#### Selectors
- Prefer class selectors over element selectors
- Avoid overly specific selectors
- Use BEM naming when nesting is needed

### JavaScript

#### Formatting
- Use `const` by default, `let` when reassignment needed
- Avoid `var`
- Use template literals for string concatenation
- Use arrow functions for callbacks

```javascript
// Good
const handleClick = () => {
  const text = input.value.trim();
  if (!text) return;
  // ...
};

// Bad
var handleClick = function() {
  var text = input.value.trim();
  if (text == "") return;
  // ...
};
```

#### DOM Manipulation
- Cache DOM references outside event handlers
- Use event delegation when appropriate
- Handle null/undefined cases

```javascript
// Good
const btn = document.getElementById("addButton");
btn.addEventListener("click", () => {
  const text = input.value.trim();
  if (!text) return;
  // ...
});
```

## General Principles

1. **Simplicity first**: Write clear, straightforward code
2. **Comments**: Document the "why", not the "what"
3. **Consistency**: Match existing code style in each project
4. **No magic numbers**: Use named constants instead of bare numbers
5. **Early returns**: Handle error cases first and exit early
6. **Resource cleanup**: Always close files, free memory, release resources

## Project-Specific Notes

### SDL3 Graphics Programs
- Include `<SDL3/SDL_oldnames.h>` for compatibility
- Use `SDL_FRect` for floating-point rectangles
- Call `SDL_Init()` before creating windows
- Process events in a loop with `SDL_PollEvent()`

### Socket Programming
- Always check return values of `socket()`, `bind()`, `listen()`, `accept()`
- Use `perror()` for error reporting
- Free `malloc()`'d socket structures

### Unix Utilities
- Follow POSIX conventions for flags (e.g., `-n` for line numbers)
- Support stdin when no files specified
- Handle file open errors gracefully
