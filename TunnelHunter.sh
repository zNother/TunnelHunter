#!/bin/bash
REPORT="vpn_report_$(date +%Y%m%d_%H%M%S).log"
SCORE=0

# Colores
R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; N="\e[0m"

log(){ echo -e "$1" | tee -a "$REPORT"; }

info(){ log "${B}[INFO]${N} $1"; }
ok(){ log "${G}[OK]${N} $1"; }
warn(){ log "${Y}[WARN]${N} $1"; SCORE=$((SCORE+1)); }
crit(){ log "${R}[CRITICAL]${N} $1"; SCORE=$((SCORE+2)); }

section(){
  echo "" | tee -a "$REPORT"
  log "======== $1 ========"
}

echo "Generando informe: $REPORT"
echo "===== VPN FORENSIC REPORT =====" > "$REPORT"
echo "Fecha: $(date)" >> "$REPORT"

section "IP PUBLICA"

PUBIP=$(curl -s ifconfig.me)

log "IP actual: $PUBIP"

if [[ "$PUBIP" =~ ^10\.|^172\.|^192\.168 ]]; then
  warn "IP privada detectada (posible túnel)"
else
  ok "IP pública válida"
fi

section "INTERFACES"

ip -brief a | tee -a "$REPORT"

if ip a | grep -qE "tun|tap|wg|ppp"; then
  crit "Interfaces VPN detectadas"
fi

section "PROCESOS"

PROC=$(ps aux | grep -Ei "openvpn|wg|wireguard|vpn" | grep -v grep)

if [ -n "$PROC" ]; then
  crit "Procesos sospechosos"
  log "$PROC"
else
  ok "Sin procesos VPN"
fi

section "RUTAS"

ip route | tee -a "$REPORT"

if ip route | grep -qE "tun|wg"; then
  warn "Tráfico redirigido"
fi

section "DNS"

cat /etc/resolv.conf | tee -a "$REPORT"

if grep -qE "10\.|100\.|172\." /etc/resolv.conf; then
  warn "DNS interno detectado"
fi

section "CONEXIONES ACTIVAS"

ss -tulnp | tee -a "$REPORT"

if ss -tulnp | grep -qi vpn; then
  crit "Sockets relacionados con VPN"
fi

section "TIMELINE (7 DIAS)"

journalctl --since "7 days ago" 2>/dev/null | \
grep -iE "vpn|tun|wireguard|openvpn" | tail -n 30 | tee -a "$REPORT"

section "ANTI-FORENSICS"

LOGSIZE=$(stat -c%s /var/log/syslog 2>/dev/null)
UPTIME=$(uptime -p)

log "Tamaño syslog: $LOGSIZE"
log "Uptime: $UPTIME"

if [ "$LOGSIZE" -lt 50000 ]; then
  warn "Logs pequeños (posible limpieza)"
fi

section "ARTEFACTOS"

find /etc /home -type f -iname "*vpn*" 2>/dev/null | head -n 20 | tee -a "$REPORT"

section "HISTORIAL"

grep -iE "vpn|openvpn|wg" ~/.bash_history 2>/dev/null | tail -n 10 | tee -a "$REPORT"

section "SOFTWARE"

dpkg -l 2>/dev/null | grep -iE "vpn|wireguard|openvpn" | tee -a "$REPORT"

section "VEREDICTO FINAL"

if [ $SCORE -le 2 ]; then
  RES="SIN EVIDENCIA"
elif [ $SCORE -le 5 ]; then
  RES="INDICIOS"
elif [ $SCORE -le 9 ]; then
  RES="USO PROBABLE"
else
  RES="USO CONFIRMADO"
fi

log "Resultado: $RES"
log "Score: $SCORE"

echo ""
echo -e "${B}Informe generado:${N} $REPORT"