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
from ruamel.yaml import YAML, SafeConstructor, VersionedResolver, resolver

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


class NoDateResolver(VersionedResolver):
    def __init__(self, version=None, loader=None, loadumper=None):
        super().__init__(version, loader, loadumper)

    @property
    def versioned_resolver(self):
        # type: () -> Any
        """
        select the resolver based on the version we are parsing
        """
        version = self.processing_version
        if version not in self._version_implicit_resolver:
            for x in resolver.implicit_resolvers:
                if version in x[0] and x[1] != u'tag:yaml.org,2002:timestamp':
                    self.add_version_implicit_resolver(version, x[1], x[2], x[3])
        return self._version_implicit_resolver[version]


yaml = YAML(typ='safe')
yaml.Resolver = NoDateResolver

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
