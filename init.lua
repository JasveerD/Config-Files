-- init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic settings
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8          -- keep 8 lines above/below cursor
vim.opt.signcolumn = "yes"     -- always show sign column (no layout shift)
vim.opt.updatetime = 250       -- faster CursorHold / gitsigns
vim.opt.splitright = true      -- new vertical splits go right
vim.opt.splitbelow = true      -- new horizontal splits go below
vim.opt.ignorecase = true      -- case-insensitive search...
vim.opt.smartcase = true       -- ...unless you type a capital
vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ─────────────────────────────────────────────────────────────
-- PLUGINS
-- ─────────────────────────────────────────────────────────────
require("lazy").setup({
  spec = {

    -- ── Colorscheme ───────────────────────────────────────────
    { "nyoom-engineering/oxocarbon.nvim" },

    -- ── Telescope & FZF ───────────────────────────────────────
    {
      "nvim-telescope/telescope.nvim",
      version = "*",
      dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-telescope/telescope-ui-select.nvim",   -- use telescope for code actions
      },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            layout_strategy = "horizontal",
            sorting_strategy = "ascending",
            layout_config = { prompt_position = "top" },
          },
          extensions = {
            ["ui-select"] = { require("telescope.themes").get_dropdown() },
          },
        })
        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")
      end,
    },

    -- ── Treesitter ────────────────────────────────────────────
    {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").setup({
      ensure_install = {
        "lua", "c", "cpp", "python", "rust",
        "javascript", "typescript", "toml", "json", "yaml", "markdown",
      },
    })
  end,
},

    -- ── Statusline ────────────────────────────────────────────
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        options = {
          theme = "auto",
          globalstatus = true,        -- single statusline across all splits
        },
        sections = {
          lualine_c = { { "filename", path = 1 } },  -- show relative path
        },
      },
    },

    -- ── File Explorer ─────────────────────────────────────────
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = "nvim-tree/nvim-web-devicons",
      opts = {
        view = { width = 35 },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = { show = { git = true } },
        },
        filters = { dotfiles = false },
        git = { enable = true },
        actions = {
          open_file = { quit_on_open = false },
        },
      },
    },

    -- ── Git signs ─────────────────────────────────────────────
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]h", gs.next_hunk,        "Next hunk")
          map("n", "[h", gs.prev_hunk,        "Prev hunk")
          map("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", gs.blame_line,   "Blame line")
        end,
      },
    },

    -- ── Commenting ────────────────────────────────────────────
    {
      "numToStr/Comment.nvim",
      config = function() require("Comment").setup() end,
    },

    -- ── Autopairs ─────────────────────────────────────────────
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local autopairs = require("nvim-autopairs")
        autopairs.setup({ check_ts = true })  -- treesitter-aware
        -- integrate with nvim-cmp
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },

    -- ── Indent guides ─────────────────────────────────────────
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = { char = "│" },
        scope  = { enabled = true },
      },
    },

    -- ── Which-key (keybinding hints) ──────────────────────────
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      config = function()
        local wk = require("which-key")
        wk.setup()
        -- register group labels shown in the popup
        wk.add({
          { "<leader>f", group = "Find (Telescope)" },
          { "<leader>g", group = "Git" },
          { "<leader>h", group = "Hunk" },
          { "<leader>l", group = "LSP" },
        })
      end,
    },

    -- ── Autocomplete ──────────────────────────────────────────
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp-signature-help",  -- signature help while typing
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",          -- ready-made snippet library
      },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        local cmp     = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args) luasnip.lsp_expand(args.body) end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-n>"]   = cmp.mapping.select_next_item(),
            ["<C-p>"]   = cmp.mapping.select_prev_item(),
            ["<C-d>"]   = cmp.mapping.scroll_docs(4),
            ["<C-u>"]   = cmp.mapping.scroll_docs(-4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"]    = cmp.mapping.confirm({ select = true }),
            -- Tab to navigate snippets
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
              else fallback() end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then luasnip.jump(-1)
              else fallback() end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
            { name = "path" },
          }, {
            { name = "buffer", keyword_length = 4 },
          }),
          window = {
            completion    = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          formatting = {
            format = function(_, item)
              -- trim long entries
              local label = item.abbr
              if #label > 40 then item.abbr = label:sub(1, 37) .. "…" end
              return item
            end,
          },
        })
      end,
    },

    -- ── Mason (installs LSP server binaries) ──────────────────
{
  "williamboman/mason.nvim",
  config = function() require("mason").setup() end,
},
{
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "pyright",
        "rust_analyzer",
        "clangd",
        "lua_ls",
      },
      automatic_installation = true,
    })
  end,
},

-- ── LSP config (nvim 0.11 native API) ─────────────────────
{
  "neovim/nvim-lspconfig",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end
      local tb = require("telescope.builtin")
      map("gd",         tb.lsp_definitions,      "Go to definition")
      map("gr",         tb.lsp_references,        "Go to references")
      map("gI",         tb.lsp_implementations,   "Go to implementation")
      map("<leader>lt", tb.lsp_type_definitions,  "Type definition")
      map("<leader>ls", tb.lsp_document_symbols,  "Document symbols")
      map("<leader>lw", tb.lsp_workspace_symbols, "Workspace symbols")
      map("<leader>lr", vim.lsp.buf.rename,        "Rename symbol")
      map("<leader>la", vim.lsp.buf.code_action,   "Code action")
      map("K",          vim.lsp.buf.hover,         "Hover docs")
      map("<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format buffer")
      map("[d", vim.diagnostic.goto_prev,   "Prev diagnostic")
      map("]d", vim.diagnostic.goto_next,   "Next diagnostic")
      map("<leader>ld", vim.diagnostic.open_float, "Diagnostic float")
    end

    -- Diagnostic signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      vim.fn.sign_define("DiagnosticSign"..type, { text = icon, texthl = "DiagnosticSign"..type })
    end

    -- 0.11 native API (replaces lspconfig.xxx.setup)
    vim.lsp.config("pyright",       { capabilities = capabilities, on_attach = on_attach })
    vim.lsp.config("rust_analyzer", { capabilities = capabilities, on_attach = on_attach })
    vim.lsp.config("clangd",        { capabilities = capabilities, on_attach = on_attach })
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach    = on_attach,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace   = { checkThirdParty = false },
        },
      },
    })
    vim.lsp.enable({ "pyright", "rust_analyzer", "clangd", "lua_ls" })
  end,
},

{
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_close_icon = false,
      }
    })
  end,
},

  }, -- end spec

  install = { colorscheme = { "oxocarbon" } },
  checker  = { enabled = true },
  rocks    = { enabled = false },
})

-- ─────────────────────────────────────────────────────────────
-- COLORSCHEME
-- ─────────────────────────────────────────────────────────────
vim.cmd.colorscheme("oxocarbon")

-- ─────────────────────────────────────────────────────────────
-- KEYMAPS
-- ─────────────────────────────────────────────────────────────
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- File explorer
map("n", "<leader>e",  ":NvimTreeToggle<CR>",  "Toggle file explorer")
map("n", "<leader>E",  ":NvimTreeFocus<CR>",   "Focus file explorer")

-- Telescope
local tb = require("telescope.builtin")
map("n", "<C-p>",      tb.find_files,          "Find files")
map("n", "<leader>ff", tb.find_files,          "Find files")
map("n", "<leader>fg", tb.live_grep,           "Live grep")
map("n", "<leader>fb", tb.buffers,             "Find buffers")
map("n", "<leader>fh", tb.help_tags,           "Help tags")
map("n", "<leader>fr", tb.oldfiles,            "Recent files")
map("n", "<leader>fc", tb.commands,            "Commands")
map("n", "<leader>fd", tb.diagnostics,         "Diagnostics")
map("n", "<leader>/",  tb.current_buffer_fuzzy_find, "Fuzzy search buffer")

-- Buffer navigation
map("n", "<S-h>", ":bprevious<CR>", "Prev buffer")
map("n", "<S-l>", ":bnext<CR>",     "Next buffer")
map("n", "<leader>bd", ":bd<CR>",   "Delete buffer")

-- Window navigation (no Ctrl-W gymnastics)
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-l>", "<C-w>l", "Move to right window")
map("n", "<C-j>", "<C-w>j", "Move to lower window")
map("n", "<C-k>", "<C-w>k", "Move to upper window")

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", "Move line down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move line up")

-- Keep cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", "Scroll down (centred)")
map("n", "<C-u>", "<C-u>zz", "Scroll up (centred)")
map("n", "n",     "nzzzv",   "Next search (centred)")
map("n", "N",     "Nzzzv",   "Prev search (centred)")

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR>", "Clear search highlight")

-- Quick save
map("n", "<leader>w", ":w<CR>", "Save file")
map("n", "<leader>q", ":q<CR>", "Quit")
