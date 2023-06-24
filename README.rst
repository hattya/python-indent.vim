python-indent.vim
=================

python-indent.vim is a Vim indent plugin for Python which complies with
`PEP 8`_.

.. image:: https://github.com/hattya/python-indent.vim/actions/workflows/ci.yml/badge.svg
   :target: https://github.com/hattya/python-indent.vim/actions/workflows/ci.yml

.. image:: https://ci.appveyor.com/api/projects/status/j20153feidmt9vai/branch/master?svg=true
   :target: https://ci.appveyor.com/project/hattya/python-indent-vim

.. image:: https://codecov.io/gh/hattya/python-indent.vim/branch/master/graph/badge.svg
   :target: https://codecov.io/gh/hattya/python-indent.vim

.. image:: https://img.shields.io/badge/doc-:h%20python--indent.txt-blue.svg
   :target: doc/python-indent.txt

.. _PEP 8: https://www.python.org/dev/peps/pep-0008/


Installation
------------

Vundle_

.. code:: vim

   Plugin 'hattya/python-indent.vim'

vim-plug_

.. code:: vim

   Plug 'hattya/python-indent.vim', { 'for': 'python' }

dein.vim_

.. code:: vim

   call dein#add('hattya/python-indent.vim')

.. _Vundle: https://github.com/VundleVim/Vundle.vim
.. _vim-plug: https://github.com/junegunn/vim-plug
.. _dein.vim: https://github.com/Shougo/dein.vim


Requirements
------------

- Vim 7.4+


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
