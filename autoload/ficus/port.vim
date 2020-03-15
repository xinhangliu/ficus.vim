function! ficus#port#categories() abort
    if !exists('g:Ficus')
        return []
    endif

    let categories = []
    for child in g:Ficus.categoryRoot.children
        let categories += child.renderToStringList()
    endfor
    return categories
endfunction

function! ficus#port#tags() abort
    if !exists('g:Ficus')
        return []
    endif

    let tags = copy(g:Ficus.tags.children)
    let tags = sort(tags, {tag, other ->
                \tag.notesCount() == other.notesCount() ? 0 :
                \tag.notesCount() < other.notesCount() ? 1 : -1})
    call map(tags, 'v:val.name')
    return tags
endfunction

function! ficus#port#notes() abort
    if !exists('g:Ficus')
        return []
    endif

    return g:Ficus.categoryAll.notes
endfunction
