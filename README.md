# Sistema de Registro de Estudiantes - Práctica I

Este repositorio contiene la implementación de un sistema de gestión de entrada y salida de estudiantes para la asignatura de **Programación de Lenguajes de Programación**. El objetivo es comparar el comportamiento de un mismo problema bajo dos paradigmas diferentes: **Funcional (Haskell)** y **Lógico (Prolog)**.

## 📝 Descripción
El sistema permite controlar el acceso a la universidad registrando identificaciones y tiempos de permanencia, con persistencia de datos en un archivo de texto.

### Funcionalidades:
1. **Check In:** Registro de ID y hora de entrada.
2. **Búsqueda por ID:** Localización de estudiantes activos.
3. **Cálculo de Tiempo:** Determinación de minutos de estancia.
4. **Listado (Carga de archivo):** Persistencia mediante `University.txt`.
5. **Check Out:** Registro de salida y actualización del estado.

---

## 📂 Estructura del Proyecto
* `/haskellProject`: Código fuente en Haskell (.hs).
* `/PracticaProlog`: Código fuente en Prolog (.pl).
* `University.txt`: Base de datos compartida (formato plano).

---
