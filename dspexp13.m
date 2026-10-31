clc;
clear;
close all;

%% 1. INPUT PARAMETERS

N = 24;                  % FIR Filter Order
M = 2;                   % Decimation Factor
Fs = 8000;               % Sampling Frequency (Hz)
N_samples = 128;         % Number of Samples

% FIR Prototype Filter
b = fir1(N,0.4);

% Polyphase Decomposition for M = 2
E0 = b(1:M:end);         % Branch 0 (Even indices)
E1 = b(2:M:end);         % Branch 1 (Odd indices)

% Input Signal: 500 Hz Sinusoid
t = (0:N_samples-1)/Fs;

x = sin(2*pi*500*t);

%% 2. CONVENTIONAL VS POLYPHASE DECIMATION

% Direct Path: Filtering followed by Downsampling

y_direct_full = filter(b,1,x);

y_direct = y_direct_full(1:M:end);

% Polyphase Path: Downsampling followed by Low-rate Filtering

x0 = x(1:M:end);

x_delayed = [0,x(1:end-1)];

x1 = x_delayed(1:M:end);

% Polyphase Output

y_poly = filter(E0,1,x0) + filter(E1,1,x1);

%% 3. VERIFICATION METRICS

rec_error = max(abs(y_direct-y_poly));

% Computational Complexity

N_taps = length(b);

N_in = length(x);

N_out = length(y_direct);

% Direct Filtering MAC Operations

MAC_direct = N_in*N_taps;

% Polyphase Filtering MAC Operations
MAC_poly = N_out*(length(E0)+length(E1));

% Computational Savings

comp_saving = (1-(MAC_poly/MAC_direct))*100;

%% 4. COMMAND WINDOW DISPLAY

fprintf('\n');
fprintf('====================================================\n');
fprintf(' EXPERIMENT 13: POLYPHASE DECOMPOSITION\n');
fprintf('====================================================\n');

fprintf('Decimation Factor (M) : %d\n',M);

fprintf('Filter Order (N) : %d (%d Taps)\n',N,N_taps);

fprintf('Input Signal : 500 Hz Sinusoid (%d samples)\n',N_samples);

fprintf('Sampling Frequency (Fs) : %d Hz\n\n',Fs);

fprintf('Polyphase Sub-Filter Coefficients:\n');

fprintf('E0(z) = [');
fprintf('%.4f ',E0);
fprintf(']\n');

fprintf('E1(z) = [');
fprintf('%.4f ',E1);
fprintf(']\n\n');

fprintf('COMPUTATIONAL COMPLEXITY ANALYSIS:\n');

fprintf('Direct MAC Operations : %d MACs\n',MAC_direct);

fprintf('Polyphase MAC Operations : %d MACs\n',MAC_poly);

fprintf('Computational Savings : %.2f%%\n\n',comp_saving);

fprintf('VERIFICATION:\n');

fprintf('Maximum Absolute Difference : %.4e\n',rec_error);

if rec_error < 1e-12

    fprintf('Status : Polyphase Verification Successful!\n');

else

    fprintf('Status : Verification Failed!\n');

end

fprintf('====================================================\n');

%% 5. SUBFIGURE GENERATION

figW = 8.5;
figH = 5.5;

%% SUBFIGURE 13A: PROTOTYPE IMPULSE RESPONSE

figA = figure('Units','centimeters', ...
    'Position',[2,2,figW,figH]);

stem(0:N,b,'b','filled','LineWidth',1.2);

grid on;
box on;

title('Prototype FIR Filter Impulse Response');

xlabel('Sample Index (n)');
ylabel('Coefficient Value');

exportgraphics(figA, ...
    'Exp13_SubfigA_Prototype.png','Resolution',600);

%% SUBFIGURE 13B: POLYPHASE COEFFICIENTS

figB = figure('Units','centimeters', ...
    'Position',[11,2,figW,figH]);

stem(0:length(E0)-1,E0,'b','filled', ...
    'LineWidth',1.2);

hold on;

stem(0:length(E1)-1,E1,'r--', ...
    'LineWidth',1.2);

grid on;
box on;

title('Polyphase Sub-Filter Coefficients (M=2)');

xlabel('Sub-Filter Sample Index');
ylabel('Coefficient Value');

legend('Branch E0[n]','Branch E1[n]','FontSize',7);

exportgraphics(figB, ...
    'Exp13_SubfigB_Polyphase.png','Resolution',600);

%% SUBFIGURE 13C: OUTPUT COMPARISON

figC = figure('Units','centimeters', ...
    'Position',[20,2,figW,figH]);

plot(y_direct(1:50),'b','LineWidth',1.5);

hold on;

plot(y_poly(1:50),'r--','LineWidth',1.5);

grid on;
box on;

title('Time-Domain Output Comparison');

xlabel('Sample Index');
ylabel('Amplitude');

legend('Direct Decimation', ...
    'Polyphase Decimation','FontSize',7);

exportgraphics(figC, ...
    'Exp13_SubfigC_OutputComparison.png','Resolution',600);