% =========================================================================
% UNIVERSIDAD DE PAMPLONA - SISTEMAS DE CONTROL INDUSTRIAL I
% ASIGNACIÓN PREVIO 1: CASO No. 1 - TANQUE CON DESCARGA POR GRAVEDAD
% -------------------------------------------------------------------------
% PARTE E: SIMULACIÓN EN LAZO ABIERTO Y EXPORTACIÓN DE DATOS
% =========================================================================
clear; clc; close all;

%% 1. PARÁMETROS FÍSICOS Y GEOMÉTRICOS DEL PROTOTIPO (PUNTOS B Y C)
% Geometría del tanque superior (Tanque de proceso T1)
L1 = 0.142;          % Largo [m] (14.2 cm)
W1 = 0.143;          % Ancho [m] (14.3 cm)
A1 = L1 * W1;        % Área transversal [m^2] (203.06 cm^2)

% Propiedades hidráulicas linealizadas
R   = 5246.98;       % Resistencia hidráulica linealizada [s/m^2]
K   = R;             % Ganancia estática del proceso [m/(m^3/s)]
tau = R * A1;        % Constante de tiempo [s] (106.545 s)

%% 2. PARÁMETROS DE MUESTREO Y TIEMPO DE SIMULACIÓN
Ts = 1.0;            % Tiempo de muestreo declarado [s] (Cumple Ts <= tau/10)
t_final = 600;       % Tiempo total de simulación [s] (~5.6*tau)
t = (0:Ts:t_final)'; % Vector de tiempo discreto [s]

%% 3. DEFINICIÓN DEL PUNTO DE OPERACIÓN Y ENTRADA ESCALÓN
h0 = 0.072;          % Nivel nominal en estado estacionario [m] (7.20 cm)
q_in0 = 2.74444e-5;  % Caudal nominal de entrada [m^3/s] (27.444 cm^3/s)

% Definición del escalón en la variable manipulada en t = 10 s
t_step = 10;                     % Instante de aplicación del escalón [s]
delta_Q = 2.0e-5;                % Incremento del caudal [m^3/s] (20 cm^3/s)

% Caudal absoluto Q_in(t)
Q_in = q_in0 * ones(size(t));
Q_in(t >= t_step) = q_in0 + delta_Q;

% Variable manipulada en desviación Delta_Q(t)
delta_q_in = Q_in - q_in0;

%% 4. SIMULACIÓN DEL MODELO LINEALIZADO (FUNCIÓN DE TRANSFERENCIA)
% Gp(s) = K / (tau*s + 1)
num = [K];
den = [tau, 1];
sys_gp = tf(num, den);

% Respuesta en desviación Delta_h(t) ante el escalón Delta_Q(t)
[delta_h, ~] = lsim(sys_gp, delta_q_in, t);

% Salida absoluta del nivel h(t) [m]
h_out = h0 + delta_h;

%% 5. GENERACIÓN DE GRÁFICAS DE ENTRADA Y SALIDA CON EJES E IDENTIFICACIÓN
fig = figure('Name', 'Parte E: Simulacion Lazo Abierto', 'Color', [1 1 1]);

% Subplot 1: Variable Manipulada - Caudal de Entrada Qin(t)
subplot(2,1,1);
plot(t, Q_in * 1e6, 'b-', 'LineWidth', 1.8); grid on; hold on;
xline(t_step, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
title('Variable Manipulada: Caudal de Entrada q_{in}(t)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo t [s]', 'FontSize', 10);
ylabel('Caudal q_{in} [cm^3/s]', 'FontSize', 10);
axis([0 t_final 20 50]);

% Subplot 2: Variable Controlada - Altura de Agua h(t)
subplot(2,1,2);
plot(t, h_out * 100, 'r-', 'LineWidth', 1.8); grid on; hold on;
xline(t_step, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
yline(h0 * 100, 'k:', 'Punto de Operación (7.2 cm)', 'LineWidth', 1.1);
title('Variable Controlada: Nivel del Tanque h(t)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo t [s]', 'FontSize', 10);
ylabel('Nivel h [cm]', 'FontSize', 10);
axis([0 t_final 6 12]);

%% 6. EXPORTACIÓN DE ARCHIVOS PLANOS PARA IDENTIFICACIÓN PARAMÉTRICA
% Creación de la estructura en tabla de datos
% Columnas: [Tiempo_s, Caudal_Entrada_m3s, Nivel_m, Nivel_cm]
tabla_datos = table(t, Q_in, h_out, h_out*100, ...
    'VariableNames', {'Tiempo_s', 'Q_in_m3s', 'Nivel_m', 'Nivel_cm'});

% A. Exportación a Formato Excel (.xlsx)
writetable(tabla_datos, 'Datos_Simulacion_LazoAbierto.xlsx');

% B. Exportación a Formato CSV (.csv)
writetable(tabla_datos, 'Datos_Simulacion_LazoAbierto.csv');

% C. Exportación a Formato MATLAB Workspace (.mat)
save('Datos_Simulacion_LazoAbierto.mat', 't', 'Q_in', 'h_out', 'Ts', 'h0', 'q_in0');

% Confirmación en consola
disp('=================================================================');
disp('  SIMULACIÓN COMPLETADA Y ARCHIVOS EXPORTADOS EXITOSAMENTE');
disp('=================================================================');
disp(['Tiempo de muestreo declarado (Ts) : ', num2str(Ts), ' s']);
disp(['Muestras totales registradas      : ', num2str(length(t))]);
disp('Archivos generados en la carpeta de trabajo:');
disp(' 1. Datos_Simulacion_LazoAbierto.xlsx');
disp(' 2. Datos_Simulacion_LazoAbierto.csv');
disp(' 3. Datos_Simulacion_LazoAbierto.mat');
disp('=================================================================');
