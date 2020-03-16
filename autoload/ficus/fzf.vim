if !exists('g:Ficus')
    finish
endif
" Categories {{{1
function! ficus#fzf#categories(...) abort
    stopinsert
    return fzf#run(fzf#wrap(
                \ 'ficus-categories',
                \ {
                \   'source': ficus#port#categories(),
                \   'sink': function('s:categories_handler'),
                \   'options': ['--prompt=FICUS:categories> ']
                \ },
                \ a:0 > 0 ? a:1 : 0
                \))
endfunction

function! s:categories_handler(line) abort
    execute 'normal! a' . a:line
endfunction
" }}}
" Tags {{{1
function! ficus#fzf#tags(...) abort
    stopinsert
    return fzf#run(fzf#wrap(
                \ 'ficus-tags',
                \ {
                \   'source': ficus#port#tags(),
                \   'sink*': function('s:tags_handler'),
                \   'options': ['--multi', '--no-sort', '--prompt=FICUS:tags> ']
                \ },
                \ a:0 > 0 ? a:1 : 0
                \))
endfunction

function! s:tags_handler(lines) abort
    let out = join(a:lines, ', ')
    if empty(out)
        return
    endif
    execute 'normal! a' . out
endfunction
" }}}
" Notes {{{1
function! ficus#fzf#notes(...) abort
    stopinsert
    return fzf#run(fzf#wrap(
                \ 'ficus-notes',
                \ {
                \   'source': s:notes_source(),
                \   'sink*': function('s:notes_handler'),
                \   'options': [
                \       '--multi',
                \       '--ansi',
                \       '--prompt=FICUS:notes> ',
                \       '--expect=ctrl-t,ctrl-p'
                \   ],
                \ },
                \ a:0 > 0 ? a:1 : 0
                \))
endfunction

function! s:notes_source() abort
    let notes = []
    for note in g:Ficus.categoryAll.notes
        let relpath = substitute(
                    \ note.path,
                    \ '\v^' . escape(expand(ficus#options('ficus_dir')), '/') . '\/?',
                    \ '',
                    \ ''
                    \ )
        let s = '[0m[35m' . relpath . '[0m[37m: [0m' . note.title
        call add(notes, s)
    endfor
    return notes
endfunction

function! s:notes_handler(lines) abort
    if len(a:lines) < 2
        return
    endif

    let action = a:lines[0]
    let targets = a:lines[1:]

    let out = ''
    for target in targets
        let parts = split(target, ': ', 1)
        let relpath = parts[0]
        let title = join(parts[1:], ': ')

        if len(targets) > 1
            let out .= '- '
        endif
        if action ==# 'ctrl-t'
            let out .= title
        elseif action ==# 'ctrl-p'
            let out .= relpath
        else
            let out .= '[' . title . '](' . relpath . ')'
        endif
        if len(targets) > 1
            let out .= "\n"
        endif
    endfor

    execute 'normal! a' . out
endfunction
" }}}
" vim: fdm=marker:
