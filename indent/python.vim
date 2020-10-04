" Vim indent file
" Language:    Python
" Author:      Akinori Hattori <hattya@gmail.com>
" Last Change: 2020-10-04
" License:     MIT License

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal nolisp
setlocal autoindent
setlocal indentexpr=GetPEP8PythonIndent()
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

function! GetPEP8PythonIndent() abort
  if v:lnum == 1
    return 0
  endif

  " keep current indent
  let l = getline(v:lnum)
  let colon = l[col('.')-2] ==# ':'
  if s:synmatch(v:lnum, 1, s:syn_str) != -1 && s:synmatch(v:lnum - 1, 1, s:syn_str) != -1
    " inside string
    return -1
  elseif colon && col('.') < col('$')
    " : is not at EOL
    return -1
  elseif l =~# '^\s*#'
    " comment
    return -1
  endif

  " indent for bracket
  let pos = s:searchbrkt(v:lnum)
  if pos != [0, 0]
    let l = getline(pos[0])
    if l =~# '[({[]\s*$'
      " hanging indent
      let ind = indent(pos[0])
      if s:rbrkt() || getline(v:lnum) !~# '^\s*[]})]'
        if s:is_compound_stmt(l, 1)
          let ind += s:ml_stmt() || !s:is_compound_stmt(l) ? shiftwidth() * 2 : shiftwidth()
        else
          let ind += s:cont()
        endif
      endif
    else
      let ind = strdisplaywidth(l[: pos[1]-1])
      if s:ml_stmt() && s:is_compound_stmt(l)
        let ind += shiftwidth()
      endif
    endif
    return ind
  endif

  " indent for compound statement
  let l = getline(v:lnum)
  for [stmt, pat] in items(s:compound_stmts)
    if l =~# stmt
      let lnum = s:prevstmt(v:lnum - 1, s:syn_skip)
      let ind = indent(v:lnum) + 1
      while lnum > 0
        while lnum > 1 && getline(lnum - 1) =~# s:lcont
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
  let lnum = s:prevstmt(v:lnum - 1, s:syn_cmt)
  let buf = []
  while lnum > 0
    call insert(buf, matchlist(getline(lnum), '\v^(.{-})\\=$')[1])
    if getline(lnum - 1) =~# s:lcont
      let lnum -= 1
    elseif s:synmatch(lnum, 1, s:syn_str) != -1
      let lnum = prevnonblank(lnum - 1)
    else
      call cursor(lnum, 1)
      let pos = s:searchbrkt(lnum)
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
    let ind += shiftwidth()
  elseif ll =~# s:dedent
    " simple statement
    let ind -= shiftwidth()
  elseif getline(v:lnum - 1) =~# s:lcont
    " line continuation
    if s:is_compound_stmt(ll)
      let ind += s:ml_stmt() ? shiftwidth() * 2 : shiftwidth()
    else
      let ind += s:cont()
    endif
  elseif colon
    " : is at EOL
    return -1
  endif
  return ind
endfunction

function! s:searchbrkt(lnum) abort
  let pos = getpos('.')
  try
    call cursor(a:lnum, 1)
    return searchpairpos('[({[]', '', '[]})]', 'bnW', 's:synmatch(line("."), col("."), s:syn_skip) != -1', max([1, line('.') - s:maxoff]))
  finally
    call setpos('.', pos)
  endtry
endfunction

function! s:prevstmt(lnum, pat) abort
  let lnum = prevnonblank(a:lnum)
  while lnum > 0 && s:synmatch(lnum, indent(lnum) + 1, a:pat) != -1
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum
endfunction

function! s:synmatch(lnum, col, pat) abort
  return match(map(synstack(a:lnum, a:col), 'synIDattr(v:val, "name")'), a:pat)
endfunction

function! s:is_compound_stmt(str, ...) abort
  return (a:0 && a:1 && a:str =~# '\v^\s*<%(class|def)>') || a:str =~# '\v^\s*<%(if|elif|while|for|except|with)>'
endfunction

function! s:cont() abort
  return eval(s:getvar('python_indent_continue', shiftwidth()))
endfunction

function! s:rbrkt() abort
  return s:getvar('python_indent_right_bracket')
endfunction

function! s:ml_stmt() abort
  return s:getvar('python_indent_multiline_statement')
endfunction

function! s:getvar(name, ...) abort
  return get(b:, a:name, get(g:, a:name, a:0 ? a:1 : 0))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
