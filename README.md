# Flip
Flip is a Neovim plugin that facilitates quick navigation between files associated with the current file.

Flip identifies associated file counterparts based on the root name of the file (as with the `:r` filename modifier).
All files starting with the same root are considered to be counterparts.

## Installation
Install via your plugin management method of choice. Flip does not require the invocation of a `setup()` function,
although one exists in order to adjust Flip's behavior.

## Configuration
Flip comes with a handful of options to customize its behavior. To change those options, call `setup()` and pass a table
containing the desired options. The example below illustrates the available options and their defaults:

```lua
  require("flip").setup({
    -- A list of additional paths to search for counterparts (Flip always searches the directory containing the current
    -- file). Relative paths are evaluated relative to the directory containing the current file.
    paths = {}, 

    -- A set of regular expressions (provided to `string.match()`; files that match any of the provided expressions will
    -- be excluded from the counterpart set.
    exclude_patterns = {},
  })
```

## Usage
Running the `:Flip next` command will move to the next file in the counterpart list. `:Flip prior` will move to the
previous file. Flip will first attempt to activate the window containing the counterpart, if it exists, and otherwise
will open the file using `:edit`.

