" MavenSearch by Ole Algoritme
com! -nargs=1 MavenSearch call s:maven_search(<f-args>)

fu! s:maven_search(query) abort
    let s:options_valid = split(system("python search_repo.py " . a:query), ",")
    call add(s:options_valid, 'Select Your Dependency')
    vnew | exe 'vert resize '.(&columns/4)
    setl bh=wipe bt=nofile nobl noswf nowrap
    if !bufexists('Maven Repository') | sil file Maven\ Repository| endif

    sil! 0put =s:options_valid
    sil! $d_
    setl noma ro

    nno <silent> <buffer> <nowait> q     :<c-u>close<cr>
    nno <silent> <buffer> <nowait> <cr>  :<c-u>call <sid>toggle_option()<cr>

    augroup multi_op_close
        au!
        au WinLeave <buffer> call s:close()
    augroup END
endfu

fu! s:close() abort
    let g:selected_options = exists('w:options_chosen')
                           \   ? map(w:options_chosen.lines, 's:options_valid[v:val-1]')
                           \   : []
    au! multi_op_close | aug! multi_op_close
    close
endfu

fu! s:toggle_option() abort
    if !exists('w:options_chosen')
        let w:options_chosen = { 'lines' : [], 'pattern' : '', 'id' : 0 }
    else
        if w:options_chosen.id
            call matchdelete(w:options_chosen.id)
            let w:options_chosen.pattern .= '|'
        endif
    endif

    if !empty(w:options_chosen.lines) && count(w:options_chosen.lines, line('.'))
        call filter(w:options_chosen.lines, "v:val != line('.')")
    else
        let w:options_chosen.lines += [ line('.') ]
    endif

    let w:options_chosen.pattern = '\v'.join(map(
                                 \               copy(w:options_chosen.lines),
                                 \               "'%'.v:val.'l'"
                                 \              ), '|')

    let w:options_chosen.id = !empty(w:options_chosen.lines)
                            \   ? matchadd('IncSearch', w:options_chosen.pattern)
                            \   : 0
endfu
