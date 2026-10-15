
clc;
clear;
close all;

%% FIR FILTER PARAMETERS

b = [0.0625 0.2500 0.3750 0.2500 0.0625];
Fs = 1000;
N = 128;

x = [1 zeros(1,N-1)];
n = 0:N-1;

%% 1. DIRECT REALIZATION

yd = filter(b,1,x);

%% 2. CASCADE REALIZATION

z = roots(b);
g = b(1);
yc = g*x;

for k = 1:length(z)
    yc = filter([1 -z(k)],1,yc);
end

yc = real(yc);

%% 3. SYMMETRY AND LINEAR PHASE

symErr = max(abs(b-fliplr(b)));
D = (length(b)-1)/2;

if symErr < 1e-12
    symmetry = 'Symmetric';
else
    symmetry = 'Not Symmetric';
end

%% 4. FREQUENCY, PHASE AND GROUP DELAY

[H,w] = freqz(b,1,1024);
phase = unwrap(angle(H));
gd = grpdelay(b,1,1024);

%% 5. NUMERICAL COMPARISON

err = max(abs(yd-yc));
dev = err/max(abs(yd))*100;

%% DISPLAY RESULTS

fprintf('\n============================================\n');
fprintf(' FIR FILTER REALIZATION RESULTS\n');
fprintf('============================================\n');

fprintf('\nFIR Coefficients:\n');
disp(b);

fprintf('Sampling Frequency = %d Hz\n',Fs);
fprintf('Number of Samples = %d\n',N);

fprintf('Coefficient Symmetry = %s\n',symmetry);
fprintf('Symmetry Error = %.3e\n',symErr);
fprintf('Group Delay = %.2f samples\n',D);

fprintf('\nMaximum Error = %.3e\n',err);
fprintf('Percentage Deviation = %.3e %%\n',dev);

%% IMPULSE RESPONSE VALUES

fprintf('\n============================================\n');
fprintf('FIRST 10 IMPULSE RESPONSE VALUES\n');
fprintf('============================================\n');

fprintf(' n   Direct       Cascade\n');

for k = 1:10
    fprintf('%4d %10.6f %10.6f\n',n(k),yd(k),yc(k));
end

%% CASCADE ZEROS

fprintf('\n============================================\n');
fprintf('CASCADE REALIZATION ZEROS\n');
fprintf('============================================\n');

disp(z);

%% OUTPUT PARAMETER TABLE

Parameter = {
    'Direct realization output'
    'Cascade realization output'
    'Impulse response'
    'Phase response'
    'Comparison of realizations'
};

Observation = {
    'Direct FIR filtering'
    'Cascade of first-order sections'
    'Equal to FIR coefficient sequence'
    'Linear phase'
    'Equivalent transfer-function behavior'
};

Value = {
    sprintf('[%.4f %.4f %.4f %.4f %.4f]',yd(1:5))
    sprintf('[%.4f %.4f %.4f %.4f %.4f]',yc(1:5))
    sprintf('[%.4f %.4f %.4f %.4f %.4f]',yd(1:5))
    sprintf('Group delay = %.2f samples',D)
    sprintf('Max error = %.3e; Deviation = %.3e %%',err,dev)
};

Unit_Note = {
    'Amplitude'
    'Amplitude'
    'h[n]'
    'Samples'
    'Numerical precision'
};

Output_Table = table(Parameter,Observation,Value,Unit_Note);

fprintf('\n============================================\n');
fprintf('OUTPUT PARAMETER TABLE\n');
fprintf('============================================\n');

disp(Output_Table);

%% GRAPH 1: DIRECT VS CASCADE IMPULSE RESPONSE

figure('Name','Direct vs Cascade Impulse Response');

stem(n,yd,'filled');
hold on;
stem(n,yc,'--');

grid on;
xlabel('Sample n');
ylabel('Amplitude');
title('Direct and Cascade FIR Impulse Responses');
legend('Direct Realization','Cascade Realization');

%% GRAPH 2: MAGNITUDE RESPONSE

figure('Name','FIR Magnitude Response');

plot(w/pi,abs(H),'LineWidth',1.5);

grid on;
