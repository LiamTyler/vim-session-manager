let g:session_dir = expand('~/.vim/.sessions/')
let g:session_number = -1
let g:session_name = ''

function! GetRootGitRepo()
  let full_path = ''
  let git_dir = ''
  let path_arg = '%:p'
  while full_path != '/'
    let full_path = expand(path_arg)
    let listing = split(globpath(full_path, '.git'), '\n')
    if len(listing) > 0
      let git_dir = full_path
    endif
    let path_arg = path_arg . ':h'
  endwhile

  echom git_dir
  return substitute(git_dir, '/', '_', 'g')
endfunction

function! g:EndSession()
  let repo = GetRootGitRepo()
  if len(repo) == 0
    return
  endif

  let num_tabs = tabpagenr('$')
  let num_splits = winnr('$')
  if num_tabs < 2 && num_splits < 2
    return
  endif

  let filename = g:session_dir . repo . '__' . g:session_number
  if g:session_number < 0
    let session_files = split(globpath(g:session_dir, repo), '\n')
    let current_session_number = len(session_files)
    let filename = g:session_dir . repo . '__' . current_session_number
  endif

  if empty(glob(g:session_dir))
    execute '!mkdir -p ' . g:session_dir
  endif

  execute "mksession! " . filename
endfunction

function! g:StartSession()
  let repo = GetRootGitRepo()
  if len(repo) == 0
    return
  endif

  let session_files = split(globpath(g:session_dir, repo . '*'), '\n')

  let this_file = expand('%:t')
  let found = ''
  for session_file in session_files
    let rows = readfile(session_file)
    for row in rows
      if row =~ '.*edit .*' . this_file . '.*'
        let found = session_file
        break
      endif
      if found != ''
        break
      endif
    endfor
  endfor

  if found != ''
    execute 'source ' . found
  endif

  let g:session_number = split(found, '__')[-1]
  let g:session_name = found
endfunction

function GarbageCollectSession()
  let repo = GetRootGitRepo()
  if len(repo) == 0 || len(g:session_name) == 0
    return
  endif

  let rows = readfile(g:session_name)
  for row in rows
    if row =~ 'badd.*'
      let parts = split(row, ' ')
      let parts = parts[2:]
      echom parts
      let file_name = parts[0]
      for part in parts
        file_name = file_name . ' ' . part
      endfor
      echom file_name
    endif
  endfor
endfunction

autocmd VimEnter * nested silent! call StartSession() | redraw!
autocmd VimLeave * silent! call EndSession()
