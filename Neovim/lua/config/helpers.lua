local M = {}

function M.select_inner_tag()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()
  while node and node:type() ~= "element" do
    node = node:parent()
  end
  if node then
    local start_row, start_col, end_row, end_col = node:range()
    vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
    vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
    vim.cmd("normal! gv")
  end
end

return M

