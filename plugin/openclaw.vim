" Plugin file for openclaw.vim
" Automatically loads the plugin on Vim startup

" Only load once
if exists('g:openclaw_loaded')
    finish
endif
let g:openclaw_loaded = 1

" Setup the plugin with default configuration
call openclaw#setup()

" Setup extended functionality
call openclaw#setup_extended()