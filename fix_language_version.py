from pathlib import Path
root = Path('lib')
for path in root.rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    if text.startswith('// @dart=2.9'):
        continue
    if text.startswith('import ') or text.startswith('part ') or text.startswith('library '):
        text = '// @dart=2.9\n\n' + text
    else:
        text = '// @dart=2.9\n\n' + text
    path.write_text(text, encoding='utf-8')
