python-indent.vim
=================

python-indent.vim is a Vim indent plugin for Python which complies with
`PEP 8`_.

.. image:: https://semaphoreci.com/api/v1/hattya/python-indent-vim/branches/master/badge.svg
   :target: https://semaphoreci.com/hattya/python-indent-vim

.. image:: https://ci.appveyor.com/api/projects/status/j20153feidmt9vai/branch/master?svg=true
   :target: https://ci.appveyor.com/project/hattya/python-indent-vim

.. image:: https://codecov.io/gh/hattya/python-indent.vim/branch/master/graph/badge.svg
   :target: https://codecov.io/gh/hattya/python-indent.vim

.. _PEP 8: https://www.python.org/dev/peps/pep-0008/


Installation
------------

pathogen.vim_

.. code:: console

   $ cd ~/.vim/bundle
   $ git clone https://github.com/hattya/python-indent.vim

Vundle_

.. code:: vim

   Plugin 'hattya/python-indent.vim'

NeoBundle_

.. code:: vim

   NeoBundle 'hattya/python-indent.vim'

vim-plug_

.. code:: vim

   Plug 'hattya/python-indent.vim', { 'for': 'python' }

.. _pathogen.vim: https://github.com/tpope/vim-pathogen
.. _Vundle: https://github.com/VundleVim/Vundle.vim
.. _NeoBundle: https://github.com/Shougo/neobundle.vim
.. _vim-plug: https://github.com/junegunn/vim-plug


Configuration
-------------

g:python_indent_continue
~~~~~~~~~~~~~~~~~~~~~~~~

Indent for a continuation line.

Default value: ``&sw``

.. code:: python

   value = 1 + \
       2 + \
       3
   value = func(
       1,
       2,
       3)


g:python_indent_right_bracket
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If set to ``1``, a right bracket will be lined up under the first non-whitespace
character of the last line.

Default:

.. code:: python

   value = [
       1,
       2,
       3,
   ]
   value = func(
       1,
       2,
       3,
   )

If set to ``1``:

.. code:: python

   value = [
       1,
       2,
       3,
       ]
   value = func(
       1,
       2,
       3,
       )


g:python_indent_multiline_statement
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If set to ``1``, add some extra indentation on the conditional continuation line.

Default:

.. code:: python

   if (isinstance(path, str) and
       os.path.isfile(path)):
       pass

If set to ``1``:

.. code:: python

   if (isinstance(path, str) and
           os.path.isfile(path)):
       pass


Testing
-------

python-indent.vim uses themis.vim_ for testing.

.. code:: console

   $ cd /path/to/python-indent.vim
   $ git clone https://github.com/thinca/vim-themis
   $ ./vim-themis/bin/themis

.. _themis.vim: https://github.com/thinca/vim-themis


License
-------

python-indent.vim is distributed under the terms of the MIT License.
