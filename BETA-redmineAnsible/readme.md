Guía de Instalación y Aprovisionamiento - redmine-ansible

Preparación del Entorno (Configuración Inicial)
Estas son las acciones que realizaron para preparar el entorno y configurar Ansible con Poetry y Python 3.11:

Inicializar Poetry en el proyecto (se crea pyproject.toml):
poetry init -n

Instalar Ansible versión compatible:
poetry add ansible@~11.0.0

Asociar el entorno virtual de Poetry con la versión actual de Python 3.11:
poetry env use python

Activar el entorno virtual de Poetry:
eval $(poetry env activate)

Verificar la versión de Ansible para confirmar la instalación:
ansible --version

--------------------------------

Uso: Ejecutar la Máquina Virtual y Aprovisionar Redmine
Ya con el entorno configurado, estos son los pasos para iniciar y aprovisionar la máquina virtual que corre Redmine:

Iniciar la VM con Vagrant:
vagrant up

Aprovisionar la VM con Ansible (este paso ejecuta los roles y tareas para instalar y configurar Redmine, pero aun no es idempotente):
vagrant provision

Acceso a la Aplicación
Puma (Servidor de aplicaciones Ruby/Rails) estará disponible en:
http://192.168.56.101:3001/

Nginx (Servidor web proxy reverso configurado) estará disponible en:
http://192.168.56.101/
