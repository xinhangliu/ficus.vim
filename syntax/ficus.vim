let markers = '(' . escape(join(g:ficus_expand_icon, '|'), '+-~') . '|  )'
let icons = '(' . escape(join(values(g:ficus_category_icons), '|'), '+-~') . ')'

execute 'syntax match FicusCategory #\v^\s*' . markers . icons . '.*# contains=FicusNoteCount,FicusPath,FicusCategoryMarker'

execute 'syntax match FicusCategoryMarker #\v' . markers . '\ze' . icons . '# contained'
execute 'syntax match FicusPath #\v' . icons . '@<=([^ ][^/]*/)*# contained conceal'
syntax match FicusNoteCount '\v\(\d+\)$' contained

highlight default link FicusCategory PreProc
highlight default link FicusNoteCount Comment
highlight default link FicusCategoryMarker Constant
