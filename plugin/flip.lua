
local commands = {
  next = function() require("flip").flip(1) end,
  prior = function() require("flip").flip(-1) end,
}

local function command_flip(options)
  local arguments = options.fargs
  local action = #arguments > 0 and arguments[1] or "next"
  local command = commands[action]
  if command then
    command()
  else
    vim.notify("Flip: Unknown action: " .. action, vim.log.levels.ERROR)
  end
end

local function complete_flip(prefix, command, _)
  if string.match(command, "^Flip%s+%w*$") then
    local keys = vim.tbl_keys(commands)
    return vim.iter(keys):filter(function(key) return key:find(prefix) ~= nil end):totable()
  end
end

vim.api.nvim_create_user_command("Flip", command_flip, {nargs = "?", desc = "Flip betwen file counterparts", complete = complete_flip})

