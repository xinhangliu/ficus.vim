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
