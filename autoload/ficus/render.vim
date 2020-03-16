function! ficus#render#Render(view) abort
    let ficuswinnr = bufwinnr(g:Ficus.buffer_name)
    if ficuswinnr == -1
        let g:Ficus.outdated = 1
        return
    elseif ficuswinnr != winnr()
        execute ficuswinnr . 'wincmd w'
    endif

    let g:Ficus.cursor_position_of_views[g:Ficus.current_view] = [line('.'), col('.'), line('w0')]

    if a:view ==# 'category'
        let output = ficus#view#categoryview#Render()
        setlocal filetype=ficus
    elseif a:view ==# 'note'
        let output = ficus#view#noteview#Render(g:Ficus.current_notes)
        setlocal filetype=ficusnotes
    elseif a:view ==# 'tag'
        let output = ficus#view#tagview#Render()
        setlocal filetype=ficustags
    else
        return
    endif

    let lazyredraw_save = &lazyredraw
    set lazyredraw
    let eventignore_save = &eventignore
    set eventignore=all
    setlocal modifiable
    silent %delete _
    silent 0put =output
    if empty(getline('$'))
        silent $delete _
    endif
    setlocal nomodifiable
    let scrolloff_save = &scrolloff
    set scrolloff=0

    let cursor_pos = get(g:Ficus.cursor_position_of_views, a:view, [1, 1, 1])
    call cursor(cursor_pos[2], 1)
    normal! zt
    call cursor(cursor_pos[0], cursor_pos[1])

    let &scrolloff = scrolloff_save

    let &lazyredraw  = lazyredraw_save
    let &eventignore = eventignore_save

    let g:Ficus.outdated = 0
    let g:Ficus.previous_view = g:Ficus.current_view
    let g:Ficus.current_view = a:view
endfunction
