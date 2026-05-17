# AstroNvim v6 Migration Log

This file tracks the migration from the previous working setup to the current daily-driver setup:

- Current daily setup: `nvim` -> `NVIM_APPNAME=astronvim_v6 $HOME/.local/neovim/0.11.6/bin/nvim`
- Current Neovim: `v0.11.6`
- Fallback v4 setup: `nvim10` -> `NVIM_APPNAME=astronvim_v4 /opt/homebrew/bin/nvim`
- Fallback Neovim: `v0.10.4`
- Target AstroNvim: `v6`

The goal is to daily-drive v6 while keeping the existing v4 setup untouched and usable until v6 is confirmed stable.

## Protocol

1. Do not bulk-copy v4 files into v6.
2. Port one file or one small feature group per patch.
3. Before each patch, present the proposed change in chat and wait for approval.
4. Each pre-patch proposal must include:
   - The relevant v4 config snippet or behavior.
   - What that v4 config did.
   - The relevant v6 default or current target state.
   - Compatibility confirmation for any AstroNvim/core/plugin modules referenced by the patch.
   - The proposed v6 change.
   - A recommendation and rationale.
   - Any explicit questions or tradeoffs.
   - For keymaps: a duplicate/default keymap check against AstroNvim v6 before preserving old mappings.
5. The user may approve, reject, redirect, or ask for edits before any patch is applied.
6. Only after approval, apply the patch.
7. After each patch, the user tests with the v6 setup before moving on. During migration this was `nvim11`; after daily-driver cutover this is `nvim`.
8. Record every decision in this file.
9. Prefer v6 defaults unless there is a clear reason to preserve old behavior.
10. Leave inactive, commented, or obsolete config behind unless explicitly chosen.
11. Keep the existing `astronvim_v4` setup available as `nvim10` until v6 is confirmed stable.
12. Keep this file during migration; delete it only after v6 is confirmed as the daily driver.

## Patch Review Template

Use this format in chat before making any migration patch:

```text
Patch: <short name>

Recommendation:
<recommended action>

Before in v4:
<snippet or behavior>

What it did:
<plain-English explanation>

Current v6 state:
<snippet or behavior>

Compatibility check:
<actual modules/functions/plugins verified in v6>

Keymap duplicate check:
<v6 built-in mappings or conflicts, when applicable>

Proposed v6 change:
<snippet or behavior>

Questions:
<specific approval questions>
```

No patch should be applied until the user approves the proposal.

## Current Side-By-Side Setup

- `nvim` maps to `astronvim_v6` and pinned Neovim `v0.11.6`.
- `nvim10` preserves the old `astronvim_v4` setup with Homebrew Neovim `v0.10.4`.
- `nvim11` remains available as an explicit v6 alias.
- `~/.config/astronvim_v6` is a symlink to this repo's `astronvim_v6/` directory.
- The v6 config started from the official AstroNvim v6 template.

## Baseline Checks

Run these after any meaningful patch:

```vim
:AstroVersion
:Lazy
:checkhealth
```

Useful targeted checks:

```vim
:Mason
:LspInfo
:checkhealth vim.lsp
:checkhealth lazy
```

Manual smoke tests:

- Open Lua file.
- Open TypeScript file.
- Open Markdown file.
- Open Rust project.
- Open C/C++ project if needed. ESP32-specific support was intentionally skipped.
- Confirm diagnostics display.
- Confirm formatting behavior.
- Confirm completion behavior.
- Confirm buffer navigation mappings.
- Confirm statusline/winbar are acceptable.

## Full Migration Plan

### 1. Baseline v6

Status: Complete

Goal: Confirm a clean AstroNvim v6 template works before customizations are added.

Actions:

- Launch `nvim11`.
- Allow plugin bootstrap to finish.
- Run `:AstroVersion`.
- Run `:Lazy`.
- Run `:checkhealth`.

Decision log:

- Started from a Noice behavior audit rather than adding Noice immediately.
- User can live without Noice command-line/search UI for now, but misses it somewhat.
- Save/yank/delete/paste noise is not currently visible in v6, so Noice message filtering is not needed for that yet.
- Hover docs, LSP progress, rename, and completion/cmdline completion are acceptable enough for now.
- Signature help while typing was the main regression.
- Approved enabling AstroLSP's built-in automatic signature help instead of adding Noice, Blink signature help, or `lsp_signature.nvim`.
- After testing, user found AstroLSP automatic signature help flickers in and out too much while typing.
- Started reversible test of Blink signature help because it owns `<C-K>` as the signature show/hide key when enabled.

Test result:

- AstroLSP signature help works and is accepted as decent for now.
- Blink signature help was tested and rejected for now.

### 2. Core Editor Preferences

Status: Tested

Source files:

- `astronvim_v4/lua/plugins/astrocore.lua`

Target files:

- `astronvim_v6/lua/plugins/astrocore.lua`

Candidates to port:

- `showtabline = 0`
- `relativenumber = true`
- `number = true`
- `spell = false`
- `signcolumn = "auto"` versus v6 default `"yes"`
- `wrap = false`
- diagnostics preferences, especially virtual text and virtual lines
- `H` and `L` buffer navigation
- `<Leader>bD` buffer picker close mapping

Questions before patch:

- Keep `H`/`L` for buffer navigation, or adopt v6 defaults `[b` and `]b`?
- Keep `showtabline = 0`, or allow the v6 tabline/default UI?
- Keep `signcolumn = "auto"`, or use v6 default `"yes"`?
- Keep virtual diagnostic lines enabled by default?

Decision log:

- Approved `H`/`L` buffer navigation.
- Approved `showtabline = 0`.
- Chose v6 default `signcolumn = "yes"` after clarification: the signcolumn is the left-side column for diagnostics, git signs, breakpoints, and similar signs. Keeping it always visible avoids horizontal text shifting.
- Initially approved diagnostic virtual lines enabled by default, then disabled them after testing.
- Kept v6 default `[b`/`]b` and `<Leader>bd` mappings in addition to restoring v4 `H`/`L`.
- Removed restored `<Leader>bD` after duplicate check confirmed AstroNvim v6 already provides the same buffer-picker close behavior at `<Leader>bd`.
- Compatibility confirmed in installed v6 modules:
  - `astrocore.buffer.nav` exists in `~/.local/share/astronvim_v6/lazy/astrocore/lua/astrocore/buffer.lua`.
  - `astrocore.buffer.close` exists in `~/.local/share/astronvim_v6/lazy/astrocore/lua/astrocore/buffer.lua`.
  - `astroui.status.heirline.buffer_picker` exists in `~/.local/share/astronvim_v6/lazy/astroui/lua/astroui/status/heirline.lua`.
  - AstroNvim v6 defaults use the same `buffer_picker` plus `astrocore.buffer.close` pattern in its Heirline mappings.

Test result:

- User tested with `nvim11` and reported "so far so good".

### 3. AstroCommunity Imports

Status: Complete, with intentional skips

Source files:

- `astronvim_v4/lua/community.lua`

Target files:

- `astronvim_v6/lua/community.lua`

Candidates to port:

- `astrocommunity.pack.lua`
- `astrocommunity.pack.python`
- `astrocommunity.pack.typescript-all-in-one`
- `astrocommunity.pack.svelte`
- `astrocommunity.pack.tailwindcss`
- `astrocommunity.pack.markdown`
- `astrocommunity.pack.just`
- `astrocommunity.pack.terraform`
- `astrocommunity.pack.bash`
- `astrocommunity.colorscheme.catppuccin`
- `astrocommunity.markdown-and-latex.markdown-preview-nvim`
- `astrocommunity.editing-support.rainbow-delimiters-nvim`
- `astrocommunity.diagnostics.trouble-nvim`
- `astrocommunity.motion.nvim-surround`
- `astrocommunity.motion.mini-move`
- `astrocommunity.file-explorer.oil-nvim`
- `astrocommunity.utility.noice-nvim`
- `astrocommunity.scrolling.neoscroll-nvim`
- `astrocommunity.recipes.telescope-lsp-mappings`

Likely skipped unless requested:

- commented `astrocommunity.pack.typescript`
- commented `astrocommunity.pack.godot`
- commented `astrocommunity.diagnostics.lsp_lines-nvim`

Questions before patch:

- Port all active community imports in one batch, or split language packs and UI/tooling packs?
- Keep TypeScript all-in-one, or revisit TypeScript setup?
- Keep Oil as the file explorer overlay?
- Keep Noice and Neoscroll?

Decision log:

- Split this into smaller patches. First patch covers language/tooling baseline only.
- Approved moving Python from top-level `astrocommunity.pack.python` to explicit `python.base`, `python.basedpyright`, and `python.ruff`.
- Initially approved adding explicit `astrocommunity.pack.eslint` and `astrocommunity.pack.prettier`; later removed ESLint because it was noisy in projects without a local ESLint library.
- Initially kept `typescript-all-in-one`, then replaced it with `typescript` because the user does not use Deno.
- Kept Lua, Svelte, TailwindCSS, Markdown, Just, Terraform, and Bash packs.
- Added `astrocommunity.motion.nvim-surround` after approval.
- Added `astrocommunity.editing-support.rainbow-delimiters-nvim` after approval.
- Added `astrocommunity.diagnostics.trouble-nvim` after approval.
- Added `astrocommunity.motion.mini-move` after approval.
- Added `astrocommunity.file-explorer.oil-nvim` after approval.
- Added `astrocommunity.scrolling.neoscroll-nvim` after approval.
- Added `astrocommunity.markdown-and-latex.markdown-preview-nvim` after approval, but disabled its `<Leader>M` mappings because the user uses the commands directly.
- Added `astrocommunity.recipes.picker-lsp-mappings` after approval as the AstroNvim v6 replacement for the old Telescope-only `telescope-lsp-mappings` recipe.
- Deferred UI/tooling imports such as Catppuccin and Noice.
- Compatibility checked against current AstroCommunity repository:
  - `astrocommunity.pack.lua`
  - `astrocommunity.pack.python.base`
  - `astrocommunity.pack.python.basedpyright`
  - `astrocommunity.pack.python.ruff`
  - `astrocommunity.pack.typescript`
  - `astrocommunity.pack.prettier`
  - `astrocommunity.pack.svelte`
  - `astrocommunity.pack.tailwindcss`
  - `astrocommunity.pack.markdown`
  - `astrocommunity.pack.just`
  - `astrocommunity.pack.terraform`
  - `astrocommunity.pack.bash`
  - `astrocommunity.motion.nvim-surround`
  - `astrocommunity.editing-support.rainbow-delimiters-nvim`
  - `astrocommunity.diagnostics.trouble-nvim`
  - `astrocommunity.motion.mini-move`
  - `astrocommunity.file-explorer.oil-nvim`
  - `astrocommunity.scrolling.neoscroll-nvim`
  - `astrocommunity.markdown-and-latex.markdown-preview-nvim`
  - `astrocommunity.recipes.picker-lsp-mappings`

Test result:

- User reported Python and JavaScript/TypeScript projects are working well.
- `nvim-surround` was installed and dynamically checked with headless `nvim11`; `ys`, `yss`, `ds`, `cs`, and visual `S` are currently owned by `nvim-surround`.
- `rainbow-delimiters.nvim` adds `<Leader>u(` for current-buffer toggling; duplicate check found no current owner for that exact mapping.
- `trouble.nvim` adds `<Leader>xx`, `<Leader>xX`, `<Leader>xQ`, `<Leader>xL`, and Todo variants when `todo-comments.nvim` is available; duplicate check found no exact conflict with AstroNvim v6's native `<Leader>xq` and `<Leader>xl` mappings.
- `mini.move` adds `<A-h>`, `<A-j>`, `<A-k>`, and `<A-l>` in normal and visual mode; dynamic keymap check found no current owner for those exact mappings before adding it.
- `oil.nvim` adds `<Leader>O`; dynamic keymap check found no current owner for `<Leader>O`, while `<Leader>o` and `<Leader>e` remain Neo-tree mappings.
- User prefers Oil on `<Leader>o`; added an AstroCore override so `<Leader>o` opens Oil, while `<Leader>e` remains the Neo-tree toggle.
- Updated `<Leader>o` to call Oil's floating window API, `require("oil").open_float()`, and disabled the redundant `<Leader>O` mapping from the community import.
- `neoscroll.nvim` wraps built-in scrolling/recentering motions such as `<C-u>`, `<C-d>`, `<C-b>`, `<C-f>`, `zt`, `zz`, and `zb`; dynamic keymap check found no AstroNvim mapping owners for the main scroll keys before adding it. Known caveat: scroll-key mappings can affect macros that include those keys.
- `markdown-preview.nvim` is available through `:MarkdownPreview`, `:MarkdownPreviewToggle`, and `:MarkdownPreviewStop`; Node.js is installed. Disabled the community `<Leader>M`, `<Leader>Mp`, `<Leader>Ms`, and `<Leader>Mt` mappings because the user prefers typed commands.
- The AstroCommunity build hook `vim.fn["mkdp#util#install"]()` failed in Lazy's build phase with `Unknown function: mkdp#util#install`; added a local plugin override to use the upstream Node/Yarn build command instead: `cd app && npx --yes yarn install`.
- `picker-lsp-mappings` is supported by AstroCommunity and detects the active picker backend. Runtime check showed `snacks.nvim` is available and `telescope.nvim` is not, so this recipe will use Snacks picker for LSP definitions, references, implementations, type definitions, document symbols, and workspace symbols.

### 4. Theme And UI

Status: Tested

Source files:

- `astronvim_v4/lua/plugins/astroui.lua`
- `astronvim_v4/lua/plugins/catppuccin.lua`
- `astronvim_v4/lua/plugins/heirline.lua`
- `astronvim_v4/lua/plugins/alpha.lua`
- `astronvim_v4/lua/plugins/noice.lua`

Target files:

- `astronvim_v6/lua/plugins/astroui.lua`
- optional v6 plugin files as needed

Candidates to port:

- Catppuccin theme choice/customization
- Statusline changes from `heirline.lua`
- Winbar changes from `heirline.lua`
- Dashboard changes from `alpha.lua`
- Noice options from `noice.lua`

Questions before patch:

- Keep Catppuccin as the main theme, or try v6's default `astrotheme` first?
- Keep the custom statusline/winbar, or start from v6 defaults and only port pain points?
- Keep Noice customizations?

Decision log:

- First UI patch targets the functional regression where `showtabline = 0` made the active filename disappear in v6.
- Research confirmed AstroNvim v6 has no newer high-level option for active winbar path/filename.
- AstroNvim current recipe path still uses Heirline plus AstroUI status components.
- Approved using maintained AstroCommunity recipe `astrocommunity.recipes.heirline-vscode-winbar` rather than creating a custom `heirline.lua`.
- Compatibility confirmed in current AstroCommunity and installed v6 AstroUI modules.
- Second UI patch restores Catppuccin Mocha as the colorscheme using the maintained AstroCommunity Catppuccin import.
- Deferred the old custom `native_lsp` undercurl configuration because current Catppuccin has changed its LSP highlight integration model.
- Third UI patch restores diagnostic undercurl using Catppuccin's current `lsp_styles.underlines` API.
- Fourth UI patch keeps the v6 Snacks dashboard but restores the v4 `SKARIVIM` dashboard header.
- Fifth UI patch restores the v4 statusline visual intent using v6 AstroUI/Heirline components in `lua/plugins/heirline.lua`.
- The v6 statusline override intentionally changes only `opts.statusline`; it leaves the already-tested `astrocommunity.recipes.heirline-vscode-winbar` behavior intact.
- Tried clearing `StatusLine` and `StatusLineNC` backgrounds with a local Heirline `config` function, but this replaced AstroNvim's Heirline setup and caused Neovim to fall back to a plain statusline.
- Reverted the local `config` function. Keep the v4-like statusline layout patch intact while researching a safer transparency approach.
- Added an AstroUI `status.colors` override in `lua/plugins/astroui.lua` to feed transparent background aliases into AstroNvim's supported Heirline color pipeline.
- Targeted aliases now set to `NONE`: `none`, `bg`, `section_bg`, `file_info_bg`, `git_branch_bg`, `git_diff_bg`, `diagnostics_bg`, `cmd_info_bg`, and `nav_bg`.
- Left mode colors intact so the mode pill keeps its visible color.
- Added an AstroCore `VimEnter` autocmd to clear the base Neovim `StatusLine` and `StatusLineNC` backgrounds after UI setup.
- Kept both transparency pieces because they cover different layers:
  - AstroUI status color aliases clear Heirline component backgrounds.
  - AstroCore autocmd clears the base statusline row background.
- Ported visual behavior rather than copying old internals:
  - mode pill on the left
  - filetype only, no filename
  - git branch and compact git diff
  - centered command info when relevant
  - compact LSP status/progress signal with client names hidden
  - diagnostics and compact nav percentage/scrollbar on the right
  - no LSP client names, Treesitter indicator, virtualenv segment, cursor ruler, or duplicate right-side mode marker
- Re-added the compact v4 LSP component after audit found it had been unintentionally omitted from the first statusline port.

Test result:

- User tested `nvim11` visually and reported the winbar "looks good".
- Catppuccin patch headless load passed. Awaiting user visual test.
- User tested Catppuccin and diagnostic undercurl visually and reported it "looks good".
- User tested Snacks dashboard header visually and reported it "looks good".
- Headless v6 load passed after adding the statusline override. Awaiting user visual test.
- User screenshot showed the one-time transparency `config` hook broke Heirline rendering. Reverted that hook and verified headless v6 startup succeeds again.
- Headless v6 startup passed after the AstroUI status color patch.
- Runtime check confirmed Heirline loaded the targeted statusline background aliases as `NONE`, while `normal` still resolves to the Catppuccin blue mode color.
- Runtime check after the AstroCore autocmd confirmed `StatusLine` and `StatusLineNC` no longer have `bg` values, while Heirline component background aliases remain `NONE`.
- Headless v6 startup passed after re-adding the compact LSP statusline component.

### 5. LSP Core

Status: Complete

Source files:

- `astronvim_v4/lua/plugins/astrolsp.lua`

Target files:

- `astronvim_v6/lua/plugins/astrolsp.lua`
- optionally `astronvim_v6/lsp/*.lua` or `astronvim_v6/after/lsp/*.lua`

Context:

- AstroNvim v6 uses Neovim's `vim.lsp.config` model.
- Avoid old `require("lspconfig").server.setup(...)` patterns.

Candidates to port:

- `features.codelens = true`
- `features.inlay_hints = false`
- `features.semantic_tokens = true`
- format-on-save enabled
- format timeout
- diagnostics float mapping `gl`
- document highlight autocmd behavior if still wanted
- custom `on_attach` if it becomes non-empty

Questions before patch:

- Keep format-on-save globally enabled?
- Keep `gl` for diagnostics float?
- Keep document highlight autocmds, or use v6 defaults?
- Move any server-specific config into `lsp/<server>.lua` files?

Decision log:

- `gl` diagnostics hover was not ported because AstroNvim v6 already provides it by default, along with `<Leader>ld`.
- v4 LSP document highlighting autocmds were not ported. AstroNvim v6 already enables equivalent reference highlighting through `snacks.words`, with `<Leader>ur` to toggle and `]r`/`[r` to jump between references.
- Adding the old `vim.lsp.buf.document_highlight()` autocmds would be redundant and may overlap visually with Snacks reference highlighting.

Test result:

- User observed reference highlighting already working in v6; decision is to skip the v4 document-highlight autocmd patch.

### 6. Completion

Status: Reviewed sources, no patch

Source files:

- `astronvim_v4/lua/plugins/cmp.lua`

Target files:

- `astronvim_v6/lua/plugins/rust.lua`

Context:

- AstroNvim v6 defaults to `blink.cmp`.
- Current v4 config customizes `nvim-cmp`.

Current v4 behavior:

- Adds sources: LSP, LuaSnip, pandoc references, LaTeX symbols, emoji, calc, path, buffer.
- Uses `lspkind`.
- Customizes menu text.
- Uses `cmp-under-comparator`.
- Disables ghost text.

Questions before patch:

- Try v6 `blink.cmp` first and only port missing behavior?
- Or preserve `nvim-cmp` explicitly?
- Which sources are actually still important: pandoc, LaTeX symbols, emoji, calc?
- Is ghost text still undesired?

Decision log:

- Reviewed v4 `nvim-cmp` sources against v6 `blink.cmp` defaults.
- v6 already covers the sources the user currently relies on: LSP, snippets, path, and buffer.
- User does not currently use the extra v4 sources: emoji, LaTeX symbols, calc, or Pandoc references.
- Decision: do not add completion-source imports now.
- `cmp-under-comparator` was not ported because it is specific to `nvim-cmp`; no replacement was chosen.
- Completion formatting and ghost-text behavior were not changed; revisit only if user observes a concrete issue while testing Blink.

Test result:

- User previously reported JavaScript/TypeScript and Python completion behavior is working well enough with the v6 setup.

### 7. Rust

Status: Complete

Source files:

- `astronvim_v4/lua/plugins/rust.lua`

Target files:

- To be decided.

Candidates to port:

- Rust treesitter parser ensure-installed behavior
- `rust_analyzer` clippy check command
- `CARGO_PROFILE_RUST_ANALYZER_INHERITS`
- custom cargo profile arguments
- `rustaceanvim`
- codelldb adapter integration
- crates.nvim behavior and mappings
- neotest Rust adapter

Questions before patch:

- Keep the custom rustaceanvim setup, or start with AstroCommunity Rust defaults first?
- Keep crates.nvim?
- Keep custom codelldb adapter logic?
- Keep the rust-analyzer cargo profile override?

Decision log:

- Added `astrocommunity.pack.rust` as the v6 Rust baseline.
- The Rust pack provides TOML support, Rust Tree-sitter, rustaceanvim, rust-analyzer ownership through rustaceanvim, clippy checks, codelldb wiring, crates.nvim, and neotest integration when neotest is available.
- Preserved the old rust-analyzer cargo profile override in `lua/plugins/rust.lua` because AstroCommunity still documents this pattern and rust-analyzer officially supports `cargo.extraEnv` and `cargo.extraArgs`.
- Did not restore the old `<leader>r...` crates keymaps yet. The current crates.nvim wrapper enables its in-process LSP integration with hover, code actions, and completion in `Cargo.toml`, plus the `:Crates ...` command family.
- Plan is to test the modern Cargo.toml hover/code-action/command workflow before adding back custom crates keymaps.
- Accepted the v6 Rust pack's newer crates.nvim integration instead of restoring old nvim-cmp/null-ls-specific crates wiring.
- Did not restore the old Rustaceanvim rounded float border because it is visual polish only and was not important to the user.

Test result:

- User tested the Rust baseline and reported it seems good.
- Deferred restoring old `<leader>r...` crates keymaps unless the newer Cargo.toml hover/code-action/`:Crates` workflow proves insufficient.

### 8. ESP32 / clangd

Status: Skipped

Source files:

- `astronvim_v4/lua/plugins/esp.lua`

Target files:

- None.

Candidates to port:

- `Aietes/esp32.nvim`
- clangd server enablement
- `esp32.lsp_config()` merge

Questions before patch:

- Is ESP32 support still required in the new setup?
- Should clangd config live in AstroLSP opts or in an `lsp/clangd.lua` file?

Decision log:

- Skipped by user decision. ESP32 projects are not part of current workflow.
- Do not add `Aietes/esp32.nvim` or an ESP32-specific `clangd` overlay during this migration.
- If C/C++ work becomes relevant later, evaluate `astrocommunity.pack.cpp` separately as a generic C/C++ baseline rather than carrying the old ESP32-specific config forward.

Test result:

- Not applicable.

### 9. Telescope And Navigation

Status: Reviewed

Source files:

- `astronvim_v4/lua/plugins/telescope.lua`

Target files:

- None.

Questions before patch:

- Keep Telescope customizations?
- Use v6 defaults or newer picker defaults first?

Decision log:

- Do not add Telescope back for this old customization.
- AstroNvim v6 is using Snacks picker. Runtime/source inspection confirmed `telescope.nvim` is disabled and `snacks.nvim` picker is active.
- Old v4 customization only affected the Telescope buffer picker:
  - `sort_mru = true`
  - `ignore_current_buffer = true`
  - normal-mode `d` deleted a selected buffer
- Snacks buffer picker already sorts by last used with `sort_lastused = true`.
- Snacks buffer picker already provides delete-buffer actions with `<C-x>` in input/list mode and `dd` in the list.
- User prefers the current v6 behavior where the active buffer remains visible in the buffer picker.

Test result:

- No patch needed. User accepted current Snacks behavior and will use `<C-x>`/`dd` instead of the old Telescope `d` mapping.

### 10. Optional Or Inactive Config

Status: Complete

Source files:

- `astronvim_v4/lua/plugins/disabled.lua`
- `astronvim_v4/lua/plugins/godot.lua`
- `astronvim_v4/lua/plugins/lsp_lines.lua`
- `astronvim_v4/lua/plugins/eyeliner.lua`

Default stance:

- Skip inactive files unless explicitly requested.
- Prefer v6 native features over old plugins where reasonable.

Questions before patch:

- Is Godot still relevant?
- Is eyeliner still used?
- Do we need lsp_lines, or is native virtual lines enough?
- Are any disabled plugin rules still needed?

Decision log:

- `disabled.lua` was inactive in v4, so no disabled-plugin rules were ported.
- `godot.lua` was inactive in v4, so Godot support was not revived.
- `lsp_lines.lua` was inactive in v4, and current v6 diagnostics use native `virtual_text = true`, `virtual_lines = false`, and diagnostic undercurl.
- Trialed `astrocommunity.editing-support.quick-scope` as the v6/community replacement candidate for active v4 `eyeliner.nvim`.
- User found quick-scope visually worse because it recolors target characters but does not dim surrounding non-target characters.
- Source/docs inspection confirmed quick-scope supports primary/secondary colors and toggles, but not eyeliner's `dim = true` behavior.
- Removed quick-scope and restored `jinh0/eyeliner.nvim` locally in `lua/plugins/eyeliner.lua`.
- Preserved old v4 options: `highlight_on_key = true`, `dim = true`.

Test result:

- User tested restored eyeliner behavior and reported it is much nicer.

### 11. Polish

Status: Complete

Source files:

- `astronvim_v4/lua/polish.lua`

Target files:

- `astronvim_v6/lua/polish.lua`

Questions before patch:

- Are there any final ad hoc settings in v4 polish that still matter?

Decision log:

- Do not activate `lua/polish.lua` in v6.
- Runtime check showed `clipboard=unnamedplus` is already active in v6.
- Runtime check showed `j` and `k` already use wrapped-line movement behavior:
  - `j`: `v:count == 0 ? 'gj' : 'j'`
  - `k`: `v:count == 0 ? 'gk' : 'k'`
- Skipped old Godot LSP autostart because Godot/ESP32-style niche project support is not part of current workflow.
- Moved the remaining desired polish behavior into `lua/plugins/astrocore.lua`:
  - Set `wrap = true`.
  - Added normal-mode `0` mapping to `^` for first non-blank character.
- Final runtime check corrected an earlier mistaken check and found `clipboard` initially appeared empty in `astronvim_v6`; v4 active `polish.lua` appended `unnamedplus`.
- Added `clipboard = "unnamedplus"` under AstroCore `options.opt`.
- AstroCore defers applying clipboard with `vim.schedule()`, so immediate headless `+qa` checks can read as empty before the scheduled callback runs.

Test result:

- User tested wrap behavior and `0` mapping and reported it looks good.
- Deferred runtime check with `vim.wait()` confirmed `clipboard=unnamedplus`.

### 12. Burn-In

Status: Started

Goal: Use the v6 setup for normal work before retiring v4.

Checklist:

- Open and edit dotfiles.
- Open and edit a TypeScript project.
- Open and edit a Rust project.
- Open Markdown files.
- Confirm formatting and diagnostics do not surprise.
- Confirm completion is acceptable.
- Confirm navigation and UI feel acceptable.

Decision log:

- User chose to start daily driving v6.
- Updated `zsh/.zshrc` so `nvim` launches `NVIM_APPNAME=astronvim_v6 $HOME/.local/neovim/0.11.6/bin/nvim`.
- Added `nvim10` as the preserved v4 behavior.
- Fixed `nvim10` to call `/opt/homebrew/bin/nvim` explicitly because plain `nvim` could resolve through the new v6 alias in interactive zsh.
- Verified `/opt/homebrew/bin/nvim` is Neovim v0.10.4.
- Kept `nvim11` as a compatibility alias for the v6 pinned Neovim command.

Test result:

- Shell alias lines verified in `zsh/.zshrc`.

### 13. Final Cutover

Status: Daily-driver cutover started

Possible actions:

- Change `alias nvim=...` from `astronvim_v4` to `astronvim_v6`. Completed.
- Decide whether to keep or archive `astronvim_v4`.
- Decide whether to keep pinned Neovim `0.11.6`, move to Homebrew latest, or jump to Neovim `0.12.x`.
- Delete this migration log if no longer needed.

Decision log:

- `nvim` now points to v6/Neovim 0.11.6.
- `nvim10` preserves the prior v4/default Neovim behavior.
- `astronvim_v4` is retained for fallback during daily driving.

Test result:

- Alias definitions verified in `zsh/.zshrc`.

## Patch History

### 2026-05-17 - Migration environment created

Changes:

- Added `astronvim_v6/` from AstroNvim v6 template.
- Added `nvim11` alias in `zsh/.zshrc`.
- Installed isolated Neovim `v0.11.6`.
- Created `~/.config/astronvim_v6` symlink.

Validation:

- Existing `nvim` still reports Neovim `v0.10.4`.
- Isolated binary reports Neovim `v0.11.6`.
- User launched `nvim11` and confirmed it works.

Notes:

- No v4 config has been ported yet.

### 2026-05-17 - Core editor preferences patched

Changes:

- Activated `astronvim_v6/lua/plugins/astrocore.lua`.
- Restored v4 large-buffer threshold.
- Restored hidden tabline.
- Restored `H`/`L` buffer navigation.
- Enabled diagnostic virtual lines by default.
- Kept v6 signcolumn default `"yes"`.
- Kept v6 buffer mappings `[b`, `]b`, and `<Leader>bd`.
- Removed duplicate `<Leader>bD` mapping because v6 already has the same behavior on `<Leader>bd`.

Validation:

- Compatibility checked against installed v6 AstroCore/AstroUI modules.
- Duplicate keymap check confirmed no remaining added keymaps duplicate AstroNvim v6 defaults. Remaining additions are `H` and `L`; v6 defaults use `[b` and `]b`.
- User tested with `nvim11` and reported "so far so good".

### 2026-05-17 - AstroCommunity language/tooling baseline patched

Changes:

- Activated `astronvim_v6/lua/community.lua`.
- Added language packs for Lua, TypeScript, Svelte, TailwindCSS, Markdown, Just, Terraform, and Bash.
- Migrated Python to explicit `base` + `basedpyright` + `ruff`.
- Added explicit Prettier pack.
- Removed ESLint pack after testing because it reported "Unable to find ESLint library" in projects without local ESLint.

Validation:

- Confirmed all imports exist in current AstroCommunity before patching.
- Headless `nvim11` install/load cloned AstroCommunity and related plugins successfully.

### 2026-05-17 - Remove Deno and disable virtual lines

Changes:

- Replaced `astrocommunity.pack.typescript-all-in-one` with `astrocommunity.pack.typescript`.
- Set startup diagnostic virtual lines to `false`.
- Set diagnostic config virtual lines to `false`.

Reason:

- User does not use Deno.
- `typescript-all-in-one` imports `typescript-deno`, which imports `sigmasd/deno-nvim`.
- `deno-nvim` still calls deprecated `require("lspconfig").denols.setup(...)`, causing the Neovim 0.11/nvim-lspconfig deprecation warning.
- User requested disabling virtual lines for now.

Validation:

- Headless `nvim11` load passed after removing Deno support.
- User later reported Python and JavaScript/TypeScript projects are working well.

### 2026-05-17 - Remove ESLint pack

Changes:

- Removed `astrocommunity.pack.eslint`.
- Kept `astrocommunity.pack.prettier`.

Reason:

- ESLint was not part of the v4 baseline.
- The ESLint LSP reports "Unable to find ESLint library" in projects without a local `node_modules/eslint`.
- Prefer keeping the migration baseline quiet; a conditional ESLint setup can be added later if needed.

Validation:

- Headless `nvim11` load passed.
- User reported Python and JavaScript/TypeScript projects are working well.

### 2026-05-17 - Add VS Code-style winbar recipe

Changes:

- Added `astrocommunity.recipes.heirline-vscode-winbar`.

Reason:

- v4 showed path and filename in the top winbar, which made hidden tabline viable.
- v6 default active winbar is breadcrumbs-only, so the filename can disappear.
- AstroNvim/AstroCommunity still recommend Heirline/AstroUI components for this behavior.
- The maintained AstroCommunity recipe is less brittle than copying a custom local `heirline.lua`.

Validation:

- Headless `nvim11` load passed.
- User tested `nvim11` visually and reported the winbar "looks good".

### 2026-05-17 - Restore Catppuccin Mocha

Changes:

- Added `astrocommunity.colorscheme.catppuccin`.
- Activated `astronvim_v6/lua/plugins/astroui.lua`.
- Set `colorscheme = "catppuccin-mocha"`.

Reason:

- v4 used Catppuccin Mocha as the daily colorscheme.
- The maintained AstroCommunity import already configures Catppuccin for current v6-era plugins, including Snacks.
- The old local `native_lsp` undercurl customization was not ported in this patch because current Catppuccin has changed LSP highlight integration behavior.

Validation:

- Headless `nvim11` load passed and installed Catppuccin into the isolated `astronvim_v6` profile.
- User later tested Catppuccin and diagnostic undercurl visually and reported it "looks good".

### 2026-05-17 - Restore Catppuccin diagnostic undercurl

Changes:

- Added `astronvim_v6/lua/plugins/catppuccin.lua`.
- Set Catppuccin `lsp_styles.underlines` entries to `{ "undercurl" }` for errors, hints, warnings, information, and ok diagnostics.

Reason:

- v4 used Catppuccin's old `integrations.native_lsp.underlines` API to show diagnostic undercurls.
- Current Catppuccin moved that behavior to `lsp_styles.underlines`.
- AstroCore diagnostics already has `underline = true`, so this patch only changes underline style from plain underline to undercurl.

Validation:

- Live pre-patch inspection showed `DiagnosticUnderlineError` and `DiagnosticUnderlineWarn` used plain `underline = true`.
- Headless load intentionally skipped per user request.
- User tested visually and reported it "looks good".

### 2026-05-17 - Restore SKARIVIM dashboard header

Changes:

- Added `astronvim_v6/lua/plugins/snacks-dashboard.lua`.
- Overrode `folke/snacks.nvim` dashboard `preset.header` with the v4 `SKARIVIM` banner.
- Kept the header as a list joined with `"\n"`; this is a separator between banner rows, not a trailing newline.

Reason:

- v4 customized only the Alpha dashboard banner.
- AstroNvim v6 uses Snacks dashboard by default.
- Keeping Snacks preserves v6 dashboard behavior, mappings, and defaults while restoring the visible personalization.

Validation:

- Compatibility checked against installed AstroNvim v6 Snacks dashboard config.
- Headless load intentionally skipped per user request.
- User tested visually and reported it "looks good".

### 2026-05-17 - Enable automatic AstroLSP signature help

Changes:

- Activated `astronvim_v6/lua/plugins/astrolsp.lua`.
- Set `features.signature_help = true`.

Reason:

- User missed automatic signature popups while typing.
- AstroNvim v6 has this built into AstroLSP.
- AstroCommunity's old `astrolsp-auto-signature-help` recipe now points users to this built-in option.
- Noice was not added because v4 Noice had `signature = { enabled = false }`, so Noice was not the right mechanism for restoring this behavior.
- Blink signature help was not enabled because it is experimental and would supersede AstroLSP signature handling in AstroNvim's integration.

Validation:

- Compatibility checked against installed AstroNvim v6 AstroLSP autocmds and AstroCommunity recipe.
- User tested and confirmed it appears while typing, but found it too transient.

### 2026-05-17 - Test Blink signature help

Changes:

- Added `astronvim_v6/lua/plugins/blink.lua`.
- Enabled `blink.cmp` signature help.
- Set AstroLSP `features.signature_help = false` to avoid two competing signature systems.
- Added experimental Blink keymaps:
  - `<C-Space>` toggles completion visibility.
  - `<C-E>` toggles signature help.
  - `<C-J>` and `<C-K>` remain next/previous completion navigation.
- Changed `<C-E>` to Blink's documented signature ordering: `show_signature`, then `hide_signature`, before considering disabling automatic signature triggers.
- Replaced the `<C-E>` command chain with an explicit function that checks `cmp.is_signature_visible()` and calls `hide_signature()` or `show_signature()`.
- Switched key spellings to Blink's documented lowercase `<C-space>` and `<C-e>` forms.
- Replaced the `<C-e>` public API toggle with a direct `blink.cmp.signature.trigger` context toggle because the public toggle did not work reliably in user testing.
- Changed Blink signature help to manual-only by disabling signature triggers and restoring the documented `<C-e>` command chain.

Reason:

- User wants signature help that can be shown/toggled from insert mode with `<C-K>`.
- Blink documents `<C-K>` as its signature show/hide key when signature help is enabled.
- This is a reversible test because Blink marks signature help experimental.
- User wants a clear insert-mode model for completion and signature help controls.

Validation:

- User tested several Blink signature mappings on `<C-e>`.
- Live config and `:verbose imap <C-e>` confirmed the mapping was active, but Blink signature still did not toggle reliably.
- Reverted Blink signature help and restored AstroLSP automatic signature help.
- Removed the local Blink override entirely after user requested returning to default keymaps.
- Tried restoring Blink signature trigger behavior without custom keymaps, but user no longer saw signature help.
- Reverted again to last known working behavior: AstroLSP `signature_help = true`, with no local Blink override.
- User accepted AstroLSP signature help as decent for now.

## Open Questions

- Continue burn-in with daily-driver `nvim`.
- Keep `nvim10`/`astronvim_v4` available until v6 is confirmed stable enough to archive the old setup.
- Keep `.neoconf.json` for now. It may be inherited AstroNvim template metadata; do not delete it without high confidence that v6 no longer consumes it.

### 2026-05-17 - Remove disabled v6 plugin template files

Changes:

- Deleted disabled template files from `astronvim_v6`:
  - `lua/plugins/mason.lua`
  - `lua/plugins/treesitter.lua`
  - `lua/plugins/none-ls.lua`
  - `lua/plugins/user.lua`
- Briefly deleted `lua/polish.lua` and removed `require "polish"`, then restored both by user preference.
- `lua/polish.lua` remains as an inactive template hook for future ad hoc config.

Reason:

- User requested deleting disabled files in the v6 config, then clarified that keeping the disabled polish template and hook may be useful later.
- The desired old polish behavior had already been moved into `lua/plugins/astrocore.lua`.

Validation:

- `rg` found only the intentional disabled `lua/polish.lua` guard in `astronvim_v6`.
- `NVIM_APPNAME=astronvim_v6 nvim11 --headless +qa` completed successfully.

### 2026-05-17 - Final audit cleanup

Changes:

- Removed leftover AstroNvim template `fooscript` filetype examples from `astronvim_v6/lua/plugins/astrocore.lua`.
- Cleaned stale migration log status text after daily-driver cutover.
- Recorded final audit decisions:
  - Rust v6 pack behavior is accepted; old crates.nvim nvim-cmp/null-ls wiring is not being restored.
  - Rustaceanvim rounded border polish is not important enough to port.
  - `.neoconf.json` is left untouched until there is high confidence it is unused.

Validation:

- Final audit used full-file comparisons of v4 and v6 config files.
