function! ficus#view#noteview#GetCursorNote() abort
    let linenr = line('.')
    if getline(linenr) =~# '\v^' . escape(g:ficus_notes_seperator, '+-~') . '+(\d+)?$'
        return {}
    endif

    let id = -1
    while linenr <= line('$')
        let linenr += 1
        let matched = matchlist(getline(linenr), '\v^\-+(\d+)$')
        if !empty(matched)
            let id = str2nr(matched[1])
            break
        endif
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

function! s:CompareNote(note, other) abort
    let ret = 0
    if index(['title'], g:ficus_note_sort_order[0]) >= 0
        let str1 = get(a:note, g:ficus_note_sort_order[0], '')
        let str2 = get(a:other, g:ficus_note_sort_order[0], '')
        if str1 !=# str2
            let ret = str1 ># str2 ? 1 : -1
        endif
    elseif index(['created', 'modified'], g:ficus_note_sort_order[0]) >= 0
        let str1 = get(a:note, g:ficus_note_sort_order[0], '')
        let str2 = get(a:other, g:ficus_note_sort_order[0], '')
        let ret = ficus#util#CompareDate(str1, str2, g:ficus_date_format)
    endif

    return ret
endfunction

function! ficus#view#noteview#Render(notes) abort
    let output = repeat(g:ficus_notes_seperator, g:ficus_winwidth) . "\n"

    let notes = copy(a:notes)
    let notes = sort(notes, function('<SID>CompareNote'))
    if g:ficus_note_sort_order[1] != 0
        let notes = reverse(notes)
    endif

    for note in notes
        let output .= note.title . "\n"
        if !empty(note.description)
            let output .= '> ' . note.description . "\n"
        endif
        let output .= '* ' . note.modified . "\n"
        let tag_str = ''
        for tag in note.tags
            let tag_str .= '#' . tag . ' '
        endfor
        if !empty(tag_str)
            let output .= tag_str . "\n"
        endif
        let output .= repeat(g:ficus_notes_seperator, g:ficus_winwidth - len(note.id)) . note.id . "\n"
    endfor

    return output
endfunction

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
        execute 'vertical resize' g:ficus_winwidth
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

    if g:ficus_auto_update_modified_date
        call ficus#automatic#AutoUpdateModifiedDate(note)
    endif

    call ficus#automatic#AutoUpdateNote(note)
    if a:stay
        execute current_winnr . 'wincmd w'
    endif
endfunction

function! ficus#view#noteview#GoBack() abort
    call ficus#render#Render(g:Ficus.current_notes_view)
endfunction

function! ficus#view#noteview#Rename() abort
    let note = ficus#view#noteview#GetCursorNote()
    if empty(note)
        return 0
    endif

    let new_name = input('New note name: ')
    if empty(new_name)
        return
    endif

    let msg = "Confirm renaming: '" . fnamemodify(note.path, ':p:t') . "' -> '" . new_name
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call note.rename(new_name)
    endif
endfunction

function! ficus#view#noteview#DeleteNote() abort
    let note = ficus#view#noteview#GetCursorNote()
    if empty(note)
        return 0
    endif

    let msg = 'Confirm deleting: ' . note.path
    let choice = confirm(msg, "&Yes\n&No", 2)
    if choice == 1
        call system(g:ficus_delete_command . ' ' . shellescape(note.path))
        if v:shell_error == 0
            call ficus#ficus#RemoveNote(note)
            echo 'Note deleted'
        else
            echohl WarningMsg
                echo 'Failed to delete note'
            echohl NONE
        endif
    endif
    call ficus#render#Render('note')
endfunction
