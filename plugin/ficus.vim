if exists('g:loaded_ficus')
    finish
endif
let g:loaded_ficus = 1

command! -bang Ficus call ficus#Ficus(<bang>0)
command! FicusToggle call ficus#FicusToggle()
command! FicusReload call ficus#FicusReload()
command! -bang -nargs=? FicusAssetCollect call ficus#asset#Collect(<bang>0, '<args>')
command! -nargs=0 FicusAssetRename call ficus#asset#Rename()

nnoremap <Plug>(ficus-fzf-tags) call ficus#fzf#tags()<CR>
nnoremap <Plug>(ficus-fzf-categories) call ficus#fzf#categories()<CR>
nnoremap <Plug>(ficus-fzf-notes) call ficus#fzf#notes()<CR>
