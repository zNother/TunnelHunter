# TunnelHunter (Linux)

Herramienta para **detectar, analizar y correlacionar artefactos de uso de VPN** en sistemas Linux utilizando técnicas forenses.

---

## Funcionalidades

- Detección de interfaces VPN (tun/tap/wg)  
- Análisis de procesos y servicios activos  
- Inspección de rutas de red  
- Detección de anomalías en DNS  
- Reconstrucción de timeline (journalctl)  
- Detección de posibles manipulaciones de logs (anti-forensics)  
- Correlación de actividad de usuario (historial de Bash)  
- Detección de software VPN instalado  
- Inspección de conexiones activas  
- Verificación de IP pública  
- Sistema de scoring forense para evaluar probabilidad de uso de VPN  

---

## Casos de uso

- Investigaciones forenses digitales  
- Respuesta ante incidentes (DFIR)  
- Auditorías de sistemas  
- Análisis de comportamiento de red sospechoso  

---

## Limitaciones

- No garantiza la detección de VPNs ocultas o muy avanzadas  
- Técnicas de anti-forensics avanzadas pueden evadir la detección  
- VPNs que solo viven en memoria requieren herramientas de análisis de RAM  

---

## Uso

```bash
chmod +x vpn_forensic.sh
sudo ./vpn_forensic.sh
