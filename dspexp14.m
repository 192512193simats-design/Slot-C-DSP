
clear; clc; close all;

%% 1. PARAMETER DEFINITIONS
fc_carrier = 28e9;       % Carrier Frequency (28 GHz)
Fs_in = 1000e6;          % Input Sampling Frequency (1000 MHz)
M = 4;                   % Decimation Factor
L = 2;                   % Interpolation Factor

Fs_dec = Fs_in / M;      % Decimated Sampling Frequency (250 MHz)
Fs_out = Fs_dec * L;     % Interpolated Output Sampling Frequency (500 MHz)

N_samples = 4000;
t_in = (0:N_samples-1) / Fs_in;

% Generate 5G-like Multitone Baseband Signal
f1 = 15e6;               % 15 MHz component
f2 = 35e6;               % 35 MHz component

x_in = sin(2*pi*f1*t_in) + 0.5*cos(2*pi*f2*t_in);


%% 2. DECIMATION STAGE (ANTI-ALIASING FILTER + DOWNSAMPLING)

N_fir = 60;              % FIR Filter Order

% Normalized Cutoff Frequency
fc_dec = (Fs_dec/2) / (Fs_in/2);

% Design Anti-Aliasing FIR Low-Pass Filter
b_dec = fir1(N_fir, fc_dec, 'low');

% Apply Anti-Aliasing Filter
x_filtered_dec = filter(b_dec, 1, x_in);

% Downsampling by Factor M
x_dec = x_filtered_dec(1:M:end);


%% 3. INTERPOLATION STAGE (UPSAMPLING + ANTI-IMAGING FILTER)

% Upsampling by Factor L
x_up = zeros(1, length(x_dec)*L);
x_up(1:L:end) = x_dec;

% Normalized Cutoff Frequency
fc_interp = (Fs_dec/2) / (Fs_out/2);

% Design Anti-Imaging FIR Low-Pass Filter
b_interp = fir1(N_fir, fc_interp, 'low');

% Apply Anti-Imaging Filter
x_out = L * filter(b_interp, 1, x_up);


%% 4. PERFORMANCE METRICS

% Frequency Response of Anti-Aliasing Filter
[H, f] = freqz(b_dec, 1, 8192, Fs_in);

H_mag_db = 20*log10(abs(H) + eps);

% Passband and Stopband Regions
pb_idx = f <= (Fs_dec/2 * 0.8);
sb_idx = f >= (Fs_dec/2);

% Calculate Passband Ripple
passband_ripple = max(H_mag_db(pb_idx)) - min(H_mag_db(pb_idx));

% Calculate Stopband Attenuation
stopband_atten = -max(H_mag_db(sb_idx));


%% 5. COMMAND WINDOW DISPLAY

fprintf('========================================================\n');
fprintf(' EXPERIMENT 14: 5G mmWave MULTIRATE PROCESSING RESULTS\n');
fprintf('========================================================\n');

fprintf('Carrier Frequency: %.2f GHz\n', fc_carrier/1e9);
fprintf('Input Sampling Rate: %.2f MHz\n', Fs_in/1e6);
fprintf('Decimation Factor (M): %d\n', M);
fprintf('Downsampled Sampling Rate: %.2f MHz\n\n', Fs_dec/1e6);

fprintf('Signal Parameters:\n');
fprintf(' - Original Sequence Length: %d samples\n', length(x_in));
fprintf(' - Downsampled Sequence Length: %d samples\n', length(x_dec));
fprintf(' - Interpolated Sequence Length: %d samples\n', length(x_out));

fprintf(' - Passband Ripple: %.2f dB\n', passband_ripple);
fprintf(' - Stopband Attenuation: %.2f dB\n\n', stopband_atten);

fprintf('Output Sampling Rate: %.2f MHz\n', Fs_out/1e6);

fprintf('Status: 5G mmWave Baseband Multirate Processing Complete.\n');

fprintf('========================================================\n');


%% 6. VISUALIZATION

Nfft = 8192;

% Original Signal Spectrum
[X_in, f_in] = freqz(x_in, 1, Nfft, Fs_in);

% Decimated Signal Spectrum
[X_dec, f_dec] = freqz(x_dec, 1, Nfft, Fs_dec);

% Interpolated Signal Spectrum
[X_out, f_out] = freqz(x_out, 1, Nfft, Fs_out);

% Normalize Spectra
X_in_db = 20*log10(abs(X_in)/max(abs(X_in)) + eps);
X_dec_db = 20*log10(abs(X_dec)/max(abs(X_dec)) + eps);
X_out_db = 20*log10(abs(X_out)/max(abs(X_out)) + eps);


%% 7. PLOT RESULTS

figure('Name', 'Experiment 14: 5G mmWave Multirate Processing', ...
       'NumberTitle', 'off');

% Original Signal
subplot(3,1,1);

plot(f_in/1e6, X_in_db, 'b', 'LineWidth', 1.2);
grid on;

title('1. Original Baseband Signal Spectrum (Fs = 1000 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_in/2/1e6]);
ylim([-80 5]);


% Decimated Signal
subplot(3,1,2);

plot(f_dec/1e6, X_dec_db, 'r', 'LineWidth', 1.2);
grid on;

title('2. Decimated Signal Spectrum (M = 4, Fs = 250 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_dec/2/1e6]);
ylim([-80 5]);


% Interpolated Signal
subplot(3,1,3);

plot(f_out/1e6, X_out_db, 'm', 'LineWidth', 1.2);
grid on;

title('3. Interpolated Output Signal Spectrum (L = 2, Fs = 500 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_out/2/1e6]);
ylim([-80 5]);

sgtitle('5G mmWave Multirate Signal Processing');

