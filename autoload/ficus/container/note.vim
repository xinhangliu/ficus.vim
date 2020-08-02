let s:Note = {}

" function! ficus#container#note#New(path, id) abort {{{1
function! ficus#container#note#New(path, id) abort
    let newObj = copy(s:Note)
    let newObj.path = a:path
    let newObj.id = a:id
    call newObj.parse()
    return newObj
endfunction

" function! s:Note.parse() abort {{{1
function! s:Note.parse() abort
    let metadata = ficus#reader#Read(self.path)
    let self.title = get(metadata, 'title', '')
    let self.author = get(metadata, 'author', '')
    let self.created = get(metadata, 'created', '')
    let self.modified = get(metadata, 'modified', '')
    let self.description = get(metadata, 'description', '')
    let self.category = get(metadata, 'category', [])
    let self.tags = get(metadata, 'tags', [])
endfunction

" function! s:Note.rename(new_name) abort {{{1
function! s:Note.rename(new_name) abort
    let new_path = fnamemodify(self.path, ':p:h') . '/' . a:new_name . '.' . ficus#options('ficus_note_extension')
    if filereadable(expand(new_path))
        call ficus#util#Error('File already exists!')
        return
    endif

    let ret = system('mv "' . self.path . '" "' . new_path . '"')
    if v:shell_error != 0
        call ficus#util#Error('Failed to rename this note.')
        return
    endif
    let self.path = new_path
endfunction

" function! s:Note.renderToString() abort {{{1
function! s:Note.renderToString() abort
    let output = ''
    let output = output . self.title

    return output
endfunction

" vim:set foldenable foldmethod=marker:
