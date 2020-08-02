function! ficus#mapping#SetupNoteMapping() abort
    " TODO: Error when pumvisible
    inoremap <silent><buffer> @c <C-r>=ficus#fzf#categories()<CR>
    inoremap <silent><buffer> @n <C-r>=ficus#fzf#notes()<CR>
    inoremap <silent><buffer> @t <C-r>=ficus#fzf#tags()<CR>
    nnoremap <silent><buffer> @c :call ficus#fzf#categories()<CR>
    nnoremap <silent><buffer> @n :call ficus#fzf#notes()<CR>
    nnoremap <silent><buffer> @t :call ficus#fzf#tags()<CR>

    nnoremap <silent><buffer> @i :call ficus#asset#Collect(0)<CR>
    nnoremap <silent><buffer> @r :call ficus#asset#Rename()<CR>
endfunction
