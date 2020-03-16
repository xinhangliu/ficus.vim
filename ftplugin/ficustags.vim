setlocal noreadonly
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal noswapfile
setlocal nobuflisted
setlocal nomodifiable

setlocal textwidth=0
setlocal winfixwidth
setlocal nowrap
setlocal concealcursor=nvc conceallevel=2

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

nnoremap <silent> <buffer> o :<C-u>call ficus#view#tagview#OpenTag()<CR>
nnoremap <silent> <buffer> u :<C-u>call ficus#render#Render('category')<CR>
nnoremap <silent> <buffer> R :<C-u>call ficus#view#tagview#Rename()<CR>
nnoremap <silent> <buffer> C :<C-u>call ficus#CreateNote()<CR>

nnoremap <silent> <buffer> st :<C-u>call ficus#sort#Sort('tag', 'name')<CR>
nnoremap <silent> <buffer> sc :<C-u>call ficus#sort#Sort('tag', 'count')<CR>
nnoremap <silent> <buffer> sr :<C-u>call ficus#sort#SortReverse('tag')<CR>
nnoremap <silent> <buffer> ss :<C-u>call ficus#sort#SortTraverse('tag', 0)<CR>
nnoremap <silent> <buffer> sS :<C-u>call ficus#sort#SortTraverse('tag', 1)<CR>
