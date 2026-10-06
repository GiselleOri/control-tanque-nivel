% =========================================================================
% UNIVERSIDAD DE PAMPLONA - SISTEMAS DE CONTROL INDUSTRIAL I
% PARTE K: IDENTIFICACIÓN PARAMÉTRICA (SIMULACIÓN VS. PLANTA FÍSICA)
% =========================================================================
clear; clc; close all;

%% 1. CONSOLIDACIÓN DE DATOS ENTRADA - SALIDA
load('Datos_Simulacion_LazoAbierto.mat');
t_sim = t; Q_sim = Q_in; h_sim = h_sim;

load('Datos_PlantaFisica_LazoAbierto.mat');
t_fis = t; Q_fis = Q_in; h_fis = h_fisica;

% Conversión a variables de desviación respecto al punto de operación
% Entrada u(t) = Delta_Qin [cm^3/s], Salida y(t) = Delta_h [cm]
u_sim_desv = (Q_sim - q_in0) * 1e6;
y_sim_desv = (h_sim - h0) * 100;

u_fis_desv = (Q_fis - q_in0) * 1e6;
y_fis_desv = (h_fis - h0) * 100;

% Creación de objetos iddata para MATLAB System Identification
data_sim = iddata(y_sim_desv, u_sim_desv, Ts);
data_fis = iddata(y_fis_desv, u_fis_desv, Ts);

%% 2. IDENTIFICACIÓN PARAMÉTRICA (FOPDT Y SOPDT)

% --- Escenario 1: Simulación Teórica ---
fopdt_sim = tfest(data_sim, 1, 0, 0); % 1 polo, 0 ceros, sin retardo
sopdt_sim = tfest(data_sim, 2, 0, 0); % 2 polos, 0 ceros, sin retardo

% --- Escenario 2: Planta Física ---
fopdt_fis = tfest(data_fis, 1, 0, NaN); % 1 polo, 0 ceros, estimando retardo
sopdt_fis = tfest(data_fis, 2, 0, NaN); % 2 polos, 0 ceros, estimando retardo

%% 3. EVALUACIÓN Y CÁLCULO DE LA MÉTRICA IAE
% IAE = integral(|y_medida(t) - y_modelo(t)| dt)

% Simulación de respuestas de los modelos identificados
y_fopdt_sim = lsim(fopdt_sim, u_sim_desv, t_sim);
y_sopdt_sim = lsim(sopdt_sim, u_sim_desv, t_sim);

y_fopdt_fis = lsim(fopdt_fis, u_fis_desv, t_fis);
y_sopdt_fis = lsim(sopdt_fis, u_fis_desv, t_fis);

% Cálculo numérico del IAE por regla del trapecio
iae_fopdt_sim = trapz(t_sim, abs(y_sim_desv - y_fopdt_sim));
iae_sopdt_sim = trapz(t_sim, abs(y_sim_desv - y_sopdt_sim));

iae_fopdt_fis = trapz(t_fis, abs(y_fis_desv - y_fopdt_fis));
iae_sopdt_fis = trapz(t_fis, abs(y_fis_desv - y_sopdt_fis));

%% 4. PRESENTACIÓN DE RESULTADOS EN CONSOLA
disp('=================================================================');
disp('            RESULTADOS DE IDENTIFICACIÓN PARAMÉTRICA             ');
disp('=================================================================');
disp('ESCENARIO 1: DATA DE SIMULACIÓN');
disp(['FOPDT -> IAE: ', num2str(iae_fopdt_sim, '%.4f')]);
disp(['SOPDT -> IAE: ', num2str(iae_sopdt_sim, '%.4f')]);
disp('-----------------------------------------------------------------');
disp('ESCENARIO 2: DATA DE PLANTA FÍSICA');
disp(['FOPDT -> IAE: ', num2str(iae_fopdt_fis, '%.4f')]);
disp(['SOPDT -> IAE: ', num2str(iae_sopdt_fis, '%.4f')]);
disp('=================================================================');