
clc;
clear;
close all;

%% 1. SIGNAL PREPARATION AND NOISE CORRUPTION

Fs = 16000;                 % Sampling Frequency (Hz)
duration = 1.5;              % Duration (seconds)

t = 0:1/Fs:duration-1/Fs;

% Speech Signal Frequencies
f1 = 300;
f2 = 800;
f3 = 2200;

% Generate Speech Envelope
envelope = sin(pi*t/duration).^2;

% Generate Clean Speech Signal
x_clean = (sin(2*pi*f1*t) + ...
           0.6*sin(2*pi*f2*t) + ...
           0.3*sin(2*pi*f3*t)) .* envelope;

% Additive White Gaussian Noise
target_SNR = 10;

speech_pwr = mean(x_clean.^2);
noise_pwr_req = speech_pwr / (10^(target_SNR/10));

rng(42);
noise = sqrt(noise_pwr_req) * randn(size(t));

x_noisy = x_clean + noise;


%% 2. SPECTRAL SUBTRACTION ALGORITHM

N_frame = 256;
hop = 128;
N_fft = 512;

win = hamming(N_frame)';

alpha = 2.0;                % Over-subtraction factor
beta = 0.02;                % Spectral floor factor

% Noise Spectrum Estimation
N_noise_frames = 5;

noise_spectrum_sum = zeros(1,N_fft);

for i = 1:N_noise_frames

    idx = (i-1)*hop + (1:N_frame);

    noise_frame = x_noisy(idx).*win;

    noise_spectrum_sum = noise_spectrum_sum + ...
                         abs(fft(noise_frame,N_fft));

end

N_est = noise_spectrum_sum/N_noise_frames;


%% 3. OVERLAP-ADD PROCESSING

num_frames = floor((length(x_noisy)-N_frame)/hop)+1;

x_enhanced = zeros(1,length(x_noisy));
win_gain = zeros(1,length(x_noisy));

for m = 1:num_frames

    idx = (m-1)*hop + (1:N_frame);

    % Extract and Window Frame
    frame = x_noisy(idx).*win;

    % FFT
    Y = fft(frame,N_fft);

    Y_mag = abs(Y);
    Y_phase = angle(Y);

    % Spectral Magnitude Subtraction
    S_hat_mag = max(Y_mag-alpha*N_est,beta*Y_mag);

    % Restore Original Phase
    S_hat = S_hat_mag.*exp(1i*Y_phase);

    % Inverse FFT
    frame_enhanced = real(ifft(S_hat,N_fft));

    % Overlap-Add Reconstruction
    x_enhanced(idx) = x_enhanced(idx) + ...
                      frame_enhanced(1:N_frame).*win;

    win_gain(idx) = win_gain(idx) + win.^2;

end

% Normalize Reconstructed Signal
valid_idx = win_gain > 1e-3;

x_enhanced(valid_idx) = ...
    x_enhanced(valid_idx)./win_gain(valid_idx);


%% 4. PERFORMANCE EVALUATION

% Input SNR
SNR_in = 10*log10( ...
    sum(x_clean.^2)/sum((x_clean-x_noisy).^2));

% Output SNR
SNR_out = 10*log10( ...
    sum(x_clean.^2)/sum((x_clean-x_enhanced).^2));

% SNR Improvement
SNR_improvement = SNR_out-SNR_in;


%% 5. DISPLAY RESULTS

fprintf('\n');
fprintf('============================================\n');
fprintf(' EXPERIMENT 19: SPEECH ENHANCEMENT RESULTS\n');
fprintf('============================================\n');

fprintf('Sampling Frequency       : %d Hz\n',Fs);
fprintf('Signal Duration           : %.2f seconds\n',duration);
fprintf('Target Input SNR          : %.2f dB\n',target_SNR);

fprintf('Input SNR                 : %.2f dB\n',SNR_in);
fprintf('Output SNR                : %.2f dB\n',SNR_out);

fprintf('SNR Improvement           : %.2f dB\n',SNR_improvement);

fprintf('============================================\n');

fprintf('Status: Spectral Subtraction Speech Enhancement Completed.\n');

fprintf('============================================\n');


%% 6. SUBFIGURE PLOTTING AND EXPORT

figW = 8.5;
figH = 5.5;

% Figure 19A: Clean Speech Waveform
figA = figure('Units','centimeters', ...
              'Position',[2 2 figW figH]);

plot(t,x_clean,'b','LineWidth',1.2);

grid on;
box on;

title('Clean Speech Waveform');
xlabel('Time (s)');
ylabel('Amplitude');

exportgraphics(figA,'Exp19_SubfigA_CleanSpeech.png', ...
                'Resolution',600);


% Figure 19B: Noisy Speech Waveform
figB = figure('Units','centimeters', ...
              'Position',[11 2 figW figH]);

plot(t,x_noisy,'r','LineWidth',1.2);

grid on;
box on;

title(sprintf('Noisy Speech Waveform (SNR = %.2f dB)',SNR_in));
xlabel('Time (s)');
ylabel('Amplitude');

exportgraphics(figB,'Exp19_SubfigB_NoisySpeech.png', ...
                'Resolution',600);


% Figure 19C: Enhanced Speech Waveform
figC = figure('Units','centimeters', ...
              'Position',[20 2 figW figH]);

plot(t,x_enhanced,'g','LineWidth',1.2);

grid on;
box on;

title(sprintf('Enhanced Speech Waveform (SNR = %.2f dB)',SNR_out));
xlabel('Time (s)');
ylabel('Amplitude');

exportgraphics(figC,'Exp19_SubfigC_EnhancedSpeech.png', ...
                'Resolution',600);


%% 7. COMBINED WAVEFORM COMPARISON

figure('Name','Experiment 19: Speech Enhancement', ...
       'NumberTitle','off');

subplot(3,1,1);

plot(t,x_clean,'b');
grid on;
title('Clean Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');


subplot(3,1,2);

plot(t,x_noisy,'r');
grid on;
title('Noisy Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');


subplot(3,1,3);

plot(t,x_enhanced,'g');
grid on;
title('Enhanced Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

sgtitle('Speech Enhancement Using Spectral Subtraction');


