setlocal noreadonly
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal noswapfile
setlocal nobuflisted
setlocal nomodifiable

setlocal textwidth=0
setlocal winfixwidth
setlocal wrap
setlocal concealcursor=nvc conceallevel=1

setlocal nolist
setlocal nospell
setlocal colorcolumn=
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn="no"

setlocal nofoldenable
setlocal foldcolumn=0
setlocal foldmethod&
setlocal foldexpr&

nnoremap <silent> <buffer> o :<C-u>call ficus#view#noteview#OpenNote('p', 0)<CR>
nnoremap <silent> <buffer> p :<C-u>call ficus#view#noteview#OpenNote('p', 1)<CR>
nnoremap <silent> <buffer> O :<C-u>call ficus#view#noteview#OpenNote('s', 0)<CR>
nnoremap <silent> <buffer> v :<C-u>call ficus#view#noteview#OpenNote('v', 0)<CR>
nnoremap <silent> <buffer> t :<C-u>call ficus#view#noteview#OpenNote('t', 0)<CR>
nnoremap <silent> <buffer> u :<C-u>call ficus#view#noteview#GoBack()<CR>

nnoremap <silent> <buffer> R :<C-u>call ficus#view#noteview#Rename()<CR>
nnoremap <silent> <buffer> C :<C-u>call ficus#CreateNote()<CR>
nnoremap <silent> <buffer> D :<C-u>call ficus#view#noteview#DeleteNote()<CR>

nnoremap <silent> <buffer> st :<C-u>call ficus#sort#Sort('note', 'title')<CR>
nnoremap <silent> <buffer> sm :<C-u>call ficus#sort#Sort('note', 'modified')<CR>
nnoremap <silent> <buffer> sc :<C-u>call ficus#sort#Sort('note', 'created')<CR>
nnoremap <silent> <buffer> sr :<C-u>call ficus#sort#SortReverse('note')<CR>
nnoremap <silent> <buffer> ss :<C-u>call ficus#sort#SortTraverse('note', 0)<CR>
nnoremap <silent> <buffer> sS :<C-u>call ficus#sort#SortTraverse('note', 1)<CR>
