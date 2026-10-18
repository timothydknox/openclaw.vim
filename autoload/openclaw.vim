" openclaw.vim
" Vim plugin for OpenClaw CLI integration
" https://github.com/openclaw/openclaw

let g:openclaw_config = {
    \ 'command': 'openclaw',
    \ 'auto_connect': 0,
    \ 'status_refresh_ms': 5000,
    \ 'notify_on_status_change': 1,
    \ }

let g:openclaw_state = {
    \ 'connected': 0,
    \ 'status': 'stopped',
    \ 'last_check': 0,
    \ }

" Execute OpenClaw command and return result
function! s:exec_openclaw(args)
    let cmd = g:openclaw_config.command . ' ' . a:args
    let result = system(cmd)
    let success = v:shell_error == 0
    return [success, result]
endfunction

" Check OpenClaw status
function! openclaw#status()
    let cmd = g:openclaw_config.command . ' gateway status'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    let was_connected = g:openclaw_state.connected
    
    if success && result =~ 'running'
        let g:openclaw_state.connected = 1
        let g:openclaw_state.status = 'running'
    else
        let g:openclaw_state.connected = 0
        let g:openclaw_state.status = 'stopped'
    endif
    
    let g:openclaw_state.last_check = reltime()
    
    if g:openclaw_config.notify_on_status_change && was_connected != g:openclaw_state.connected
        if g:openclaw_state.connected
            echohl WarningMsg | echom "🦞 OpenClaw connected" | echohl None
        else
            echohl ErrorMsg | echom "🦞 OpenClaw disconnected" | echohl None
        endif
    endif
    
    return [success, result]
endfunction

" Connect to OpenClaw (start gateway)
function! openclaw#connect()
    echo "🦞 Starting OpenClaw gateway..."
    let cmd = g:openclaw_config.command . ' gateway start'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 OpenClaw gateway started"
        call openclaw#status()
    else
        echohl ErrorMsg | echom "🦞 Failed to start OpenClaw: " . (result != '' ? result : 'unknown error') | echohl None
    endif
endfunction

" Disconnect from OpenClaw (stop gateway)
function! openclaw#disconnect()
    echo "🦞 Stopping OpenClaw gateway..."
    let cmd = g:openclaw_config.command . ' gateway stop'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 OpenClaw gateway stopped"
        let g:openclaw_state.connected = 0
        let g:openclaw_state.status = 'stopped'
    else
        echohl ErrorMsg | echom "🦞 Failed to stop OpenClaw: " . (result != '' ? result : 'unknown error') | echohl None
    endif
endfunction

" Restart OpenClaw gateway
function! openclaw#restart()
    echo "🦞 Restarting OpenClaw gateway..."
    let cmd = g:openclaw_config.command . ' gateway restart'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 OpenClaw gateway restarted"
        call openclaw#status()
    else
        echohl ErrorMsg | echom "🦞 Failed to restart OpenClaw: " . (result != '' ? result : 'unknown error') | echohl None
    endif
endfunction

" Run OpenClaw setup wizard
function! openclaw#setup_wizard()
    execute 'terminal ' . g:openclaw_config.command . ' setup'
endfunction

" Run OpenClaw doctor
function! openclaw#doctor()
    execute 'terminal ' . g:openclaw_config.command . ' doctor'
endfunction

" Open OpenClaw dashboard
function! openclaw#dashboard()
    let cmd = g:openclaw_config.command . ' dashboard'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Opening OpenClaw dashboard..."
    else
        echohl ErrorMsg | echom "🦞 Failed to open dashboard: " . (result != '' ? result : 'unknown error') | echohl None
    endif
endfunction

" Open OpenClaw TUI
function! openclaw#tui()
    execute 'terminal ' . g:openclaw_config.command . ' tui'
endfunction

" View logs
function! openclaw#logs()
    execute 'terminal ' . g:openclaw_config.command . ' logs -f'
endfunction

" Get statusline component
function! openclaw#statusline()
    if g:openclaw_state.connected
        return "🦞 OpenClaw"
    else
        return "🦞 ⏸"
    endif
endfunction

" Check if connected
function! openclaw#is_connected()
    return g:openclaw_state.connected
endfunction

" Get current state
function! openclaw#get_state()
    return deepcopy(g:openclaw_state)
endfunction

" Setup function - handles optional configuration
function! openclaw#setup(...)
    " Handle optional argument for configuration
    let opts = {}
    if a:0 > 0
        let opts = a:1
    endif
    
    " Merge options with default config
    if !empty(opts)
        for [key, value] in items(opts)
            let g:openclaw_config[key] = value
        endfor
    endif
    
    " Create user commands
    command! -nargs=0 OpenClawStatus call openclaw#status()
    command! -nargs=0 OpenClawConnect call openclaw#connect()
    command! -nargs=0 OpenClawDisconnect call openclaw#disconnect()
    command! -nargs=0 OpenClawRestart call openclaw#restart()
    command! -nargs=0 OpenClawSetup call openclaw#setup_wizard()
    command! -nargs=0 OpenClawDoctor call openclaw#doctor()
    command! -nargs=0 OpenClawDashboard call openclaw#dashboard()
    command! -nargs=0 OpenClawTUI call openclaw#tui()
    command! -nargs=0 OpenClawLogs call openclaw#logs()
    
    " Auto-connect if configured
    if g:openclaw_config.auto_connect
        call timer_start(1000, function('s:auto_connect'))
    else
        " Just check status on startup
        call timer_start(500, function('s:check_status_on_startup'))
    endif
    
    " Periodic status check
    if g:openclaw_config.status_refresh_ms > 0
        call timer_start(g:openclaw_config.status_refresh_ms, function('s:periodic_status_check'), {'repeat': -1})
    endif
endfunction

" Auto connect function
function! s:auto_connect(timer)
    call openclaw#status()
endfunction

" Check status on startup
function! s:check_status_on_startup(timer)
    call openclaw#status()
endfunction

" Periodic status check
function! s:periodic_status_check(timer)
    call openclaw#status()
endfunction

" Create a new session with workspace context based on current file
function! openclaw#create_session(...)
    let file_path = expand('%:p')
    let file_name = expand('%:t')
    let file_dir = expand('%:p:h')
    
    " Get optional configuration for the session
    let opts = {}
    if a:0 > 0
        let opts = a:1
    endif
    
    " Prepare session creation command
    let cmd = g:openclaw_config.command . ' session create'
    
    " Add file context if available
    if !empty(file_path)
        let cmd .= ' --file ' . shellescape(file_path)
    endif
    
    " Add model selection if specified
    if has_key(opts, 'model')
        let cmd .= ' --model ' . shellescape(opts.model)
    endif
    
    " Add custom session name if specified
    if has_key(opts, 'name')
        let cmd .= ' --name ' . shellescape(opts.name)
    endif
    
    " Add workspace directory if specified
    if has_key(opts, 'workspace_dir')
        let cmd .= ' --workspace ' . shellescape(opts.workspace_dir)
    endif
    
    echo "🦞 Creating session for " . file_name
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Session created successfully"
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to create session: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" Send a message to the current session
function! openclaw#send_to_session(message)
    let cmd = g:openclaw_config.command . ' session send ' . shellescape(a:message)
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Message sent to session"
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to send message: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" Get current session information
function! openclaw#get_session_info()
    let cmd = g:openclaw_config.command . ' session info'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Current session info:"
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to get session info: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" List available models
function! openclaw#list_models()
    let cmd = g:openclaw_config.command . ' model list'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Available models:"
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to list models: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" Switch to a specific session
function! openclaw#switch_session(session_id)
    let cmd = g:openclaw_config.command . ' session switch ' . shellescape(a:session_id)
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Switched to session " . a:session_id
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to switch session: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" Get session history
function! openclaw#get_session_history()
    let cmd = g:openclaw_config.command . ' session history'
    let result = system(cmd)
    let success = v:shell_error == 0
    
    if success
        echo "🦞 Session history:"
        echo result
    else
        echohl ErrorMsg | echom "🦞 Failed to get session history: " . (result != '' ? result : 'unknown error') | echohl None
    endif
    
    return [success, result]
endfunction

" Create commands for the new functionality
function! openclaw#setup_extended()
    command! -nargs=0 OpenClawCreateSession call openclaw#create_session()
    command! -nargs=1 OpenClawSendToSession call openclaw#send_to_session(<f-args>)
    command! -nargs=0 OpenClawSessionInfo call openclaw#get_session_info()
    command! -nargs=0 OpenClawListModels call openclaw#list_models()
    command! -nargs=1 OpenClawSwitchSession call openclaw#switch_session(<f-args>)
    command! -nargs=0 OpenClawSessionHistory call openclaw#get_session_history()
endfunction