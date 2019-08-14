function! ficus#Ficus(bang) abort
    if !exists('g:Ficus')
        call ficus#ficus#Init()
    endif
    if a:bang
        call ficus#wm#Close()
    else
        call ficus#wm#Open()
    endif
endfunction

function! ficus#FicusToggle() abort
    if !exists('g:Ficus')
        call ficus#ficus#Init()
    endif
    call ficus#wm#Toggle()
endfunction

function! ficus#FicusReload() abort
    unlet! g:Ficus
    call ficus#ficus#Init()
    call ficus#ficus#UpdateView()
endfunction
