function! ficus#util#CompareDate(date, other, fmt) abort
    let l:ret = 0
python3 << EOF
import vim
from datetime import datetime
try:
    d1 = datetime.strptime(vim.eval('a:date'), vim.eval('a:fmt'))
    d2 = datetime.strptime(vim.eval('a:other'), vim.eval('a:fmt'))

    res = 0
    if d1 > d2:
        res = 1
    elif d1 < d2:
        res = -1

    vim.command('let l:ret = %d' % res)
except Exception:
    pass
EOF
    return l:ret
endfunction

function! ficus#util#Error(msg, toHistory = v:true) abort
    redraw
    echohl ErrorMsg
    if a:toHistory
        echom printf('[Ficus] %s', a:msg)
    else
        echo printf('[Ficus] %s', a:msg)
    endif
    echohl None
endfunction

function! ficus#util#Info(msg, toHistory = v:false) abort
    redraw
    if a:toHistory
        echom printf('[Ficus] %s', a:msg)
    else
        echo printf('[Ficus] %s', a:msg)
    endif
endfunction

function! ficus#util#Warning(msg, toHistory = v:true) abort
    redraw
    echohl WarningMsg
    if a:toHistory
        echom printf('[Ficus] %s', a:msg)
    else
        echo printf('[Ficus] %s', a:msg)
    endif
    echohl None
endfunction

