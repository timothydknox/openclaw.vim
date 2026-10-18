# openclaw.vim

Vim plugin for [OpenClaw](https://github.com/openclaw/openclaw) CLI integration.

This is a Vim port of the original Neovim plugin [openclaw.nvim](https://github.com/njg7194/openclaw.nvim), extended with additional coding assistance features.

## Features

- 🔌 **Gateway Control** - Start, stop, and restart OpenClaw gateway
- 📊 **Status Monitoring** - Real-time connection status in your statusline
- 🔧 **Quick Access** - Commands for setup wizard, doctor, dashboard, and TUI
- ⚡ **Async Operations** - Non-blocking commands that won't freeze your editor
- 🎨 **Lualine Support** - Ready-to-use component for lualine
- 🤖 **Coding Assistance** - Create context-aware AI sessions for your current file
- 🧠 **Model Selection** - Choose specific AI models for different coding tasks
- 📁 **Project Context** - Sessions understand the project context of your files

## Installation

### Using vim-plug
```vim
Plug 'openclaw/openclaw.vim'
```

### Using packadd (Vim's built-in package manager)
```bash
mkdir -p ~/.vim/pack/plugins/start/openclaw.vim
cd ~/.vim/pack/plugins/start/openclaw.vim
git clone https://github.com/openclaw/openclaw.vim .
```

## Configuration

Add to your `.vimrc`:
```vim
" Basic setup
call openclaw#setup()

" Advanced setup with options
call openclaw#setup({
    \ 'auto_connect': 1,
    \ 'status_refresh_ms': 3000,
    \ 'command': 'openclaw'
    \ })
```

## Usage

### Gateway Management
- `:OpenClawStatus` - Check gateway status
- `:OpenClawConnect` - Start the gateway
- `:OpenClawDisconnect` - Stop the gateway
- `:OpenClawRestart` - Restart the gateway
- `:OpenClawSetup` - Run setup wizard
- `:OpenClawDoctor` - Run health checks
- `:OpenClawDashboard` - Open web dashboard
- `:OpenClawTUI` - Open terminal UI
- `:OpenClawLogs` - View live logs

### Coding Assistance
- `:OpenClawCreateSession` - Create session with context from current file
- `:OpenClawSendToSession "message"` - Send message to active session
- `:OpenClawSessionInfo` - Show current session info
- `:OpenClawListModels` - List available models
- `:OpenClawSwitchSession session-id` - Switch to different session
- `:OpenClawSessionHistory` - Show conversation history

## License

This project is licensed under the BSD-3-Clause-Open-MPI License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Original Neovim plugin: [openclaw.nvim](https://github.com/njg7194/openclaw.nvim)
- This Vim version was created by [timothydknox](https://github.com/timothydknox/openclaw.vim) as a port and extension of the original work
