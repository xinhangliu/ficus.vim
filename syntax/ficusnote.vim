syntax region FicusNoteTitle matchgroup=FicusNoteID start='\v^\[\d+\]' end='$' concealends
execute 'syntax match FicusNoteSeperator /\v^\' . ficus#options('ficus_border_char') . '+(\d+)?$/'
syntax match FicusNoteTagLine '\v^(#[^#]*)+$' contains=FicusNoteTag
syntax match FicusNoteTag '\v#[^#]*\ze #' contained
syntax match FicusNoteTag '\v#[^#]*$' contained
syntax match FicusNoteModified '\v^\* .*$'
syntax match FicusNoteDescription '\v^\> .*$'

highlight default link FicusNoteSeperator Comment
highlight default link FicusNoteTitle Title
highlight default link FicusNoteTag TabLine
highlight default link FicusNoteModified Comment
highlight default link FicusNoteDescription Normal
