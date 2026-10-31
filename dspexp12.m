clc;
clear;
close all;

%% 1. SIGNAL GENERATION

Fs = 8000;                 % Input sampling frequency (Hz)
f1 = 500;
f2 = 1500;                 % Signal components

M = 2;
L = 2;                     % Rate conversion factors

N = 1000;                  % Signal length

fc_dec = 1800;             % Anti-aliasing cutoff frequency
fc_interp = 3600;          % Anti-imaging cutoff frequency

n = 0:N-1;
t = n/Fs;

x = sin(2*pi*f1*t) + 0.8*sin(2*pi*f2*t);

%% 2. DECIMATION

% Direct Downsampling (Without Filtering)

x_down_direct = x(1:M:end);

Fs_dec = Fs/M;

% Filtered Decimation (Anti-Aliasing)

b_dec = fir1(60,fc_dec/(Fs/2));

x_dec_filtered = filter(b_dec,1,x);

x_dec_filtered = x_dec_filtered(1:M:end);

%% 3. INTERPOLATION

% Upsampling

x_up = zeros(1,length(x)*L);

x_up(1:L:end) = x;

Fs_interp = Fs*L;

% Anti-Imaging Filter

b_interp = L*fir1(60,fc_interp/(Fs_interp/2));

x_interp_filtered = filter(b_interp,1,x_up);

%% 4. SPECTRUM COMPUTATION

Nfft = 2048;

[X_mag,f_x] = compute_spectrum(x,Fs,Nfft);

[X_down_mag,f_down] = compute_spectrum(x_down_direct,Fs_dec,Nfft);

[X_dec_mag,f_dec] = compute_spectrum(x_dec_filtered,Fs_dec,Nfft);

[X_up_mag,f_up] = compute_spectrum(x_up,Fs_interp,Nfft);

[X_interp_mag,f_interp] = compute_spectrum(x_interp_filtered,Fs_interp,Nfft);

%% 5. COMMON PLOT PARAMETERS

figW = 8.5;
figH = 6.5;

%% 6. SUBFIGURE 12A: ORIGINAL SIGNAL

figA = figure('Units','centimeters', ...
    'Position',[2,2,figW,figH]);

subplot(2,1,1);

plot(t(1:100)*1000,x(1:100),'b','LineWidth',1.2);

grid on;

title('Original Input Waveform');

xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);

plot(f_x,X_mag,'b','LineWidth',1.2);

grid on;

title('Original Spectrum (Fs = 8000 Hz)');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

exportgraphics(figA,'Exp12_SubfigA_Original.png','Resolution',600);

%% 7. SUBFIGURE 12B: DECIMATED SIGNAL

figB = figure('Units','centimeters', ...
    'Position',[11,2,figW,figH]);

t_dec = (0:length(x_dec_filtered)-1)/Fs_dec;

subplot(2,1,1);

plot(t_dec(1:50)*1000,x_dec_filtered(1:50), ...
    'r','LineWidth',1.2);

grid on;

title('Decimated Waveform (M = 2)');

xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);

plot(f_down,X_down_mag,'k--','LineWidth',1);

hold on;

plot(f_dec,X_dec_mag,'r','LineWidth',1.2);

grid on;

title('Decimated Spectra (Fs/M = 4000 Hz)');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

legend('Direct (Without Filtering)', ...
    'Filtered (Anti-Aliasing)','FontSize',7);

exportgraphics(figB,'Exp12_SubfigB_Decimated.png','Resolution',600);

%% 8. SUBFIGURE 12C: INTERPOLATED SIGNAL

figC = figure('Units','centimeters', ...
    'Position',[20,2,figW,figH]);

t_interp = (0:length(x_interp_filtered)-1)/Fs_interp;

subplot(2,1,1);

plot(t_interp(1:200)*1000,x_interp_filtered(1:200), ...
    'm','LineWidth',1.2);

grid on;

title('Interpolated Waveform (L = 2)');

xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);

plot(f_up,X_up_mag,'k--','LineWidth',1);

hold on;

plot(f_interp,X_interp_mag,'m','LineWidth',1.2);

grid on;

title('Interpolated Spectra (Fs*L = 16000 Hz)');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

legend('Direct (Images)', ...
    'Filtered (Anti-Imaging)','FontSize',7);

exportgraphics(figC,'Exp12_SubfigC_Interpolated.png','Resolution',600);

%% 9. HELPER FUNCTION

function [X_mag,f] = compute_spectrum(signal,Fs_curr,Nfft)

    X = fft(signal,Nfft);

    X_mag = abs(fftshift(X))/length(signal);

    f = (-Nfft/2:Nfft/2-1)*(Fs_curr/Nfft);

end