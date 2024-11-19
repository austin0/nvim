return {
  {
    'LhKipp/nvim-nu',
    dependencies = { 'nvimtools/none-ls.nvim' },
    config = function()
      require('nu').setup {
        use_lsp_features = true,
      }
    end,
  },
}
