# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GleamによるWordleクローン。ターミナルで動作するCLIゲーム。

## Commands

```sh
gleam build   # ビルド
gleam test    # テスト実行
gleam run     # プロジェクト実行
gleam format  # コードフォーマット
```

## Architecture

- `src/wordlish.gleam` - メインモジュール
- `test/wordlish_test.gleam` - テスト（gleeunit使用、`_test`サフィックスで関数定義）

## Gleam Conventions

- テスト関数は `pub fn xxx_test()` の形式
- アサーションは `assert` または `gleeunit/should` モジュールを使用
- 依存関係は `gleam.toml` で管理
