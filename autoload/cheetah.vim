function! cheetah#init() abort
  " This function can be used for Vim compatibility
  " For pure Neovim plugins, it's often not necessary
  " but it's good practice to include it for compatibility
  lua require('cheetah').setup({})
endfunction
