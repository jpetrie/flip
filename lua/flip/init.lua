local flip = {
  options = {
    paths = {},
    include_path = false,
    include_buffers = true,
    exclude_patterns = {},
  }
}

local function is_counterpart_included(filename)
  for _, pattern in ipairs(flip.options.exclude_patterns) do
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
      set[item] = {}
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
  -- Prepare search paths.
  local base = vim.fn.fnamemodify(filename, ":p:h")
  local paths = {base}
  for _, path in ipairs(flip.options.paths) do
    if path[1] == "/" then
      table.insert(paths, path)
    else
      table.insert(paths, base .. "/" .. path)
    end
  end

  if flip.options.include_path then
    for _, path in ipairs(vim.opt.path:get()) do
      if #path > 0 then
        table.insert(paths, path)
      end
    end
  end

  -- Collapse the search paths into a string, separating each with a comma, for globpath().
  paths = vim.fn.join(paths, ",")

  -- Locate all potential counterparts on disk.
  local root = get_root(vim.fn.fnamemodify(filename, ":t"))
  local files = vim.fn.globpath(paths, root .. "*", 0, 1)
  local results = {}
  for _, file in ipairs(files) do
    table.insert(results, vim.fn.simplify(file))
  end

  -- Add any potential counterparts from listed buffers that haven't been written to disk yet.
  if flip.options.include_buffers then
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      local is_loaded = vim.api.nvim_buf_is_loaded(buffer)
      local is_file = vim.bo[buffer].buftype ~= "nofile"
      if is_loaded and is_file then
        local buffer_file = vim.api.nvim_buf_get_name(buffer)
        local buffer_root = get_root(vim.fn.fnamemodify(buffer_file, ":t"))
        if buffer_root == root then
          table.insert(results, vim.fn.simplify(buffer_file))
        end
      end
    end
  end

  results = deduplicate(results)
  results = vim.tbl_filter(is_counterpart_included, results)
  return results
end

local function cycle(amount, command)
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

        if #command == 0 then
          command = "edit"
        end

        vim.cmd(command .. " " .. vim.fn.fnameescape(target))
        return
      end
    end
  end

  vim.notify("No counterpart.")
end

function flip.setup(options)
  flip.options = vim.tbl_extend("keep", options, flip.options)

  vim.api.nvim_create_user_command("FlipNext", function(command) cycle(1, command.args) end, {nargs = "*"})
  vim.api.nvim_create_user_command("FlipPrevious", function(command) cycle(-1, command.args) end, {nargs = "*"})
end

return flip

