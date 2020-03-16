function! ficus#wm#Open() abort
    let ficuswinnr = bufwinnr(g:Ficus.buffer_name)
    if ficuswinnr == -1
        let mode = 'vertical'
        let openpos = 'topleft'
        let width = ficus#options('ficus_winwidth')
        execute 'silent keepalt' openpos mode width . 'split' g:Ficus.buffer_name
    elseif winnr() != ficuswinnr
            execute ficuswinnr . 'wincmd w'
    endif

    if g:Ficus.current_view ==# 'category'
        setlocal filetype=ficus
    elseif g:Ficus.current_view ==# 'note'
        setlocal filetype=ficusnotes
    endif

    call ficus#render#Render(g:Ficus.current_view)
endfunction

function! ficus#wm#Close() abort
    let ficuswinnr = bufwinnr(g:Ficus.buffer_name)
    if ficuswinnr != -1
        execute ficuswinnr . 'wincmd c'
    endif
endfunction

function! ficus#wm#Toggle() abort
    let ficuswinnr = bufwinnr(g:Ficus.buffer_name)
    if ficuswinnr == -1
        call ficus#wm#Open()
        return
    endif
    call ficus#wm#Close()
endfunction
