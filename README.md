### NeoVim

### LSP

For NeoVim's LSP settings to work you actually need the necessary language servers installed on your system (or in a development shell).

- c(++) requires `clangd`  
- go requires `gopl`  
- lua requires `lus-language-server`  
- nix requires `nil`  

#### Keybindings  

| Keybinding     | Description                                    | M    |
| -------------- | ---------------------------------------------- | ---- |
| `leader + u`   | Toggles UndoTree                               | N    |
| `J`            | Moves selection down                           | V    |
| `K`            | Moves selection up                             | V    |
| `↓`            | Jumps 10 lines down                            | N    |
| `↑`            | Jumps 10 lines up                              | N    |
| `leader + p`   | Pastes without yanking                         | x    |
| `leader + y`   | Yanks to system clipboard                      | N, V |
| `leader + Y`   | Yanks to system clipboard                      | N    |
| `leader + ff`  | Telescope: Find Files                          | N    |
| `leader + fg`  | Telescope: Live Grep                           | N    |
| `leader + fb`  | Telescope: Buffers                             | N    |
| `leader + fh`  | Telescope: Help Tags                           | N    |
| `leader + r`   | LSP: Rename                                    | B    |
| `leader + a`   | LSP: Code Action                               | B    |
| `gd`           | LSP: Go to Definition                          | B    |
| `gD`           | LSP: Go to Declaration                         | B    |
| `gI`           | LSP: Go to Implementation                      | B    |
| `leader + D`   | LSP: Go to Type Definition                     | B    |
| `gr`           | Telescope: LSP References                      | B    |
| `leader + s`   | Telescope: LSP Document Symbols                | B    |
| `leader + S`   | Telescope: LSP Dynamic Workspace Symbols       | B    |
| `K`            | LSP: Hover                                     | B    |
| `Format`       | LSP: Format code                               | B    |
| `Ctrl + Space` | CMP: Complete                                  | N    |
| `Enter`        | CMP: Confirm and Replace                       | N    |
| `Tab`          | CMP: Select Next Item or Luasnip Expand/Jump   | N    |
| `Shift + Tab`  | CMP: Select Previous Item or Luasnip Jump Back | N    |

