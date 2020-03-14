syntax match FicusNoteTitle '\v^.*$'
execute 'syntax match FicusNoteSeperator /\v^\' . g:ficus_notes_seperator . '+(\d+)?$/ contains=FicusNoteID'
execute 'syntax match FicusNoteID #\v\d# contained conceal cchar=' . g:ficus_notes_seperator
syntax match FicusNoteTags '\v^(#[^\s].*)+$'
syntax match FicusNoteModified '\v^\* .*$'
syntax match FicusNoteDescription '\v^\> .*$'

highlight clear Conceal

" highlight! link Conceal Comment
highlight default link FicusNoteSeperator Comment
highlight default link Conceal Comment
highlight default link FicusNoteTitle Title
highlight default link FicusNoteTags Keyword
highlight default link FicusNoteModified Special
highlight default link FicusNoteDescription Normal
