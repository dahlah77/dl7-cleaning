#!/bin/zsh
# Interactive, non-destructive setup for DL7 CLEANING on Apple devices.
# Run on a Mac. Never removes user files, other applications, or Xcode settings.
emulate -L zsh
set -euo pipefail

readonly dl7_repository_url="https://github.com/dahlah77/dl7-cleaning.git"
readonly dl7_source_dir="${DL7_SOURCE_DIR:-${HOME}/Developer/DL7-CLEANING}"
typeset dl7_platform=""
typeset dl7_project_root=""
typeset -i dl7_dry_run=0
typeset -i dl7_skip_launch=0
typeset -a dl7_targets

dl7_info() { print -r -- "  • $*"; }
dl7_error() { print -u2 -r -- "✖ $*"; exit 1; }

dl7_usage() {
  print -r -- 'DL7 CLEANING — One-Command Installer'
  print -r -- ''
  print -r -- 'Penggunaan: zsh scripts/install.sh [opsi]'
  print -r -- ''
  print -r -- 'Opsi:'
  print -r -- '  --platform macos|iphone|ipad|both|watchos|tvos|visionos|all'
  print -r -- '  --dry-run      Tampilkan rencana tanpa mengunduh atau memasang'
  print -r -- '  --no-launch    Siapkan hasil build tanpa membuka app / Xcode'
  print -r -- '  --help         Tampilkan bantuan'
  print -r -- ''
  print -r -- 'Tanpa --platform, menu interaktif akan muncul.'
  print -r -- 'Perangkat selain Mac memerlukan proses signing di Xcode.'
}

while (( $# > 0 )); do
  case "$1" in
    --platform)
      (( $# >= 2 )) || dl7_error 'Tambahkan nama platform setelah --platform.'
      dl7_platform="$2"
      shift 2
      ;;
    --platform=*)
      dl7_platform="${1#--platform=}"
      shift
      ;;
    --dry-run)
      dl7_dry_run=1
      shift
      ;;
    --no-launch)
      dl7_skip_launch=1
      shift
      ;;
    --help|-h)
      dl7_usage
      exit 0
      ;;
    *)
      dl7_error "Opsi tidak dikenal: $1. Lihat --help."
      ;;
  esac
done

dl7_choose_platform() {
  print -r -- ''
  print -r -- '╭────────────────────────────────────────────╮'
  print -r -- '│         DL7 CLEANING · SETUP              │'
  print -r -- '╰────────────────────────────────────────────╯'
  print -r -- ''
  print -r -- 'Pilih perangkat tujuan:'
  print -r -- '  1. Mac'
  print -r -- '  2. iPhone'
  print -r -- '  3. iPad'
  print -r -- '  4. Mac + iPhone'
  print -r -- '  5. Apple TV'
  print -r -- '  6. Apple Watch'
  print -r -- '  7. Apple Vision Pro'
  print -r -- '  8. Semua perangkat'
  print -r -- '  0. Keluar'
  print -n -- 'Pilihan [1–8]: '
  local response=""
  IFS= read -r response </dev/tty || dl7_error 'Terminal interaktif dibutuhkan. Gunakan --platform untuk mode otomatis.'
  case "$response" in
    1) dl7_platform="macos" ;;
    2) dl7_platform="iphone" ;;
    3) dl7_platform="ipad" ;;
    4) dl7_platform="both" ;;
    5) dl7_platform="tvos" ;;
    6) dl7_platform="watchos" ;;
    7) dl7_platform="visionos" ;;
    8) dl7_platform="all" ;;
    0) print 'Setup dibatalkan.'; exit 0 ;;
    *) dl7_error 'Pilihan tidak valid. Jalankan lagi dan pilih angka 0–8.' ;;
  esac
}

[[ -n "$dl7_platform" ]] || dl7_choose_platform

case "$dl7_platform" in
  mac|macos)
    dl7_targets=(macos)
    ;;
  ios)
    dl7_targets=(iphone)
    ;;
  iphone|ipad)
    dl7_targets=("$dl7_platform")
    ;;
  both|mac+iphone|macos+iphone)
    dl7_targets=(macos iphone)
    ;;
  tv|tvos|appletv)
    dl7_targets=(tvos)
    ;;
  watch|watchos|applewatch)
    dl7_targets=(watchos)
    ;;
  vision|visionos|visionpro)
    dl7_targets=(visionos)
    ;;
  all)
    dl7_targets=(macos iphone ipad watchos tvos visionos)
    ;;
  *)
    dl7_error "Platform tidak dikenal: $dl7_platform."
    ;;
esac

print -r -- ''
print -r -- "Target: ${(j:, :)dl7_targets}"
if (( dl7_dry_run )); then
  dl7_info 'DRY RUN — tidak ada file, app, atau pengaturan sistem yang diubah.'
  if (( ${dl7_targets[(Ie)macos]} )); then
    dl7_info 'Mac: periksa Xcode → build .app → cadangkan instalasi lama → pasang → buka.'
  fi
  if (( ${#dl7_targets} > 1 )) || [[ "${dl7_targets[1]}" != "macos" ]]; then
    dl7_info 'Companions: pasang XcodeGen bila perlu → generate project → buka Xcode.'
    dl7_info 'Perangkat fisik: pilih Apple Account/Team dan Run di Xcode.'
  fi
  exit 0
fi

[[ "$(uname -s)" == "Darwin" ]] || dl7_error 'Installer harus dijalankan dari Terminal macOS, bukan iPhone/Windows/Linux.'
for required_tool in git curl xcodebuild open; do
  command -v "$required_tool" >/dev/null 2>&1 || dl7_error "Tool belum tersedia: $required_tool."
done
xcodebuild -version >/dev/null 2>&1 || dl7_error 'Instal Xcode lengkap dari App Store, buka sekali, dan selesaikan setup awalnya.'

dl7_locate_project() {
  local script_root="${0:A:h:h}"
  if [[ -f "$script_root/scripts/build-macos.sh" && -f "$script_root/Companions/project.yml" ]]; then
    dl7_project_root="$script_root"
    return
  fi
  if [[ -f "$PWD/scripts/build-macos.sh" && -f "$PWD/Companions/project.yml" ]]; then
    dl7_project_root="$PWD"
    return
  fi

  if [[ -e "$dl7_source_dir" ]]; then
    [[ -d "$dl7_source_dir/.git" && -f "$dl7_source_dir/scripts/build-macos.sh" ]] ||
      dl7_error "Lokasi source sudah terpakai oleh file lain: $dl7_source_dir. Gunakan DL7_SOURCE_DIR untuk memilih folder lain."
    dl7_project_root="$dl7_source_dir"
    local remote_url
    remote_url="$(git -C "$dl7_project_root" remote get-url origin 2>/dev/null || true)"
    if [[ "$remote_url" == "$dl7_repository_url" || "$remote_url" == "git@github.com:dahlah77/dl7-cleaning.git" ]]; then
      local working_changes current_branch
      working_changes="$(git -C "$dl7_project_root" status --porcelain)"
      current_branch="$(git -C "$dl7_project_root" branch --show-current)"
      if [[ -z "$working_changes" && "$current_branch" == "main" ]]; then
        dl7_info 'Memperbarui source (fast-forward only)…'
        git -C "$dl7_project_root" pull --ff-only
      else
        dl7_info 'Source lokal memiliki perubahan/branch sendiri; tidak ditimpa atau di-reset.'
        local clean_checkout="${dl7_source_dir}-setup-$(date '+%Y%m%d-%H%M%S')-$$"
        dl7_info "Mengambil source terbaru ke folder terpisah: $clean_checkout"
        git clone --depth 1 "$dl7_repository_url" "$clean_checkout"
        dl7_project_root="$clean_checkout"
      fi
    else
      local clean_checkout="${dl7_source_dir}-setup-$(date '+%Y%m%d-%H%M%S')-$$"
      dl7_info 'Folder tersebut bukan checkout resmi; dibiarkan utuh.'
      git clone --depth 1 "$dl7_repository_url" "$clean_checkout"
      dl7_project_root="$clean_checkout"
    fi
    return
  fi
  mkdir -p "${dl7_source_dir:h}"
  dl7_info "Mengunduh source resmi ke $dl7_source_dir"
  git clone --depth 1 "$dl7_repository_url" "$dl7_source_dir"
  dl7_project_root="$dl7_source_dir"
}

dl7_locate_project
dl7_info "Source: $dl7_project_root"

dl7_install_mac() {
  local build_stamp build_app installed_app app_directory backup_dir backup_app
  build_stamp="$(date '+%Y%m%d-%H%M%S')-$$"
  build_app="$dl7_project_root/dist/DL7 CLEANING Setup-$build_stamp.app"
  dl7_info 'Membangun aplikasi macOS dari engine open-source yang dipin…'
  DL7_BUILD_OUTPUT_PATH="$build_app" /bin/zsh "$dl7_project_root/scripts/build-macos.sh"
  [[ -d "$build_app" ]] || dl7_error 'Build selesai tanpa bundle aplikasi yang diharapkan.'

  if [[ -d "/Applications/DL7 CLEANING.app" ]]; then
    app_directory="/Applications"
  elif [[ -d "$HOME/Applications/DL7 CLEANING.app" ]]; then
    app_directory="$HOME/Applications"
  elif [[ -w "/Applications" ]]; then
    app_directory="/Applications"
  else
    app_directory="$HOME/Applications"
  fi
  mkdir -p "$app_directory" 2>/dev/null ||
    dl7_error "Tidak bisa membuat folder $app_directory. Hasil build aman di $build_app"
  installed_app="$app_directory/DL7 CLEANING.app"

  if command -v pgrep >/dev/null 2>&1 && pgrep -x 'DL7 CLEANING' >/dev/null 2>&1; then
    dl7_info 'Meminta aplikasi DL7 CLEANING yang sedang berjalan untuk menutup…'
    /usr/bin/osascript -e 'tell application "DL7 CLEANING" to quit' >/dev/null 2>&1 || true
    sleep 2
    if pgrep -x 'DL7 CLEANING' >/dev/null 2>&1; then
      dl7_error "Tutup DL7 CLEANING yang lama terlebih dahulu. Build baru aman di: $build_app"
    fi
  fi

  if [[ -d "$installed_app" && ! -w "$app_directory" ]]; then
    dl7_info "Butuh izin admin untuk mengganti app di $app_directory."
    dl7_info "Aplikasi baru tetap tersedia di: $build_app"
    if (( ! dl7_skip_launch )); then open "$build_app"; fi
    return
  fi

  backup_app=""
  if [[ -e "$installed_app" ]]; then
    backup_dir="$HOME/Library/Application Support/DL7 CLEANING/Installation Backups"
    mkdir -p "$backup_dir"
    backup_app="$backup_dir/DL7 CLEANING-$build_stamp.app"
    dl7_info "Mencadangkan versi sebelumnya ke: $backup_app"
    mv "$installed_app" "$backup_app" ||
      dl7_error "Gagal mencadangkan app lama. Tidak melakukan penimpaan. Build baru: $build_app"
  fi

  if ! ditto "$build_app" "$installed_app"; then
    dl7_info 'Gagal memasang build baru. Memulihkan cadangan jika tersedia…'
    if [[ -e "$installed_app" ]]; then
      local failed_app="$HOME/Library/Application Support/DL7 CLEANING/Installation Backups/Failed-$build_stamp.app"
      mkdir -p "${failed_app:h}"
      mv "$installed_app" "$failed_app" || true
    fi
    if [[ -n "$backup_app" && -d "$backup_app" && ! -e "$installed_app" ]]; then
      mv "$backup_app" "$installed_app" || dl7_info "Pemulihan manual diperlukan dari $backup_app"
    fi
    dl7_error "Pemasangan gagal. Build tetap tersedia di: $build_app"
  fi
  dl7_info "Mac: terpasang di $installed_app"
  if (( ! dl7_skip_launch )); then
    open "$installed_app"
    dl7_info 'Mac: aplikasi dibuka.'
  fi
}

dl7_prepare_companions() {
  if ! command -v xcodegen >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      dl7_info 'Memasang XcodeGen melalui Homebrew…'
      brew install xcodegen
    else
      dl7_error 'XcodeGen dibutuhkan. Pasang Homebrew (https://brew.sh), lalu brew install xcodegen; atau pasang XcodeGen dari GitHub resmi.'
    fi
  fi
  dl7_info 'Membuat proyek Xcode untuk perangkat Apple…'
  (cd "$dl7_project_root/Companions" && xcodegen generate)
  local project="$dl7_project_root/Companions/DL7CleaningCompanions.xcodeproj"
  [[ -d "$project" ]] || dl7_error 'Proyek Xcode belum berhasil dibuat.'

  print -r -- ''
  print -r -- '  PROJECT READY — skema yang dipilih:'
  local device
  for device in "${dl7_targets[@]}"; do
    case "$device" in
      iphone|ipad) dl7_info "$device → DL7iOS (iOS/iPadOS 18+)" ;;
      watchos) dl7_info 'Apple Watch → DL7watchOS (eksperimental)' ;;
      tvos) dl7_info 'Apple TV → DL7tvOS (eksperimental)' ;;
      visionos) dl7_info 'Vision Pro → DL7visionOS (eksperimental)' ;;
    esac
  done
  dl7_info 'Langkah Apple yang wajib: Xcode → pilih scheme → perangkat → Signing Team → Run ▶.'
  dl7_info 'Perangkat fisik perlu pairing, Apple Account, dan Developer Mode jika diminta.'
  if (( ! dl7_skip_launch )); then
    open -a Xcode "$project"
    dl7_info 'Xcode sudah dibuka untuk pemasangan ke perangkat.'
  else
    dl7_info "Project: $project"
  fi
}

if (( ${dl7_targets[(Ie)macos]} )); then
  dl7_install_mac
fi

typeset -i dl7_needs_companions=0
for dl7_device in "${dl7_targets[@]}"; do
  if [[ "$dl7_device" != "macos" ]]; then
    dl7_needs_companions=1
    break
  fi
done
if (( dl7_needs_companions )); then
  dl7_prepare_companions
fi

print -r -- ''
print -r -- '✓ DL7 CLEANING: tahapan otomatis selesai.'
if (( dl7_needs_companions )); then
  print -r -- '  Status perangkat selain Mac: menunggu signing dan Run di Xcode.'
fi
print -r -- '  Panduan: https://github.com/dahlah77/dl7-cleaning/blob/main/docs/INSTALL.md'
