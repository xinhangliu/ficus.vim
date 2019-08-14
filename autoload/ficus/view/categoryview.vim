function! ficus#view#categoryview#GetCursorCategory() abort
    let line = getline('.')
    let markers = '(' . escape(join(g:ficus_expand_icon, '|'), '+-~') . '|  )'
    let icons = '(' . escape(join(values(g:ficus_category_icons), '|'), '+-~') . ')'
    let id = matchlist(line, '\v^\s*' . markers . icons . '(.*)\s\(\d+\)$')
    if empty(id)
        return {}
    endif
    let id = id[3]
    if id ==# 'S/Inbox'
        return g:Ficus.categoryInbox
    elseif id ==# 'S/Recent'
        return g:Ficus.categoryRecent
    elseif id ==# 'S/All'
        return g:Ficus.categoryAll
    endif
    let category = g:Ficus.categoryRoot.findChildByID(id)
    return category
endfunction

function! ficus#view#categoryview#Render() abort
    let output = ''
    let output .= g:Ficus.categoryInbox.renderToString(0)
    let output .= g:Ficus.categoryRecent.renderToString(0)
    let output .= g:Ficus.categoryAll.renderToString(0)

    for child in g:Ficus.categoryRoot.children
        let output .= child.renderToString(0)
    endfor
    return output
endfunction

function! ficus#view#categoryview#openFold() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    if category.isOpen
        return
    endif
    let category.isOpen = 1
    call ficus#render#Render('category')
endfunction

function! ficus#view#categoryview#closeFold() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    if !category.isOpen
        return
    endif
    let category.isOpen = 0
    call ficus#render#Render('category')
endfunction

function! ficus#view#categoryview#toggleFold() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    let category.isOpen = !category.isOpen
    call ficus#render#Render('category')
endfunction

function! ficus#view#categoryview#openCategory() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    let g:Ficus.current_notes = category.notes
    let g:Ficus.current_notes_view = 'category'
    let g:Ficus.current_notes_parent = category
    call ficus#render#Render('note')
endfunction

function! ficus#view#categoryview#Rename() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    if !category.renamable
        echo 'Cannot rename this category.'
        return
    endif

    let new_name = input('New category name: ')
    if empty(new_name)
        return
    endif

    let msg = "Confirm renaming: '" . category.name . "' -> '" . new_name
                \. "'. All the notes related to this category will be modified."
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call category.rename(new_name)
    endif
    call ficus#render#Render('category')
endfunction
