if exists("g:loaded_nerdtree_ag_menu")
    finish
endif
let g:loaded_nerdtree_ag_menu = 1

call NERDTreeAddMenuItem({'text': '(s)hell this dir', 'shortcut': 's', 'callback': 'NERDTreeShellNode', 'isActiveCallback': 'NERDTreeOnDir'})
call NERDTreeAddMenuItem({'text': '(b)rowse this dir', 'shortcut': 'b', 'callback': 'NERDTreeOpenNode', 'isActiveCallback': 'NERDTreeOnDir'})
call NERDTreeAddMenuItem({'text': '(f)ind file in this dir', 'shortcut': 'f', 'callback': 'NERDTreeFindNode', 'isActiveCallback': 'NERDTreeOnDir'})
call NERDTreeAddMenuItem({'text': '(g)rep in this dir', 'shortcut': 'g', 'callback': 'NERDTreeGrepNode', 'isActiveCallback': 'NERDTreeOnDir'})

function! NERDTreeOnDir()
    let node = g:NERDTreeFileNode.GetSelected()
    return node.path.isDirectory
endfunction

function! NERDTreeFindNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()

    let pat = input("Find file in ".curDirNode.path.str()."\n" .
                \ "==========================================================\n" .
                \ "Enter the pattern to find: ")
    if pat != ""
        if g:NERDTree.IsOpen()
            call g:NERDTree.Close()
        endif
        call FindInFiles(curDirNode.path.str(), pat)
    endif
endfunction

function! NERDTreeGrepNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()

    let pat = input("Grep in ".curDirNode.path.str()."\n" .
                \ "==========================================================\n" .
                \ "Enter the pattern to grep: ")

    if pat != ""
        let fnPat = input("Enter the pattern of file name: ", "*")
        if g:NERDTree.IsOpen()
            call g:NERDTree.Close()
        endif
        call FindInFiles(curDirNode.path.str(), fnPat, pat)
    endif
endfunction

function! NERDTreeShellNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()
    let $VIM_DIR = curDirNode.path.str()
    cd $VIM_DIR
    tab terminal
endfunction

function! NERDTreeOpenNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()
    exec "silent !" . g:fileBrowser . " " . curDirNode.path.str()
endfunction

function! FindInFiles(dir, pat, ...)
    let ff = $HOME."/.vim_swap/found"
    if a:0 > 0
        exec "silent !find ".escape(a:dir, ' ()')." -type f -iname '".a:pat."' -exec grep -niH '".a:000[0]."' {} \\; > ".ff
    else
        exec "silent !find ".escape(a:dir, ' ()')." -type f -iname '".a:pat."' -exec grep -niH -m 1 '.' {} \\; > ".ff
    endif
    exec "lgetf ".ff
    if len(getloclist('%')) == 0
        echo "Nothing found."
    else
        lfirst
    endif
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
