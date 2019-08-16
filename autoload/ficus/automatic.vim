" Function ficus#automatic#AutoUpdateNote(note) {{{1
" Auto update the data model of the modified note.
" Args:
"   note: Note -> The target note.
" Return:
function! ficus#automatic#AutoUpdateNote(note) abort
    augroup FicusAutoUpdateNote
        execute 'autocmd! BufWritePost <buffer=' . bufnr(a:note.path) . '> call ficus#UpdateNote("' . a:note.path . '")'
    augroup END
endfunction

" Function ficus#automatic#AutoUpdateLastmod(note) {{{1
" Auto update the last modified date of the note.
" Args:
"   note: Note -> The target note.
" Return:
function! ficus#automatic#AutoUpdateLastmod(note) abort
    augroup FicusAutoUpdateLastmod
        execute 'autocmd! BufWritePre <buffer=' . bufnr(a:note.path) . '> call ficus#UpdateLastmod()'
    augroup END
endfunction

" Function ficus#automatic#AutoUpdateView() {{{1
" Update the view if needed when switch to Ficus window.
" Args:
" Return:
function! ficus#automatic#AutoUpdateView() abort
    augroup FicusAutoUpdateView
        execute 'autocmd! WinEnter' g:Ficus.buffer_name 'call ficus#LazyUpdateView()'
    augroup END
endfunction

" Modeline {{{1
" vim:set foldenable foldmethod=marker:
