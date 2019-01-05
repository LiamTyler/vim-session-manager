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
  " if num_tabs < 2 && num_splits < 2
    " return
  " endif

  let filename = g:session_dir . GetRootGitRepo() . g:session_number
  if g:session_number < 0
    let session_files = split(globpath(g:session_dir, GetRootGitRepo()), '\n')
    let current_session_number = len(session_files)
    let filename = g:session_dir . GetRootGitRepo() . current_session_number
  endif

  if empty(glob(g:session_dir))
    execute '!mkdir -p ' . g:session_dir
  endif

  echom "Making session " . filename
  execute "mksession! " . filename
endfunction

function! g:StartSession()
  " TODO save session number
endfunction
