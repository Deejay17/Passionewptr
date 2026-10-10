#!/usr/bin/env bash
# bootstrap_pasion_quito.sh
#
# Extrae, sanea e inicializa en un repositorio PRIVADO de GitHub el código de "Pasión Quito".
# Pensado para macOS (bash 3.2 + herramientas BSD); también funciona en Linux.
#
# Uso:
#   bash bootstrap_pasion_quito.sh               ejecución completa (pide confirmación antes de publicar)
#   bash bootstrap_pasion_quito.sh --yes         sin confirmaciones interactivas
#   bash bootstrap_pasion_quito.sh --continuar   retoma tras corregir hallazgos (no vuelve a extraer)
#
# Variables opcionales:
#   BACKUP_DIR, DEST_DIR, GH_OWNER, REPO_NAME   cambian las rutas / el destino por defecto
#   PASION_IGNORAR_HALLAZGOS=1                   publica aunque el escaneo de secretos encuentre algo
#                                                (NO recomendado; revisa antes cada hallazgo)

set -Eeuo pipefail

BACKUP_DIR="${BACKUP_DIR:-/Users/macbookpro/Backups/pasion-backup-2026}"
DEST_DIR="${DEST_DIR:-/Users/macbookpro/Projects/pasion-quito}"
GH_OWNER="${GH_OWNER:-Deejay17}"
REPO_NAME="${REPO_NAME:-pasion-quito}"

SRC_TAR="$BACKUP_DIR/pasion_source_code.tar.gz"
SRC_SQL="$BACKUP_DIR/schema_disponibles_db.sql.gz"
SCHEMA_REL="database/sql/schema_limpio_quito.sql"
ENV_BACKUP=".env.espana.backup"
FULL_REPO="$GH_OWNER/$REPO_NAME"
COMMIT_MSG="feat: inicialización soberana del motor Pasión Quito (Laravel v10 + Voyager + motor de bumping)"
GITIGNORE_MARK="# >>> blindaje pasion-quito >>>"

ASSUME_YES=0
CONTINUE=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    --continuar) CONTINUE=1 ;;
    -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "Opción desconocida: $arg (usa --help)" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[1m'; N=$'\033[0m'
else
  R=''; G=''; Y=''; B=''; N=''
fi
step() { printf '\n%s==> %s%s\n' "$B" "$*" "$N"; }
ok()   { printf '  %s✔%s %s\n' "$G" "$N" "$*"; }
info() { printf '  · %s\n' "$*"; }
warn() { printf '  %s⚠ %s%s\n' "$Y" "$*" "$N" >&2; }
die()  { printf '\n%s✖ ERROR:%s %s\n' "$R" "$N" "$*" >&2; exit 1; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
count_lines() { if [ -s "$1" ]; then wc -l < "$1" | tr -d ' '; else echo 0; fi; }

confirm() {
  if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
  [ -t 0 ] || die "Se necesita confirmación interactiva (o ejecuta con --yes)."
  printf '%s%s [s/N]%s ' "$B" "$1" "$N"
  read -r ans
  case "$ans" in s|S|si|SI|Si|sí|Sí|SÍ|y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# Ejecuta git grep y distingue "sin coincidencias" (1) de un error real (>1).
git_grep_to() {
  local out="$1"; shift
  local rc=0
  git grep --cached "$@" > "$out" 2>/dev/null || rc=$?
  [ "$rc" -le 1 ] || die "git grep falló (código $rc)."
}

# Lista el contenido de un directorio sin la basura de macOS.
list_entries() { ls -A "$1" | grep -vE '^(\.DS_Store|__MACOSX|\._.*)$' || true; }

# Directorio temporal privado (fuera del proyecto) para listados y patrones de secretos.
WORK="$(mktemp -d "${TMPDIR:-/tmp}/pasion-quito.XXXXXX")"
chmod 700 "$WORK"
STAGING=""
cleanup() {
  rm -rf "$WORK"
  if [ -n "$STAGING" ] && [ -d "$STAGING" ]; then rm -rf "$STAGING"; fi
}
trap cleanup EXIT
trap 'printf "%s✖ Falló el comando de la línea %s%s\n" "$R" "$LINENO" "$N" >&2' ERR

# ---------------------------------------------------------------------------
step "0/5 Comprobaciones previas"
# ---------------------------------------------------------------------------
for cmd in git tar gzip gh awk sed grep find; do
  command -v "$cmd" >/dev/null 2>&1 || die "Falta el comando '$cmd'."
done

gh auth status >/dev/null 2>&1 || die "gh no está autenticado. Ejecuta: gh auth login"
GH_LOGIN="$(gh api user --jq .login)"
[ "$(lower "$GH_LOGIN")" = "$(lower "$GH_OWNER")" ] \
  || die "gh está autenticado como '$GH_LOGIN', no como '$GH_OWNER'. Cambia con: gh auth switch"
ok "gh autenticado como $GH_LOGIN"

if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
  die "Configura tu identidad de git: git config --global user.name \"...\" && git config --global user.email \"...\""
fi
ok "Identidad git: $(git config user.name) <$(git config user.email)>"

# Nunca publicar en un repositorio existente que sea público o que ya tenga historial.
REPO_EXISTS=0
if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  vis="$(gh repo view "$FULL_REPO" --json visibility --jq .visibility)"
  [ "$vis" = "PRIVATE" ] || die "$FULL_REPO ya existe y su visibilidad es $vis. No se publicará nada en él."
  if gh api "repos/$FULL_REPO/commits?per_page=1" >/dev/null 2>&1; then
    die "$FULL_REPO ya existe y tiene commits. Revísalo a mano antes de continuar."
  fi
  REPO_EXISTS=1
  warn "$FULL_REPO ya existe (privado y vacío): se reutilizará."
else
  ok "$FULL_REPO todavía no existe en GitHub"
fi

if [ "$CONTINUE" -eq 0 ]; then
  [ -f "$SRC_TAR" ] || die "No se encuentra $SRC_TAR"
  [ -f "$SRC_SQL" ] || die "No se encuentra $SRC_SQL"
  gzip -t "$SRC_TAR" 2>/dev/null || die "$SRC_TAR está dañado (gzip -t falló)."
  gzip -t "$SRC_SQL" 2>/dev/null || die "$SRC_SQL está dañado (gzip -t falló)."
  ok "Respaldos encontrados e íntegros"
  gzip -dc "$SRC_SQL" > "$WORK/schema_raw.sql"
  # Las filas de datos de mysqldump/pg_dump empiezan en la columna 0 (los INSERT indentados
  # pertenecen a cuerpos de triggers o procedimientos).
  data_stmts="$(grep -ciE '^(INSERT|REPLACE)[[:space:]]+INTO|^COPY[[:space:]].*FROM[[:space:]]+stdin' "$WORK/schema_raw.sql" || true)"
  if [ "$data_stmts" -gt 0 ]; then
    die "El esquema contiene $data_stmts sentencias con DATOS (INSERT/COPY). No es un esquema limpio y no se subirá.
       Genera uno sin datos, p. ej.: mysqldump --no-data --routines --triggers disponibles_db | gzip > schema_disponibles_db.sql.gz"
  fi
  ok "El esquema no contiene filas de datos"
  if [ -e "$DEST_DIR" ]; then
    [ -d "$DEST_DIR" ] || die "$DEST_DIR existe y no es un directorio."
    [ -z "$(ls -A "$DEST_DIR")" ] \
      || die "$DEST_DIR ya existe y no está vacío. Si lo preparó este script, usa --continuar; si no, muévelo."
    rmdir "$DEST_DIR"
  fi
else
  [ -d "$DEST_DIR" ] || die "--continuar necesita que exista $DEST_DIR"
  ok "Modo --continuar sobre $DEST_DIR"
fi

if [ "$CONTINUE" -eq 0 ]; then
  # -------------------------------------------------------------------------
  step "1/5 Espacio de trabajo y descompresión"
  # -------------------------------------------------------------------------
  PARENT="$(dirname "$DEST_DIR")"
  mkdir -p "$PARENT"

  # Bloquear path traversal: rutas absolutas o con componentes '..'.
  tar -tzf "$SRC_TAR" > "$WORK/listado.txt"
  if grep -Eq '(^/|(^|/)\.\.(/|$))' "$WORK/listado.txt"; then
    die "El tarball contiene rutas absolutas o '..'. Extracción abortada."
  fi
  info "Entradas en el tarball: $(count_lines "$WORK/listado.txt")"

  # Extraer en un directorio temporal del mismo volumen y moverlo después (operación atómica).
  STAGING="$(mktemp -d "$PARENT/.pasion-quito.extract.XXXXXX")"
  tar -xzf "$SRC_TAR" -C "$STAGING"

  # Si el tarball trae carpetas contenedoras (p. ej. pasion/ o home/x/public_html/), se aplanan
  # para que artisan y composer.json queden en la raíz del proyecto.
  ROOT="$STAGING"
  while [ ! -f "$ROOT/artisan" ] && [ ! -f "$ROOT/composer.json" ]; do
    entries="$(list_entries "$ROOT")"
    n="$(printf '%s' "$entries" | grep -c . || true)"
    if [ "$n" -eq 1 ] && [ -d "$ROOT/$entries" ] && [ ! -L "$ROOT/$entries" ]; then
      ROOT="$ROOT/$entries"
    else
      break
    fi
  done
  if [ ! -f "$ROOT/artisan" ] || [ ! -f "$ROOT/composer.json" ]; then
    warn "No se encontraron artisan y composer.json en la raíz extraída. Contenido:"
    list_entries "$ROOT" | head -20 | sed 's/^/      /' >&2
    confirm "¿Continuar con esta estructura como raíz del proyecto?" || die "Abortado por el usuario."
  fi
  [ "$ROOT" = "$STAGING" ] || info "Carpeta contenedora aplanada: ${ROOT#"$STAGING"/}"

  mv "$ROOT" "$DEST_DIR"
  if [ "$ROOT" = "$STAGING" ]; then STAGING=""; fi
  chmod 755 "$DEST_DIR"
  ok "Código extraído en $DEST_DIR"

  # Descartar historial git previo: podría contener credenciales de la etapa España.
  find "$DEST_DIR" \( -path "$DEST_DIR/vendor" -o -path "$DEST_DIR/node_modules" \) -prune \
    -o -name .git -print > "$WORK/gitdirs.txt"
  if [ -s "$WORK/gitdirs.txt" ]; then
    while IFS= read -r g; do
      rm -rf "$g"
      warn "Eliminado historial git previo: ${g#"$DEST_DIR"/} (sigue intacto dentro del tarball)"
    done < "$WORK/gitdirs.txt"
  fi
  find "$DEST_DIR" -name __MACOSX -type d -prune -exec rm -rf {} + 2>/dev/null || true

  # Esquema de base de datos -> database/sql/schema_limpio_quito.sql
  mkdir -p "$DEST_DIR/database/sql"
  tables="$(grep -ciE 'CREATE TABLE' "$WORK/schema_raw.sql" || true)"
  definers="$(grep -c 'DEFINER=' "$WORK/schema_raw.sql" || true)"
  autoinc="$(grep -cE ' AUTO_INCREMENT=[0-9]+' "$WORK/schema_raw.sql" || true)"
  # Sanitización: quitar DEFINER (usuario@host del servidor de España), contadores AUTO_INCREMENT
  # (revelan volumen de registros) y el host de la cabecera de mysqldump.
  cat > "$WORK/sanear.sed" <<'SED'
s/DEFINER=(`[^`]*`|'[^']*'|[A-Za-z0-9_.%-]+)@(`[^`]*`|'[^']*'|[A-Za-z0-9_.%-]+)[[:space:]]*//g
s/ AUTO_INCREMENT=[0-9]+//g
s/^-- Host: .*$/-- Host: [redactado]/
SED
  sed -E -f "$WORK/sanear.sed" "$WORK/schema_raw.sql" > "$DEST_DIR/$SCHEMA_REL"
  ok "Esquema en $SCHEMA_REL ($tables tablas; sin INSERT; $definers DEFINER y $autoinc AUTO_INCREMENT=N eliminados)"
  [ "$tables" -gt 0 ] || warn "El esquema no contiene ningún CREATE TABLE. Revísalo."
fi

cd "$DEST_DIR"

# ---------------------------------------------------------------------------
step "2/5 Blindaje: .env, .env.example y .gitignore"
# ---------------------------------------------------------------------------
if [ "$CONTINUE" -eq 0 ]; then
  if [ -f .env ]; then
    [ ! -e "$ENV_BACKUP" ] || die "Ya existe $ENV_BACKUP en el código extraído; no se sobrescribe."
    mv .env "$ENV_BACKUP"
    chmod 600 "$ENV_BACKUP"
    ok ".env renombrado a $ENV_BACKUP (permisos 600, fuera de git)"
  else
    warn "El código no trae .env: no hay credenciales históricas que preservar."
  fi
fi
find . -maxdepth 3 \( -path ./vendor -o -path ./node_modules \) -prune -o -name '.env*' -type f -print \
  | grep -vE '^\./\.env\.example$' | sed 's|^\./||' > "$WORK/envfiles.txt" || true
if [ -s "$WORK/envfiles.txt" ]; then
  info "Archivos de entorno presentes (quedarán ignorados): $(tr '\n' ' ' < "$WORK/envfiles.txt")"
fi

if [ "$CONTINUE" -eq 1 ] && [ -f .env.example ]; then
  ok ".env.example ya existe (modo --continuar): se conserva"
else
  # El .env.example se genera solo con NOMBRES de variables (del .env original y del .env.example
  # que trajera el código); los valores son vacíos o valores de prueba de una lista blanca.
  # Los comentarios se descartan porque a menudo contienen credenciales antiguas comentadas.
  cat > "$WORK/env_example.awk" <<'AWK'
BEGIN {
  d["APP_NAME"] = "\"Pasion Quito\""; d["APP_ENV"] = "local"; d["APP_DEBUG"] = "true"
  d["APP_URL"] = "http://localhost"; d["APP_TIMEZONE"] = "America/Guayaquil"; d["APP_LOCALE"] = "es"
  d["LOG_CHANNEL"] = "stack"; d["LOG_DEPRECATIONS_CHANNEL"] = "null"; d["LOG_LEVEL"] = "debug"
  d["DB_CONNECTION"] = "mysql"; d["DB_HOST"] = "127.0.0.1"; d["DB_PORT"] = "3306"
  d["DB_DATABASE"] = "pasion_quito"; d["DB_USERNAME"] = "pasion"
  d["BROADCAST_DRIVER"] = "log"; d["CACHE_DRIVER"] = "file"; d["FILESYSTEM_DISK"] = "local"
  d["FILESYSTEM_DRIVER"] = "local"; d["QUEUE_CONNECTION"] = "sync"; d["SESSION_DRIVER"] = "file"
  d["SESSION_LIFETIME"] = "120"; d["MEMCACHED_HOST"] = "127.0.0.1"
  d["REDIS_HOST"] = "127.0.0.1"; d["REDIS_PASSWORD"] = "null"; d["REDIS_PORT"] = "6379"
  d["MAIL_MAILER"] = "smtp"; d["MAIL_DRIVER"] = "smtp"; d["MAIL_HOST"] = "mailpit"; d["MAIL_PORT"] = "1025"
  d["MAIL_ENCRYPTION"] = "null"; d["MAIL_FROM_ADDRESS"] = "\"no-reply@example.com\""
  d["MAIL_FROM_NAME"] = "\"${APP_NAME}\""
  d["AWS_DEFAULT_REGION"] = "us-east-1"; d["AWS_USE_PATH_STYLE_ENDPOINT"] = "false"
  d["PUSHER_PORT"] = "443"; d["PUSHER_SCHEME"] = "https"; d["PUSHER_APP_CLUSTER"] = "mt1"
  d["VITE_APP_NAME"] = "\"${APP_NAME}\""; d["VITE_PUSHER_APP_KEY"] = "\"${PUSHER_APP_KEY}\""
  d["VITE_PUSHER_HOST"] = "\"${PUSHER_HOST}\""; d["VITE_PUSHER_PORT"] = "\"${PUSHER_PORT}\""
  d["VITE_PUSHER_SCHEME"] = "\"${PUSHER_SCHEME}\""; d["VITE_PUSHER_APP_CLUSTER"] = "\"${PUSHER_APP_CLUSTER}\""
  print "# Plantilla de entorno de Pasión Quito (sin credenciales)."
  print "# Uso: cp .env.example .env && php artisan key:generate   -> y completa los valores vacíos."
  print "# El .env real NUNCA se sube al repositorio."
  print ""
  blank = 1
}
/^[ \t]*$/ { if (FILENAME == ARGV[1] && !blank) { print ""; blank = 1 }; next }
{
  line = $0
  sub(/^[ \t]*export[ \t]+/, "", line)
  if (line !~ /^[A-Za-z_][A-Za-z0-9_]*[ \t]*=/) next
  key = line
  sub(/[ \t]*=.*$/, "", key)
  if (key in seen) next
  seen[key] = 1
  if (FILENAME != ARGV[1] && !extra) {
    if (!blank) print ""
    print "# Variables adicionales encontradas en el entorno original"
    extra = 1
  }
  if (key in d) print key "=" d[key]; else print key "="
  blank = 0
}
AWK
  if [ -f .env.example ]; then cp .env.example "$WORK/env.example.orig"; fi
  if [ -f .env.example ] && [ -f "$ENV_BACKUP" ]; then
    awk -f "$WORK/env_example.awk" "$WORK/env.example.orig" "$ENV_BACKUP" > .env.example
  elif [ -f .env.example ]; then
    awk -f "$WORK/env_example.awk" "$WORK/env.example.orig" > .env.example
  elif [ -f "$ENV_BACKUP" ]; then
    awk -f "$WORK/env_example.awk" "$ENV_BACKUP" > .env.example
  else
    cat > "$WORK/env.default" <<'ENV'
APP_NAME=
APP_ENV=
APP_KEY=
APP_DEBUG=
APP_URL=

LOG_CHANNEL=
LOG_DEPRECATIONS_CHANNEL=
LOG_LEVEL=

DB_CONNECTION=
DB_HOST=
DB_PORT=
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

BROADCAST_DRIVER=
CACHE_DRIVER=
FILESYSTEM_DISK=
QUEUE_CONNECTION=
SESSION_DRIVER=
SESSION_LIFETIME=

REDIS_HOST=
REDIS_PASSWORD=
REDIS_PORT=

MAIL_MAILER=
MAIL_HOST=
MAIL_PORT=
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=
MAIL_FROM_ADDRESS=
MAIL_FROM_NAME=
ENV
    awk -f "$WORK/env_example.awk" "$WORK/env.default" > .env.example
  fi
  ok ".env.example limpio generado ($(grep -cE '^[A-Za-z_]' .env.example || true) variables, sin valores reales)"
fi

if [ -f .gitignore ] && grep -qF "$GITIGNORE_MARK" .gitignore; then
  ok ".gitignore ya contiene el bloque de blindaje"
else
  # Se añade al final: en .gitignore la última regla gana, así que este bloque prevalece
  # sobre cualquier regla previa del código (p. ej. un '!.env').
  {
    if [ -s .gitignore ]; then printf '\n'; fi
    cat <<'GITIGNORE'
# >>> blindaje pasion-quito >>>
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.espana.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
*.dump.gz
*.sql.gz

# Endurecimiento adicional: entornos, llaves y credenciales
.env.*
!.env.example
auth.json
.htpasswd
*.pem
*.key
*.p12
*.pfx
id_rsa*
id_ed25519*

# Volcados, bases locales y respaldos comprimidos
*.sqlite
*.sqlite3
*.bak
*.zip
*.tar
*.tar.gz
*.tgz
*.rar
*.7z

# Datos de ejecución de Laravel (logs, sesiones, cachés y archivos subidos por usuarios)
*.log
/storage/logs/*
/storage/framework/cache/*
/storage/framework/sessions/*
/storage/framework/testing/*
/storage/framework/views/*
/storage/app/*
!/storage/app/public/
/storage/app/public/*
/storage/debugbar
!/storage/**/.gitignore
/public/build
/.phpunit.cache

# Sistema / editores
.DS_Store
._*
/.idea
/.vscode
/.fleet
# <<< blindaje pasion-quito <<<
GITIGNORE
  } >> .gitignore
  ok ".gitignore estricto configurado"
fi

# ---------------------------------------------------------------------------
step "3/5 Inicialización de git, escaneo de secretos y commit"
# ---------------------------------------------------------------------------
HAS_COMMIT=0
if [ -d .git ]; then
  if git rev-parse --verify -q HEAD >/dev/null; then
    if [ "$(git rev-list --count HEAD)" = "1" ] && [ "$(git log -1 --format=%s)" = "$COMMIT_MSG" ]; then
      HAS_COMMIT=1
      ok "El commit inicial ya existe (se intentará solo la publicación)"
    else
      die "El repositorio local ya tiene un historial distinto al esperado. Revísalo a mano."
    fi
  fi
else
  git init -b main >/dev/null 2>&1 || { git init >/dev/null; git symbolic-ref HEAD refs/heads/main; }
  ok "git init -b main"
fi
[ "$(git symbolic-ref --short HEAD)" = "main" ] || die "La rama actual no es main."

# Verificar que las reglas de ignorado funcionan de verdad.
for p in .env "$ENV_BACKUP" .env.backup .env.production vendor/autoload.php node_modules/x/index.js \
         storage/oauth-private.key backup.sql.gz db.dump.gz storage/logs/laravel.log; do
  git check-ignore -q --no-index "$p" || die "La regla de .gitignore para '$p' no funciona."
done
FORCE_ADD=""
for p in .env.example "$SCHEMA_REL"; do
  [ -e "$p" ] || { warn "No existe $p"; continue; }
  if git check-ignore -q --no-index "$p"; then
    warn "$p queda ignorado (¿.gitignore global?); se añadirá de forma explícita."
    FORCE_ADD="$FORCE_ADD $p"
  fi
done
ok "Reglas de .gitignore verificadas (.env, $ENV_BACKUP, vendor, node_modules, *.sql.gz...)"

if [ "$HAS_COMMIT" -eq 0 ]; then
  git read-tree --empty          # índice limpio: respeta reglas nuevas en una re-ejecución
  git add .
  for p in $FORCE_ADD; do git add -f -- "$p"; done
fi

git -c core.quotePath=false ls-files --cached > "$WORK/staged.txt"
[ -s "$WORK/staged.txt" ] || die "No hay archivos para el commit."
FINDINGS=0

# 3.1 Ningún archivo de entorno, llave o volcado sensible en el índice.
grep -E '(^|/)\.env($|\.)' "$WORK/staged.txt" | grep -vE '(^|/)\.env\.example$' > "$WORK/env_staged.txt" || true
if [ -s "$WORK/env_staged.txt" ]; then
  die "Hay archivos .env en el índice: $(tr '\n' ' ' < "$WORK/env_staged.txt")"
fi
grep -E '\.(pem|key|p12|pfx|sqlite3?)$|(^|/)(id_rsa|id_ed25519|auth\.json|\.htpasswd)' "$WORK/staged.txt" > "$WORK/keys_staged.txt" || true
if [ -s "$WORK/keys_staged.txt" ]; then
  die "Hay llaves/credenciales en el índice: $(tr '\n' ' ' < "$WORK/keys_staged.txt")"
fi
ok "Ni .env ni $ENV_BACKUP ni llaves en el commit"

# 3.2 Ningún otro .sql con datos (volcados olvidados con información de usuarios).
grep -iE '\.sql$' "$WORK/staged.txt" > "$WORK/sql_staged.txt" || true
if [ -s "$WORK/sql_staged.txt" ]; then
  while IFS= read -r f; do
    if grep -qiE '^(INSERT|REPLACE)[[:space:]]+INTO|^COPY[[:space:]].*FROM[[:space:]]+stdin' "$f"; then
      warn "Volcado con datos en el índice: $f"
      FINDINGS=$((FINDINGS + 1))
    fi
  done < "$WORK/sql_staged.txt"
fi

# 3.3 Valores reales del .env de España que aparezcan escritos en el código (config/*.php, etc.).
if [ -f "$ENV_BACKUP" ]; then
  cat > "$WORK/secretos.awk" <<'AWK'
/^[ \t]*(export[ \t]+)?[A-Za-z_][A-Za-z0-9_]*[ \t]*=/ {
  line = $0
  sub(/^[ \t]*(export[ \t]+)?/, "", line)
  key = line; sub(/[ \t]*=.*$/, "", key)
  val = line; sub(/^[^=]*=[ \t]*/, "", val)
  q = substr(val, 1, 1)
  if (q == "\"" || q == "\047") { val = substr(val, 2); i = index(val, q); if (i > 0) val = substr(val, 1, i - 1) }
  else { sub(/[ \t]+#.*$/, "", val); sub(/[ \t]+$/, "", val) }
  if (toupper(key) !~ /(KEY|SECRET|PASS|PWD|TOKEN|PRIVATE|DSN|AUTH|CREDENTIAL|SALT|WEBHOOK|SID|CLIENT_ID)/) next
  if (length(val) < 6) next
  lv = tolower(val)
  if (lv ~ /^(null|true|false|password|secret|homestead|laravel|localhost|changeme|example)$/) next
  if (val ~ /^[0-9]+$/ || val ~ /^\$\{/) next
  print val
}
AWK
  awk -f "$WORK/secretos.awk" "$ENV_BACKUP" | sort -u > "$WORK/secretos.txt"
  chmod 600 "$WORK/secretos.txt"
  if [ -s "$WORK/secretos.txt" ]; then
    git_grep_to "$WORK/hits_env.txt" -l -F -f "$WORK/secretos.txt"
    if [ -s "$WORK/hits_env.txt" ]; then
      warn "Credenciales del .env de España escritas en estos archivos (no se muestran los valores):"
      sed 's/^/      /' "$WORK/hits_env.txt" >&2
      FINDINGS=$((FINDINGS + $(count_lines "$WORK/hits_env.txt")))
    else
      ok "Ninguna de las $(count_lines "$WORK/secretos.txt") credenciales del .env de España aparece en el código"
    fi
  fi
fi

# 3.4 Patrones genéricos de secretos.
git_grep_to "$WORK/hits_regex.txt" -c -E \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e '(sk|rk)_live_[0-9A-Za-z]{20,}' \
  -e 'AIza[0-9A-Za-z_-]{35}' \
  -e 'xox[abprs]-[0-9A-Za-z-]{10,}' \
  -e 'gh[pousr]_[0-9A-Za-z]{36}' \
  -e 'github_pat_[0-9A-Za-z_]{22,}'
if [ -s "$WORK/hits_regex.txt" ]; then
  warn "Posibles secretos (archivo:coincidencias):"
  sed 's/^/      /' "$WORK/hits_regex.txt" >&2
  FINDINGS=$((FINDINGS + $(count_lines "$WORK/hits_regex.txt")))
else
  ok "Sin llaves privadas ni tokens con formato conocido"
fi

# 3.5 gitleaks, si está instalado.
if command -v gitleaks >/dev/null 2>&1; then
  gl_rc=0
  if gitleaks git --help >/dev/null 2>&1; then
    if [ "$HAS_COMMIT" -eq 1 ]; then gitleaks git --redact --no-banner . || gl_rc=$?
    else gitleaks git --pre-commit --staged --redact --no-banner . || gl_rc=$?; fi
  else
    if [ "$HAS_COMMIT" -eq 1 ]; then gitleaks detect --redact --no-banner || gl_rc=$?
    else gitleaks protect --staged --redact --no-banner || gl_rc=$?; fi
  fi
  if [ "$gl_rc" -eq 0 ]; then ok "gitleaks: sin hallazgos"; else warn "gitleaks reportó hallazgos"; FINDINGS=$((FINDINGS + 1)); fi
else
  warn "gitleaks no está instalado (recomendado: brew install gitleaks). Se usan solo los controles internos."
fi

# 3.6 Archivos grandes (GitHub rechaza > 100 MB) y resumen para revisión humana.
git -c core.quotePath=false ls-files -s | awk -F'\t' '{ split($1, m, " "); print m[2] " " $2 }' \
  | git cat-file --batch-check='%(objectsize) %(rest)' | sort -rn > "$WORK/sizes.txt"
awk '$1 > 100 * 1024 * 1024' "$WORK/sizes.txt" > "$WORK/huge.txt"
if [ -s "$WORK/huge.txt" ]; then die "Archivos > 100 MB (GitHub los rechaza): $(cut -d' ' -f2- "$WORK/huge.txt" | tr '\n' ' ')"; fi
total_mb="$(awk '{ s += $1 } END { printf "%.1f", s / 1048576 }' "$WORK/sizes.txt")"

grep -E '^storage/' "$WORK/staged.txt" | grep -vE '/\.gitignore$' > "$WORK/storage_staged.txt" || true
if [ -s "$WORK/storage_staged.txt" ]; then
  warn "Archivos de storage/ en el commit (revisa que no sean datos de usuarios):"
  head -15 "$WORK/storage_staged.txt" | sed 's/^/      /' >&2
fi

printf '\n  %sResumen del commit%s\n' "$B" "$N"
info "Archivos: $(count_lines "$WORK/staged.txt")   Tamaño: ${total_mb} MB"
info "Más grandes:"
head -5 "$WORK/sizes.txt" | awk '{ s = $1; $1 = ""; printf "      %8.1f KB %s\n", s / 1024, $0 }'
grep -iE '\.(jpe?g|png|gif|webp|heic|mp4|mov|avi|webm)$' "$WORK/staged.txt" \
  | awk -F/ '{ if (NF > 2) print $1 "/" $2; else if (NF == 2) print $1; else print "." }' \
  | sort | uniq -c | sort -rn | head -8 > "$WORK/media.txt" || true
if [ -s "$WORK/media.txt" ]; then
  info "Imágenes/vídeos por carpeta (comprueba que sean recursos del sitio y no fotos de usuarios):"
  sed 's/^/     /' "$WORK/media.txt"
fi
git -c core.quotePath=false status --ignored --porcelain | grep '^!!' | cut -c4- > "$WORK/ignored.txt" || true
info "Excluido por .gitignore ($(count_lines "$WORK/ignored.txt") rutas): $(head -12 "$WORK/ignored.txt" | tr '\n' ' ')"

if [ -f composer.json ]; then
  pkg_version() {
    grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" composer.json | head -1 \
      | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/' || true
  }
  lv="$(pkg_version 'laravel/framework')"
  vy="$(pkg_version 'tcg/voyager')"
  info "composer.json -> laravel/framework: ${lv:-?}   tcg/voyager: ${vy:-no encontrado}"
  major="$(printf '%s' "$lv" | sed -E 's/^[^0-9]*([0-9]+).*/\1/')"
  if [ "$major" != "10" ]; then
    warn "El mensaje del commit dice 'Laravel v10' pero composer.json declara '${lv:-?}'."
  fi
fi

if [ "$FINDINGS" -gt 0 ]; then
  if [ "${PASION_IGNORAR_HALLAZGOS:-0}" = "1" ]; then
    warn "$FINDINGS hallazgo(s) ignorados por PASION_IGNORAR_HALLAZGOS=1."
  else
    die "$FINDINGS hallazgo(s) de seguridad. No se ha hecho commit ni se ha publicado nada.
       Corrige los archivos indicados (mueve el valor a env('...') o añádelos a .gitignore) y ejecuta:
         bash $0 --continuar"
  fi
fi

if [ "$HAS_COMMIT" -eq 0 ]; then
  git commit -q -m "$COMMIT_MSG"
  ok "Commit inicial: $(git log -1 --format='%h %s')"
fi

# ---------------------------------------------------------------------------
step "4/5 Publicación en GitHub (repositorio PRIVADO)"
# ---------------------------------------------------------------------------
confirm "¿Crear $FULL_REPO como PRIVADO y hacer push de main?" \
  || die "Publicación cancelada. El repo local está listo; para publicar más tarde: bash $0 --continuar"

if [ "$REPO_EXISTS" -eq 1 ]; then
  proto="$(gh config get git_protocol -h github.com 2>/dev/null || true)"
  if [ "$proto" = "ssh" ]; then url="git@github.com:$FULL_REPO.git"; else url="https://github.com/$FULL_REPO.git"; fi
  if git remote get-url origin >/dev/null 2>&1; then git remote set-url origin "$url"; else git remote add origin "$url"; fi
  git push -u origin main
else
  if git remote get-url origin >/dev/null 2>&1; then
    die "Ya existe un remoto 'origin' ($(git remote get-url origin)). Elimínalo o revísalo antes de continuar."
  fi
  gh repo create "$FULL_REPO" --private --source=. --remote=origin --push
fi
ok "Push completado"

# ---------------------------------------------------------------------------
step "5/5 Verificación final"
# ---------------------------------------------------------------------------
read_repo() {
  gh repo view "$FULL_REPO" --json url,visibility,isPrivate \
    --jq '[.url, .visibility, (.isPrivate | tostring)] | @tsv'
}
IFS=$'\t' read -r R_URL R_VIS R_PRIV <<< "$(read_repo)"
if [ "$R_PRIV" != "true" ]; then
  warn "¡El repositorio NO es privado ($R_VIS)! Corrigiendo..."
  gh repo edit "$FULL_REPO" --visibility private --accept-visibility-change-consequences
  IFS=$'\t' read -r R_URL R_VIS R_PRIV <<< "$(read_repo)"
  [ "$R_PRIV" = "true" ] || die "No se pudo marcar $FULL_REPO como privado. Hazlo YA desde GitHub > Settings."
fi

LOCAL_SHA="$(git rev-parse HEAD)"
REMOTE_SHA=""
for _ in 1 2 3 4 5; do
  REMOTE_SHA="$(gh api "repos/$FULL_REPO/commits/main" --jq .sha 2>/dev/null || true)"
  [ "$REMOTE_SHA" = "$LOCAL_SHA" ] && break
  sleep 2
done
[ "$REMOTE_SHA" = "$LOCAL_SHA" ] || die "El commit remoto ($REMOTE_SHA) no coincide con el local ($LOCAL_SHA)."

for f in .env "$ENV_BACKUP"; do
  if gh api "repos/$FULL_REPO/contents/$f" >/dev/null 2>&1; then die "¡$f está en el repositorio remoto!"; fi
done

printf '\n%s  Repositorio remoto : %s%s\n' "$B" "$(git remote get-url origin)" "$N"
printf '%s  URL en GitHub      : %s%s\n' "$B" "$R_URL" "$N"
printf '%s  Visibilidad        : %s%s %s✔%s\n' "$B" "$R_VIS" "$N" "$G" "$N"
printf '%s  Rama / commit      : main @ %s%s\n' "$B" "${LOCAL_SHA:0:7}" "$N"
printf '%s  .env en remoto     : no%s %s✔%s\n' "$B" "$N" "$G" "$N"

cat <<EOF

Siguientes pasos recomendados:
  1. Crear el entorno de Quito:  cd "$DEST_DIR" && cp .env.example .env && php artisan key:generate
  2. Las credenciales de España quedan solo en $DEST_DIR/$ENV_BACKUP (chmod 600).
     Guárdalas en un gestor de contraseñas y rota las que sigan activas.
  3. Activar alertas de Dependabot:  gh api -X PUT repos/$FULL_REPO/vulnerability-alerts
EOF
