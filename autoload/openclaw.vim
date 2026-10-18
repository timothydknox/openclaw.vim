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

" Setup function
function! openclaw#setup(opts)
    " Merge options with default config
    if exists('a:opts')
        for [key, value] in items(a:opts)
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