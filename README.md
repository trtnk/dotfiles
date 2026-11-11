# dotfiles

tmux・Neovim（LazyVim）・ターミナル用の小さなツール群の設定一式。

| 入っているもの | 内容 |
|---|---|
| `tmux/tmux.conf` | Prefix を `Ctrl-Space` にした tmux 設定。セッション自動復元、Vim 風の操作 |
| `nvim/` | LazyVim ベースの Neovim 設定 |
| `bin/approvals` | 複数のペインで動くコーディングエージェントの承認待ちを、1つの画面に集めて答える |
| `bin/mdview` | Markdown を新しい順に選び、ブラウザまたはターミナルで見る |
| `bin/how` | Linux・tmux の使い方を LLM に聞く |
| `bin/inbox` | 1行メモを `~/inbox.md` に追記する |
| `bin/tmtop` | tmux のセッションごとのメモリ使用量を出す |
| `bin/mdopen` | 環境に合わせて URL を開く（WSL・デスクトップ・SSH 先） |

## 入れる

```bash
git clone https://github.com/trtnk/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` はホームへシンボリックリンクを張るだけです。

- 既にあるファイルは、リポジトリ内の `.backup/<時刻>/` に退避します（git には入りません）。
- `~/.bashrc` は書き換えず、最後に1行足します。
- 何度走らせても同じ結果になります。
- 最後に、足りないコマンドの一覧と入れ方を出します。

| リポジトリ | 張る先 |
|---|---|
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim` |
| `glow/glow.yml` | `~/.config/glow/glow.yml` |
| `bin/*` | `~/.local/bin/` |
| `bash/init.sh` | `~/.bashrc` の最後から読む |

入れたあと:

1. 新しいシェルを開く
2. tmux を起動し、`Prefix + I`（大文字の i）でプラグインを入れる
3. `nvim` を一度起動する（LazyVim がプラグインを入れる）

必要なコマンド: tmux・nvim（0.10 以上）・git・rg（ripgrep）・fzf・glow・python3。`mdserve` は、mdview でブラウザ表示をするときに要ります（ないとターミナル内表示になります）。

Ubuntu / Debian なら、まとめて入れられます。

```bash
sudo apt install tmux neovim ripgrep fzf glow cargo
cargo install mdserve    # ブラウザ表示用。ビルドに数分かかる
```

`glow` が apt にない版のディストリビューションでは、[配布ページ](https://github.com/charmbracelet/glow/releases) から入れます。

## tmux のキー（Prefix = Ctrl-Space）

| キー | 動き |
|---|---|
| `m` | mdview: Markdown を新しい順に選び（右にプレビュー）、ブラウザで見る |
| `M` | mdview -t: ターミナルの中で全画面表示 |
| `g` | how: Linux・tmux の使い方を聞く |
| `i` | inbox: 1行メモを `~/inbox.md` に追記 |
| `y` | approvals: エージェントの承認待ちを全ペインから集めて答える |
| `e` | 今のフォルダをエクスプローラで開く（WSL のときだけ） |
| `\|` / `-` | 左右 / 上下に分割 |
| `h` `j` `k` `l` | ペイン移動（Prefix なしの `Ctrl-h/j/k/l` でも nvim とまたいで移動できる） |
| `r` | 設定の再読み込み |
| `F12`（Prefix なし） | 入れ子の tmux のとき、外側の tmux を眠らせる（もう一度で戻る） |

## approvals

Claude Code・Codex・Copilot CLI・Antigravity などを tmux の多数のペインで走らせているとき、承認待ちのペインを1枚の一覧に集め、そこから返事を送ります。エージェント側には何も手を入れません。画面の文字を読み、キーを送るだけです。

`Prefix + y` で、承認待ちのペインの画面が1つずつ大きく出ます。上の帯に `承認待ち [1/3] セッション名` と出るので、左右で切り替え、上下でそのエージェントの選択肢を動かして Enter で決めます。画面は1秒ごとに作り直され、片づいたものは消えます。承認待ちがあるあいだは、ステータスバーに `承認待ち N` が出ます。

| キー | 動き |
|---|---|
| `←` `→` | 承認待ちのセッションを切り替える |
| `↑` `↓` | そのエージェントの選択肢（Yes / No など）を動かす |
| `Enter` | 確定 |
| `Esc` | 断る（Claude Code なら「別のやり方を指示する」になる） |
| `1`〜`9` | 番号で選ぶ |
| `g` | そのペインへ飛ぶ（文章で返したいとき） |
| `a` | 承認待ちだけ ／ 全ペイン の切り替え |
| `q` | 閉じる |

まとめて全部許可するキーは、わざと付けていません。

### 何を承認待ちとみなすか

各ペインの**画面末尾（空行を除いた 12 行）だけ**を見て、承認画面に特有の文言を探します。履歴までは見ません（会話に出てきた文言で誤検出するため）。既定の文言は `bin/approvals` の中にあります。

- `Do you want to proceed?` などの問い（Claude Code・Copilot CLI）
- `Would you like to run …`（Codex）
- 選択肢の `❯ 1. Yes` にカーソルが乗っている形
- `Allow once / always`、`[y/N]`、`(y/n)`

拾えないエージェントがあれば、その承認画面に出る特徴的な1行を `~/.config/approvals/patterns` に足してください（1行1つ・`grep -E` の正規表現・大文字小文字は区別しない・`#` で始まる行は無視）。逆に承認待ちでないペインが出るときは、どの文言に当たったかを見て、既定の文言をより具体的にします。見る行数は環境変数 `APPROVALS_TAIL` で変えられます。

確かめ方: 承認待ちを出した状態で `approvals --list` を打つと、`ペインID<TAB>名前` が1行ずつ出ます。

## mdview と mdopen

`mdview` は fzf で Markdown を選び（右に glow のプレビュー）、`mdserve` で配信してブラウザで開きます。`-t` を付けるか `mdserve` がなければ、glow のページャでターミナル内に表示します。

最後の「開く」は `mdopen` が環境に合わせて行います。

| 環境 | 動き |
|---|---|
| WSL（SSH していない） | Windows の既定ブラウザで開く |
| Linux デスクトップ | `xdg-open` |
| SSH 先 | URL を OSC 52 でクリップボードへ送り、画面にも出してキー待ち |

## SSH 先で使う

SSH 先にも同じ手順で入れられます。SSH 先では次のように動きます。

- ステータスバーにホスト名が出る。
- mdview のポートは 3001（手元は 3000）。
- tmux のコピーは OSC 52 で手元のクリップボードへ届く。

mdview の画面を手元のブラウザで見るには、手元の `~/.ssh/config` に転送を足します（見本は `ssh/config.example`）。

```
Host myserver
    LocalForward 3001 localhost:3001
```

足したら SSH をつなぎ直します。

## how

`how` の相手は `~/.config/how/config` で決めます（見本は `how/config.example`）。OpenAI 互換のサーバ（llama-server・ollama など）か、`claude` コマンドを使えます。

## マシンごとの設定（git に入れない）

| ファイル | 見本 | 置くもの |
|---|---|---|
| `~/.bashrc.local` | `bash/bashrc.local.example` | そのマシンだけのエイリアス・環境変数 |
| `~/.tmux.local.conf` | なし | そのマシンだけの tmux 設定（tmux.conf の最後で読む） |
| `~/.config/how/config` | `how/config.example` | how の相手 |
| `~/.config/approvals/patterns` | なし | approvals が拾う文言の追加 |

## 環境変数

| 変数 | 既定 | 意味 |
|---|---|---|
| `MDVIEW_PORT` | 3000（SSH 先は 3001） | mdserve のポート |
| `APPROVALS_TAIL` | 12 | approvals が各ペインの末尾から見る行数 |
| `HOW_BACKEND` | claude があれば claude、なければ openai | how の相手 |
| `HOW_BASE_URL` | `http://127.0.0.1:8080/v1` | OpenAI 互換サーバ |
| `HOW_MODEL` | `local` | モデル名 |
| `HOW_API_KEY` | なし | 要るサーバだけ |
| `HOW_CLAUDE_MODEL` | `haiku` | claude のときのモデル |

## ライセンス

MIT（`LICENSE`）。ただし `nvim/` のうち LazyVim の雛形から来たファイルは、雛形の Apache License 2.0（`nvim/LICENSE`）。
