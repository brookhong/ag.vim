" NOTE: You must, of course, install the ag script
"       in your path.
" On Debian / Ubuntu:
"   sudo apt-get install ag-grep
" On your vimrc:
"   let g:agprg="ag-grep -H --nocolor --nogroup --column"
"
" With MacPorts:
"   sudo port install p5-app-ag

" Location of the ag utility
if !exists("g:agprg")
    let g:agprg = "ag -f --nogroup --column --line-numbers"
endif

if !exists("g:ag_src_root_markers")
    let g:ag_src_root_markers = ["/.git/", "/.cvs/", "/.svn/", "/.hg/", "/Makefile", "/Makefile.in", "/Makefile.am", "/package.json", "/bower.json", "/build.xml", "/pom.xml", "/build.gradle", "/Rakefile", "/CMakeLists.txt", "/configure", "/build.sbt", "/Makefile"]
endif

function! s:GetSrcRoot()
    let ap = expand("%:p:h")
    let ap = substitute(ap,"\\","\/","g")
    let hit = 0
    while ap != ""

        for srm in g:ag_src_root_markers
            if (srm[-1:-1] == "/" && isdirectory(ap.srm)) || filereadable(ap.srm)
                let hit = 1
                break
            endif
        endfor

        if hit == 0
            let ap = substitute(ap, '/[^/]\+$', "","")
        else
            break
        endif

    endwhile
    if ap == ""
        let ap = expand("%:p:h")
    endif
    return ap
endfunction

function! AgPrePath()
    let ap = <SID>GetSrcRoot()
    if stridx(ap, ' ') != -1
        let ap = '"' . ap . '"'
    endif
    return ap
endfunction

function! AgInteractive()
    call inputsave()
    let gp = input("The path to grep: ", AgPrePath(), "dir")
    if len(gp) > 0
        let pat = input("The string to grep: ")
        if len(pat) > 0
            exec 'LAg '.pat.' '.gp
        endif
    endif
    call inputrestore()
endfunction

function! StrToList(mystr)
    let i = 0
    let token_start = ' '
    let token = ""
    let tokens = []
    while i < len(a:mystr)
        if len(token) == 0 && stridx("\"'", a:mystr[i]) != -1
            let token_start = a:mystr[i]
        elseif a:mystr[i] == token_start
            if len(token)
                call add(tokens, token)
                let token = ""
                let token_start = ' '
            endif
        else
            let token = token . a:mystr[i]
        endif
        let i = i + 1
    endwhile
    if len(token)
        call add(tokens, token)
    endif
    return tokens
endfunction

function! s:Ag(cmd, args)
    redraw
    echo "Searching ..."

    " If no pattern is provided, search for the word under the cursor
    if empty(a:args)
        let l:grepargs = expand("<cword>")
    else
        let l:grepargs = a:args
    end

    " Format, used to manage column jump
    if a:cmd =~# '-g$'
        let g:agformat="%f"
    else
        let g:agformat="%f:%l:%c:%m"
    end

    if executable('ag')
        let grepprg_bak=&grepprg
        let grepformat_bak=&grepformat
        try
            let &grepprg=g:agprg
            if exists("g:agOnlyMatchWholeWords") && g:agOnlyMatchWholeWords
                let &grepprg=g:agprg." -w"
            endif
            let &grepformat=g:agformat
            let cmds = StrToList(l:grepargs)
            silent execute a:cmd . " " . l:grepargs
        finally
            let &grepprg=grepprg_bak
            let &grepformat=grepformat_bak
        endtry
    else
        let cmds = StrToList(l:grepargs)
        silent execute a:cmd . " " . l:grepargs
    endif

    if a:cmd =~# '^l'
        botright lopen
    else
        botright copen
    endif

    exec "nnoremap <silent> <buffer> q :ccl<CR>"
    exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
    exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
    exec "nnoremap <silent> <buffer> o <CR>"
    exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
    exec "nnoremap <silent> <buffer> v <C-W><C-W><C-W>v<C-L><C-W><C-J><CR>"
    exec "nnoremap <silent> <buffer> gv <C-W><C-W><C-W>v<C-L><C-W><C-J><CR><C-W><C-J>"

    " If highlighting is on, highlight the search keyword.
    if exists("g:aghighlight")
        let @/=a:args
        set hlsearch
    end

    redraw!
endfunction

function! s:AgFromSearch(cmd, args)
    let search =  getreg('/')
    " translate vim regular expression to perl regular expression.
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    call s:Ag(a:cmd, '"' .  search .'" '. a:args)
endfunction

command! -bang -nargs=* -complete=file Ag call s:Ag('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file AgAdd call s:Ag('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFromSearch call s:AgFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAg call s:Ag('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAgAdd call s:Ag('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFile call s:Ag('grep<bang> -g', <q-args>)
