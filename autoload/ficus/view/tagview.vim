function! ficus#view#tagview#GetCursorTag() abort
    let line = getline('.')
    let matched = matchlist(line, '\v^\s*' . g:ficus_tag_icon . '(.*)\s\(\d+\)$')
    if empty(matched)
        return {}
    endif
    let tagname = matched[1]
    return g:Ficus.tags.getChild(tagname)
endfunction

function! s:CompareTag(tag, other) abort
    let ret = 0
    if g:ficus_tag_sort_order[0] ==# 'name'
        if a:tag.name !=# a:other.name
            let ret = a:tag.name > a:other.name ? 1 : -1
        endif
    elseif g:ficus_tag_sort_order[0] ==# 'count'
        if a:tag.notesCount() !=# a:other.notesCount()
            let ret = a:tag.notesCount() > a:other.notesCount() ? 1 : -1
        endif
    endif
    return ret
endfunction

function! ficus#view#tagview#Render() abort
    let output = ''

    let tags = copy(g:Ficus.tags.children)
    let tags = sort(tags, function('<SID>CompareTag'))
    if g:ficus_tag_sort_order[1] != 0
        let tags = reverse(tags)
    endif

    for tag in tags
        let output .= tag.renderToString()
    endfor
    return output
endfunction

function! ficus#view#tagview#openTag() abort
    let tag = ficus#view#tagview#GetCursorTag()
    if empty(tag)
        return 0
    endif

    let g:Ficus.current_notes = tag.notes
    let g:Ficus.current_notes_view = 'tag'
    let g:Ficus.current_notes_parent = tag
    call ficus#render#Render('note')
endfunction

function! ficus#view#tagview#Rename() abort
    let tag = ficus#view#tagview#GetCursorTag()
    if empty(tag)
        return 0
    endif

    let new_name = input('New tag name: ')
    if empty(new_name)
        return
    endif

    let msg = "Confirm renaming: '" . tag.name . "' -> '" . new_name
                \. "'. All the notes related to this tag will be modified."
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call tag.rename(new_name)
    endif
    call ficus#render#Render('tag')
endfunction
