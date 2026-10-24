# 開発とデプロイ

## ローカルでの動作確認

リポジトリ直下で次を実行します。

```bash
ruby -run -e httpd . -p 8000
```

ブラウザで `http://127.0.0.1:8000` を開き、検索が動作することを確認します。
Ruby は ruby.wasm によってブラウザ上で実行されます。

## 公開環境

Render の Static Site として、リポジトリ内のファイルをそのまま配信しています。

| 項目 | 設定 |
| --- | --- |
| 公開 URL | https://wordle-search.onrender.com/ |
| サービス名 | `wordle_search` |
| GitHub リポジトリ | `ledsun/wordle_search` |
| Branch | `main` |
| Root Directory | 空欄（リポジトリ直下） |
| Build Command | 空欄 |
| Publish Directory | `.` |
| Auto-Deploy | `On Commit` |

## デプロイ手順

1. ローカルで変更と動作確認を行い、コミットします。
2. 公開する変更を GitHub の `main` に push します。

   ```bash
   git push origin main
   ```

3. Render が自動でデプロイを開始します。Render ダッシュボードで
   `wordle_search` の `Deploys` を開き、対象コミットのデプロイ成功を確認します。
4. 公開 URL を開き、変更の反映と検索の動作を確認します。

ローカルでコミットしただけでは公開されません。`main` への push が公開のきっかけになります。

## Render 側の設定確認

`wordle_search` の `Settings` で、`Build` に連携リポジトリ・ブランチ・公開ディレクトリ、
`Deploy` に自動デプロイ設定があります。手動でデプロイする場合は、サービス画面右上の
`Manual Deploy` から操作します。

Deploy Hook の URL は秘密情報です。ドキュメントやリポジトリには記載しません。

## PWA とオフライン動作

対応ブラウザのインストールメニューからアプリを追加できます。iOS では共有メニューの
「ホーム画面に追加」を使います。インストールせずブラウザで使う場合もキャッシュは有効です。

初回はオンラインで開き、画面下部に `Ready for offline search` と表示されるまで待ちます。
以降はオフラインでも起動と検索ができます。候補から開く外部の辞書サイトは通信が必要です。
ブラウザが保存データを削除した場合は、再びオンラインで準備する必要があります。

`sw.js` が HTML・Ruby ファイルなどをリリースごとに保存します。バージョンを固定した
Ruby ローダー・`ruby+stdlib.wasm`・Tailwind・OrbitalRing は別のキャッシュに保存し、
アプリだけの更新では WASM を再ダウンロードしません。フォントは取得できれば保存し、
取得できない場合は端末の代替フォントで検索できます。

### 更新時の注意

- ローカルの公開ファイルを変更したら、`sw.js` の `APP_VERSION` を必ず更新します。
- 外部依存を更新したら、`index.html` と `sw.js` の URL をそろえて更新します。
  ruby.wasm の場合は `sw.js` の `RUBY_BASE` も更新します。
- 新版は必要なファイルがすべて保存されてから待機状態になります。保存に失敗した場合は
  旧版が引き続き動作し、次回オンライン起動時に再試行します。
- `Update ready` と表示されたら、このサイトのタブとインストールしたアプリのウィンドウを
  すべて閉じて開き直します。新旧の Ruby コードが混在しないよう、使用中の強制更新はしません。

### 確認方法

1. localhost または HTTPS で開き、オフライン準備完了の表示と検索動作を確認します。
2. 開発者ツールの Application で Service Worker と Cache Storage を確認します。
   `wordle-search-dependencies-v1` に `ruby+stdlib.wasm` が保存されます。
3. Network を Offline にして再読み込みし、同じ条件で検索できることを確認します。
4. オンラインに戻して再読み込みし、WASM の応答が Service Worker から返ることを確認します。
5. 更新時は旧版を開いたまま新版を配信し、待機表示を確認します。全ウィンドウを閉じて
   開き直し、新版への切り替えとオフライン検索を確認します。

## 検索辞書

`wordle_search.rb` の `DICTIONARY` は、既存の4,594語に
 [tabatkins/wordle-list](https://github.com/tabatkins/wordle-list) の14,855語を統合した
14,857語です。重複を除いてアルファベット順に並べ、小文字の英字5文字に限定しています。
データはアプリに同梱するため、起動時に辞書配布元への通信は発生しません。

取り込み元のコミットは `255b9469c4dad99a3b95cc4ddbe139b3d3747868`、ファイルは `words` です。
MIT ライセンスの表記を `licenses/wordle-list.txt` に保存しています。
このリストは推測として使える語を広く含むもので、現在の公式 Wordle の出題候補や
受け付ける語との完全な一致は保証しません。

辞書更新時は既存語を残して統合し、5文字・重複なし・既知の単語（例: `holey`）が
検索できることを確認します。PWA に反映するため `sw.js` の `APP_VERSION` も更新します。
