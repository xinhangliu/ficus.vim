let s:Note = {}

function! ficus#container#note#New(path, id) abort
    let newObj = copy(s:Note)
    let newObj.path = a:path
    let newObj.id = a:id
    call newObj.parse()
    return newObj
endfunction

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

function! s:Note.rename(new_name) abort
    let new_path = fnamemodify(self.path, ':p:h') . '/' . a:new_name
    if filereadable(expand(new_path))
        echohl ErrorMsg
            echo 'File already exists!'
        echohl NONE
        return
    endif

    let ret = system('mv "' . self.path . '" "' . new_path . '"')
    if v:shell_error != 0
        echohl ErrorMsg
            echo 'Failed to rename this note.'
        echohl NONE
        return
    endif
    let self.path = new_path
endfunction

function! s:Note.parse2() abort
    let header = readfile(self.path)
    let is_find_open = 0
    let self.title = 'No title'
    let self.author = ''
    let self.created = ''
    let self.modified = ''
    let self.description = ''
    let self.category = []
    let self.tags = []
    for line in header
        if !is_find_open && line =~# '\v^---\s*$'
            let is_find_open = 1
            continue
        endif
        if is_find_open && line =~# '\v^---\s*$'
            break
        endif
        if !is_find_open
            continue
        endif

        if self.title ==# 'No title'
            let self.title = get(matchlist(line, '\v^title:\s*(.*)$'), 1, '')
        endif
        if self.author ==# ''
            let self.author = get(matchlist(line, '\v^author:\s*(.*)$'), 1, '')
        endif
        if self.created ==# ''
            let self.created = get(matchlist(line, '\v^created:\s*(.*)$'), 1, '')
        endif
        if self.modified ==# ''
            let self.modified = get(matchlist(line, '\v^modified:\s*(.*)$'), 1, '')
        endif
        if self.description ==# ''
            let self.description = get(matchlist(line, '\v^description:\s*(.*)$'), 1, '')
        endif
        if empty(self.category)
            let category = get(matchlist(line, '\v^category:\s*(.*)$'), 1, '')
            let self.category = split(category, '/')
        endif
        if empty(self.tags)
            let tags = get(matchlist(line, '\v^tags:\s*\[(.*)\]$'), 1, '')
            let self.tags = split(tags, '\v,\s*')
        endif
    endfor
endfunction

function! s:Note.renderToString() abort
    let output = ''
    let output = output . self.title

    return output
endfunction
