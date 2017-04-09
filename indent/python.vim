" File:        indent/python.vim
" Author:      Akinori Hattori <hattya@gmail.com>
" Last Change: 2017-04-09
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

let b:undo_indent = 'setlocal lisp< autoindent< indentexpr< indentkeys<'

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
let s:lcont = '\\$'
let s:syn_skip = '\v\c%(Comment|Quotes|String)$'
let s:syn_str = '\v\c%(Quotes|String)$'
let s:syn_cmt = '\cComment$'

function! GetPEP8PythonIndent(lnum) abort
  if a:lnum == 1
    return 0
  endif

  " keep current indent
  let colon = getline(a:lnum)[col('.') - 2] ==# ':'
  if s:synmatch(a:lnum, 1, s:syn_str) != -1 && s:synmatch(a:lnum - 1, 1, s:syn_str) != -1
    " inside string
    return -1
  elseif colon && col('.') < col('$')
    " : is not at EOL
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
      let ind = strdisplaywidth(l[: pos[1] - 1])
      if s:ml_stmt() && s:is_compound_stmt(l)
        let ind += s:sw()
      endif
    endif
    return ind
  endif

  " indent for compound statement
  let l = getline(a:lnum)
  for [stmt, pat] in items(s:compound_stmts)
    if l =~# stmt
      let lnum = s:prevstmt(a:lnum - 1, s:syn_skip)
      let ind = indent(a:lnum) + 1
      while 0 < lnum
        while 1 < lnum && getline(lnum - 1) =~# s:lcont
          let lnum -= 1
        endwhile
        let pind = indent(lnum)
        if pind < ind
          if getline(lnum) =~# pat
            return pind
          endif
          let ind = pind
        endif
        let lnum = s:prevstmt(lnum - 1, s:syn_skip)
      endwhile
      return -1
    endif
  endfor

  " indent for line
  let lnum = s:prevstmt(a:lnum - 1, s:syn_cmt)
  let buf = []
  while 0 < lnum
    call insert(buf, matchlist(getline(lnum), '\v^(.{-})\\=$')[1])
    if getline(lnum - 1) =~# s:lcont
      let lnum -= 1
    elseif s:synmatch(lnum, 1, s:syn_str) != -1
      let lnum = prevnonblank(lnum - 1)
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
  elseif getline(a:lnum - 1) =~# s:lcont
    " line continuation
    if s:is_compound_stmt(ll)
      let ind += s:ml_stmt() ? s:sw() * 2 : s:sw()
    else
      let ind += s:cont()
    endif
  elseif colon
    " : is at EOL
    return -1
  endif
  return ind
endfunction

function! s:search_bracket(lnum) abort
  let pos = getpos('.')
  try
    call cursor(a:lnum, 1)
    let skip = "s:synmatch(line('.'), col('.'), s:syn_skip) != -1"
    let stopline = max([1, line('.') - s:maxoff])
    return searchpairpos('[({[]', '', '[]})]', 'bnW', skip, stopline)
  finally
    call setpos('.', pos)
  endtry
endfunction

function! s:prevstmt(lnum, pat) abort
  let lnum = prevnonblank(a:lnum)
  while 0 < lnum && s:synmatch(lnum, indent(lnum) + 1, a:pat) != -1
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum
endfunction

function! s:synmatch(lnum, col, pat) abort
  return match(map(synstack(a:lnum, a:col), "synIDattr(v:val, 'name')"), a:pat)
endfunction

function! s:is_compound_stmt(string, ...) abort
  if get(a:000, 0) && a:string =~# '\v^\s*<%(class|def)>'
    return 1
  endif
  return a:string =~# '\v^\s*<%(if|elif|while|for|except|with)>'
endfunction

function! s:cont() abort
  return eval(s:getvar('python_indent_continue', s:sw()))
endfunction

function! s:rbrkt() abort
  return s:getvar('python_indent_right_bracket')
endfunction

function! s:ml_stmt() abort
  return s:getvar('python_indent_multiline_statement')
endfunction

function! s:getvar(name, ...) abort
  return get(b:, a:name, get(g:, a:name, 0 < a:0 ? a:1 : 0))
endfunction

if exists('*shiftwidth')
  let s:sw = function('shiftwidth')
else
  function! s:sw()
    return &sw
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
