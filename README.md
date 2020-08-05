# ficus.vim

🌳 Flat-file based note-taking app for Vim

**⚠️ This project is still a work in progress, use at your own risk.**

<img width="24%" alt="cateogry" src="https://user-images.githubusercontent.com/21138560/76740497-f1602c80-67a8-11ea-9310-7a1ad15fa8f5.png"> <img width="24%" alt="tags" src="https://user-images.githubusercontent.com/21138560/76740517-fcb35800-67a8-11ea-95e0-4e6d9bf60876.png"> <img width="24%" alt="notes" src="https://user-images.githubusercontent.com/21138560/76740506-f7560d80-67a8-11ea-88af-376f4e927d51.png"> <a href="https://asciinema.org/a/PPBgcFzqzGT7jj5uc2wwpANYv" target="_blank"><img width="23%" src="https://asciinema.org/a/PPBgcFzqzGT7jj5uc2wwpANYv.svg" /></a>

## Features

- **Vim as editor**: Writing with the beloved text editor.
- **Flat-file based**: Controlling your own data fully.
- **Category and tag system**: Organizing your notes in a classic way.
- **Assets management**: Inserting images easily.

## Introduction

Ficus.vim is a note-taking app standing on the shoulder of vim. It's
flat-file based, which only requires a folder to store your note files. Folder
structure is more like this:

```
/path/to/your/library
├── assets/
├── note-1.md
├── note-2.md
└── ...
```

Ficus.vim searchs for note files under this folder (not recursively). The
attachments can be stored in `assets/` or anywhere your like. But Keep them
close to your notes is more convenient for referencing.

Currently, ficus.vim supports [Markdown](https://en.wikipedia.org/wiki/Markdown).
Note's metadata is stored in YAML Front Matter:

```
/path/to/your/library/note-1.md:
---
title: This is the title
created: 2019-08-15T22:22:22+0800
modified: 2019-08-15T22:22:59+0800
category: categoryA/subcategory/...
tags: [tag1, tag2, ...]
author: Name
description: This is the description
---

Note content goes here ...
```

## Installation

### Requirements

- vim 8
- Python3
    - ruamel.yaml: Required for read&write metadata (YAML Front Matter).

### Install with [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'xinhangliu/ficus.vim'
```

## Quick Start

Configure ficus.vim in your `.vimrc`. The default library path is
`~/Documents/ficus`, you can override it with `g:ficus_dir` option. Read the docs
for more options.

Type `:Ficus` and then press return in vim normal mode to open the ficus window.
Window can be closed by command `:Ficus!`.

For convenience, you can put this line in your `.vimrc` to easily toggle ficus
window:

```vim
nnoremap <Leader>[ :FicusToggle<CR>
```

### Views of ficus.vim

There are 3 views in ficus window:
  - CategoryView: Show the category tree
  - TagView: Show the tags list
  - NoteView: Show the notes list of the category/tag

All the views has similar keybindings. For example:
  - Switch between views: `u`
  - Open the category/tag/note: `o`
  - Create new note: `C`
  - Rename the category/tag/note: `R`

Different views have some unique keybindings. For example:
  - Collapse/expand category in CategoryView: `h/l`
  - Sort notes by title/created/modified in NoteView: `st/sc/sm`
  - Sort tags by name/count in TagView: `st/sc`

### Assets management

Personally, I don't like external image links. Move the cursor to the link in
the note, then execute command `:FicusAssetCollect`, it will be downloaded into
the assets directory. The external link will be replaced with the local one.

`:FicusAssetCollect[!]` also works with local file paths. The file will be
copied or moved (with `!`) to the assets directory.

`:FicusAssetRename` can rename the asset under the cursor.

see more details in the docs.

## Compatibility

* ✔Unix-like, ✘Windows
* ✔vim, ✘neovim
