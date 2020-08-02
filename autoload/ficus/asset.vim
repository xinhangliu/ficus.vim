" Function s:DownloadAsync(url, dest) {{{1
" Asynchronously Download from the url, save to the dest.
" Args:
"   url: string -> The url to download
"   dest: string -> The file path to save
" Return:
function! s:DownloadAsync(url, dest) abort
    let cmd = ['curl', '-L', a:url, '-o', a:dest]
    let options = {'exit_cb': function('s:Handler')}
    let job = job_start(cmd, options)
endfunction

" Function s:Handler(job, exitval) {{{1
" Exit callback function of s:DownloadAsync().
" Args:
"   job: Job -> The async job
"   exitval: number -> The exit code of the job
" Return:
function s:Handler(job, exitval) abort
    if a:exitval != 0
        let info = job_info(a:job)
        let cmd = info['cmd']
        let url = cmd[2]
        let dest = cmd[4]
        call ficus#util#Error('Failed to collect the asset "' . url . '"')
        let failed = fnamemodify(dest, ':h')
                    \ . '/' . ficus#options('ficus_assets_failed_filename')
        if filereadable(failed)
            let failed_urls = system('cat '.shellescape(failed))
            if stridx(failed_urls, url) != -1
                return
            endif
        endif
        call system(printf('echo %s >> %s', shellescape(url), shellescape(failed)))
        if v:shell_error
            call ficus#util#Error('Failed to cache the url: "' . url . '"')
            return
        endif
    endif
endfunction

" Function s:ResolveUrl(text) {{{1
" Construct the url from the text and infer the filename.
" Args:
"   text: string -> The original text
" Return: [url, fname]
"   url: string -> The constructed url
"   fname: string -> The infered filename
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

" Function s:ReplaceText(pos, old, new) {{{1
" Replace the substring in the current line.
" Args:
"   pos: List -> The target position
"   old: string -> The substring to be replaced
"   new: string -> The new replacement
" Return:
function! s:ReplaceText(pos, old, new) abort
    let line = getline(a:pos[1])
    let ccol = a:pos[2]
    let idx_start = stridx(line, a:old)
    while idx_start + strlen(a:old) <= ccol - 1
        let idx_start = stridx(line, a:old, idx_start + 1)
    endwhile
    let start_pos = copy(a:pos)
    let start_pos[2] = idx_start + 1
    let end_pos = copy(a:pos)
    let end_pos[2] = idx_start + strlen(a:old)
    call setpos("'<", start_pos)
    call setpos("'>", end_pos)
    let reg_saved = getreg('a')
    call setreg('a', a:new)
    execute 'normal! gv"ap'
    call setreg('a', reg_saved)
    call setpos('.', a:pos)
endfunction

" Function s:ReplaceText(pos, text) {{{1
" Insert the text into the position.
" Args:
"   pos: List -> The target position
"   text: string -> The string to be inserted
" Return:
function! s:InsertText(pos, text) abort
    call setpos('.', a:pos)
    let reg_saved = getreg('a')
    call setreg('a', a:text)
    execute 'normal! "ap'
    call setreg('a', reg_saved)
    call setpos('.', a:pos)
endfunction

" Function ficus#asset#Collect(bang, url = v:none) {{{1
" Localize the asset under the cursor. If the url is specified, localize the
" given url instead.
" Args:
"   bang: bool -> If true and the url is a local file, remove the original
"   file when done
"   url: string -> The specified url to download, instead of the cursor url
" Return:
function! ficus#asset#Collect(bang, url = v:none) abort
    if !exists('b:is_ficusnote')
        return
    endif

    let text = empty(a:url) ? expand('<cfile>') : a:url
    let pos_saved = getpos('.')

    " If assets dir of note is not exists, create it
    let note_name = expand('%:p:t:r')
    let note_assets_dir = ficus#options('ficus_assets_dir') . '/' . note_name
    if !isdirectory(note_assets_dir)
        call system('mkdir -p ' . fnameescape(note_assets_dir))
        if v:shell_error
            call ficus#util#Error('Failed to create the assets dir: "' . note_assets_dir . '"')
            return
        endif
    endif

    " Infer the filename from the url
    let url_and_fname = s:ResolveUrl(text)
    if empty(url_and_fname)
        call ficus#util#Error('Unresolved url: "' . text . '"')
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
            call ficus#util#Info('Reuse the existed asset: "' . fname . '"')
        else
            let fname = fname_new
            let dest = expand(ficus#options('ficus_dir'))
                        \ . '/' . note_assets_dir
                        \ . '/' . fname
        endif
    endif

    " Modify the url in the content
    if empty(a:url)
        call s:ReplaceText(pos_saved, text, note_assets_dir . '/' . fname)
    else
        call s:InsertText(pos_saved, note_assets_dir . '/' . fname)
    endif

    " Download the asset
    if download_needed
        call s:DownloadAsync(url, dest)
    endif

    if delete_original_file
        call system(ficus#options('ficus_delete_command').' '.shellescape(url[7:]))
        if v:shell_error
            call ficus#util#Error('Failed to delete the original file: "' . url . '"')
            return
        endif
    endif
endfunction

" Function ficus#asset#Rename() {{{1
" Rename the asset under the cursor.
" Args:
" Return:
function! ficus#asset#Rename() abort
    if !exists('b:is_ficusnote')
        return
    endif

    let text = expand('<cfile>')
    let pos_saved = getpos('.')

    let fname_old = fnamemodify(text, ':t')

    let note_name = expand('%:p:t:r')
    let note_assets_dir = ficus#options('ficus_assets_dir') . '/' . note_name

    if fnamemodify(text, ':h') != note_assets_dir
        call ficus#util#Warning('Not an asset')
        return
    endif

    let abspath_old = expand(ficus#options('ficus_dir')) . '/' . text
    if !filereadable(abspath_old)
        call ficus#util#Warning('Asset invalid: "' . fname_old . '"')
        return
    endif

    let fname_new = input('New name: ', fname_old)
    if empty(fname_new) || fname_new == fname_old
        call ficus#util#Info('File name not changed')
        return
    end

    let abspath_new = expand(ficus#options('ficus_dir'))
                \ . '/' . note_assets_dir
                \ . '/' . fname_new
    if filereadable(abspath_new)
        call ficus#util#Error('Asset already exists: "' . fname_new . '"')
        return
    endif

    call system('mv '.shellescape(abspath_old).' '.shellescape(abspath_new))
    if v:shell_error
        call ficus#util#Error('Failed to rename asset: "' . fname_old . '"')
        return
    endif

    " Modify the url in the content
    call s:ReplaceText(pos_saved, text, note_assets_dir . '/' . fname_new)
endfunction
" Modeline {{{1
" vim:set foldenable foldmethod=marker:
