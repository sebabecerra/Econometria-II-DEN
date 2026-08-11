# Tarea 1 — Econometría II

Repositorio con la base `NLS80V2.dta` y el desarrollo completo de las cinco preguntas.

## Abrir en Google Colab

[![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/sebabecerra/Econometria-II-DEN/blob/main/Tarea_1_NLS80V2_Colab.ipynb)

Si Colab solicita la base, sube el archivo `data/NLS80V2.dta` desde el repositorio.

## Contenido

- `Tarea_1_NLS80V2_Colab.ipynb`: nueva versión completa y ejecutada.
- `data/NLS80V2.dta`: base utilizada.
- `requirements.txt`: librerías necesarias.

## Resultados principales

- Modelo MCO: 935 observaciones y R² de `0.1282`.
- Efecto promedio de un año adicional de educación a edad fija: `0.05822` log puntos.
- Política de educación mínima de 12 años: `0.01083` log puntos o `8.98` unidades de salario.
- Error estándar del efecto: `0.00124` clásico y `0.00116` robusto HC1.

Los resultados son predicciones del modelo MCO y requieren supuestos adicionales para interpretarse causalmente.
