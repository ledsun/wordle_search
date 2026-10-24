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
