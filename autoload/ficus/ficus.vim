scriptencoding utf-8

function! ficus#ficus#Init() abort
    call s:LoadOptions()

    let g:Ficus = {}
    let g:Ficus.categoryInbox = ficus#container#category#New('S/Inbox')
    let g:Ficus.categoryRecent = ficus#container#category#New('S/Recent')
    let g:Ficus.categoryAll = ficus#container#category#New('S/All')

    let g:Ficus.categoryInbox.icon = g:ficus_category_icons['inbox']
    let g:Ficus.categoryRecent.icon = g:ficus_category_icons['recent']
    let g:Ficus.categoryAll.icon = g:ficus_category_icons['all']

    let g:Ficus.categoryInbox.renamable = 0
    let g:Ficus.categoryRecent.renamable = 0
    let g:Ficus.categoryAll.renamable = 0

    let g:Ficus.categoryRoot = ficus#container#category#New('S/Root')
    let g:Ficus.categoryRoot.renamable = 0
    let g:Ficus.categoryRoot.isRoot = 1
    let g:Ficus.tags = ficus#container#category#New('S/Tags')
    let g:Ficus.tags.renamable = 0

    let g:Ficus.buffer_name = '^\[ficus\]$'
    let g:Ficus.outdated = 0
    let g:Ficus.next_note_id = 0
    let g:Ficus.opened_notes = []
    let g:Ficus.current_view = 'category'
    let g:Ficus.current_notes = []
    let g:Ficus.current_notes_view = ''
    let g:Ficus.current_notes_parent = {}
    let g:Ficus.cursor_position_of_views = {}

    call ficus#automatic#AutoUpdateView()

    if !isdirectory(g:ficus_dir)
        call mkdir(g:ficus_dir, 'p')
    endif
    call ficus#ficus#UpdateData(g:ficus_dir)
endfunction

function! ficus#ficus#Sort(view, by) abort
    if a:view ==# 'note'
        let sort_order = g:ficus_note_sort_order
    elseif a:view ==# 'tag'
        let sort_order = g:ficus_tag_sort_order
    else
        return
    endif

    let sort_order[0] = a:by
    if a:view ==# g:Ficus.current_view
        call ficus#render#Render(g:Ficus.current_view)
    endif
endfunction

function! ficus#ficus#SortReverse(view) abort
    if a:view ==# 'note'
        let sort_order = g:ficus_note_sort_order
    elseif a:view ==# 'tag'
        let sort_order = g:ficus_tag_sort_order
    else
        return
    endif

    let sort_order[1] = !sort_order[1]
    if a:view ==# g:Ficus.current_view
        call ficus#render#Render(g:Ficus.current_view)
    endif
endfunction

function! ficus#ficus#SortTraverse(view, reverse) abort
    if a:view ==# 'note'
        let sort_options = ['title', 'created', 'modified']
        let sort_order = g:ficus_note_sort_order
    elseif a:view ==# 'tag'
        let sort_options = ['name', 'count']
        let sort_order = g:ficus_tag_sort_order
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

function! s:LoadOptions() abort
    let g:ficus_expand_icon = get(g:, 'ficus_expand_icon', ['▶', '▼'])
    let g:ficus_category_icons = get(g:, 'ficus_category_icons', {})
    let g:ficus_category_icons['category'] = get(g:ficus_category_icons, 'category', '')
    let g:ficus_category_icons['inbox'] = get(g:ficus_category_icons, 'inbox', '')
    let g:ficus_category_icons['recent'] = get(g:ficus_category_icons,  'recent', '')
    let g:ficus_category_icons['all'] = get(g:ficus_category_icons, 'all', '')
    let g:ficus_tag_icon = get(g:, 'ficus_tag_icon', '')
    let g:ficus_notes_seperator = get(g:, 'ficus_notes_seperator', '-')
    let g:ficus_date_format = get(g:, 'ficus_date_format', '%Y-%m-%dT%H:%M:%S%z')
    let g:ficus_category_recent_offset_days = get(g:, 'ficus_category_recent_offset_days', 7)
    let g:ficus_category_open_max_level = get(g:, 'ficus_category_open_max_level', 2)
    let g:ficus_note_sort_order = get(g:, 'ficus_note_sort_order', ['title', 0])
    let g:ficus_tag_sort_order = get(g:, 'ficus_tag_sort_order', ['count', 1])
    let g:ficus_winwidth = get(g:, 'ficus_winwidth', 35)
    let g:ficus_newnote_header = get(g:, 'ficus_newnote_header',
                \ "---\n" .
                \ "title: {{title}}\n" .
                \ "created: {{created}}\n" .
                \ "modified: {{modified}}\n" .
                \ "category: {{category}}\n" .
                \ "tags: {{tags}}\n" .
                \ "author: {{author}}\n" .
                \ "description: {{description}}\n" .
                \ "---\n")
    let g:ficus_dir = get(g:, 'ficus_dir', '~/Documents/ficus')
    let g:ficus_dir = substitute(g:ficus_dir, '\v/$', '', '')
    let g:ficus_dir = expand(g:ficus_dir)
    let g:ficus_note_extension = get(g:, 'ficus_note_extension', 'md')
    let g:ficus_delete_command = get(g:, 'ficus_delete_command', 'rm -rf')
    let g:ficus_auto_update_modified_date = get(g:, 'ficus_auto_update_modified_date', 1)
endfunction

function! ficus#ficus#AddNote(path) abort
    let note = ficus#container#note#New(a:path, g:Ficus.next_note_id)
    let g:Ficus.next_note_id += 1
    call add(g:Ficus.categoryAll.notes, note)

    let level = 1
    let parent = g:Ficus.categoryRoot
    for cate in note.category
        let categoryNode = parent.getChild(cate)
        if empty(categoryNode)
            let categoryNode = ficus#container#category#New(cate)
            call parent.addChild(categoryNode)
        endif

        if '' . g:ficus_category_open_max_level ==# '$'
                    \ || level <= g:ficus_category_open_max_level
            let categoryNode.isOpen = 1
        else
            let categoryNode.isOpen = 0
        endif
        let level += 1

        let parent = categoryNode
    endfor
    if parent.isRoot
        call g:Ficus.categoryInbox.addNote(note)
    else
        call parent.addNote(note)
    endif

    for tagname in note.tags
        let tag = g:Ficus.tags.getChild(tagname)
        if empty(tag)
            let tag = ficus#container#tag#New(tagname)
            call g:Ficus.tags.addChild(tag)
        endif
        call tag.addNote(note)
    endfor

    let current_date = strftime(g:ficus_date_format, localtime()
                \ - g:ficus_category_recent_offset_days * 24 * 60 * 60)
    if !empty(note.modified)
                \ && ficus#util#CompareDate(note.modified, current_date, g:ficus_date_format)
        call g:Ficus.categoryRecent.addNote(note)
    endif
endfunction

function! ficus#ficus#RemoveNote(note) abort
    let category = g:Ficus.categoryRoot.findChildByID(a:note.category)
    if !empty(category)
        call category.removeNote(a:note)
    endif

    for category in [g:Ficus.categoryInbox, g:Ficus.categoryRecent, g:Ficus.categoryAll]
        call category.removeNote(a:note)
    endfor

    for tagname in a:note.tags
        let tag = g:Ficus.tags.getChild(tagname)
        if !empty(tag)
            call tag.removeNote(a:note)
            if tag.notesCount() == 0
                call g:Ficus.tags.removeChild(tag)
            endif
        endif
    endfor

    for n in g:Ficus.current_notes
        if n.path ==# a:note.path
            call remove(g:Ficus.current_notes, n)
        endif
    endfor
endfunction

function! ficus#ficus#CreateNote() abort
    let fname = input('New note filename: ')
    if empty(fname)
                \ || fname ==# '.'
                \ || fname ==# '..'
                \ || fname =~? '\v[\\/:?"<>|\*]'
        echohl WarningMsg
        echo 'Filename is not valid.'
        echohl NONE
        return
    endif

    let note_path = g:ficus_dir . '/' . fname . '.' . g:ficus_note_extension
    if filereadable(note_path)
        echohl WarningMsg
        echo 'File already exists!'
        echohl NONE
        return
    endif

    let note_category = []
    let note_tags = []
    if g:Ficus.current_view ==# 'category'
        let category = ficus#view#categoryview#GetCursorCategory()
        if !empty(category) && category.renamable
            let note_category = category.idList()
        endif
    elseif g:Ficus.current_view ==# 'tag'
        let tag = ficus#view#tagview#GetCursorTag()
        if !empty(tag)
            let note_tags = [tag.name]
        endif
    elseif g:Ficus.current_view ==# 'note'
        let parent = g:Ficus.current_notes_parent
        if g:Ficus.current_notes_view ==# 'category'
            if parent.renamable
                let note_category = parent.idList()
            endif
        elseif g:Ficus.current_notes_view ==# 'tag'
            let note_tags = [parent.name]
        endif
    endif

    let header = copy(g:ficus_newnote_header)
    let header = substitute(header, '\v\{\{category}\}', join(note_category, '/'), 'g')
    let header = substitute(header, '\v\{\{tags\}\}', '[' . join(note_tags, ', ') . ']', 'g')

    let date = strftime(g:ficus_date_format)
    let header = substitute(header, '\v\{\{created\}\}', date, 'g')
    let header = substitute(header, '\v\{\{modified\}\}', date, 'g')
    let header = substitute(header, '\v\{\{[^\{\}]+\}\}', '', 'g')

    echom header
    call writefile(split(header, "\n"), note_path)
    call ficus#ficus#AddNote(note_path)
    call ficus#ficus#UpdateView()
endfunction

function! ficus#ficus#UpdateNote(path) abort
    let old_note = g:Ficus.categoryAll.getNote(a:path)
    if !empty(old_note)
        call ficus#ficus#RemoveNote(old_note)
    endif
    call ficus#ficus#AddNote(a:path)
    let g:Ficus.outdated = 1
endfunction

function! ficus#ficus#UpdateModifiedDate() abort
    if getline(1) !~# '\v^---\s*$'
        return
    endif

    let saved_curosr = getpos('.')
    let target_lineno = 0
    let target_valid = 0
    let lineno = 2
    while lineno <= line('$')
        if getline(lineno) =~# '\v^modified:.*$'
            let target_lineno = lineno
        elseif getline(lineno) =~# '\v^---\s*$'
            let target_valid = 1
            break
        endif
        let lineno += 1
    endwhile

    if target_valid && target_lineno
        let date = strftime(g:ficus_date_format)
        let date = substitute(date, '#', '\#', 'g')
        silent execute target_lineno . ',' . target_lineno . 's#\v^modified:\s*\zs.*\ze$#' . date . '#e'
        call setpos('.', saved_curosr)
    endif
endfunction

function! ficus#ficus#UpdateData(path) abort
    for f in glob(a:path . '/*.' . g:ficus_note_extension, 0, 1)
        call ficus#ficus#AddNote(f)
    endfor
endfunction

function! ficus#ficus#UpdateView() abort
    call ficus#render#Render(g:Ficus.current_view)
endfunction

function! ficus#ficus#LazyUpdateView() abort
    if g:Ficus.outdated
        call ficus#ficus#UpdateView()
    endif
endfunction
