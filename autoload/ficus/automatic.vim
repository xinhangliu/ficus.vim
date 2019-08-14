function! ficus#automatic#AutoUpdateNote(note) abort
    augroup FicusAutoUpdateNote
        execute 'autocmd! BufWritePost <buffer=' . bufnr(a:note.path) . '> call ficus#ficus#UpdateNote("' . a:note.path . '")'
    augroup END
endfunction

function! ficus#automatic#AutoUpdateModifiedDate(note) abort
    augroup FicusAutoUpdateModifiedDate
        execute 'autocmd! BufWritePre <buffer=' . bufnr(a:note.path) . '> call ficus#ficus#UpdateModifiedDate()'
    augroup END
endfunction

function! ficus#automatic#AutoUpdateView() abort
    augroup FicusAutoUpdateView
        execute 'autocmd! WinEnter' g:Ficus.buffer_name 'call ficus#ficus#LazyUpdateView()'
    augroup END
endfunction
