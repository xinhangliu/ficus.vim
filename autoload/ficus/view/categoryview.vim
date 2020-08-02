" Function ficus#view#category#GetCursorCategory() {{{1
" Get category object under cursor.
" Args:
" Return:
"   : Category -> Matched category. If valid category is not found, `{}` is
"   returned.
function! ficus#view#categoryview#GetCursorCategory() abort
    let line = getline('.')
    let id = matchlist(line, '\v^\{\{(.*)\}\}.*$')
    if empty(id)
        return {}
    endif
    let id = id[1]
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

" Function ficus#view#categoryview#Render() {{{1
" Render categoryview at current window.
" Args:
" Return:
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

" Function ficus#view#categoryview#OpenFold() {{{1
" Expand the category under the cursor in current window.
" Args:
" Return:
function! ficus#view#categoryview#OpenFold() abort
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

" Function ficus#view#categoryview#CloseFold() {{{1
" Collapse the category under the cursor in current window.
" Args:
" Return:
function! ficus#view#categoryview#CloseFold() abort
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

" Function ficus#view#categoryview#ToggleFold() {{{1
" Expand/Collapse the category under the cursor in current window.
" Args:
" Return:
function! ficus#view#categoryview#ToggleFold() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    let category.isOpen = !category.isOpen
    call ficus#render#Render('category')
endfunction

" Function ficus#view#categoryview#OpenCategory() {{{1
" Open the noteview of the category under the cursor in current window.
" Args:
" Return:
function! ficus#view#categoryview#OpenCategory() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    let g:Ficus.current_notes = category.notes
    let g:Ficus.current_notes_view = 'category'
    let g:Ficus.current_notes_parent = category
    call ficus#render#Render('note')
endfunction

" Function ficus#view#categoryview#Rename() {{{1
" Rename the category under the cursor in current window.
" Args:
" Return:
function! ficus#view#categoryview#Rename() abort
    let category = ficus#view#categoryview#GetCursorCategory()
    if empty(category)
        return 0
    endif

    if category.isRoot()
        call ficus#util#Info('Cannot rename this category.')
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

" Modeline {{{1
" vim:set foldenable foldmethod=marker:
