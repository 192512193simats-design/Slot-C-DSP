clc;
clear;
close all;

%% INPUTS
b = [0.0048 0.0193 0.0289 0.0193 0.0048];
a = [1 -2.3695 2.3140 -1.0547 0.1874];

A = 0.9;
f = 50;
Fs = 1000;
N = 200;
B = 8;
SF = 0.5;

n = 0:N-1;
x = A*sin(2*pi*f*n/Fs);

S = 2^(B-1);             % Q1.7 scaling factor
Qmax = 1 - 1/S;          % Maximum positive value
Qmin = -1;               % Minimum negative value

%% IDEAL AND QUANTIZED RESPONSE
y = filter(b,a,x);

q = @(z) round(z*S)/S;

ys = q(y);

%% OVERFLOW
ov = (y > Qmax) | (y < Qmin);

No_Overflow = sum(ov);
Peak_Unscaled = max(abs(y));

%% SATURATION
ysat = q(min(max(y,Qmin),Qmax));

%% WRAP-AROUND
ywrap = (mod(round(y*S)+S,2*S)-S)/S;

%% SIGNAL SCALING
xs = SF*x;

y_ideal_scaled = SF*y;

yscale = q(filter(b,a,xs));

Peak_Scaled = max(abs(yscale));

No_Overflow_Scaled = sum( ...
    (filter(b,a,xs) > Qmax) | ...
    (filter(b,a,xs) < Qmin));

%% ERRORS
RMSE_Sat = sqrt(mean((y-ysat).^2));

RMSE_Wrap = sqrt(mean((y-ywrap).^2));

RMSE_Scale = sqrt(mean((y_ideal_scaled-yscale).^2));

%% OUTPUT
fprintf('\n===== RESULTS =====\n');

fprintf('Q1.7 Range : [-1, 0.9921875]\n');

fprintf('Unscaled Peak : %.6f\n',Peak_Unscaled);

fprintf('Overflow Count : %d\n',No_Overflow);

fprintf('Saturation Peak : %.6f\n',max(abs(ysat)));

fprintf('Wrap-around Peak : %.6f\n',max(abs(ywrap)));

fprintf('Scaling Factor : %.2f\n',SF);

fprintf('Scaled Peak : %.6f\n',Peak_Scaled);

fprintf('Scaled Overflow Count : %d\n',No_Overflow_Scaled);

fprintf('Saturation RMSE : %.6e\n',RMSE_Sat);

fprintf('Wrap-around RMSE : %.6e\n',RMSE_Wrap);

fprintf('Scaled Output RMSE : %.6e\n',RMSE_Scale);

%% TABLE
Method = {'Unscaled';'Saturation';'Wrap-around';'Scaled'};

Peak = [Peak_Unscaled;
        max(abs(ysat));
        max(abs(ywrap));
        Peak_Scaled];

RMSE = [0;
        RMSE_Sat;
        RMSE_Wrap;
        RMSE_Scale];

Overflow = [No_Overflow;
            0;
            0;
            No_Overflow_Scaled];

disp('===== COMPARISON TABLE =====');

disp(table(Method,Peak,RMSE,Overflow));

%% PLOT 1: IDEAL VS SATURATION
figure;

plot(n,y,'k',n,ysat,'--');
grid on;

title('Ideal vs Saturation');
xlabel('Sample Number');
ylabel('Amplitude');

legend('Ideal','Saturation');

%% PLOT 2: IDEAL VS WRAP-AROUND
figure;

plot(n,y,'k',n,ywrap,'--');
grid on;

title('Ideal vs Wrap-around');
xlabel('Sample Number');
ylabel('Amplitude');

legend('Ideal','Wrap-around');

%% PLOT 3: SCALED OUTPUT
figure;

plot(n,y_ideal_scaled,'k',n,yscale,'--');
grid on;

title('Scaled Output');
xlabel('Sample Number');
ylabel('Amplitude');

legend('Scaled Ideal','Quantized');

%% PLOT 4: ERROR COMPARISON
figure;

plot(n,y-ysat);
hold on;

plot(n,y-ywrap);

plot(n,y_ideal_scaled-yscale);

grid on;

title('Error Comparison');
xlabel('Sample Number');
ylabel('Error');

legend('Saturation','Wrap-around','Scaling');

%% PLOT 5: PEAK MAGNITUDE COMPARISON
figure;

bar(Peak);
grid on;

set(gca,'XTickLabel',Method);

ylabel('Peak Magnitude');

title('Peak Magnitude Comparison');