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
| `bin/vsopen` | SSH 先のフォルダを、手元の VS Code（Remote-SSH）で開く住所を作って、手元のクリップボードへ送る |

## 使い始める: SSH 先のサーバに入れて、手元のブラウザで Markdown を見る

想定する形:

- **手元**: SSH を打つ側のマシン。Windows の WSL、Linux、Mac のどれでもよい。ブラウザはこのマシンのもの。
- **サーバ**: SSH 先の Ubuntu / Debian。作業は、サーバの tmux の中で行う。

手順の見出しに、どちらのマシンで打つかを書いてあります。

### 1. サーバ: 必要なコマンドを入れる

```bash
sudo apt update
sudo apt install tmux git ripgrep fzf python3
```

- 必要なもの: tmux・nvim（0.10 以上）・git・rg（ripgrep）・fzf・glow・python3。`mdserve` は、ブラウザで見るときだけ要ります（ないと mdview はターミナル内表示になります）。
- 上の 5 つは apt のもので足ります（Ubuntu 22.04 でも動きます）。
- **nvim・glow・mdserve** は、apt にないか、古いことがあります（Ubuntu 22.04 の nvim は 0.6 です）。それらは、次の 2 で dotfiles を取ったあと、`install-tools.sh` が公式の配布物から `~/.local` に入れます（`sudo` 不要・Rust 不要）。
- `sudo` が使えないときは、各コマンドの配布物をホーム配下に置いて、PATH を通します。

### 2. サーバ: dotfiles を入れる

```bash
git clone https://github.com/trtnk/dotfiles ~/dotfiles
~/dotfiles/install-tools.sh    # nvim・glow・mdserve が足りない／古いときだけ。足りていれば「済み」と出て飛ばす
~/dotfiles/install.sh
```

`install-tools.sh` は、nvim（0.10 以上）・glow・mdserve を、すでに足りているものは飛ばして、足りないものだけ入れます。CPU（x86_64・arm64）は自動で選びます。版は `NVIM_VERSION` `GLOW_VERSION` `MDSERVE_VERSION` で変えられます。取れなかったときは、各プロジェクトの配布ページから、実行ファイルを手で `~/.local/bin` に置いてください。

`install.sh` はホームへシンボリックリンクを張るだけです。

- 既にあるファイルは、リポジトリ内の `.backup/<時刻>/` に退避します（git には入りません）。
- `~/.bashrc` は書き換えず、最後に1行足します。
- 何度走らせても同じ結果になります。
- 最後に、足りないコマンドの一覧を出します。**空なら 1 は済んでいます。**

| リポジトリ | 張る先 |
|---|---|
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim` |
| `glow/glow.yml` | `~/.config/glow/glow.yml` |
| `bin/*` | `~/.local/bin/` |
| `bash/init.sh` | `~/.bashrc` の最後から読む |

### 3. 手元: ブラウザへの転送を足す

手元の `~/.ssh/config` の、サーバの `Host` の段に1行足します（見本は `ssh/config.example`）。

```
Host myserver
    HostName server.example.com
    User me
    LocalForward 3001 localhost:3001
```

- 段の中に、他の行と同じ深さで書きます。段の外に書くと効きません。
- ssh の設定は行末にコメントを書けません。コメントは別の行に書きます。

足したら、つなぐ前に設定が読めているかを確かめます。

```bash
ssh -G myserver | grep -i localforward
```

`localforward 3001 [localhost]:3001` と出れば通っています。何も出なければ、足した場所が段の外です。

転送は**つなぐときにだけ**張られます。つないでいる SSH があれば、一度抜けて `ssh myserver` でつなぎ直します。

WSL で張った転送は、既定で Windows のブラウザの `http://localhost:3001` から届きます。届かないときは、Windows 側の `%UserProfile%\.wslconfig` の `[wsl2]` 節で `localhostForwarding=true`（または `networkingMode=mirrored`）になっているかを見ます。

### 4. サーバ: tmux を起動してプラグインを入れる

つなぎ直したシェルで、まず PATH を確かめます（`install.sh` が足した設定は、新しいシェルから効きます）。

```bash
command -v mdserve tmux glow fzf rg
```

5 つとも、パスが 1 行ずつ出れば成功です。

```bash
tmux
```

tmux の中で `Ctrl-Space` を押して離し、続けて大文字の `I`（`Shift + i`）を押すと、プラグインが入ります。

### 5. Markdown を見る

試す Markdown を作ります。

```bash
echo '# テスト' > ~/test.md
```

tmux の中で `Ctrl-Space` を押して離し、続けて `m` を押します。

1. Markdown の一覧が出る（新しい順・右にプレビュー）。`test.md` を選んで Enter。
2. サーバが URL を OSC 52 で**手元のクリップボードへ送り**、画面にも出してキー待ちになる。
3. 手元のブラウザのアドレス欄に貼る（`http://localhost:3001`）。表示されれば成功。
4. サーバで `test.md` を保存し直すと、ブラウザが自動で再読み込みする。

ブラウザなしでターミナルの中に出すなら `Ctrl-Space` → `M`（大文字）です。

### うまくいかないとき

| 症状 | 見るところ |
|---|---|
| `install.sh` が `mdserve` を足りないと言う | 古いシェルで PATH が通っていないだけのことがある。新しいシェルで `command -v mdserve` |
| `mdserve` `nvim` `glow` が「ない」「古い」と出る | `~/dotfiles/install-tools.sh`。入れ先は `~/.local/bin`。新しいシェルで PATH に入る |
| ブラウザが開かない・接続できない | 3 の転送を足したあと、つなぎ直したか。`ssh -G` で設定が読めているか |
| クリップボードに URL が入らない | 手元のターミナルが OSC 52 に対応しているか。画面に出た URL を手で打ってもよい |
| `Ctrl-Space` に反応しない | 手元の日本語入力などが、そのキーを先に取っていないか |
| プラグインが入らない（`Prefix + I`） | tmux の中で押したか。大文字の `I` か。`~/.tmux/plugins/tpm` があるか |

## 手元だけで使う（SSH しない）

同じ手順の 1・2・4・5 だけで動きます。3 は要りません。mdview はポート 3000 で、ブラウザを直接開きます（WSL なら Windows の既定ブラウザ）。

## 手元とサーバの両方に入れる

同じリポジトリを両方で clone し、それぞれで `install.sh` を走らせます。設定ファイルは共通で、動きはそのマシンが WSL か・SSH 先かを見て変わります。

| | 手元 | SSH 先 |
|---|---|---|
| mdview | ポート 3000。ブラウザを直接開く | ポート 3001。URL をクリップボードへ送る |
| `Prefix + e` | WSL のときだけ使える | 出ない |
| ステータスバー | ホスト名なし | ホスト名を出す |

手元でも tmux を起動してその中で ssh すると、入れ子になります。手元の tmux で `F12` を押すと手元の tmux が眠り、キーが全部サーバへ届きます。もう一度 `F12` で戻ります。眠っている間は、手元のステータスバーに `[OFF]` が出ます。

## tmux のキー（Prefix = Ctrl-Space）

| キー | 動き |
|---|---|
| `m` | mdview: Markdown を新しい順に選び（右にプレビュー）、ブラウザで見る |
| `M` | mdview -t: ターミナルの中で全画面表示 |
| `g` | how: Linux・tmux の使い方を聞く |
| `i` | inbox: 1行メモを `~/inbox.md` に追記 |
| `y` | approvals: エージェントの承認待ちを全ペインから集めて答える |
| `v` | vsopen: 今のフォルダを手元の VS Code（Remote-SSH）で開くための住所を、手元のクリップボードへ送る（SSH 先で使う） |
| `e` | 今のフォルダをエクスプローラで開く（WSL のときだけ） |
| `\|` / `-` | 左右 / 上下に分割 |
| `h` `j` `k` `l` | ペイン移動（Prefix なしの `Ctrl-h/j/k/l` でも nvim とまたいで移動できる） |
| `r` | 設定の再読み込み |
| `F12`（Prefix なし） | 入れ子のとき、外側の tmux を眠らせる（もう一度で戻る） |

ポップアップ（`m`・`g`・`i`・`y`）は、押した tmux のあるマシンで動きます。サーバの tmux で押せば、サーバで動きます。

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

## mdopen のふるまい

mdview は最後に `mdopen` で URL を開きます。環境で動きが変わります。

| 環境 | 動き |
|---|---|
| WSL（SSH していない） | Windows の既定ブラウザで開く |
| Linux デスクトップ | `xdg-open` |
| SSH 先 | URL を OSC 52 でクリップボードへ送り、画面にも出してキー待ち |

Windows Terminal のリンクは `Ctrl+クリック` で開きますが、tmux のマウス有効中はクリックを tmux が取るので届かないことがあります。クリップボードに貼るのが確実です。

## サーバのフォルダを手元の VS Code で開く（vsopen）

SSH 先のプロジェクトを、コピーせずに、手元の VS Code で開きます。ファイルはサーバに置いたままで、VS Code がサーバへ見に行きます（Remote-SSH）。巨大なプロジェクトでも、そのまま開けます。Markdown を何枚も開いて見るときにも向いています。

1. サーバの tmux で、開きたいフォルダに移って `Prefix + v` を押す。
2. `vscode://vscode-remote/ssh-remote+<Host名>/<パス>` という住所が、手元のクリップボードに入る。
3. 手元のブラウザのアドレス欄に貼って Enter。「Visual Studio Code を開きますか？」に答えると、VS Code でフォルダが開く。

ファイルを指定して開く（サーバの端末で `vsopen path/to/file.md`）こともできます。

用意するもの（手元）:

- Windows の VS Code と、拡張 **Remote - SSH**。
- **Windows 側の ssh の設定**（`%UserProfile%\.ssh\config`）に、サーバの `Host` があること。VS Code は WSL の `~/.ssh/config` を読みません。
- サーバの `hostname -s` と Host 名が違うときは、サーバの `~/.bashrc.local` に `export VSOPEN_HOST=<Host名>` と書く。

サーバには、初回の接続で VS Code のサーバプログラム（`~/.vscode-server`）が入ります。会社の PC やサーバでは、VS Code・拡張・`vscode://` の住所を開くことが許されているか、先に確かめてください。

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
| `MDVIEW_PORT` | 3000（SSH 先は 3001） | mdserve のポート。変えたら 3 の `LocalForward` も合わせる |
| `APPROVALS_TAIL` | 12 | approvals が各ペインの末尾から見る行数 |
| `HOW_BACKEND` | claude があれば claude、なければ openai | how の相手 |
| `HOW_BASE_URL` | `http://127.0.0.1:8080/v1` | OpenAI 互換サーバ |
| `HOW_MODEL` | `local` | モデル名 |
| `HOW_API_KEY` | なし | 要るサーバだけ |
| `HOW_CLAUDE_MODEL` | `haiku` | claude のときのモデル |

## ライセンス

MIT（`LICENSE`）。ただし `nvim/` のうち LazyVim の雛形から来たファイルは、雛形の Apache License 2.0（`nvim/LICENSE`）。
