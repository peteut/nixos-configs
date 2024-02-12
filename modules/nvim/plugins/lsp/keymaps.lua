local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = severity }) end
end

local keys = {
  { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
  { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
  { "gd", require("telescope.builtin").lsp_definitions, desc = "Goto Definition", has = "definition" },
  { "gr", require("telescope.builtin").lsp_references, desc = "References" },
  { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  { "gI", require("telescope.builtin").lsp_implementations, desc = "Goto Implementation" },
  { "gy", require("telescope.builtin").lsp_type_definitions, desc = "Goto T[y]pe Definition" },
  { "K", vim.lsp.buf.hover, desc = "Hover" },
  { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
  { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
  { "]d", diagnostic_goto(true), desc = "Next Diagnostic" },
  { "[d", diagnostic_goto(false), desc = "Prev Diagnostic" },
  { "]e", diagnostic_goto(true, "ERROR"), desc = "Next Error" },
  { "[e", diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
  { "]w", diagnostic_goto(true, "WARN"), desc = "Next Warning" },
  { "[w", diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
  { "<leader>cf", "<cmd>Format<cr>", desc = "Format Document", has = "documentFormatting" },
  { "<leader>cf", "<cmd>Format<cr>", desc = "Format Range", mode = "v", has = "documentRangeFormatting" },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
  {
    "<leader>cA",
    function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source" },
          diagnostics = {},
        },
      })
    end,
    desc = "Source Action",
    has = "codeAction",
  },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
}
