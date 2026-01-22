set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

lua <<LUAEND
vim.lsp.config['vtsls'] = {
  -- Command and arguments to start the server.
  cmd = { 'vtsls', '--stdio' },
  -- Filetypes to automatically attach to.
  filetypes = { 'typescript' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { 'package.json', '.git' },
}
vim.lsp.enable('vtsls')
LUAEND

nmap <C-W><C-]> :tab split \| lua vim.lsp.buf.definition()<CR>
nmap <C-W>t :tab split<CR>
