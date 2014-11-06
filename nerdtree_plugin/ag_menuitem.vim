if exists("g:loaded_nerdtree_ag_menu")
    finish
endif
let g:loaded_nerdtree_ag_menu = 1

call NERDTreeAddMenuItem({'text': '(o)pen this dir', 'shortcut': 'o', 'callback': 'NERDTreeOpenNode'})
call NERDTreeAddMenuItem({'text': '(f)ind file in this dir', 'shortcut': 'f', 'callback': 'NERDTreeFindNode', 'isActiveCallback': 'NERDTreeOnDir'})
call NERDTreeAddMenuItem({'text': '(g)rep in this dir', 'shortcut': 'g', 'callback': 'NERDTreeGrepNode', 'isActiveCallback': 'NERDTreeOnDir'})

" FUNCTION: NERDTreeOnDir() {{{1
function! NERDTreeOnDir()
    let node = g:NERDTreeFileNode.GetSelected()
    return node.path.isDirectory
endfunction
" FUNCTION: NERDTreeFindNode() {{{1
function! NERDTreeFindNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()

    let pat = input("Find file in this dir\n" .
                          \ "==========================================================\n" .
                          \ "Enter the pattern to find:                                \n" .
                          \ "" . curDirNode.path.str() . ":")
    if pat != ""
        call nerdtree#closeTreeIfOpen()
        exec "AgFile " .  pat . ' "' . curDirNode.path.str() . '"'
    else
        call s:echo("Find aborted.")
    endif
endfunction
" FUNCTION: NERDTreeGrepNode() {{{1
function! NERDTreeGrepNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()

    let pat = input("Grep in this dir\n" .
                          \ "==========================================================\n" .
                          \ "Enter the pattern to grep:                                \n" .
                          \ "" . curDirNode.path.str() . ":")
    if pat != ""
        call nerdtree#closeTreeIfOpen()
        exec "LAg " .  pat . ' "' . curDirNode.path.str() . '"'
    else
        call s:echo("Grep aborted.")
    endif
endfunction

" FUNCTION: NERDTreeOpenNode() {{{1
function! NERDTreeOpenNode()
    let curDirNode = g:NERDTreeDirNode.GetSelected()
    exec "silent !" . g:fileBrowser . " " . curDirNode.path.str()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
