function! s:Curl(url, dest) abort
    let s = system('curl -L ' . shellescape(a:url) . ' -o ' . shellescape(a:dest))
    return s
endfunction

function! s:ResolveUrl(text) abort
    if a:text =~? '\v^(http|https|ftp|ftps|file)\:\/\/.*$'
        let fname = fnamemodify(a:text, ':t')
        let fname = split(fname, '\v\?')[0]
        let fname = split(fname, '#')[0]
        return [a:text, fname]
    elseif a:text =~? '\v^\/?([^\/]+\/)+([^\/]+)?$'
        if a:text =~? '\v^[\~\/].*$'
            let abspath = fnamemodify(a:text, ':p')
        else
            let abspath = expand('%:p:h') . '/' . a:text
        endif
        let fname = fnamemodify(abspath, ':t')
        return ['file://' . abspath, fname]
    else
        return []
    endif
endfunction

function! ficus#asset#Collect(bang) abort
    if !exists('b:is_ficusnote')
        return
    endif

    let text = expand('<cfile>')
    let ccol = col('.')
    let pos_saved = getpos('.')
    let line = getline('.')

    " If assets dir of note is not exists, create it
    let note_name = expand('%:p:t:r')
    let note_assets_dir = ficus#options('ficus_assets_dir') . '/' . note_name
    if !isdirectory(note_assets_dir)
        call system('mkdir -p ' . fnameescape(note_assets_dir))
    endif

    " Infer the filename from the url
    let url_and_fname = s:ResolveUrl(text)
    if empty(url_and_fname)
        echohl ErrorMsg
        echo '[Ficus] Unresolved url "' . text . '"'
        echohl None
        return
    endif
    let [url, fname] = url_and_fname

    let dest = expand(ficus#options('ficus_dir'))
                \ . '/' . note_assets_dir
                \ . '/' . fname

    let delete_original_file = v:false
    if url =~? '\v^file\:\/\/.*$'
        let fpath = url[7:]
        if fpath ==# dest
            return
        endif

        if a:bang
            let delete_original_file = v:true
        endif
    endif

    " If the asset exists, ask for a new name
    let download_needed = v:true
    if filereadable(dest)
        let fname_new = input('New name: ', fname)
        if fname_new ==# '' || fname_new ==# fname
            let download_needed = v:false
            " TODO: clean commandline first
            echo '[Ficus] Reuse the existed asset "' . fname . '"'
        else
            let fname = fname_new
            let dest = expand(ficus#options('ficus_dir'))
                        \ . '/' . note_assets_dir
                        \ . '/' . fname
        endif
    endif

    " Modify the url in the content
    let idx_start = stridx(line, text)
    while idx_start + strlen(text) <= ccol - 1
        let idx_start = stridx(line, text, idx_start + 1)
    endwhile
    let start_pos = copy(pos_saved)
    let start_pos[2] = idx_start + 1
    let end_pos = copy(pos_saved)
    let end_pos[2] = idx_start + strlen(text)
    call setpos("'<", start_pos)
    call setpos("'>", end_pos)
    let reg_saved = getreg('a')
    call setreg('a', note_assets_dir . '/' . fname)
    execute 'normal! gv"ap'
    call setreg('a', reg_saved)

    call setpos('.', pos_saved)

    " Download the asset
    if download_needed
        " TODO: Save url to the asset dir if failed to download it
        " TODO: Async downloading
        call s:Curl(url, dest)
    endif

    if delete_original_file
        call system(ficus#options('ficus_delete_command') . ' ' . shellescape(url[7:]))
    endif
endfunction

function! ficus#asset#Rename() abort
    if !exists('b:is_ficusnote')
        return
    endif

endfunction

function! ficus#asset#Delete() abort
    if !exists('b:is_ficusnote')
        return
    endif

endfunction

function! ficus#asset#InsertImage(url) abort
    if !exists('b:is_ficusnote')
        return
    endif

endfunction
