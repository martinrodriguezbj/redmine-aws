#!/bin/bash

# --- Configuración ---
ANSIBLE_DIR="BETA-redmineAnsible"
INFRA_DIR="infra"
ANSIBLE_PLAYBOOK="playbook.yml"

# Activar entorno virtual de Ansible
echo ">> Activando entorno virtual de Ansible..."
source ./.venv/bin/activate || { echo "ERROR: No se pudo activar el entorno virtual de Ansible."; exit 1; }
echo ">> Entorno virtual activado."

# --Descomentar las siguientes dos lineas si  la clave SSH (si tienes passphrase) --
#echo ">> Iniciando agente SSH y añadiendo clave (si tienes passphrase)..."
#eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_ed25519 
if [ $? -ne 0 ]; then
    echo "ERROR: No se pudo añadir la clave SSH al agente. Asegúrate que la clave exista y la passphrase sea correcta (si aplica)."
    exit 1
fi
echo ">> Agente SSH configurado."

# --- Paso 1: Aprovisionar Infraestructura ---
echo "--- Paso 1: Aprovisionando infraestructura con Terraform ---"
cd "$INFRA_DIR" || { echo "ERROR: No se pudo cambiar al directorio $INFRA_DIR"; exit 1; }

# Inicializar Terraform (si no se ha hecho o si hay cambios en los providers)
echo ">> Inicializando Terraform..."
terraform init
if [ $? -ne 0 ]; then
Terraform    exit 1
fi

# Aplicar la configuración de Terraform
echo ">> Aplicando configuración de Terraform (creando EC2, RDS, etc.)..."
terraform apply -auto-approve
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la aplicación de Terraform."
    exit 1
fi

echo "--- Terraform ha terminado de aprovisionar la infraestructura. ---"

# --- Volver al directorio raíz del proyecto ---
cd ../ # Volver a 'redmine-aws/'

# --- Paso 2: Configurar Aplicación con Ansible ---
echo "--- Paso 2: Configurando Redmine con Ansible ---"
cd "$ANSIBLE_DIR" || { echo "ERROR: No se pudo cambiar al directorio $ANSIBLE_DIR"; exit 1; }

echo ">> Ejecutando Playbook de Ansible..."
# Ejecutamos el playbook. El inventario se lee de ansible.cfg
ansible-playbook "$ANSIBLE_PLAYBOOK" -vvv # -vvv para ver detalles de depuración
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la ejecución del Playbook de Ansible."
    exit 1
fi

echo "--- ¡Despliegue de Redmine completado exitosamente! ---"

# --- Opcional: Detener agente SSH si se inició aquí ---
# echo ">> Deteniendo agente SSH (si se inició por el script)..."
# ssh-agent -k