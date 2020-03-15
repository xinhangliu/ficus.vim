" function! ficus#sort#Sort(view, by) abort {{{1
function! ficus#sort#Sort(view, by) abort
    if a:view ==# 'note'
        let sort_order = ficus#options_list('ficus_note_sort_order')
    elseif a:view ==# 'tag'
        let sort_order = ficus#options_list('ficus_tag_sort_order')
    else
        return
    endif

    let sort_order[0] = a:by
    if a:view ==# g:Ficus.current_view
        call ficus#render#Render(g:Ficus.current_view)
    endif
endfunction

" function! ficus#sort#SortReverse(view) abort {{{1
function! ficus#sort#SortReverse(view) abort
    if a:view ==# 'note'
        let sort_order = ficus#options_list('ficus_note_sort_order')
    elseif a:view ==# 'tag'
        let sort_order = ficus#options_list('ficus_tag_sort_order')
    else
        return
    endif

    let sort_order[1] = !sort_order[1]
    if a:view ==# g:Ficus.current_view
        call ficus#render#Render(g:Ficus.current_view)
    endif
endfunction

" function! ficus#sort#SortTraverse(view, reverse) abort {{{1
function! ficus#sort#SortTraverse(view, reverse) abort
    if a:view ==# 'note'
        let sort_options = ['title', 'created', 'modified']
        let sort_order = ficus#options_list('ficus_note_sort_order')
    elseif a:view ==# 'tag'
        let sort_options = ['name', 'count']
        let sort_order = ficus#options_list('ficus_tag_sort_order')
    else
        return
    endif

    let idx = index(sort_options, sort_order[0])
    if idx < 0
        let idx = 0
    endif

    let idx += a:reverse == 0 ? 1 : -1
    if idx < 0
        let idx = len(sort_options)
    elseif idx >= len(sort_options)
        let idx = 0
    endif

    let sort_order[0] = sort_options[idx]
    if a:view ==# g:Ficus.current_view
        call ficus#render#Render(g:Ficus.current_view)
    endif
endfunction

" Modeline {{{1
" vim:set foldenable foldmethod=marker:
