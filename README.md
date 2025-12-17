# Trabajo de Fin de Máster – Arquitectura DevOps Multinube  
**Máster Universitario en DevOps – UNIR**

---

## Descripción general

Este repositorio contiene el desarrollo técnico, la infraestructura como código, la automatización de configuración, los mecanismos de despliegue y el diseño del pipeline CI/CD asociados al **Trabajo de Fin de Máster (TFM)** del Máster Universitario en DevOps de la Universidad Internacional de La Rioja (UNIR).

El proyecto se centra en el **diseño e implementación de una arquitectura DevOps multinube**, orientada al despliegue seguro, automatizado y controlado de aplicaciones contenerizadas sobre **Kubernetes**, utilizando **AWS EKS y Azure AKS** como plataformas de ejecución.

El enfoque del trabajo prioriza:

- Automatización end-to-end  
- Seguridad desde el diseño (*shift-left security*)  
- Reproducibilidad  
- Control de versiones  
- Trazabilidad académica entre objetivos, código y evidencias  

---

## Objetivo general

Diseñar e implementar una arquitectura DevOps multinube que permita el despliegue automatizado, seguro y controlado de aplicaciones contenerizadas sobre Kubernetes, aplicando buenas prácticas de Infraestructura como Código, CI/CD, seguridad y gobierno.

---

## Objetivos específicos

- Definir una arquitectura basada en Kubernetes orientada a entornos multinube.  
- Implementar Infraestructura como Código mediante **Terraform** y **Packer**.  
- Automatizar la configuración de nodos y servicios mediante **Ansible**.  
- Diseñar un pipeline **CI/CD** seguro utilizando **Jenkins**.  
- Incorporar políticas de seguridad como código mediante **Kyverno**.  
- Gestionar control de accesos mediante **RBAC** por entorno.  
- Preparar despliegues en **AWS EKS** y **Azure AKS**.  
- Garantizar trazabilidad, versionado y control de cambios del proyecto.  

---

## Alcance actual del proyecto

El estado actual del proyecto corresponde a una **fase avanzada de diseño e implementación de la plataforma DevOps**, con los siguientes elementos **ya desarrollados**:

- ✔ Infraestructura como Código (AWS y Azure)  
- ✔ Automatización de configuración de nodos Kubernetes  
- ✔ Diseño completo del pipeline CI/CD  
- ✔ Despliegue Kubernetes mediante Helm  
- ✔ Políticas de seguridad y control de acceso  
- ✔ Control de versiones y estructura académica del repositorio  

Quedan **fuera de alcance temporal** en esta fase:

- Implementación del Dockerfile y aplicación de ejemplo  
- Activación real del build de imágenes  
- Observabilidad avanzada y métricas finales  

Estas fases se abordarán en iteraciones posteriores del proyecto.

---

## Estructura del repositorio

El repositorio está organizado por capas, siguiendo un enfoque académico y profesional:

├── cicd/ # Pipeline CI/CD (Jenkins)
│ └── Jenkinsfile
│
├── config/ # Automatización de configuración
│ └── ansible/
│ ├── inventories/ # Inventarios AWS, Azure y local
│ ├── playbooks/ # Playbooks de configuración
│ └── roles/ # Roles Ansible reutilizables
│
├── infra/ # Infraestructura como Código
│ ├── packer/ # Construcción de imágenes base
│ └── terraform/ # Provisión de infraestructura AWS / Azure
│
├── deploy/ # Despliegue en Kubernetes
│ ├── helm/ # Charts Helm y values por proveedor
│ └── policies/ # Seguridad y control
│ ├── kyverno/
│ └── rbac/
│
├── docs/ # Documentación técnica (en desarrollo)
├── annexes/ # Anexos académicos y trazabilidad (en desarrollo)
│
├── README.md
├── LICENSE
└── .gitignore


---

## Infraestructura como Código

La provisión de infraestructura se realiza mediante:

### Terraform
- Creación de clústeres **EKS** y **AKS**  
- Definición de redes, nodos y dependencias  
- Uso de módulos reutilizables  

### Packer
- Construcción de imágenes base para nodos  
- Preparación de entornos homogéneos y reproducibles  

Esta capa permite reconstruir la infraestructura de forma determinística en ambos proveedores de nube.

---

## Automatización de configuración

La configuración de los nodos y servicios se realiza mediante **Ansible**, utilizando:

- Inventarios separados por proveedor (AWS / Azure)  
- Roles reutilizables para:
  - configuración base  
  - nodos Kubernetes  
  - servicios de monitorización  
- Playbooks orquestados para la preparación completa del entorno  

Este enfoque garantiza consistencia y reduce configuración manual.

---

## Despliegue en Kubernetes

El despliegue de aplicaciones se gestiona mediante:

- **Helm**
  - Chart genérico ubicado en `deploy/helm/apps`
  - Values específicos por proveedor (EKS / AKS)
- **Namespaces separados** por entorno (`staging` / `producción`)

Los despliegues están preparados para realizarse **por digest**, garantizando inmutabilidad.

---

## Seguridad y control

El proyecto incorpora seguridad como parte integral del diseño:

### Kyverno
- Restricción de imágenes sin digest  
- Bloqueo del uso de la etiqueta `latest`  
- Control de registros permitidos  
- Preparación para verificación de firmas  

### RBAC
- Definición de roles y permisos por entorno  
- Separación clara entre `staging` y `producción`  

Estas políticas refuerzan el gobierno del clúster y la seguridad operativa.

---

## Pipeline CI/CD

El pipeline CI/CD se implementa con **Jenkins** y contempla:

- Control de versiones y metadatos de build  
- Gates de seguridad:
  - análisis estático (SAST)  
  - análisis de dependencias (SCA)  
  - escaneo de secretos  
  - escaneo de imágenes  
  - pruebas dinámicas (DAST)  
- Generación de SBOM  
- Firma de imágenes (seguridad de la supply chain)  
- Despliegue multinube en EKS y AKS  
- Promoción a producción con aprobación manual  
- Archivado de evidencias para trazabilidad  

> **Nota:**  
> La construcción de la imagen Docker está definida a nivel de pipeline, pero su implementación se abordará en una fase posterior del proyecto.

---

## Metodología y enfoque

El desarrollo sigue un enfoque incremental alineado con principios DevOps:

- Automatización progresiva  
- Seguridad desde el diseño  
- Reproducibilidad de entornos  
- Versionado y control de cambios  
- Mejora continua basada en iteraciones  

---

## Estado del proyecto

| Componente                          | Estado |
|-----------------------------------|--------|
| Estructura del repositorio        | ✔ Completa |
| Infraestructura como Código       | ✔ Implementada |
| Automatización con Ansible        | ✔ Implementada |
| Pipeline CI/CD                    | ✔ Diseñado y consolidado |
| Despliegue Kubernetes             | ✔ Preparado |
| Seguridad (Kyverno / RBAC)        | ✔ Implementada |
| Dockerfile / App ejemplo          | ⏳ Pendiente |
| Observabilidad avanzada           | ⏳ Pendiente |
| Documentación y anexos finales    | ⏳ En progreso |

---

## Autor

**Owen Puerta Sauto**  
Máster Universitario en DevOps  
Universidad Internacional de La Rioja (UNIR)

---

## Licencia

Este proyecto se distribuye bajo licencia **MIT**, salvo indicación contraria.
