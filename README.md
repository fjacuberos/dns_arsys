# Script para utilizar la API de Arsys para validar certificados solicitados con [acme.sh](https://github.com/acmesh-official/acme.sh)

La API de [arsys](https://www.arsys.es) permite gestionar las entradas DNS. Este script integra el uso de dicha API con el script de obtención de certificados *acme.sh*

La API es muy simple (imagino que la de partners/resellers será más completa) y sólo gestiona un dominio.

Al no tener zonas la identificación del dominio se hace vía parámetro de configuración. Es restrictivo pero la otra opción sería obtener todas las entradas de tipo A y ver la parte común; más complejo y no veo lo que aporta (repito, mi acceso es de cliente individual con un dominio).

# 1. Requisitos previos
- Una API KEY que nos autorice para acceder al dominio deseado. Se obtiene activando la opcion de API en la opción DNS del panel de control.
- Una instalación funcional de acme.sh
# 2. Instalación
Copiar el shell a la carpeta dnsapi de la instalación de acme.sh, por omisión en `~/.acme.sh/dnsapi`
Añadir en el fichero `account.conf` las líneas con nuestra API KEY y el dominio sobre el que da acceso:

```
ARSYS_Zone_ID='midominio.es'
ARSYS_API_KEY='Cadena_Obtenida_al_activar_la_API'
```
# 3. Uso
Un ejemplo de uso sería

```
acme.sh --issue --dns dns_arsys  -d test1.midominio.es
```

Se puede obtener una traza de ejecución en pantalla y en un fichero añadiendo los parámetros de debug

```
acme.sh --issue --dns dns_arsys  --debug 2 --log .acme.sh/salida.log --log-level 2 -d test1.midominio.es
```

Probado con dominio simple, múltiple y wildcard.

Más información  de como usar acme.sh en su [web](https://github.com/acmesh-official/acme.sh)
