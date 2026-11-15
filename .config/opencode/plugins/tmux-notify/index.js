// Server half of the tmux-notify plugin. It owns no behaviour: the tmux calls
// live in ./tui.js because they need the terminal's TMUX_PANE. Declaring the
// server part makes OpenCode discover the plugin and hand its TUI part to the
// terminal clients.

import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "tmux.notify",
  setup() {},
})
