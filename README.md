# ficus.vim

🌳 Taking notes with plaintext and Vim.

**⚠️ This project is still a work in progress, use at your own risk.**

<!-- TODO: screenshot/gif/video -->

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
- **Unlimited**: Ficus.vim currently supports Markdown only, but it can be
easily extended to support other markup languages.

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

<!-- TODO: quick start -->

## Companions

Ficus.vim keeps this idea in mind: do one thing, let other plugins do more.

- [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc): Export markdown to varies format
- [vim-pandoc-syntax](https://github.com/vim-pandoc/vim-pandoc-syntax): Better Markdown syntax highlight
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim): Instant markdown preview
- [vim-instant-markdown](https://github.com/suan/vim-instant-markdown): Instant markdown preview
- [vim-markdown-wiki](https://github.com/mmai/vim-markdown-wiki): Ease links manipulation and navigation
- [vista.vim](https://github.com/liuchengxu/vista.vim): Section navigation
