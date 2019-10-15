" MavenSearch by Ole Algoritme
com! -nargs=1 MavenSearch call s:maven_search(<f-args>)

fu! s:maven_search(query) abort

    let s:options_valid = split(system("python ./search_repo.py " . a:query), "\n")
    let options_len = len(s:options_valid)

    if(options_len > 0)
        echo "Please select your artifacts"
    else
        echo "No artifacts found."
        if !bufexists('Maven Repository Search') | sil file Maven\ Repository\ Search| endif
        return
    endif

    new | exe 'resize '.(&lines/2)
    setl bh=wipe bt=nofile nobl noswf nowrap
    if !bufexists('Maven Repository Search') | sil file Maven\ Repository\ Search| endif

    sil! 0put =s:options_valid
    sil! $d_
    setl noma ro

    " Q = close | Enter = Select | Leader = Select
    nno <silent> <buffer> <nowait> a     :<c-u>call <sid>get_selected()<cr>
    nno <silent> <buffer> <nowait> q     :<c-u>close<cr>
    nno <silent> <buffer> <nowait> <cr>  :<c-u>call <sid>toggle_option()<cr>
    nno <silent> <buffer> <nowait> <Leader>  :<c-u>call <sid>toggle_option()<cr>

    
    augroup multi_op_close
        au!
        au WinLeave <buffer> call s:close()
    augroup END
endfu


fu! s:get_selected() abort 
    if exists('w:options_chosen')
        echo 'Do you want to add selected artifacts to pom.xml [Y/n]: ' w:options_chosen.lines
    endif
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

    if(len(w:options_chosen.lines) > 0)
        echo '[Q=Quit | A=Add Selected] Selected: ' w:options_chosen.lines
    else
        echo ''
    endif
    
    let w:options_chosen.pattern = '\v'.join(map(
                                 \               copy(w:options_chosen.lines),
                                 \               "'%'.v:val.'l'"
                                 \              ), '|')

    let w:options_chosen.id = !empty(w:options_chosen.lines)
                            \   ? matchadd('IncSearch', w:options_chosen.pattern)
                            \   : 0

endfu
