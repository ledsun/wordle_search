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

## 検索辞書

既存の辞書に [tabatkins/wordle-list](https://github.com/tabatkins/wordle-list) の単語リストを
統合した、14,857語の英字5文字の辞書を使用しています。辞書はアプリに同梱しています。

参照元のコミットは [`255b946`](https://github.com/tabatkins/wordle-list/tree/255b9469c4dad99a3b95cc4ddbe139b3d3747868) です。
同リストは MIT ライセンスで公開されており、ライセンス全文を
[licenses/wordle-list.txt](licenses/wordle-list.txt) に収録しています。

推測に使える語を広く含むため、現在の公式 Wordle の出題候補や受け付ける語と完全に一致するものではありません。
