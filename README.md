Cambios conceptuales Parte 1→ Parte 2

Parte 1:
-Todo en una VM Vagrant Local.
-Base de datos MySQL instalada localmente con el rol de geerlingguy.mysql

Parte 2:
-EC2 en AWS: redmine corre acá
-RDS en AWS: base de datos gestionada (no instalamos MySQL con Ansible)
-Infraestructura creada 100% con OpenTofu (VPC, subredes, EC2, RDS, Sgs)
-Redmine sigue usando nuestro role de common + redmine + asdf + nginx igual que antes.


Comenzamos creando un directorio Infra/ para opentofu separado de nuestro Ansibe

entrega2/
├── ansible/    # Copia de nuestro repo actual (pero sin el rol de base local)
└── infra/      # Archivos tofu

En cuanto la carpeta de ansible (nuestro repo), fue necesario.
- Eliminar el role geerlingguy.mysql de roles.
- Eliminar el role geerlingguy.mysql del playbook.
- Quitar geerlingguy.mysql de requierements.txt.

Además, fue necesario modificar una de las dependencias de roles/common/tasks/main.yml.
Ya que el AMI de aws “ami-0779caf41f9ba54f0” no reconocia la dependencia libmysqlclient-dev, por lo que fue reemplazada por default-libmysqlclient-dev.
Nota: el usuario de este AMI es admin.

Luego. Cada vez que se levanta la infraestructura, es necesario modificar el inventory/hosts_ec2.ini haciendo referencia a la máquina. También es necesario modificar la variable “mysql_server” de vars.yml, con la dirección de la base de datos RDS.


En cuanto el directorio infra. Cuenta con lo siguiente:

infra
├── main.tf
├── provider.tf

Quizá se podría simplificar un poco mas, modularizar..

Puntos claves del mian.tf.

profile = "496318587878_onboard_IsbUsersPS" → corresponde a mi cuenta aws individual, hay que hacer una grupal..

public_key = file("~/.ssh/id_ed25519.pub") → hace referencia a mi clave pública. Esto debe ser reemplazado según la clave pública de cada uno.


Login SSH
ssh -i ~/.ssh/id_ed25519 admin@<IP>

En nuestro caso:
ssh -i ~/.ssh/id_ed25519 admin@54.157.27.106

Aprovisionamiento:
ansible-playbook -i inventory/hosts_ec2.ini playbook.yml 
