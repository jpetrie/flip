local M = {
  --- @class (exact) flip.Options
  --- @field paths string[]|nil
  --- @field exclude_patterns string[]|nil
  options = {
    paths = {},
    exclude_patterns = {},
  }
}

local function is_counterpart_included(filename)
  for _, pattern in ipairs(M.options.exclude_patterns) do
    if string.match(filename, pattern) ~= nil then
      return false
    end
  end

  return true
end

local function deduplicate(list)
  local set = {}
  for _, item in ipairs(list) do
    if set[item] == nil then
      set[item] = true
    end
  end

  local results = {}
  for item,_ in pairs(set) do
    table.insert(results, item)
  end

  table.sort(results)
  return results
end

local function get_root(filename)
  local parts = vim.fn.split(filename, "[.]")
  local result = parts[1]
  if filename[1] == "." then
    -- Restore the leading dot, if it existed.
    result = "." .. result
  end

  return result
end

local function get_counterparts(filename)
  if filename == nil or #filename == 0 then
    return {}
  end

  -- Prepare search paths.
  local base = vim.fn.fnamemodify(filename, ":p:h")
  local paths = {base}
  for _, path in ipairs(M.options.paths) do
    if path[1] == "/" then
      table.insert(paths, path)
    else
      table.insert(paths, base .. "/" .. path)
    end
  end

  -- Remove any duplicates to reduce redundant searches.
  paths = deduplicate(paths)

  -- Locate all potential counterparts on disk.
  local root = get_root(vim.fn.fnamemodify(filename, ":t"))
  local files = vim.fn.globpath(vim.fn.join(paths, ","), root .. ".*", false, true)
  local results = {}
  for _, file in ipairs(files) do
    table.insert(results, vim.fn.simplify(file))
  end

  results = deduplicate(results)
  results = vim.tbl_filter(is_counterpart_included, results)
  return results
end

M.flip = function(amount)
  local file = vim.api.nvim_buf_get_name(0)
  local counterparts = get_counterparts(file)

  for index, counterpart in ipairs(counterparts) do
    if counterpart == file then
      local which = (index + amount - 1) % #counterparts
      local target = counterparts[which + 1]
      if target ~= file then
        local window = vim.fn.bufwinid(target)
        if window >= 0 then
          vim.api.nvim_set_current_win(window)
          return
        end

        vim.cmd("edit " .. vim.fn.fnameescape(target))
        return
      end
    end
  end

  vim.notify("No counterpart.")
end

M.setup = function(options)
  M.options = vim.tbl_extend("keep", options, M.options)
end

return M

