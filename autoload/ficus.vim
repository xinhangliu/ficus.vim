scriptencoding utf-8

" Global variables {{{1
let g:ficus_expand_icon = get(g:, 'ficus_expand_icon', ['▶', '▼', '  '])
let g:ficus_icons = get(g:, 'ficus_icons', {})
let g:ficus_icons['category'] = get(g:ficus_icons, 'category', '')
let g:ficus_icons['inbox'] = get(g:ficus_icons, 'inbox', '')
let g:ficus_icons['recent'] = get(g:ficus_icons,  'recent', '')
let g:ficus_icons['all'] = get(g:ficus_icons, 'all', '')
let g:ficus_icons['tag'] = get(g:ficus_icons, 'tag', '')
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
let g:ficus_auto_update_lastmod = get(g:, 'ficus_auto_update_lastmod', 0)

" Function s:EchoError(msg) {{{1
" Echo the given message with ErrorMsg highlight.
" Args:
"   msg: string -> The message to display.
" Return:
function! s:EchoError(msg) abort
    echohl ErrorMsg
    echo '[Ficus] ' . a:msg
    echohl NONE
endfunction

" Function s:CheckRequirements() {{{1
" Check if requirements are satisfied.
" Args:
" Return:
"   :bool -> True if requirements are satisfied.
function! s:CheckRequirements() abort
    if exists('s:requirements_satisfied')
        return s:requirements_satisfied
    endif

    if g:ficus_note_extension ==# 'md'
        if !has('python3')
            call s:EchoError('Python3 support is required.')
            return 0
        endif

        let l:ret = 1
python3 << EOF
import vim
try:
    import ruamel.yaml
except ImportError:
    vim.command('let l:ret = %d' % 0)
EOF
        if !l:ret
            call s:EchoError('ruamel.yaml package is required.')
            return 0
        endif
    endif

    let s:requirements_satisfied = 1
    return 1
endfunction

" Function s:Init() {{{1
function! s:Init() abort
    let g:Ficus = {}
    let g:Ficus.categoryInbox = ficus#container#category#New('Inbox')
    let g:Ficus.categoryRecent = ficus#container#category#New('Recent')
    let g:Ficus.categoryAll = ficus#container#category#New('All')

    let g:Ficus.categoryInbox.icon = g:ficus_icons['inbox']
    let g:Ficus.categoryRecent.icon = g:ficus_icons['recent']
    let g:Ficus.categoryAll.icon = g:ficus_icons['all']

    let g:Ficus.categoryRoot = ficus#container#category#New('Root')
    let g:Ficus.tags = ficus#container#category#New('Tags')

    let g:Ficus.buffer_name = '__ficus__'
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
    call s:UpdateData(g:ficus_dir)
endfunction

" Function s:UpdateData(path) {{{1
" Search for note files in path, and add them.
" Args:
"   path: string -> Parent path of note files.
" Return:
function! s:UpdateData(path) abort
    for f in glob(a:path . '/*.' . g:ficus_note_extension, 0, 1)
        call s:AddNote(f)
    endfor
endfunction

" Function s:UpdateView() {{{1
" Rerender current view.
function! s:UpdateView() abort
    call ficus#render#Render(g:Ficus.current_view)
endfunction

" Function ficus#LazyUpdateView() {{{1
" Lazy rerender current view.
function! ficus#LazyUpdateView() abort
    if g:Ficus.outdated
        call s:UpdateView()
    endif
endfunction

" Function s:AddNote(path) {{{1
" Add note to data model.
" Args:
"   path: string -> Path of the note file.
" Return:
function! s:AddNote(path) abort
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
    if parent.isRoot()
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
                \ && ficus#util#CompareDate(note.modified, current_date, g:ficus_date_format) > 0
        call g:Ficus.categoryRecent.addNote(note)
    endif
endfunction

" Function ficus#RemoveNote(note) {{{1
" Remove the note from data model.
" Args:
"   note: Note -> The note to remove.
" Return:
function! ficus#RemoveNote(note) abort
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

" Function ficus#CreateNote() {{{1
" Create a new note.
" Args:
" Return:
function! ficus#CreateNote() abort
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
        if !empty(category) && !category.isRoot()
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
            if !parent.isRoot()
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

    call writefile(split(header, "\n"), note_path)
    call s:AddNote(note_path)
    call s:UpdateView()
endfunction

" Function ficus#UpdateNote(path) {{{1
" Update the existing note file to data model.
" Args:
"   path: string -> The target note file path.
" Return:
function! ficus#UpdateNote(path) abort
    let old_note = g:Ficus.categoryAll.getNote(a:path)
    if !empty(old_note)
        call ficus#RemoveNote(old_note)
    endif
    call s:AddNote(a:path)
    let g:Ficus.outdated = 1
endfunction

" Function ficus#UpdateLastmod() {{{1
" Update note's `modified` metadata of current buffer.
" Args:
" Return:
function! ficus#UpdateLastmod() abort
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

" Function ficus#Ficus(bang) {{{1
function! ficus#Ficus(bang) abort
    if !s:CheckRequirements()
        return
    endif

    if !exists('g:Ficus')
        call s:Init()
    endif
    if a:bang
        call ficus#wm#Close()
    else
        call ficus#wm#Open()
    endif
endfunction

" Function ficus#FicusToggle() {{{1
function! ficus#FicusToggle() abort
    if !s:CheckRequirements()
        return
    endif

    if !exists('g:Ficus')
        call s:Init()
    endif
    call ficus#wm#Toggle()
endfunction

" Function ficus#FicusReload() {{{1
function! ficus#FicusReload() abort
    if !s:CheckRequirements()
        return
    endif

    unlet! g:Ficus
    call s:Init()
    call s:UpdateView()
endfunction

" vim:set foldenable foldmethod=marker:
