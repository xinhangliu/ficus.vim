function! ficus#reader#Read(path) abort
    let default_reader_name = get(g:, 'FicusCustomReader', 'ficus#reader#MarkdownReader')
    let Reader = function(default_reader_name)

    return Reader(a:path)
endfunction

function! ficus#reader#MarkdownReader(path) abort
    let l:metadata = {}
python3 << EOF
import re
import vim
from ruamel.yaml import YAML
re_empty = re.compile(r'^\s+')
re_open = re.compile(r'^---\s*')
re_close = re.compile(r'^---\s*')
re_nonempty = re.compile(r'\S')
is_find_open = False
is_find_close = False
data = ''
with open(vim.eval('a:path'), 'r') as f:
    line = f.readline()
    while line is not None and line != '':
        if not is_find_open and re_open.match(line):
            is_find_open = True
            line = f.readline()
            continue
        if is_find_open and re_close.match(line):
            is_find_close = True
            break
        if is_find_open and not is_find_close:
            data += line
            line = f.readline()
            continue
        if re_empty.fullmatch(line):
            line = f.readline()
            continue
        if not is_find_open and re_nonempty.search(line) is not None:
            break
    if not is_find_close:
        data = ''

yaml = YAML(typ='safe')
data_dict = yaml.load(data)

if isinstance(data_dict, dict):
    category = data_dict.get('category')
    if isinstance(category, str) and category:
        data_dict['category'] = category.strip('/').split('/')
    else:
        data_dict['category'] = []

    tags = data_dict.get('tags')
    if isinstance(tags, str) and tags:
        data_dict['tags'] = [tags]
    elif isinstance(tags, list):
        tags = [tag for tag in tags if tag]
        data_dict['tags'] = list(set(tags))
    else:
        data_dict['tags'] = []

    metadata = vim.bindeval('l:metadata')
    metadata.update(data_dict)
EOF
    return l:metadata
endfunction
