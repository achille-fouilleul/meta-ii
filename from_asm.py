def get_mnemo_arg(l):
    assert l.startswith(' ')
    l = l.strip()
    i = l.find(' ')
    if i >= 0:
        return (l[:i], l[i+1:].strip())
    else:
        return (l, None)

def get_func_names(lines):
    names = set()
    entry = None
    for l in lines:
        if l.startswith(' '):
            mnemo, arg = get_mnemo_arg(l)
            if mnemo in { 'ADR', 'CLL' }:
                names.add(arg)
                if mnemo == 'ADR':
                    assert entry is None
                    assert arg is not None
                    entry = arg
    return entry, names
