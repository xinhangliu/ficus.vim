# ficus.vim

🌳 Taking notes with plaintext and Vim.

**⚠️ This project is still a work in progress, use at your own risk.**

![CategoryView](https://user-images.githubusercontent.com/21138560/63208187-b65b2500-c103-11e9-8ccc-920ada8635e7.png)

![TagView](https://user-images.githubusercontent.com/21138560/63208194-c541d780-c103-11e9-96a1-eda8b359d4d1.png)

![NoteView](https://user-images.githubusercontent.com/21138560/63208198-ca068b80-c103-11e9-9118-fa1313c8334d.png)

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

## Features

- **Vim as editor**: Vim is a great editor, and comes with tons of awesome
plugins which can help you write (highlight, spellcheck, preview, ....).
- **Flat-file based**: Everything is plain text, backup easily. Even though
without ficus.vim, you can still access your notes. Data is always with you.
- **Won't mass with your data**: Ficus.vim requires nothing except a metadata
header for your note. The internal links of note (attachments, other notes)
will just work when you open it with other tools.
- **Infinite category levels**: Organize your notes with a nested tree structure.
Every note only belongs to one category.
- **Tag system**: Organize your notes with a flat tag structure. Every note can
own multiple tags.

## Installation

### Requirements

- vim 8
- Python3
    - ruamel.yaml

Currently, ficus.vim supports Markdown as note-taking language. python package
`ruamel.yaml` is required for read&write notes' metadata (YAML Front Matter).

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

see more details in docs.
