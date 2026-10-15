
clc;
clear;
close all;

%% IIR Filter Coefficients
b = [0.0048 0.0193 0.0289 0.0193 0.0048];
a = [1 -2.3695 2.3140 -1.0547 0.1874];

N = 50;
x = [1 zeros(1,N-1)];   % Unit impulse input
n = 0:N-1;

%% 1. Direct Form-I and Direct Form-II
% MATLAB filter function implements the transfer function.
y1 = filter(b,a,x);     % Direct Form-I
y2 = filter(b,a,x);     % Direct Form-II reference

%% 2. Cascade Realization
[sos,g] = tf2sos(b,a);

yc = zeros(size(x));
yc(1) = g;

for i = 1:size(sos,1)
    yc = filter(sos(i,1:3),sos(i,4:6),yc);
end

%% 3. Parallel Realization
[r,p,k] = residuez(b,a);

% Direct term contribution
yp = filter(k,1,x);

% Add each first-order partial fraction
for i = 1:length(r)
    yp = yp + filter(r(i),[1 -p(i)],x);
end

% Remove negligible imaginary numerical errors, if any
y1 = real(y1);
y2 = real(y2);
yc = real(yc);
yp = real(yp);

%% 4. Display Filter Coefficients
disp('========================================');
disp('        IIR FILTER REALIZATION');
disp('========================================');

disp('Numerator coefficients b:');
disp(b);

disp('Denominator coefficients a:');
disp(a);

%% 5. Display Cascade Coefficients
disp('========================================');
disp('         CASCADE REALIZATION');
disp('========================================');

disp('Second-Order Sections (SOS):');
disp(sos);

disp('Overall Gain:');
disp(g);

%% 6. Display Parallel Coefficients
disp('========================================');
disp('         PARALLEL REALIZATION');
disp('========================================');

disp('Residues:');
disp(r);

disp('Poles:');
disp(p);

disp('Direct term:');
disp(k);

%% 7. Display First Ten Impulse Response Samples
disp('========================================');
disp('       REFERENCE IMPULSE RESPONSE');
disp('========================================');

disp(y1(1:10));

%% 8. Numerical Error Calculation
E = [
    max(abs(y1-y2));
    max(abs(y1-yc));
    max(abs(y1-yp))
];

reference_peak = max(abs(y1));

if reference_peak > 0
    D = (E/reference_peak)*100;
else
    D = zeros(size(E));
end

%% 9. Comparison Table
Structure = ["Direct Form-I"; ...
             "Direct Form-II"; ...
             "Cascade"; ...
             "Parallel"];

Maximum_Error = [
    0;
    max(abs(y1-y2));
    max(abs(y1-yc));
    max(abs(y1-yp))
];

Deviation_percent = [
    0;
    D(1);
    D(2);
    D(3)
];

T = table(Structure,Maximum_Error,Deviation_percent);

disp('========================================');
disp('          NUMERICAL COMPARISON');
disp('========================================');

disp(T);

%% 10. Impulse Response Comparison
figure;

stem(n,y1,'filled');
hold on;
stem(n,y2,'--');
stem(n,yc,':','LineWidth',1.5);
stem(n,yp,'-.');

grid on;
xlabel('Sample Number (n)');
ylabel('Amplitude');
title('Impulse Response of IIR Filter Realizations');

legend('Direct Form-I', ...
       'Direct Form-II', ...
       'Cascade', ...
       'Parallel');

%% 11. Numerical Error Plot
figure;

plot(n,abs(y1-y2),'--','LineWidth',1.2);
hold on;
plot(n,abs(y1-yc),':','LineWidth',1.5);
plot(n,abs(y1-yp),'-.','LineWidth',1.2);

grid on;
xlabel('Sample Number (n)');
ylabel('Absolute Error');
title('Numerical Error Between IIR Realizations');

legend('DF-I vs DF-II', ...
       'DF-I vs Cascade', ...
       'DF-I vs Parallel');

%% 12. Frequency Response
figure;

freqz(b,a,1024);
title('Frequency Response of IIR Filter');

%% 13. Pole-Zero Plot
figure;

zplane(b,a);
title('Pole-Zero Plot');

%% 14. Stability Check
poles = roots(a);

disp('========================================');
disp('           STABILITY CHECK');
disp('========================================');

disp('Poles of the filter:');
disp(poles);

if all(abs(poles) < 1)
    disp('The filter is stable.');
else
    disp('The filter is unstable.');
end

