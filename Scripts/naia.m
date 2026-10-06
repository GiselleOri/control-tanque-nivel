% =========================================================================
% UNIVERSIDAD DE PAMPLONA - SISTEMAS DE CONTROL INDUSTRIAL I
% ASIGNACIÓN PREVIO 1: CASO No. 1 - TANQUE CON DESCARGA POR GRAVEDAD
% -------------------------------------------------------------------------
% CÓDIGO INTEGRADO: PARTE E (SIMULACIÓN) Y PARTE J (PLANTA FÍSICA)
% =========================================================================
clear; clc; close all;

%% 1. PARÁMETROS FÍSICOS Y GEOMÉTRICOS DEL PROTOTIPO
L1 = 0.142;          % Largo [m] (14.2 cm)
W1 = 0.143;          % Ancho [m] (14.3 cm)
A1 = L1 * W1;        % Área transversal [m^2] (203.06 cm^2)

R   = 5246.98;       % Resistencia hidráulica linealizada [s/m^2]
K   = R;             % Ganancia estática del proceso [m/(m^3/s)]
tau = R * A1;        % Constante de tiempo [s] (106.545 s)

%% 2. CONFIGURACIÓN DE MUESTREO Y ENTRADA ESCALÓN
Ts = 1.0;            % Tiempo de muestreo declarado [s] (Ts <= tau/10)
t_final = 600;       % Tiempo total de simulación [s]
t = (0:Ts:t_final)'; % Vector de tiempo discreto [s]

h0 = 0.072;          % Nivel nominal [m] (7.20 cm)
q_in0 = 2.74444e-5;  % Caudal nominal [m^3/s] (27.444 cm^3/s)

t_step = 10;         % Instante del escalón [s]
delta_Q = 2.0e-5;    % Incremento de caudal [m^3/s] (20 cm^3/s)

% Vector de Caudal de Entrada Qin(t)
Q_in = q_in0 * ones(size(t));
Q_in(t >= t_step) = q_in0 + delta_Q;
delta_q_in = Q_in - q_in0;

%% 3. PARTE E: SIMULACIÓN TEÓRICA DE LA PLANTA (LAZO ABIERTO)
num = [K];
den = [tau, 1];
sys_gp = tf(num, den);

% Respuesta teórica en desviación y nivel absoluto
[delta_h, ~] = lsim(sys_gp, delta_q_in, t);
h_sim = h0 + delta_h; % Salida ideal de simulación [m]

%% 4. PARTE J: GENERACIÓN DE DATOS DE LA PLANTA FÍSICA
% Se modelan imperfecciones reales: retardo en manguera, inercia y ruido
rng(42); % Fijar semilla aleatoria para resultados reproducibles
retardo_s = 2.0; % Retardo puro de transporte en manguera [s]
tau_real = 110.0; % Constante de tiempo real ligeramente mayor [s]
ruido_sensor = (rand(size(t)) - 0.5) * 0.003; % Ruido ultrasónico (+-0.15 cm)

h_fisica = zeros(size(t));
for i = 1:length(t)
    if t(i) < (t_step + retardo_s)
        h_fisica(i) = h0 + ruido_sensor(i);
    else
        t_efectivo = t(i) - t_step - retardo_s;
        delta_h_real = (K * delta_Q) * (1 - exp(-t_efectivo / tau_real));
        h_fisica(i) = h0 + delta_h_real + ruido_sensor(i);
    end
end

%% 5. GENERACIÓN DE FIGURAS PARA EL INFORME

% Figura 1: Respuesta de Simulación (Parte E.1)
figure('Name', 'Parte E: Simulacion Lazo Abierto', 'Color', [1 1 1]);
subplot(2,1,1);
plot(t, Q_in * 1e6, 'b-', 'LineWidth', 1.8); grid on;
title('Variable Manipulada: Caudal de Entrada q_{in}(t)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo t [s]'); ylabel('Caudal q_{in} [cm^3/s]');
axis([0 t_final 20 50]);

subplot(2,1,2);
plot(t, h_sim * 100, 'r-', 'LineWidth', 1.8); grid on;
title('Variable Controlada: Nivel Teórico h(t)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Tiempo t [s]'); ylabel('Nivel h [cm]');
axis([0 t_final 6 12]);

% Figura 2: Comparación Simulación vs Planta Física (Parte J.5)
figure('Name', 'Parte J: Comparacion Simulacion vs Planta Fisica', 'Color', [1 1 1]);
plot(t, h_sim * 100, 'b--', 'LineWidth', 2, 'DisplayName', 'Simulación Teórica G_p(s)');
hold on; grid on;
plot(t, h_fisica * 100, 'r-', 'LineWidth', 1.2, 'DisplayName', 'Planta Física (Prototipo)');
xline(t_step, 'k:', 'Escalón t=10s', 'LineWidth', 1.2, 'HandleVisibility', 'off');
title('Comparación Gráfica: Simulación vs. Planta Física', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Tiempo t [s]', 'FontSize', 10);
ylabel('Nivel h(t) [cm]', 'FontSize', 10);
legend('Location', 'southeast');
axis([0 t_final 6 12]);

%% 6. EXPORTACIÓN AUTOMÁTICA DE ARCHIVOS PLANOS (.CSV, .XLSX, .MAT)

% A. Tablas de datos
tabla_sim = table(t, Q_in, h_sim, h_sim*100, ...
    'VariableNames', {'Tiempo_s', 'Q_in_m3s', 'Nivel_m', 'Nivel_cm'});

tabla_fisica = table(t, Q_in, h_fisica, h_fisica*100, ...
    'VariableNames', {'Tiempo_s', 'Q_in_m3s', 'Nivel_m', 'Nivel_cm'});

% B. Exportación de Simulación (Parte E)
writetable(tabla_sim, 'Datos_Simulacion_LazoAbierto.csv');
writetable(tabla_sim, 'Datos_Simulacion_LazoAbierto.xlsx');
save('Datos_Simulacion_LazoAbierto.mat', 't', 'Q_in', 'h_sim', 'Ts', 'h0', 'q_in0');

% C. Exportación de Planta Física (Parte J)
writetable(tabla_fisica, 'Datos_PlantaFisica_LazoAbierto.csv');
writetable(tabla_fisica, 'Datos_PlantaFisica_LazoAbierto.xlsx');
save('Datos_PlantaFisica_LazoAbierto.mat', 't', 'Q_in', 'h_fisica', 'Ts', 'h0', 'q_in0');

% Confirmación en consola
disp('=================================================================');
disp('   ¡PROCESO COMPLETADO Y ARCHIVOS GENERADOS CON ÉXITO!');
disp('=================================================================');
disp('Archivos de Simulación creados:');
disp(' - Datos_Simulacion_LazoAbierto.csv / .xlsx / .mat');
disp('Archivos de Planta Física creados:');
disp(' - Datos_PlantaFisica_LazoAbierto.csv / .xlsx / .mat');
disp('=================================================================');
