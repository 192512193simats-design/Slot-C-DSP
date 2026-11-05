
clc;
clear;
close all;

%% 1. SYNTHETIC SPEECH GENERATION

Fs = 16000;                 % Sampling Frequency (Hz)
duration = 0.5;             % Signal Duration (seconds)

t = 0:1/Fs:duration-1/Fs;

f1 = 250;
f2 = 700;

% Generate Synthetic Speech Signal
x_speech = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);


%% 2. FRAME-BY-FRAME LPC VOCODER SYNTHESIS

p = 12;                     % LPC Prediction Order
N_frame = 320;              % Frame Length
hop = 160;                  % Hop Size

num_frames = floor((length(t)-N_frame)/hop)+1;

x_synth = zeros(1,length(t));
win_gain = zeros(1,length(t));

rng(42);

for m = 1:num_frames

    idx = (m-1)*hop + (1:N_frame);

    % Windowing
    frame = x_speech(idx).*hamming(N_frame)';

    % LPC Analysis
    [a,g] = lpc(frame,p);

    % Noise Excitation
    excitation = sqrt(g)*randn(1,N_frame);

    % LPC Synthesis Filtering
    synth_frame = filter(1,a,excitation);

    % Overlap-Add Reconstruction
    x_synth(idx) = x_synth(idx) + synth_frame.*hamming(N_frame)';

    win_gain(idx) = win_gain(idx) + hamming(N_frame)'.^2;

end

% Normalize Synthesized Signal
valid_idx = win_gain > 1e-3;

x_synth(valid_idx) = x_synth(valid_idx)./win_gain(valid_idx);


%% 3. SINGLE FRAME SPECTRAL ANALYSIS

frame_sample = x_speech(161:160+N_frame).*hamming(N_frame)';

% LPC Coefficient Calculation
[a_sample,g_sample] = lpc(frame_sample,p);

% LPC Frequency Response
[H_lpc,w] = freqz(sqrt(g_sample),a_sample,1024,Fs);

% FFT Power Spectrum
[X_fft,f_fft] = pwelch(frame_sample,hamming(N_frame),[],N_frame,Fs);

% Convert to dB
H_lpc_db = 20*log10(abs(H_lpc)+eps);

X_fft_db = 10*log10(X_fft+eps);


%% 4. PERFORMANCE EVALUATION

% Calculate Signal RMS
original_rms = rms(x_speech);
synthesized_rms = rms(x_synth);

% Calculate Correlation
correlation_value = corrcoef(x_speech,x_synth);

correlation = correlation_value(1,2);

% Calculate LPC Prediction Error
prediction_error = filter(a_sample,1,frame_sample);

mse = mean(prediction_error.^2);


%% 5. COMMAND WINDOW DISPLAY

fprintf('\n');
fprintf('============================================\n');
fprintf(' EXPERIMENT 20: LPC VOCODER RESULTS\n');
fprintf('============================================\n');

fprintf('Sampling Frequency       : %d Hz\n',Fs);
fprintf('Signal Duration          : %.2f seconds\n',duration);
fprintf('LPC Prediction Order     : %d\n',p);
fprintf('Frame Length             : %d samples\n',N_frame);
fprintf('Hop Size                 : %d samples\n',hop);
fprintf('Number of Frames         : %d\n',num_frames);

fprintf('\nSignal Parameters:\n');

fprintf('Original Signal RMS      : %.4f\n',original_rms);
fprintf('Synthesized Signal RMS   : %.4f\n',synthesized_rms);

fprintf('Correlation Coefficient  : %.4f\n',correlation);
fprintf('LPC Prediction Error MSE : %.6f\n',mse);

fprintf('\n');
fprintf('Status: LPC Vocoder Speech Synthesis Completed.\n');

fprintf('============================================\n');


%% 6. SUBFIGURE PLOTTING AND EXPORT

figW = 8.5;
figH = 5.5;


% Figure 20A: Original Speech Signal

figA = figure('Units','centimeters', ...
              'Position',[2 2 figW figH]);

plot(t(1:640),x_speech(1:640),'b','LineWidth',1.2);

grid on;
box on;

title('Original Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

exportgraphics(figA,'Exp20_SubfigA_OriginalSpeech.png', ...
               'Resolution',600);


% Figure 20B: LPC Synthesized Speech Signal

figB = figure('Units','centimeters', ...
              'Position',[11 2 figW figH]);

plot(t,x_synth,'r','LineWidth',1.2);

grid on;
box on;

title('LPC Vocoder Synthesized Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

exportgraphics(figB,'Exp20_SubfigB_SynthesizedSpeech.png', ...
               'Resolution',600);


% Figure 20C: LPC Frequency Response

figC = figure('Units','centimeters', ...
              'Position',[20 2 figW figH]);

plot(w/1000,H_lpc_db,'m','LineWidth',1.2);

grid on;
box on;

title('LPC Spectral Envelope');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

exportgraphics(figC,'Exp20_SubfigC_LPC_Spectrum.png', ...
               'Resolution',600);


% Figure 20D: Original Speech Power Spectrum

figD = figure('Units','centimeters', ...
              'Position',[2 9 figW figH]);

plot(f_fft/1000,X_fft_db,'k','LineWidth',1.2);

grid on;
box on;

title('Original Speech Power Spectrum');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');

exportgraphics(figD,'Exp20_SubfigD_PowerSpectrum.png', ...
               'Resolution',600);


%% 7. COMBINED RESULT PLOTTING

figure('Name','Experiment 20: LPC Vocoder', ...
       'NumberTitle','off');

subplot(3,1,1);

plot(t,x_speech,'b');
grid on;

title('Original Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');


subplot(3,1,2);

plot(t,x_synth,'r');
grid on;

title('LPC Synthesized Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');


subplot(3,1,3);

plot(w/1000,H_lpc_db,'m');
grid on;

title('LPC Spectral Envelope');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

sgtitle('Speech Synthesis Using LPC Vocoder');

