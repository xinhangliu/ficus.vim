if exists('g:loaded_ficus')
    finish
endif
let g:loaded_ficus = 1

command! -bang Ficus call ficus#Ficus(<bang>0)
command! FicusToggle call ficus#FicusToggle()
command! FicusReload call ficus#FicusReload()
