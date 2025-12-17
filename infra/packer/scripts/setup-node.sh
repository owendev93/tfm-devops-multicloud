#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Inicio de configuración del nodo EKS personalizado"

# 1. Actualización básica del sistema
echo "[INFO] Actualizando paquetes del sistema..."
sudo yum update -y || sudo apt-get update -y || true

# 2. Instalación de herramientas de diagnóstico y utilidades
echo "[INFO] Instalando herramientas básicas (htop, jq, curl, wget)..."
if command -v yum &>/dev/null; then
  sudo yum install -y htop jq curl wget git
elif command -v apt-get &>/dev/null; then
  sudo apt-get install -y htop jq curl wget git
fi

# 3. Configuración básica de logging adicional (sin tocar configuración propia de EKS)
echo "[INFO] Creando directorio de logs personalizados..."
sudo mkdir -p /var/log/custom
sudo touch /var/log/custom/node-setup.log
sudo chown root:root /var/log/custom/node-setup.log

echo "[INFO] Guardando metadatos de la imagen..."
{
  echo "Imagen preparada para nodos EKS"
  echo "Fecha de construcción: $(date -u)"
  echo "Hostname inicial: $(hostname)"
} | sudo tee -a /var/log/custom/node-setup.log

# 4. Limpieza de paquetes
echo "[INFO] Limpiando paquetes innecesarios..."
if command -v yum &>/dev/null; then
  sudo yum autoremove -y || true
  sudo yum clean all -y || true
elif command -v apt-get &>/dev/null; then
  sudo apt-get autoremove -y || true
  sudo apt-get clean -y || true
fi

echo "[INFO] Configuración del nodo EKS personalizada finalizada correctamente."

