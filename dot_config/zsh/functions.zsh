ports() {
  if [[ -n "$1" ]]; then
    lsof -i :"$1" -P -n \
      | awk 'NR==1 {printf "%-20s %-8s %-10s %-8s %s\n", "COMMAND", "PID", "USER", "PORT", "INFO"; next}
             {
               split($9,a,":");
               port=a[length(a)];
               printf "%-20s %-8s %-10s %-8s %s\n", $1, $2, $3, port, $10
             }'
  else
    lsof -i -P -n \
      | rg LISTEN \
      | awk 'NR==1 {printf "%-20s %-8s %-10s %-8s %s\n", "COMMAND", "PID", "USER", "PORT", "INFO"; next}
             {
               split($9,a,":");
               port=a[length(a)];
               printf "%-20s %-8s %-10s %-8s %s\n", $1, $2, $3, port, $10
             }'
  fi
}
killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local pid
  pid=$(lsof -ti :"$1")

  if [[ -z "$pid" ]]; then
    echo "No process found on port $1"
    return 1
  fi

  echo "Killing process $pid on port $1"
  kill -9 $pid
}
myip() {
  if [[ "$1" == "public" ]]; then
    curl -s ifconfig.me
    echo
  else
    local iface=$(route get default 2>/dev/null | awk '/interface: / {print $2}')
    ipconfig getifaddr "$iface"
  fi
}
docker-clean() {
  local mode=${1:-safe}

  echo "🧹 Docker cleanup mode: $mode"

  case "$mode" in
    safe)
      echo "➡️ Removing stopped containers..."
      docker container prune -f

      echo "➡️ Removing unused images (dangling only)..."
      docker image prune -f

      echo "➡️ Removing unused networks..."
      docker network prune -f
      ;;

    standard)
      echo "➡️ Removing stopped containers..."
      docker container prune -f

      echo "➡️ Removing ALL unused images..."
      docker image prune -a -f

      echo "➡️ Removing unused volumes..."
      docker volume prune -f

      echo "➡️ Removing unused networks..."
      docker network prune -f

      echo "➡️ Removing build cache..."
      docker builder prune -f
      ;;

    aggressive|all)
      echo "🔥 Full system prune (containers, images, volumes, networks)..."
      docker system prune -a --volumes -f
      ;;

    preview)
      echo "👀 Preview mode (no deletion)"
      docker system df
      ;;

    *)
      echo "❌ Unknown mode: $mode"
      echo "Usage: docker-clean [safe|standard|aggressive|preview]"
      return 1
      ;;
  esac

  echo "✅ Done!"
}
mkcd() {
  if [[ -z "$1" ]]; then
    echo "❌ Usage: mkcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
