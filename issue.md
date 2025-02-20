## Bug Report

Please answer these questions before submitting your issue. Thanks!

### 1. Minimal reproduce step (Required)

1. Install nix + direnv
2. Clone https://github.com/isbecker/kcl
3. Navigate to the directory and run `direnv allow`
4. You will now be in the `devenv` shell from `flake.nix`
5. Use `kcl-language-server`, like via [kcl vscode extension](https://marketplace.visualstudio.com/items?itemName=kcl.kcl-vscode-extension)

### 2. What did you expect to see? (Required)

### 3. What did you see instead (Required)
`kcl-language-server` crashes repeatedly, due to the new file watching (added in https://github.com/kcl-lang/kcl/issues/1564 and first released in v0.11.0).

Observe these logs from the [nvim-lsp](https://github.com/neovim/nvim-lspconfig) logs below:
```
[START][2025-02-20 08:00:22] LSP logging initiated
[ERROR][2025-02-20 08:00:22] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/mdvc9srx40fl1637cm61xgjlphicvfby-kcl-language-server-0.11.1/bin/kcl-language-server"	"stderr"	"thread 'main' panicked at tools/src/LSP/src/state.rs:579:22:\ncalled `Result::unwrap()` on an `Err` value: Error { kind: MaxFilesWatch, paths: [\"/path/to/my/project/.direnv/flake-inputs/yzv2p09a0pmxps631z44civzsffl89m5-source/pkgs/kde/frameworks/purpose\"] }\nnote: run with `RUST_BACKTRACE=1` environment variable to display a backtrace\n"
[ERROR][2025-02-20 08:00:34] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/mdvc9srx40fl1637cm61xgjlphicvfby-kcl-language-server-0.11.1/bin/kcl-language-server"	"stderr"	"thread 'main' panicked at tools/src/LSP/src/state.rs:579:22:\ncalled `Result::unwrap()` on an `Err` value: Error { kind: MaxFilesWatch, paths: [\"/path/to/my/project/.direnv/flake-inputs/yzv2p09a0pmxps631z44civzsffl89m5-source/pkgs/kde/frameworks/purpose\"] }"
[ERROR][2025-02-20 08:00:34] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/mdvc9srx40fl1637cm61xgjlphicvfby-kcl-language-server-0.11.1/bin/kcl-language-server"	"stderr"	"\nnote: run with `RUST_BACKTRACE=1` environment variable to display a backtrace\n"
[START][2025-02-20 08:00:40] LSP logging initiated
[ERROR][2025-02-20 08:00:40] .../vim/lsp/rpc.lua:770	"rpc"	"/nix/store/mdvc9srx40fl1637cm61xgjlphicvfby-kcl-language-server-0.11.1/bin/kcl-language-server"	"stderr"	"thread 'main' panicked at tools/src/LSP/src/state.rs:579:22:\ncalled `Result::unwrap()` on an `Err` value: Error { kind: MaxFilesWatch, paths: [\"/path/to/my/project/.direnv/flake-inputs/yzv2p09a0pmxps631z44civzsffl89m5-source/pkgs/kde/frameworks/purpose\"] }\nnote: run with `RUST_BACKTRACE=1` environment variable to display a backtrace\n"
```

Notably, the error is `value: Error { kind: MaxFilesWatch`. This behavior is due to the fact that I am using nix + direnv. As you can see from the `kcl-language-server` logs, the directories that are cuasing this are all `.direnv`

In that `.direnv/flake-inputs` directory, there are **316262 files**. That is because it is my entire dev environment for this project (kcl, various other build tools, etc), built using nix + [devenv](https://devenv.sh).

### 4. What is your KCL components version? (Required)
```terminal
❯ kcl version
0.11.0-linux-amd64
❯ kcl-language-server version
Version: 0.11.1-c020ab3eb4b9179219d6837a57f5d323
Platform: x86_64-unknown-linux-gnu
GitCommit: d8964b29170ba28c98a31b561a2d9525112d1f30
```