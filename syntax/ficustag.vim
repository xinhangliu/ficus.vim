execute 'syntax match FicusTag /\v^\s*' . escape(ficus#options_dict('ficus_icons', 'tag'), '/') . '.*/ contains=FicusTagNoteCount'

syntax match FicusTagNoteCount '\v \(\d+\)$' contained

highlight default link FicusTag Directory
highlight default link FicusTagNoteCount Comment
