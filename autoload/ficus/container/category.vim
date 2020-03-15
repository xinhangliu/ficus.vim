let s:RootCategoryPrefix = 'S/'

let s:Category = {}

" function! ficus#container#category#New(name) abort {{{1
function! ficus#container#category#New(name) abort
    let newObj = copy(s:Category)
    let newObj.name = a:name
    let newObj.parent = {}
    let newObj.children = []
    let newObj.notes = []
    let newObj.isOpen = 1
    let newObj.icon = ficus#options_dict('ficus_icons', 'category')
    return newObj
endfunction

" function! s:Category.renderToString(level) abort {{{1
function! s:Category.renderToString(level) abort
    let marker = ficus#options_list('ficus_expand_icon', 0)
    if self.isOpen
        let marker = ficus#options_list('ficus_expand_icon', 1)
    endif

    if empty(self.children)
        let marker = ficus#options_list('ficus_expand_icon', 2)
    endif

        let id = self.isRoot() ? s:RootCategoryPrefix . self.id() : self.id()
    let output = '{{' . id . '}}'
                \. repeat('  ', a:level) . marker . self.icon . self.name
                \. ' (' . self.notesCount() . ')' . "\n"
    if self.isOpen
        for child in self.children
            let output = output . child.renderToString(a:level + 1)
        endfor
    endif

    return output
endfunction

function! s:Category.renderToStringList(...) abort
    if a:0 > 0
        let prefix = a:1 . '/' . self.name
    else
        let prefix = self.name
    endif
    let out = [prefix]
    for child in self.children
        let out = out + child.renderToStringList(prefix)
    endfor

    return out
endfunction

" function! s:Category.renderNotes() abort {{{1
function! s:Category.renderNotes() abort
    let output = ''
    for note in self.notes
        let output = output . note.renderToString()
    endfor
    return output
endfunction

function! s:Category.isRoot() abort
    if empty(self.parent)
        return 1
    endif
    return 0
endfunction

" function! s:Category.id() abort {{{1
function! s:Category.id() abort
    return join(self.idList(), '/')
endfunction

" function! s:Category.idList() abort {{{1
function! s:Category.idList() abort
    let parent = self.parent
    let idlist = [self.name]
    while !empty(parent) && !parent.isRoot()
        call add(idlist, parent.name)
        let parent = parent.parent
    endwhile
    return reverse(idlist)
endfunction

" function! s:Category.rename(new_name) abort {{{1
function! s:Category.rename(new_name) abort
    if self.isRoot()
        return
    endif
    if self.name ==# a:new_name
        return
    endif


    let sibling = self.parent.getChild(a:new_name)
    if !empty(sibling)
        let sibling.notes += self.notes
        for child in self.children
            call sibling.addChild(child)
        endfor
        call sibling._updateDescendantNotes()
        call self.parent.removeChild(self)
    else
        let self.name = a:new_name
        call self._updateDescendantNotes()
    endif
endfunction

" function! s:Category._updateDescendantNotes() abort {{{1
function! s:Category._updateDescendantNotes() abort
    let idlist = self.idList()
    for note in self.notes
        let note.category = idlist
        call ficus#writer#Write(note)
    endfor

    for child in self.children
        call child._updateDescendantNotes()
    endfor
endfunction

" function! s:Category.findChildByID(id) abort {{{1
function! s:Category.findChildByID(id) abort
    let id = a:id
    if type(id) == 1
        let id = split(id, '/')
    endif
    if type(id) != 3 || empty(id)
        return {}
    endif

    let parent = self
    for name in id
        let child = parent.getChild(name)
        if empty(child)
            return {}
        endif
        let parent = child
    endfor
    return parent
endfunction

" function! s:Category.addChild(child) abort {{{1
function! s:Category.addChild(child) abort
    call add(self.children, a:child)
    let a:child.parent = self
endfunction

function! s:Category.removeChild(child) abort
    for idx in range(self.childrenCount())
        if self.children[idx].name == a:child.name
            return remove(self.children, idx)
        endif
    endfor
    return {}
endfunction

" function! s:Category.addNote(note) abort {{{1
function! s:Category.addNote(note) abort
    call add(self.notes, a:note)
endfunction

" function! s:Category.removeNote(note) abort {{{1
function! s:Category.removeNote(note) abort
    for idx in range(self.notesCount())
        if self.notes[idx].path == a:note.path
            return remove(self.notes, idx)
        endif
    endfor
    return {}
endfunction

" function! s:Category.getChild(name) abort {{{1
function! s:Category.getChild(name) abort
    for child in self.children
        if child.name ==# a:name
            return child
        endif
    endfor
    return {}
endfunction

" function! s:Category.childrenCount() abort {{{1
function! s:Category.childrenCount() abort
    return len(self.children)
endfunction

" function! s:Category.notesCount() abort {{{1
function! s:Category.notesCount() abort
    return len(self.notes)
endfunction

" function! s:Category.getNote(path) abort {{{1
function! s:Category.getNote(path) abort
    for note in self.notes
        if note.path ==# a:path
            return note
        endif
    endfor
    return {}
endfunction

" vim:set foldenable foldmethod=marker:
