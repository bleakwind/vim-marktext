# vim-marktext

## Markdown utilities for vim...
vim-marktext is a Vim plugin designed to simplify Markdown document management by automating heading generation and date updates. It creates properly formatted headings with customizable levels and can automatically update timestamps in your documents.

## Features
- marktext_toc:
    - Creates a hierarchical TOC from Markdown headings
    - Supports configurable maximum heading level
    - Generates proper anchor links
    - Updates existing TOC sections when file is saved
- marktext_time:
    - Inserts current date/time at cursor position
    - Updates dates when file is saved

## Screenshot
![Marktext Screenshot](https://github.com/bleakwind/vim-marktext/blob/main/vim-marktext.png)

## Requirements
Recommended Vim 8.1+

## Installation
```vim
" Using Vundle
Plugin 'bleakwind/vim-marktext'
```

And Run:
```vim
:PluginInstall
```

## Configuration
Add these to your `.vimrc`:

marktext_toc
```vim
" Set 1 enable marktext_toc (default: 0)
let g:marktext_toc_enabled = 0
" Set default heading level
let g:marktext_toc_maxlevel = 3
" Enable automatic toc updates
let g:marktext_toc_autoupdate = 1
```

marktext_time
```vim
" Set 1 enable marktext_time (default: 0)
let g:marktext_time_enabled = 0
" Enable automatic time updates
let g:marktext_time_autoupdate = 1
```

## Usage
| Command         | Description                        |
| --------------- | ---------------------------------- |
| `:MarktextToc`  | Build and insert table of contents |
| `:MarktextTime` | Insert time                        |

## License
BSD 2-Clause - See LICENSE file

