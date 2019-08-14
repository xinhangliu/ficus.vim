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

nnoremap <script> <silent> <buffer> <2-LeftMouse>
            \ :<c-u>call ficus#view#categoryview#toggleFold()<CR>
nnoremap <silent> <buffer> h :<c-u>call ficus#view#categoryview#closeFold()<CR>
nnoremap <silent> <buffer> l :<C-U>call ficus#view#categoryview#openFold()<CR>
nnoremap <silent> <buffer> o :<C-u>call ficus#view#categoryview#openCategory()<CR>
nnoremap <silent> <buffer> u :<C-U>call ficus#render#Render('tag')<CR>

nnoremap <silent> <buffer> R :<C-u>call ficus#view#categoryview#Rename()<CR>
nnoremap <silent> <buffer> C :<C-u>call ficus#ficus#CreateNote()<CR>
