let markers = '(' . escape(join(g:ficus_expand_icon, '|'), '+-~*.#') . ')'
let icons = '(' . escape(join(values(g:ficus_icons), '|'), '+-~*.#') . ')'

execute 'syntax match FicusCategory #\v^\{\{.*\}\}\s*' . markers . icons . '.*# contains=FicusNoteCount,FicusCategoryID,FicusCategoryMarker'

execute 'syntax match FicusCategoryMarker #\v' . markers . '\ze' . icons . '# contained'
execute 'syntax match FicusCategoryID #\v^\{\{.*\}\}# contained conceal'
syntax match FicusNoteCount '\v \(\d+\)$' contained

highlight default link FicusCategory Directory
highlight default link FicusNoteCount Comment
highlight default link FicusCategoryMarker Special
