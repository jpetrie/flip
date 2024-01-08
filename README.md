# Flip
Flip is a Neovim plugin that enables quick navigation between files associated with the current file.

Flip identifies associated file counterparts based on the root name of the file (as with the `:r` filename modifier).
All files starting with the same root are considered to be counterparts.

## Features
### Cycle Through Counterparts
Use `:FlipNext` and `:FlipPrevious` to navigate forward and backward within the counterparts of the current file.
Flip will try to switch to a window containing the counterpart if one is visible, otherwise it will open the file.

### Define How Counterparts Open
Both of Flip's commands can take arguments that control how a counterpart will be opened when neccessary. The default
is to use `:edit`, but you can for example invoke `FlipNext botright vsplit` to open the next counterpart in a vertical
split to the right.

### Configure Search Paths
The `paths` option can be set to a list of paths to search when finding counterparts. Non-absolute paths are considered
relative to the directory of the current file. By default, only the directory of the current file is searched. Flip can
also be configured to search the directories defined by Neovim's `path` option, and to include listed buffers that
haven't yet been saved to disk in the search. 

## Installation
Install via your plugin manager of choice. For example, using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  "jpetrie/flip",
  opts = {
    -- see below for options
  }
}
```

## Configuration
Flip comes with the following defaults. See `:help flip.options` for more details.

```lua
{
  -- A list of paths to search for counterparts (in addition to the directory of the
  -- current file, which is always searched).
  paths = {}, 

  -- If true, also search the directories in Neovim's path (:help path).
  include_path = false,

  -- If true, also search listed buffers.
  include_buffers = true,

  -- A set of regular expressions; files that match any of the provided expressions
  -- will be excluded from the counterpart set.
  exclude_paths = {},
}
```

