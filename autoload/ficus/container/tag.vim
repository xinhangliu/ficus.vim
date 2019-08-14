let s:Tag = {}

function! ficus#container#tag#New(name) abort
    let newObj = copy(s:Tag)
    let newObj.name = a:name
    let newObj.notes = []
    let newObj.icon = g:ficus_tag_icon
    return newObj
endfunction

function! s:Tag.renderToString() abort
    let output = '  ' . self.icon . self.name . ' (' . self.notesCount() . ')' . "\n"

    return output
endfunction

function! s:Tag.rename(new_name) abort
    if self.name ==# a:new_name
        return
    endif

    let sibling = self.parent.getChild(a:new_name)
    for note in self.notes
        let note.tags = filter(note.tags, 'v:val !=# "' . self.name . '"')
        if !empty(sibling)
            if index(note.tags, a:new_name) < 0
                call add(note.tags, a:new_name)
            endif
            if empty(sibling.getNote(note.path))
                call sibling.addNote(note)
            endif
        else
            call add(note.tags, a:new_name)
        endif
        call ficus#writer#Write(note)
    endfor

    if !empty(sibling)
        call self.parent.removeChild(self)
    else
        let self.name = a:new_name
    endif
endfunction

function! s:Tag.addNote(note) abort
    call add(self.notes, a:note)
endfunction

function! s:Tag.removeNote(note) abort
    for idx in range(self.notesCount())
        if self.notes[idx].path == a:note.path
            return remove(self.notes, idx)
        endif
    endfor
    return {}
endfunction

function! s:Tag.notesCount() abort
    return len(self.notes)
endfunction

function! s:Tag.getNote(path) abort
    for note in self.notes
        if note.path ==# a:path
            return note
        endif
    endfor
    return {}
endfunction
