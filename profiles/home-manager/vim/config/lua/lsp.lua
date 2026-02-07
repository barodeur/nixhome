require'fidget'.setup {}

-- Advertise completion capabilities to LSP servers
vim.lsp.config('*', {
  capabilities = require'cmp_nvim_lsp'.default_capabilities(),
})

-- Per-server overrides
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = false,
        excludee = {'**/.direnv', '**/.tox'},
      },
    },
  },
})

vim.lsp.config('ts_ls', {
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
  end,
})

vim.lsp.config('yamlls', {
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
    },
  },
})

vim.lsp.config('ocamllsp', {
  cmd = { "ocamllsp" },
  filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
  root_markers = { "*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace" },
})

-- Enable all servers
vim.lsp.enable({
  'bashls',
  'clangd',
  'cssls',
  'dockerls',
  'gopls',
  'html',
  'jsonls',
  'pyright',
  'terraformls',
  'ts_ls',
  'yamlls',
  'ocamllsp',
})

-- Keybindings on LSP attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local opts = { buffer = args.buf }

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>D', '<cmd>Telescope lsp_type_definitions<CR>', opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)
    vim.keymap.set('n', '<leader>q', '<cmd>Trouble diagnostics<CR>', opts)

    if client:supports_method('textDocument/formatting') then
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end, opts)
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
    if client:supports_method('textDocument/rangeFormatting') then
      vim.keymap.set('v', '<leader>f', function() vim.lsp.buf.format() end, opts)
    end

    if client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd('CursorHold', {
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
