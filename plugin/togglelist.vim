" toggle list plugin
"
" Donald Ephraim Curtis (2011)
"
" boom
"
" This plugin allows you to use \l and \q to toggle the location list and
" quickfix list (respectively).
"
"

if exists("g:loaded_toggle_list")
  finish
endif

function! s:GetBufferList()
  redir =>buflist
  silent! ls
  redir END
  return buflist
endfunction

function! ToggleLocationList()
  let curbufnr = winbufnr(0)
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Location List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if curbufnr == bufnum
      lclose
      return
    endif
  endfor

  let winnr = winnr()
  let prevwinnr = winnr("#")

  let nextbufnr = winbufnr(winnr + 1)
  try
    lopen
  catch /E776/
      echohl ErrorMsg
      echo "Location List is Empty."
      echohl None
      return
  endtry
  if g:toggle_list_restore
    if winbufnr(0) == nextbufnr
      lclose
      if prevwinnr > winnr
        let prevwinnr-=1
      endif
    else
      if prevwinnr > winnr
        let prevwinnr+=1
      endif
    endif
    " restore previous window
    exec prevwinnr."wincmd w"
    exec winnr."wincmd w"
  endif
endfunction

function! ToggleQuickfixList()
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Quickfix List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      cclose
      return
    endif
  endfor
  let winnr = winnr()
  if exists("g:toggle_list_copen_command")
    exec(g:toggle_list_copen_command)
  else
    copen
  endif
  if g:toggle_list_restore
    if winnr() != winnr
      wincmd p
    endif
  endif
endfunction

if !exists("g:toggle_list_no_mappings")
    nmap <script> <silent> <leader>l :call ToggleLocationList()<CR>
    nmap <script> <silent> <leader>q :call ToggleQuickfixList()<CR>
endif

if !exists("g:toggle_list_restore")
    let g:toggle_list_restore = 1
endif

