function! GetMPCStatusline()
  let command = "mpc status"
  let result = split(system(command), '\n')

  let status = len(result) == 3 ? result[2] : result[0] 

  let [s:count, s:settings] = 
        \ [len(split(system('mpc playlist'), '\n')),
        \ split(status, '   ')]

  let s:statusline = "%= " 
        \ . s:settings[1] . " --- " 
        \ . s:settings[2] . " --- " 
        \ . s:count . " songs "

  return substitute(s:statusline, " ", "\ ", "g")
endfunction

"START:commandPlaySelected
command! -buffer PlaySelectedSong call mpc#PlaySong(line("."))
"END:commandPlaySelected
"START:commandToggleRandomRepeat
command! -buffer ToggleRandom     call mpc#ToggleRandom()
command! -buffer ToggleRepeat     call mpc#ToggleRepeat()
"END:commandToggleRandomRepeat

"START:mappings
nnoremap <silent>             <plug>MpcToggleplayback   :TogglePlayback<cr>
nnoremap <silent> <buffer>    <c-x>                     :PlaySelectedSong<cr>
nnoremap <silent> <buffer>    <c-a>                     :ToggleRandom<cr>
nnoremap <silent> <buffer>    <c-e>                     :ToggleRepeat<cr>
"END:mappings
"START:mapToPlugToggleplayback
if !hasmapto("<plug>MpcToggleplayback")
  nmap <leader>p   <plug>MpcToggleplayback
endif
"END:mapToPlugToggleplayback



" fold logic
function! MpcFolds()
    let l:thisline = getline(v:lnum)  " v:lnum special readonly variable for folds
    let l:previousline = getline(v:lnum - 1)

    let l:artist_pattern = '@ar.\+ar@'
    let l:album_pattern = '@al.\+al@'

    let l:current_artist = matchstr(l:thisline, l:artist_pattern)
    let l:previous_artist = matchstr(l:previousline, l:artist_pattern)

    let l:current_album = matchstr(l:thisline, l:album_pattern)
    let l:previous_album = matchstr(l:previousline, l:album_pattern)

    if match(l:thisline, '^@ar.\+ar@$') > -1
        return '>1'
    endif
    if (l:previous_artist == l:current_artist)
        if(l:previous_album == l:current_album)
            return '='
        else
            return '>2'
        endif
    else
        return '>2'
    endif
endfunction

" Text for the fold
function! MpcFoldText()
    let l:thisline = getline(v:foldstart)
    let l:artist_pattern = '@ar.\+ar@'
    let l:album_pattern = '@al.\+al@'
    let l:current_artist = Strip(matchstr(l:thisline, l:artist_pattern), '@ar\|ar@')
    let l:current_album = Strip(matchstr(l:thisline, l:album_pattern), '@al\|al@')

    if (v:foldlevel) == 1
        return v:folddashes.l:current_artist
    else
        let l:song_num = v:foldend - v:foldstart + 1
        " return v:folddashes.'(#'.l:song_num.') '.l:current_album
        return v:folddashes.l:current_album.' (#'.l:song_num.')'
    endif
endfunction

" Removes pattern from text
function! Strip(text, pattern)
    return substitute(a:text, a:pattern, '', 'g')
endfunction

" Fold method declaration
setlocal foldmethod=expr
setlocal foldexpr=MpcFolds()
setlocal foldtext=MpcFoldText()
setlocal fillchars=fold:\ 
setlocal buftype=nofile
setlocal conceallevel=3
setlocal concealcursor=nvic
setlocal statusline=%!GetMPCStatusline()
setlocal norelativenumber
setlocal nonumber

