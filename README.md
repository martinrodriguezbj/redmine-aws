# 🚀 Despliegue Automatizado de Redmine: De Local a la Nube AWS

Este repositorio contiene el código para el despliegue automatizado de Redmine, mostrando su evolución desde un entorno local basado en Vagrant hasta una infraestructura robusta y automatizada en Amazon Web Services (AWS) utilizando una combinación de OpenTofu y Ansible.

<br/>

# ✨ Visión General del Proyecto

El proyecto aborda el desafío de desplegar Redmine de manera eficiente y consistente. Partiendo de una configuración manual con limitaciones, se ha evolucionado hacia una solución completamente automatizada basada en la Infraestructura como Código (IaC).

## Objetivos Clave:

- **Automatización Total**: Instalar y configurar Redmine de forma automatizada.

- **Despliegue en la Nube**: Realizar despliegues consistentes y fiables de Redmine en AWS.

<br/>

# 📂 Estructura del Repositorio

Este repositorio contiene el código de ambas partes del proyecto, organizado en dos directorios principales:

- `BETA-redmineAnsible/`: Contiene el código de la parte 1 (despliegue local de Redmine en una VM Vagrant).

- `infra/`: Contiene el código de la parte 2 (despliegue de infraestructura y Redmine en AWS).

<br/>

# 🚀 Guía Rápida de Despliegue

1. Prepara el entorno virtual

Desde la raíz del proyecto (redmine-aws/) ejecuta:

```bash
python3 -m venv .venv
source ./.venv/bin/activate
pip install boto3 botocore ansible # Instalar Ansible aquí también
deactivate # Salir del venv para que el script deploy-redmine.sh lo active
```

<br/>

1. Dar Permisos de Ejecución a los Scripts `deploy-redmine.sh` y `destroy.sh`:

```bash
chmod +x deploy-redmine.sh
chmod +x destroy.sh
```

2. Ejecutar el Script `deploy-redmine.sh`:

```bash
./deploy-redmine.sh
```

<br/>

# 🔑 Acceso SSH

Conéctate a tu instancia EC2 usando tu clave privada y la IP obtenida:

    ```bash
    ssh -i ~/.ssh/id_ed25519 admin@<IP_PUBLICA_EC2>
    ```

<br/>

# 🧹 Limpieza

Para destruir todos los recursos de AWS creados ejecutar el Script `destroy.sh`:

```bash
./destroy.sh
```

> Se requerirá confirmación manual, escribe `yes` cuando se te solicite.
