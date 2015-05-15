" File:        indent/python.vim
" Author:      Akinori Hattori <hattya@gmail.com>
" Last Change: 2015-05-15
" License:     MIT License

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal nolisp
setlocal autoindent
setlocal indentexpr=GetPEP8PythonIndent(v:lnum)
setlocal indentkeys-=0{
setlocal indentkeys-=:
setlocal indentkeys+=0),0],<:>,=elif,=except,=finally

if exists('*GetPEP8PythonIndent')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let s:maxoff = 50
let s:compound_stmts = {
\  '^\s*\<elif\>':    '\v^\s*<%(if|elif)>',
\  '^\s*\<else\>':    '\v^\s*<%(if|elif|for|try|except)>',
\  '^\s*\<except\>':  '\v^\s*<%(try|except)>',
\  '^\s*\<finally\>': '\v^\s*<%(try|except|else)>',
\}
let s:dedent = '\v^\s*<%(pass|return|raise|break|continue)>'

function GetPEP8PythonIndent(lnum)
  " keep current indent inside string
  if s:is_str(a:lnum, 1)
    return -1
  endif

  " indent for bracket
  let pos = s:search_bracket(a:lnum)
  if pos != [0, 0]
    let l = getline(pos[0])
    if l =~# '[({[]\s*$'
      " hanging indent
      let ind = indent(pos[0])
      if s:rbrkt() || getline(a:lnum) !~# '^\s*[]})]'
        if s:is_compound_stmt(l, 1)
          let ind += s:ml_stmt() || !s:is_compound_stmt(l) ? s:sw() * 2 : s:sw()
        else
          let ind += s:cont()
        endif
      endif
    else
      let ind = pos[1]
      if s:ml_stmt() && s:is_compound_stmt(l)
        let ind += s:sw()
      endif
    endif
    return ind
  endif

  " indent for compound statement
  let l = getline(a:lnum)
  for stmt in keys(s:compound_stmts)
    if l =~# stmt
      let pat = s:compound_stmts[stmt]
      let lnum = s:prevstmt(a:lnum - 1)
      let ind = indent(a:lnum) + 1
      while 0 < lnum
        let pind = indent(lnum)
        if pind < ind
          let ind = pind
          if getline(lnum) =~# pat
            return ind
          endif
        endif
        let lnum = s:prevstmt(lnum - 1)
      endwhile
      return -1
    endif
  endfor

  " indent for line
  let buf = []
  let lnum = s:prevstmt(a:lnum - 1)
  while 0 < lnum
    call insert(buf, matchlist(getline(lnum), '\v^(.{-})\\=$')[1])
    if getline(lnum - 1) =~# '\\$'
      let lnum -= 1
    else
      call cursor(lnum, 1)
      let pos = s:search_bracket(lnum)
      if pos == [0, 0]
        break
      endif
      let buf = getline(pos[0], lnum - 1) + buf
      let lnum = pos[0]
    endif
  endwhile
  if lnum < 1
    return -1
  endif

  let ind = indent(lnum)
  let ll = join(buf, ' ')
  if ll =~# ':\s*\%(#.*\)\=$'
    " compound statement
    let ind += s:sw()
  elseif ll =~# s:dedent
    " simple statement
    let ind -= s:sw()
  elseif getline(a:lnum - 1) =~# '\\$'
    " line continuation
    if s:is_compound_stmt(ll)
      let ind += s:ml_stmt() ? s:sw() * 2 : s:sw()
    else
      let ind += s:cont()
    endif
  endif
  return ind
endfunction

function! s:search_bracket(lnum)
  let pos = getpos('.')
  try
    call cursor(a:lnum, 1)
    let skip = "!s:is_stmt(line('.'), col('.'))"
    let stopline = max([1, line('.') - s:maxoff])
    return searchpairpos('[({[]', '', '[]})]', 'bnW', skip, stopline)
  finally
    call setpos('.', pos)
  endtry
endfunction

function! s:prevstmt(lnum)
  let lnum = a:lnum
  while 0 < lnum
    let lnum = prevnonblank(lnum)
    if s:is_stmt(lnum, indent(lnum) + 1)
      return lnum
    endif
    let lnum -= 1
  endwhile
endfunction

function! s:is_stmt(lnum, col)
  return s:synmatch(a:lnum, a:col,'\v\c%(Comment|String)$') == -1
endfunction

function! s:is_str(lnum, col)
  return s:synmatch(a:lnum, a:col, '\cString$') != -1
endfunction

function! s:synmatch(lnum, col, pat)
  return match(map(synstack(a:lnum, a:col), "synIDattr(v:val, 'name')"), a:pat)
endfunction

function! s:is_compound_stmt(string, ...)
  if a:0 && a:1 &&
  \  a:string =~# '\v^\s*<%(class|def)>'
    return 1
  endif
  return a:string =~# '\v^\s*<%(if|elif|while|for|except|with)>'
endfunction

function! s:cont()
  return eval(s:getvar('python_indent_continue', s:sw()))
endfunction

function! s:rbrkt()
  return s:getvar('python_indent_right_bracket')
endfunction

function! s:ml_stmt()
  return s:getvar('python_indent_multiline_statement')
endfunction

function! s:getvar(name, ...)
  return get(b:, a:name, get(g:, a:name, 0 < a:0 ? a:1 : 0))
endfunction

if exists('*shiftwidth')
  function! s:sw()
    return shiftwidth()
  endfunction
else
  function! s:sw()
    return &sw
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
