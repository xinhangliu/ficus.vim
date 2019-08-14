function! ficus#writer#Write(note) abort
    let default_writer_name = get(g:, 'FicusCustomWriter', 'ficus#writer#MarkdownWriter')
    let Writer = function(default_writer_name)

    call Writer(a:note)
endfunction

function! ficus#writer#MarkdownWriter(note) abort
python3 << EOF
import re
import vim
import sys
from ruamel.yaml import YAML
from ruamel.yaml.compat import StringIO

note = vim.eval('a:note')

with open(note['path'], 'r') as f:
    raw = f.read()

matched = re.match(r'^---\s*?\n(.*?)\n---\s*?\n', raw, re.DOTALL)

yaml = YAML()
yaml.width = float('Infinity')
yaml.preserve_quotes = True
yaml.default_flow_style = None

if matched:
    metadata = yaml.load(matched.group(1))
    raw = raw[len(matched.group(0)):]
    metadata['title'] = note['title']
    metadata['modified'] = note['modified']
    metadata['created'] = note['created']
    metadata['category'] = '/'.join(note['category'])
    metadata['tags'] = note['tags']
    metadata['description'] = note['description']
    metadata['author'] = note['author']

    stream = StringIO()
    yaml.dump(metadata, stream)

    with open(note['path'], 'w') as f:
        f.write('---\n')
        f.write(stream.getvalue())
        f.write('---\n')
        f.write(raw)
EOF
endfunction
