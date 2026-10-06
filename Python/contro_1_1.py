
import matplotlib.pyplot as plt
import numpy as np

# 1. Configuración de la figura
plt.figure(figsize=(8, 5.5), dpi=300)

# 2. Parámetros dinámicos del sistema
tau = 106.5452
pole_real = -1.0 / tau
pole_imag = 0.0

# 3. Dibujar ejes cartesianos del plano s
plt.axhline(0, color='black', linewidth=1.2, linestyle='--')
plt.axvline(
    0, 
    color='red', 
    linewidth=1.5, 
    label='Eje Imaginario jω'
)

# 4. Sombrear Semi-Plano Izquierdo (SPI)
plt.axvspan(
    -0.025, 0, 
    color='green', 
    alpha=0.12, 
    label='SPI — Región Estable'
)

# 5. Marcador del polo real de la planta
plt.plot(
    pole_real, pole_imag, 
    'x', 
    color='darkred', 
    markersize=14, 
    markeredgewidth=3,
    label='Polo: s1 = -0.009386 rad/s'
)

# 6. Anotación en la gráfica
texto_box = (
    "Polo Real Físico\n"
    "s1 = -0.009386 rad/s\n"
    "(τ = 106.55 s)\n"
    "Sistema BIBO Estable"
)

plt.annotate(
    texto_box,
    xy=(pole_real, 0.0),
    xytext=(-0.021, 0.005),
    arrowprops=dict(
        facecolor='black', 
        shrink=0.08, 
        width=1.2, 
        headwidth=7
    ),
    fontsize=9.5,
    bbox=dict(
        boxstyle="round,pad=0.4", 
        fc="white", 
        ec="darkred", 
        lw=1.5
    )
)

# 7. Formato de ejes, títulos y leyenda
plt.xlim([-0.025, 0.010])
plt.ylim([-0.015, 0.015])

plt.xlabel(
    'Eje Real σ (rad/s) — Amortiguamiento', 
    fontsize=10.5, 
    fontweight='bold'
)
plt.ylabel(
    'Eje Imaginario jω (rad/s) — Frecuencia', 
    fontsize=10.5, 
    fontweight='bold'
)
plt.title(
    'Ubicación de Polos en el Plano Complejo s\n'
    'Sistema Hidráulico de Nivel de Primer Orden',
    fontsize=11.5, 
    fontweight='bold', 
    pad=10
)

plt.grid(True, linestyle=':', alpha=0.7)
plt.legend(
    loc='upper right', 
    frameon=True, 
    facecolor='white', 
    framealpha=0.9, 
    fontsize=8.5
)

plt.tight_layout()

# 8. Guardar la imagen
plt.savefig('mapa_polos_tanque.png', dpi=300)
plt.show()
