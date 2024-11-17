return {
  'LhKipp/nvim-nu',
  build = ':TSInstall nu',
  opts = {},
  dependancies = {
    {
      'jay-babu/mason-null-ls.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'williamboman/mason.nvim',
        'nvimtools/none-ls.nvim',
      },
      config = function()
        require('nu').setup {
          use_lsp_features = true,
        }
      end,
    },
  },
}
