from pathlib import Path
root = Path('lib')
for path in root.rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    if '// @dart=2.9' in text:
        text = text.replace('// @dart=2.9\n\n', '').replace('// @dart=2.9\n', '').replace('// @dart=2.9', '')
        path.write_text(text, encoding='utf-8')
