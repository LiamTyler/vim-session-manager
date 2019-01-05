let g:session_dir = expand('~/.vim/.sessions/')
let g:session_number = -1

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

  return substitute(git_dir, '/', '_', 'g')
endfunction

function! g:EndSession()
  let num_tabs = tabpagenr('$')
  let num_splits = winnr('$')
  if num_tabs < 2 && num_splits < 2
    return
  endif

  let filename = g:session_dir . GetRootGitRepo() . '__' . g:session_number
  if g:session_number < 0
    let session_files = split(globpath(g:session_dir, GetRootGitRepo()), '\n')
    let current_session_number = len(session_files)
    let filename = g:session_dir . GetRootGitRepo() . '__' . current_session_number
  endif

  if empty(glob(g:session_dir))
    execute '!mkdir -p ' . g:session_dir
  endif

  execute "mksession! " . filename
endfunction

function! g:StartSession()
  let session_files = split(globpath(g:session_dir, GetRootGitRepo() . '*'), '\n')

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
endfunction

autocmd VimEnter * nested silent! call StartSession() | redraw!
autocmd VimLeave * silent! call EndSession()
