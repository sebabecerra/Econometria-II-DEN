# Tarea 1 — Econometría II

Repositorio preparado para ejecutar la tarea con la base `NLS80V2.dta` en Google Colab.

## Contenido

- `Tarea_1_NLS80V2_Colab.ipynb`: notebook con las cinco respuestas.
- `data/NLS80V2.dta`: base utilizada.
- `requirements.txt`: librerías necesarias.

## Abrir directamente en Colab

1. Entra a [Google Colab](https://colab.research.google.com/).
2. Selecciona **GitHub** y busca `sebabecerra/Econometria-II-DEN`.
3. Abre `Tarea_1_NLS80V2_Colab.ipynb`.
4. Ejecuta las celdas en orden.

Si Colab no encuentra la base automáticamente, la primera celda mostrará una ventana para subir `data/NLS80V2.dta`.

## Resultados principales

- Retorno estimado de la educación manteniendo experiencia constante: `0.08383`.
- Efecto de un año adicional de educación a edad fija: `0.05822` log puntos.
- Efecto de la política de educación mínima de 12 años: `8.98` unidades de salario.
- Error estándar bootstrap del efecto: aproximadamente `1.31`.

Los resultados son predicciones del modelo MCO y requieren supuestos adicionales para interpretarse causalmente.
