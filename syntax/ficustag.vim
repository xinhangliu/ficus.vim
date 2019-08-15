execute 'syntax match FicusTag #\v^\s*' . g:ficus_tag_icon . '.*# contains=FicusTagNoteCount'

syntax match FicusTagNoteCount '\v\(\d+\)$' contained

highlight default link FicusTag Directory
highlight default link FicusTagNoteCount Comment
