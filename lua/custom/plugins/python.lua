return {
  {
    -- TOOLING: COMPLETION, DIAGNOSTICS, FORMATTING

    -- MASON
    -- * Manager for external tools (LSPs, linters, debuggers, formatters)
    -- * auto-install those external tools
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      dependencies = {
        { 'williamboman/mason.nvim', opts = true },
        { 'williamboman/mason-lspconfig.nvim', opts = true },
      },
      opts = {
        ensure_installed = {
          'pyright', -- LSP for python
          'ruff', -- linter & formatter (includes flake8, pep8, black, isort, etc.)
          'debugpy', -- debugger
          'taplo', -- LSP for toml (e.g., for pyproject.toml files)
        },
      },
    },

    -- Setup the LSPs
    -- `gd` and `gr` for goto definition / references
    -- `<C-f>` for formatting
    -- `<leader>c` for code actions (organize imports, etc.)
    {
      'neovim/nvim-lspconfig',
      keys = {
        { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition' },
        { 'gr', vim.lsp.buf.references, desc = 'Goto References' },
        { '<leader>c', vim.lsp.buf.code_action, desc = 'Code Action' },
        { '<C-f>', vim.lsp.buf.format, desc = 'Format File' },
      },
      init = function()
        -- this snippet enables auto-completion
        local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
        lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

        -- setup pyright with completion capabilities
        require('lspconfig').pyright.setup {
          capabilities = lspCapabilities,
          cmd = { 'pyright-langserver', '--stdio' },
        }

        -- setup taplo with completion capabilities
        require('lspconfig').taplo.setup {
          capabilities = lspCapabilities,
        }

        -- ruff uses an LSP proxy, therefore it needs to be enabled as if it
        -- were a LSP. In practice, ruff only provides linter-like diagnostics
        -- and some code actions, and is not a full LSP yet.
        require('lspconfig').ruff.setup {
          -- disable ruff as hover provider to avoid conflicts with pyright
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        }
      end,
    },

    -- COMPLETION
    {
      'saghen/blink.cmp',
      version = 'v0.*', -- blink.cmp requires a release tag for its rust binary

      opts = {
        -- 'default' for mappings similar to built-in vim completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        keymap = { preset = 'default' },

        highlight = {
          -- sets the fallback highlight groups to nvim-cmp's highlight groups
          -- useful for when your theme doesn't support blink.cmp
          use_nvim_cmp_as_default = true,
        },
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },
    },

    -----------------------------------------------------------------------------
    -- PYTHON REPL
    -- A basic REPL that opens up as a horizontal split
    -- * use `<leader>i` to toggle the REPL
    -- * use `<leader>I` to restart the REPL
    -- * `+` serves as the "send to REPL" operator. That means we can use `++`
    -- to send the current line to the REPL, and `+j` to send the current and the
    -- following line to the REPL, like we would do with other vim operators.
    {
      'Vigemus/iron.nvim',
      keys = {
        { '<leader>i', vim.cmd.IronRepl, desc = '󱠤 Toggle REPL' },
        { '<leader>I', vim.cmd.IronRestart, desc = '󱠤 Restart REPL' },

        -- these keymaps need no right-hand-side, since that is defined by the
        -- plugin config further below
        { '+', mode = { 'n', 'x' }, desc = '󱠤 Send-to-REPL Operator' },
        { '++', desc = '󱠤 Send Line to REPL' },
      },

      -- since irons's setup call is `require("iron.core").setup`, instead of
      -- `require("iron").setup` like other plugins would do, we need to tell
      -- lazy.nvim which module to via the `main` key
      main = 'iron.core',

      opts = {
        keymaps = {
          send_line = '++',
          visual_send = '+',
          send_motion = '+',
        },
        config = {
          -- This defines how the repl is opened. Here, we set the REPL window
          -- to open in a horizontal split to the bottom, with a height of 10.
          repl_open_cmd = 'horizontal bot 10 split',

          -- This defines which binary to use for the REPL. If `ipython` is
          -- available, it will use `ipython`, otherwise it will use `python3`.
          -- since the python repl does not play well with indents, it's
          -- preferable to use `ipython` or `bypython` here.
          -- (see: https://github.com/Vigemus/iron.nvim/issues/348)
          repl_definition = {
            python = {
              command = function()
                local ipythonAvailable = vim.fn.executable 'ipython' == 1
                local binary = ipythonAvailable and 'ipython' or 'python3'
                return { binary }
              end,
            },
          },
        },
      },
    },

    -----------------------------------------------------------------------------
    -- SYNTAX HIGHLIGHTING & COLORSCHEME

    -- treesitter for syntax highlighting
    -- * auto-installs the parser for python
    {
      'nvim-treesitter/nvim-treesitter',
      -- automatically update the parsers with every new release of treesitter
      build = ':TSUpdate',

      -- since treesitter's setup call is `require("nvim-treesitter.configs").setup`,
      -- instead of `require("nvim-treesitter").setup` like other plugins do, we
      -- need to tell lazy.nvim which module to via the `main` key
      main = 'nvim-treesitter.configs',

      opts = {
        highlight = { enable = true }, -- enable treesitter syntax highlighting
        indent = { enable = true }, -- better indentation behavior
        ensure_installed = {
          -- auto-install the Treesitter parser for python and related languages
          'python',
          'toml',
          'rst',
          'ninja',
          'markdown',
          'markdown_inline',
        },
      },
    },

    -----------------------------------------------------------------------------
    -- DEBUGGING

    -- DAP Client for nvim
    -- * start the debugger with `<leader>dc`
    -- * add breakpoints with `<leader>db`
    -- * terminate the debugger `<leader>dt`
    {
      'mfussenegger/nvim-dap',
      keys = {
        {
          '<leader>dc',
          function()
            require('dap').continue()
          end,
          desc = 'Start/Continue Debugger',
        },
        {
          '<leader>db',
          function()
            require('dap').toggle_breakpoint()
          end,
          desc = 'Add Breakpoint',
        },
        {
          '<leader>dt',
          function()
            require('dap').terminate()
          end,
          desc = 'Terminate Debugger',
        },
      },
    },

    -- UI for the debugger
    -- * the debugger UI is also automatically opened when starting/stopping the debugger
    -- * toggle debugger UI manually with `<leader>du`
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
      keys = {
        {
          '<leader>du',
          function()
            require('dapui').toggle()
          end,
          desc = 'Toggle Debugger UI',
        },
      },
      -- automatically open/close the DAP UI when starting/stopping the debugger
      config = function()
        local listener = require('dap').listeners
        listener.after.event_initialized['dapui_config'] = function()
          require('dapui').open()
        end
        listener.before.event_terminated['dapui_config'] = function()
          require('dapui').close()
        end
        listener.before.event_exited['dapui_config'] = function()
          require('dapui').close()
        end
      end,
    },

    -- Configuration for the python debugger
    -- * configures debugpy for us
    -- * uses the debugpy installation from mason
    {
      'mfussenegger/nvim-dap-python',
      dependencies = 'mfussenegger/nvim-dap',
      config = function()
        -- fix: E5108: Error executing lua .../Local/nvim-data/lazy/nvim-dap-ui/lua/dapui/controls.lua:14: attempt to index local 'element' (a nil value)
        -- see: https://github.com/rcarriga/nvim-dap-ui/issues/279#issuecomment-1596258077
        require('dapui').setup()
        -- uses the debugypy installation by mason
        local debugpyPythonPath = require('mason-registry').get_package('debugpy'):get_install_path() .. '/venv/bin/python3'
        require('dap-python').setup(debugpyPythonPath, {}) ---@diagnostic disable-line: missing-fields
      end,
    },

    -----------------------------------------------------------------------------
    -- EDITING SUPPORT PLUGINS
    -- some plugins that help with python-specific editing operations

    -- Docstring creation
    -- * quickly create docstrings via `<leader>a`
    {
      'danymat/neogen',
      opts = true,
      keys = {
        {
          '<leader>a',
          function()
            require('neogen').generate()
          end,
          desc = 'Add Docstring',
        },
      },
    },

    -- f-strings
    -- * auto-convert strings to f-strings when typing `{}` in a string
    -- * also auto-converts f-strings back to regular strings when removing `{}`
    {
      'chrisgrieser/nvim-puppeteer',
      dependencies = 'nvim-treesitter/nvim-treesitter',
    },
  },
}
