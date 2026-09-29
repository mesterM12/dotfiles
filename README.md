# Mac recovery

This repository restores configuration with chezmoi, applications with Homebrew,
and development tools with mise. Private configuration is age-encrypted, including
Git identity, SSH hosts, agent settings, the gateway API key, and the detailed
recovery inventory. File permissions alone are not encryption.

## Recovery key comes first

The age identity is **never stored in Git**. Keep an off-device copy in a password
manager or encrypted offline backup. A copy exists in this Mac's login Keychain
under service `chezmoi-age-identity`; Keychain on the same disk is not an off-device
backup. Losing both the identity and its backup makes encrypted files unrecoverable.

Restore the identity to `~/.config/chezmoi/age-identity.txt`, with directory mode
`0700` and file mode `0600`. If recovering from a restored login Keychain:

```sh
(
  set -eu
  umask 077
  identity=$(security find-generic-password -s chezmoi-age-identity -w)
  case "$identity" in AGE-SECRET-KEY-*) ;; *) exit 1 ;; esac
  mkdir -p "$HOME/.config/chezmoi"
  printf '%s\n' "$identity" > "$HOME/.config/chezmoi/age-identity.txt"
)
```

## Bootstrap

Install Apple's Command Line Tools (`xcode-select --install`) and Homebrew from
https://brew.sh. Set `DOTFILES_URL` to this repository's clone URL, then:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install mise
mise exec chezmoi@2.73.0 -- chezmoi init "$DOTFILES_URL"
mise exec chezmoi@2.73.0 -- chezmoi apply --dry-run
mise exec chezmoi@2.73.0 -- chezmoi apply
brew bundle --file="$HOME/Brewfile"
mise install
eval "$(mise activate zsh)"
```

Read `~/.config/mac-recovery/RECOVERY.md` after decryption for the private inventory,
DNS setup, plugin installation, and app recovery details. Review absolute paths
before applying to a different username. Restore SSH private keys, app databases,
projects, and login sessions from a separate encrypted backup or reauthenticate.
macOS privacy permissions and app licenses need manual restoration.

## Verify and maintain

```sh
chezmoi status
brew bundle check --file="$HOME/Brewfile"
mise doctor
```

After deliberate live changes, use `chezmoi re-add`, inspect the source diff, then
commit and push. Add private files with `chezmoi add --encrypt PATH`; never add the
age identity. Ciphertext is safe to version; decrypted backups and diagnostic
output must remain outside Git. Scan both working files and all history with
Gitleaks (`--redact`) before publishing. Git metadata is public too: use a
non-identifying author when publishing this repository.
