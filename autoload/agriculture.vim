if !exists('g:agriculture#rg_base_options')
  let g:agriculture#rg_base_options='--column --line-number --no-heading --color=always --smart-case'
endif

if !exists('g:agriculture#fzf_extra_options')
  let g:agriculture#fzf_extra_options=''
endif

function! agriculture#smart_quote_input(input)
  if get(g:, 'agriculture#disable_smart_quoting', 0) > 0
    return a:input
  endif
  let hasQuotes = match(a:input, '"') > -1 || match(a:input, "'") > -1
  let hasOptions = match(' ' . a:input, '\s-[-a-zA-Z]') > -1
  let hasEscapedSpacesPlusPath = match(a:input, '\\ .*\ ') > 0
  return hasQuotes || hasOptions || hasEscapedSpacesPlusPath ? a:input : '-- "' . a:input . '"'
endfunction

function! agriculture#trim_and_escape_register_a()
  let query = getreg('a')
  let trimmedQuery = s:trim(query)
  let escapedQuery = escape(trimmedQuery, "'#%\\")
  call setreg('a', escapedQuery)
endfunction

function! agriculture#fzf_ag_raw(command_suffix, ...)
  if !executable('ag')
    return s:warn('ag is not found')
  endif
  let userOptions = get(g:, 'agriculture#ag_options', '')
  let command = 'ag --nogroup --column --color ' . s:trim(userOptions . ' ' . a:command_suffix)
  return call('fzf#vim#grep', extend([command, 1], a:000))
endfunction

function! agriculture#fzf_rg_raw(command_suffix, ...)
  if !executable('rg')
    return s:warn('rg is not found')
  endif
  let userOptions = get(g:, 'agriculture#rg_options', '')
  let baseOptions = get(g:, 'agriculture#rg_base_options', '')
  let fzfExtraOptions = get(g:, 'agriculture#fzf_extra_options', '')
  let command = 'rg ' . baseOptions . ' ' . s:trim(userOptions . ' ' . a:command_suffix)
  echom g:agriculture#fzf_extra_options
  return call('fzf#vim#grep', extend([command, 1, {'options': fzfExtraOptions}], a:000))
endfunction

function! agriculture#fzf_rg_raw_all(command_suffix, ...)
  if !executable('rg')
    return s:warn('rg is not found')
  endif

  let userOptions = get(g:, 'agriculture#rg_options', '')
  let baseOptions = get(g:, 'agriculture#rg_base_options', '')
  let fzfExtraOptions = get(g:, 'agriculture#fzf_extra_options', '')
  let command = 'rg ' . baseOptions . ' --no-ignore --hidden ' . s:trim(userOptions . ' ' . a:command_suffix)
  return call('fzf#vim#grep', extend([command, 1, {'options': fzfExtraOptions}], a:000))
endfunction

function! s:trim(str)
  if exists('*trim')
    return trim(a:str)
  endif

  return matchstr(a:str, '^\s*\zs.\{-}\ze\s*$')
endfunction

function! s:warn(message)
  echohl WarningMsg
  echom a:message
  echohl None
  return 0
endfunction
