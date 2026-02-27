-- ─────────────────────────────────────────────────────────────────────────────
--  ~/.config/nvim/init.lua
--  Stack: lazy.nvim · catppuccin · treesitter · mason/lspconfig · nvim-cmp
--         telescope · which-key · lualine · gitsigns · autopairs · comment
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Leader (must be before lazy) ─────────────────────────────────────────────
vim.g.mapleader      = ' '
vim.g.maplocalleader = '\\'

-- ── Options ───────────────────────────────────────────────────────────────────
local o = vim.opt
o.number         = true
o.relativenumber = true
o.expandtab      = true
o.shiftwidth     = 2
o.tabstop        = 2
o.smartindent    = true
o.wrap           = false
o.ignorecase     = true
o.smartcase      = true
o.termguicolors  = true
o.signcolumn     = 'yes'
o.updatetime     = 250
o.timeoutlen     = 300
o.splitbelow     = true
o.splitright     = true
o.scrolloff      = 8
o.clipboard      = 'unnamedplus'
o.cursorline     = true
o.undofile       = true
o.list           = true
o.listchars      = { tab = '» ', trail = '·', nbsp = '␣' }

-- ── Bootstrap lazy.nvim ───────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ───────────────────────────────────────────────────────────────────
require('lazy').setup({

  -- ── Theme ──────────────────────────────────────────────────────────────────
  {
    'catppuccin/nvim',
    name     = 'catppuccin',
    priority = 1000,
    opts = {
      flavour            = 'mocha',
      transparent_background = true,
      integrations = {
        cmp        = true,
        gitsigns   = true,
        telescope  = { enabled = true },
        treesitter = true,
        which_key  = true,
        mason      = true,
        lsp_trouble = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  -- ── Treesitter ─────────────────────────────────────────────────────────────
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash', 'go', 'gomod', 'javascript', 'json', 'jsonc',
        'lua', 'markdown', 'markdown_inline', 'python', 'rust',
        'toml', 'typescript', 'yaml',
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- ── LSP + Mason ────────────────────────────────────────────────────────────
  {
    'williamboman/mason.nvim',
    opts = { ui = { border = 'rounded' } },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'gopls', 'pyright', 'bashls' },
        handlers = {
          -- Default handler — works for most servers
          function(server)
            require('lspconfig')[server].setup({})
          end,
          -- lua_ls needs special settings so it doesn't complain about vim globals
          lua_ls = function()
            require('lspconfig').lua_ls.setup({
              settings = {
                Lua = {
                  diagnostics = { globals = { 'vim' } },
                  workspace   = { checkThirdParty = false },
                  telemetry   = { enable = false },
                },
              },
            })
          end,
        },
      })

      -- Diagnostic signs
      local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
      end

      -- LSP keymaps (set on attach)
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local map = function(k, f, d)
            vim.keymap.set('n', k, f, { buffer = ev.buf, desc = d })
          end
          map('gd',        vim.lsp.buf.definition,      'Go to Definition')
          map('gD',        vim.lsp.buf.declaration,     'Go to Declaration')
          map('gr',        vim.lsp.buf.references,      'References')
          map('gi',        vim.lsp.buf.implementation,  'Implementation')
          map('K',         vim.lsp.buf.hover,           'Hover Docs')
          map('<leader>rn', vim.lsp.buf.rename,         'Rename')
          map('<leader>ca', vim.lsp.buf.code_action,    'Code Action')
          map('<leader>f',  vim.lsp.buf.format,         'Format')
        end,
      })
    end,
  },

  -- ── Completion ─────────────────────────────────────────────────────────────
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp     = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        window  = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>']     = cmp.mapping.select_next_item(),
          ['<C-p>']     = cmp.mapping.select_prev_item(),
          ['<C-d>']     = cmp.mapping.scroll_docs(-4),
          ['<C-f>']     = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>']      = cmp.mapping.confirm({ select = true }),
          ['<Tab>']     = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fb() end
          end, { 'i', 's' }),
          ['<S-Tab>']   = cmp.mapping(function(fb)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fb() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- ── Telescope ──────────────────────────────────────────────────────────────
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      defaults = {
        border      = true,
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        layout_config = { prompt_position = 'top' },
        sorting_strategy = 'ascending',
      },
    },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>',                desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',                 desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',                   desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',                 desc = 'Help tags' },
      { '<leader>fr', '<cmd>Telescope oldfiles<cr>',                  desc = 'Recent files' },
      { '<leader>fd', '<cmd>Telescope diagnostics<cr>',               desc = 'Diagnostics' },
      { '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>',      desc = 'Symbols' },
      { '<leader>gc', '<cmd>Telescope git_commits<cr>',               desc = 'Git commits' },
      { '<leader>gs', '<cmd>Telescope git_status<cr>',                desc = 'Git status' },
    },
  },

  -- ── Which-key ──────────────────────────────────────────────────────────────
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts  = { delay = 300 },
  },

  -- ── Status line ────────────────────────────────────────────────────────────
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme                = 'catppuccin',
        component_separators = '|',
        section_separators   = '',
        globalstatus         = true,
      },
    },
  },

  -- ── Git signs ──────────────────────────────────────────────────────────────
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
      },
    },
    keys = {
      { ']h', '<cmd>Gitsigns next_hunk<cr>',        desc = 'Next hunk' },
      { '[h', '<cmd>Gitsigns prev_hunk<cr>',        desc = 'Prev hunk' },
      { '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', desc = 'Stage hunk' },
      { '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>', desc = 'Reset hunk' },
      { '<leader>hp', '<cmd>Gitsigns preview_hunk<cr>', desc = 'Preview hunk' },
      { '<leader>hb', '<cmd>Gitsigns blame_line<cr>',  desc = 'Blame line' },
    },
  },

  -- ── Auto-pairs ─────────────────────────────────────────────────────────────
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  -- ── Comments ───────────────────────────────────────────────────────────────
  { 'numToStr/Comment.nvim', opts = {} },

}, {
  ui = {
    border = 'rounded',
  },
  install = {
    colorscheme = { 'catppuccin', 'habamax' },
  },
  checker = { enabled = true, notify = false },
})

-- ── Key mappings ──────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- General
map('n', '<leader>w',  '<cmd>w<cr>',          { desc = 'Save' })
map('n', '<leader>q',  '<cmd>q<cr>',          { desc = 'Quit' })
map('n', '<leader>bd', '<cmd>bd<cr>',         { desc = 'Close buffer' })
map('n', '<Esc>',      '<cmd>nohlsearch<cr>', { desc = 'Clear search' })

-- Window navigation (mirrors tmux Alt+arrow)
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Diagnostics
map('n', '[d',          vim.diagnostic.goto_prev,  { desc = 'Prev diagnostic' })
map('n', ']d',          vim.diagnostic.goto_next,  { desc = 'Next diagnostic' })
map('n', '<leader>e',   vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- Move selected lines in visual mode
map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move lines down' })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move lines up' })

-- Keep cursor centred when jumping
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n',     'nzzzv')
map('n', 'N',     'Nzzzv')
