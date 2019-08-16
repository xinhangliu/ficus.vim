execute 'syntax match FicusTag /\v^\s*' . escape(g:ficus_icons['tag'], '/') . '.*/ contains=FicusTagNoteCount'

syntax match FicusTagNoteCount '\v \(\d+\)$' contained

highlight default link FicusTag Directory
highlight default link FicusTagNoteCount Comment
