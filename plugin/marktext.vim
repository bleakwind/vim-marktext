" vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4: */
"
" +--------------------------------------------------------------------------+
" | $Id: marktext.vim 2025-05-23 02:30:17 Bleakwind Exp $                    |
" +--------------------------------------------------------------------------+
" | Copyright (c) 2008-2025 Bleakwind(Rick Wu).                              |
" +--------------------------------------------------------------------------+
" | This source file is marktext.vim.                                        |
" | This source file is release under BSD license.                           |
" +--------------------------------------------------------------------------+
" | Author: Bleakwind(Rick Wu) <bleakwind@qq.com>                            |
" +--------------------------------------------------------------------------+
"

if exists('g:marktext_plugin') || &compatible
    finish
endif
let g:marktext_plugin = 1

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" ============================================================================
" 01: marktext_toc setting
" ============================================================================
let g:marktext_toc_enabled      = get(g:, 'marktext_toc_enabled',       0)
let g:marktext_toc_maxlevel     = get(g:, 'marktext_toc_maxlevel',      9)
let g:marktext_toc_autoupdate   = get(g:, 'marktext_toc_autoupdate',    1)

" ============================================================================
" 02: marktext_time setting
" ============================================================================
let g:marktext_time_enabled     = get(g:, 'marktext_time_enabled',      0)
let g:marktext_time_tformat     = get(g:, 'marktext_time_tformat',      '%Y-%m-%d %H:%M:%S')
let g:marktext_time_autoupdate  = get(g:, 'marktext_time_autoupdate',   1)

" ============================================================================
" 01: marktext_toc detail
" g:marktext_toc_enabled = 1
" ============================================================================
if exists('g:marktext_toc_enabled') && g:marktext_toc_enabled == 1

    " --------------------------------------------------
    " marktext#TocInsert
    " --------------------------------------------------
    function! marktext#TocInsert() abort
        let l:data_list = marktext#TocBuild()
        call append(line('.') - 1, [ '<!-- MARKTEXT_TOC_START -->', ''] + l:data_list + [ '', '<!-- MARKTEXT_TOC_FINISH -->'])
    endfunction

    " --------------------------------------------------
    " marktext#TocUpdate
    " --------------------------------------------------
    function! marktext#TocUpdate() abort
        let l:save_pos = getpos('.')
        let l:toc_start = -1
        let l:toc_finish = -1
        let l:con_all = getline(1, '$')
        " find the toc section
        for il in range(1, len(l:con_all))
            let l:line = l:con_all[il - 1]
            if l:line =~# '<!-- MARKTEXT_TOC_START -->'
                let l:toc_start = il
            elseif l:line =~# '<!-- MARKTEXT_TOC_FINISH -->' && l:toc_start > 0
                let l:toc_finish = il
                break
            endif
        endfor
        " if toc found update
        if l:toc_start > 0 && l:toc_finish > 0
            let new_toc = marktext#TocBuild()
            if !empty(new_toc)
                silent execute (l:toc_start + 1).','.(l:toc_finish - 1).'d'
                call append(l:toc_start, [ ''] + new_toc + [''])
            endif
        endif
        call setpos('.', l:save_pos)
    endfunction

    " --------------------------------------------------
    " marktext#TocBuild
    " --------------------------------------------------
    function! marktext#TocBuild() abort
        let l:data_list = []
        let l:head_list = marktext#TocHeading()
        for il in l:head_list
            let l:level = il.level
            let l:text = il.text
            let l:anchor = marktext#TocAnchor(l:text)
            let l:indent = repeat('    ', l:level - 1)
            let l:line = l:indent.'- ['.l:text.'](#'.l:anchor.')'
            call add(l:data_list, l:line)
        endfor
        return l:data_list
    endfunction

    " --------------------------------------------------
    " marktext#TocHeading
    " --------------------------------------------------
    function! marktext#TocHeading() abort
        let l:head_list = []
        let l:con_all = getline(1, '$')
        let l:prev_line = ''
        let l:prev_long = 0
        for il in range(1, len(l:con_all))
            let l:line = l:con_all[il - 1]
            " check heading #
            let l:matches = matchlist(l:line, '^\(#\+\)\s*\(.*\)$')
            if !empty(l:matches)
                let l:level = len(l:matches[1])
                if l:level <= g:marktext_toc_maxlevel
                    call add(l:head_list, { 'level': l:level, 'text': l:matches[2], 'lnum': il })
                endif
                continue
            endif
            " check heading =
            if l:line =~ '^=\+$' && !empty(l:prev_line) && l:prev_long == il - 1
                call add(l:head_list, { 'level': 1, 'text': l:prev_line, 'lnum': l:prev_long })
                continue
            endif
            " check heading -
            if l:line =~ '^-\+$' && !empty(l:prev_line) && l:prev_long == il - 1
                call add(l:head_list, { 'level': 2, 'text': l:prev_line, 'lnum': l:prev_long })
                continue
            endif
            let l:prev_line = l:line
            let l:prev_long = il
        endfor
        return l:head_list
    endfunction

    " --------------------------------------------------
    " marktext#TocAnchor
    " --------------------------------------------------
    function! marktext#TocAnchor(text) abort
        let l:anchor = tolower(a:text)
        let l:anchor = substitute(l:anchor, '[!?.,:;*"''<>()\[\]{}\\\|`~#$%^&=+/]', '', 'g')
        let l:anchor = substitute(l:anchor, '\s\+', '-', 'g')
        let l:anchor = substitute(l:anchor, '-\+', '-', 'g')
        let l:anchor = substitute(l:anchor, '^-\|-$', '', 'g')
        return l:anchor
    endfunction

    " --------------------------------------------------
    " MarktextCmdToc
    " --------------------------------------------------
    augroup MarktextCmdToc
        autocmd!
        if g:marktext_toc_autoupdate
            autocmd BufWritePre *.md call marktext#TocUpdate()
        endif
    augroup END

    " --------------------------------------------------
    " command
    " --------------------------------------------------
    command! MarktextToc call marktext#TocInsert()

endif

" ============================================================================
" 02: marktext_time detail
" g:marktext_time_enabled = 1
" ============================================================================
if exists('g:marktext_time_enabled') && g:marktext_time_enabled == 1

    " --------------------------------------------------
    " marktext#TimeInsert
    " --------------------------------------------------
    function! marktext#TimeInsert() abort
        let l:data_list = strftime(g:marktext_time_tformat)
        execute "normal! i".l:data_list."\<Esc>"
    endfunction

    " --------------------------------------------------
    " marktext#TimeUpdate
    " --------------------------------------------------
    function! marktext#TimeUpdate(...)
        let l:save_pos = getpos('.')
        let l:con_get = getline(1, '$')
        let l:con_len = len(l:con_get)
        for il in range(1, l:con_len)
            let l:line = ''
            if l:con_get[il-1] =~ '\v\$[0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}\:[0-9]{2}\:[0-9]{2}\c'
                let l:line = substitute(l:con_get[il-1], '\v\$[0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}\:[0-9]{2}\:[0-9]{2}\c', '$'.strftime(g:marktext_time_tformat), 'g')
                call setline(il, l:line)
            endif
        endfor
        call setpos('.', l:save_pos)
    endfunction

    " --------------------------------------------------
    " MarktextCmdTime
    " --------------------------------------------------
    augroup MarktextCmdTime
        autocmd!
        if g:marktext_time_autoupdate
            autocmd BufWritePre *.md call marktext#TimeUpdate()
        endif
    augroup END

    " --------------------------------------------------
    " command
    " --------------------------------------------------
    command! MarktextTime call marktext#TimeInsert()

endif

" ============================================================================
" Other
" ============================================================================
let &cpoptions = s:save_cpo
unlet s:save_cpo

