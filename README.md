# Wordle Search

Wordle 用の候補検索ツールです。`ruby.wasm` で `main.rb` をブラウザ上で実行します。

公開先: https://wordle-search.onrender.com/

## 使い方

```bash
ruby -run -e httpd . -p 8000
```

ブラウザで `http://127.0.0.1:8000` を開き、次を入力して検索します。

- `Excluded characters`: 含まれない文字
- `Included characters`: 含まれる文字
- `Correct places`: 確定位置。未確定は `*`
