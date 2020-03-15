" Function ficus#view#noteview#GetCursorNote() {{{1
" Get the note object under the cursor of current window.
" Args:
" Return:
function! ficus#view#noteview#GetCursorNote() abort
    let linenr = line('.')
    if getline(linenr) =~# '\v^' . escape(ficus#options('ficus_notes_seperator'), '+-~') . '+$'
        return {}
    endif

    let id = -1
    while linenr >= 1
        let matched = matchlist(getline(linenr), '\v^\[(\d+)\].*$')
        if !empty(matched)
            let id = str2nr(matched[1])
            break
        endif
        let linenr -= 1
    endwhile
    if id == -1
        return {}
    endif

    for note in g:Ficus.categoryAll.notes
        if note.id == id
            return note
        endif
    endfor
    return {}
endfunction

" Function s:CompareNote(note, other) {{{1
" Compare the given two notes.
" Args:
"   note: Note -> The note.
"   other: Note -> the other note.
" Return:
"   : number -> 0 if equal, 1 if greater, -1 if less.
function! s:CompareNote(note, other) abort
    let ret = 0
    if index(['title'], ficus#options_list('ficus_note_sort_order', 0)) >= 0
        let str1 = get(a:note, ficus#options_list('ficus_note_sort_order', 0), '')
        let str2 = get(a:other, ficus#options_list('ficus_note_sort_order', 0), '')
        if str1 !=# str2
            let ret = str1 ># str2 ? 1 : -1
        endif
    elseif index(['created', 'modified'], ficus#options_list('ficus_note_sort_order', 0)) >= 0
        let str1 = get(a:note, ficus#options_list('ficus_note_sort_order', 0), '')
        let str2 = get(a:other, ficus#options_list('ficus_note_sort_order', 0), '')
        let ret = ficus#util#CompareDate(str1, str2, ficus#options('ficus_date_format'))
    endif

    return ret
endfunction

" Function ficus#view#noteview#Render(notes) {{{1
" Render the noteview of the given notes list.
" Args:
"   notes: List[Note] -> The notes list to render.
" Return:
function! ficus#view#noteview#Render(notes) abort
    let output = repeat(ficus#options('ficus_notes_seperator'), ficus#options('ficus_winwidth')) . "\n"

    let notes = copy(a:notes)
    let notes = sort(notes, function('<SID>CompareNote'))
    if ficus#options_list('ficus_note_sort_order', 1) != 0
        let notes = reverse(notes)
    endif

    for note in notes
        let output .= '[' . note.id . ']' . note.title . "\n"
        if !empty(note.description)
            let output .= '> ' . note.description . "\n"
        endif
        let output .= '* ' . note.modified . "\n"
        if !empty(note.tags)
            let output .= '#' . join(note.tags, ' #') . "\n"
        endif
        let output .= repeat(ficus#options('ficus_notes_seperator'), ficus#options('ficus_winwidth')) . "\n"
    endfor

    return output
endfunction

" Function ficus#view#noteview#OpenNote(flag, stay) {{{1
" Open the file of the note.
" Args:
"   flag: char -> 't' open in newtab,
"                 'p' open in previous window,
"                 's' open in split of previous window,
"                 'v' open in vsplit of previous window.
"  stay: bool -> Stay in the Ficus window if True after open the note.
" Return:
function! ficus#view#noteview#OpenNote(flag, stay) abort
    let note = ficus#view#noteview#GetCursorNote()
    if empty(note)
        return
    endif

    if index(g:Ficus.opened_notes, note) < 0
        call add(g:Ficus.opened_notes, note)
    endif

    let current_winnr = winnr()
    let previous_winnr = winnr('#')
    let win_count = winnr('$')

    if a:flag ==# 't'
        execute 'silent tabedit' note.path
    elseif win_count == 1
        execute 'silent keepalt vertical rightbelow split' note.path
        execute current_winnr . 'wincmd w'
        execute 'vertical resize' ficus#options('ficus_winwidth')
        wincmd p
    elseif win_count >= 2
        execute previous_winnr . 'wincmd w'
        if a:flag ==# 'p'
            if !&modified
                execute 'silent keepalt edit' note.path
            else
                execute 'silent keepalt split' note.path
            endif
        elseif a:flag ==# 's'
            execute 'silent keepalt split' note.path
        elseif a:flag ==# 'v'
            execute 'silent keepalt vertical split' note.path
        endif
    endif

    if ficus#options('ficus_auto_update_lastmod')
        call ficus#automatic#AutoUpdateLastmod(note)
    endif

    call ficus#automatic#AutoUpdateNote(note)
    if a:stay
        execute current_winnr . 'wincmd w'
    endif
endfunction

" Function ficus#view#noteview#GoBack() {{{1
" Go back to the parent view of current notes list.
" Args:
" Return:
function! ficus#view#noteview#GoBack() abort
    call ficus#render#Render(g:Ficus.current_notes_view)
endfunction

" Function ficus#view#noteview#Rename() {{{1
" Rename the filename of the note under the cursor in the current window.
" Args:
" Return:
function! ficus#view#noteview#Rename() abort
    let note = ficus#view#noteview#GetCursorNote()
    if empty(note)
        return 0
    endif

    let new_name = input('New note name: ')
    if empty(new_name)
        return
    endif

    let msg = "Confirm renaming: '" . fnamemodify(note.path, ':p:t')
                \. "' -> '" . new_name . '.' . ficus#options('ficus_note_extension') . "'"
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call note.rename(new_name)
    endif
endfunction

" Function ficus#view#noteview#DeleteNote() {{{1
" Delete the file of note under the cursor.
" Command of deleting can be specified by option `g:ficus_delete_command`.
" Args:
" Return:
function! ficus#view#noteview#DeleteNote() abort
    let note = ficus#view#noteview#GetCursorNote()
    if empty(note)
        return 0
    endif

    let msg = 'Confirm deleting: ' . note.path
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call system(ficus#options('ficus_delete_command') . ' ' . shellescape(note.path))
        if v:shell_error == 0
            call ficus#RemoveNote(note)
            echo 'Note deleted'
        else
            echohl WarningMsg
                echo 'Failed to delete note'
            echohl NONE
        endif
    endif
    call ficus#render#Render('note')
endfunction

" Modeline {{{1
" vim:set foldenable foldmethod=marker:
