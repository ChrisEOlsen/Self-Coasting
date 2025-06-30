vim.g.mapleader = " "
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local ts_utils = require("nvim-treesitter.ts_utils")

-- viq (already native, no change needed)

-- vit for HTML inner tags (using Treesitter)
map("x", "vit", ":<C-u>lua require'config.helpers'.select_inner_tag()<CR>", opts)

-- File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Fuzzy finder
map("n", "<leader>f", ":Telescope find_files<CR>", opts)

-- LazyGit 
map("n", "<leader>gg", ":LazyGit<CR>", opts)

-- Clipboard over SSH
map("v", "<leader>y", function()
  require("osc52").copy_visual()
end, opts)

map("n", "<leader>w", function()
  local api = require("nvim-tree.api")

  -- If the tree is not visible, open it
  if not api.tree.is_visible() then
    api.tree.open()
    return
  end

  -- If the tree is already focused, go right (to editor)
  local current_buf = vim.api.nvim_buf_get_name(0)
  if current_buf:match("NvimTree_") then
    vim.cmd("wincmd l")
  else
    -- Focus the tree
    api.tree.focus()
  end
end, opts)

-- Toggle terminal at the bottom
map("n", "<leader>t", function()
  local term_buf_name = "bottom_term"
  local term_bufnr = nil

  -- Search for an existing terminal buffer
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(bufnr):find(term_buf_name) then
      term_bufnr = bufnr
      break
    end
  end

  -- If buffer exists and window is open, jump to it
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == term_bufnr then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- If not found, open a new terminal in a split
  vim.cmd("botright split")
  vim.cmd("resize 12")
  vim.cmd("term")
  vim.cmd("file " .. term_buf_name)
  vim.cmd("startinsert")
end, opts)


-- Python function skeleton
map("n", "<leader>fp", function()
  if vim.bo.filetype == "python" then
    vim.api.nvim_put({
      "def function_name(params):",
      "    \"\"\"Docstring.\"\"\"",
      "    return true"
    }, "l", true, true)
  end
end, opts)

-- 🐍 Python FastAPI route skeleton
map("n", "<leader>ap", function()
  if vim.bo.filetype == "python" then
    vim.api.nvim_put({
      "from fastapi import APIRouter, HTTPException",
      "",
      "router = APIRouter()",
      "",
      "@router.get(\"/endpoint\")",
      "async def read_item():",
      "    try:",
      "        # Your logic here",
      "        return {\"message\": \"Success\"}",
      "    except Exception as e:",
      "        raise HTTPException(status_code=500, detail=str(e))",
      "",
    }, "l", true, true)
  end
end, opts)

-- JS function skeleton
map("n", "<leader>fj", function()
  if vim.bo.filetype == "javascript" then
    vim.api.nvim_put({
      "function functionName(params) {",
      "}"
    }, "l", true, true)
  end
end, opts)

-- ⚛️ JavaScript (React) fetch skeleton with try/catch
map("n", "<leader>aj", function()
  if vim.bo.filetype == "javascript" then
    vim.api.nvim_put({
      "async function fetchData() {",
      "  try {",
      "    const response = await fetch('/api/endpoint');",
      "    if (!response.ok) throw new Error('Network response was not ok');",
      "    const data = await response.json();",
      "    console.log(data);",
      "  } catch (error) {",
      "    console.error('Fetch error:', error);",
      "  }",
      "}",
      "",
    }, "l", true, true)
  end
end, opts)

-- 🧩 Next.js API handler skeleton (generic)
map("n", "<leader>an", function()
  if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then
    vim.api.nvim_put({
      "// Example API route: /api/your-endpoint",
      "export default async function handler(req, res) {",
      "  try {",
      "    // Your logic here",
      "    return res.status(200).json({ message: \"Success\" });",
      "  } catch (error) {",
      "    console.error(error);",
      "    return res.status(500).json({ error: \"Internal server error\" });",
      "  }",
      "}",
      "",
    }, "l", true, true)
  end
end, opts)

vim.keymap.set("n", "<leader>?", function()
  vim.cmd("new")  -- open split
  vim.cmd("setlocal buftype=nofile")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "Your Keymap Cheatsheet:",
    "",
    "<leader>fp  - Python function skeleton",
    "<leader>fj  - JS function skeleton",
    "<leader>ap  - FastAPI endpoint skeleton",
    "<leader>an  - Next.js API route",
    "<leader>aj  - JS fetch with try/catch",
    "<leader>gg  - LazyGit",
    "<leader>e   - Toggle file explorer",
    "<leader>w   - Switch focus between file explorer/editor",
    "<leader>t   - Toggle terminal",
  })
end, { desc = "Show keymap cheat sheet" })


local ts_utils = require("nvim-treesitter.ts_utils")

local function get_function_types()
  local ft = vim.bo.filetype
  if ft == "python" then
    return { "function_definition" }
  elseif ft == "javascript" or ft == "typescript" then
    return { "function", "function_declaration", "method_definition", "arrow_function" }
  else
    return {}
  end
end

local function goto_next_function()
  local node = ts_utils.get_node_at_cursor()
  if not node then return end

  local root = ts_utils.get_root_for_node(node)
  local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1

  local found = nil
  local function_types = get_function_types()

  local function walk(n)
    if not n then return end
    for child in n:iter_children() do
      local start_row = child:range()
      if vim.tbl_contains(function_types, child:type()) and start_row > current_row then
        if not found or start_row < found:range() then
          found = child
        end
      end
      walk(child)
    end
  end

  walk(root)

  if found then
    local row, col = found:range()
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
  else
    print("No next function found.")
  end
end

vim.keymap.set("n", "<leader>nf", goto_next_function, { desc = "Jump to next function", noremap = true, silent = true })

