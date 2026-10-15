
clc;
clear;
close all;

%% =========================================================
% DESIGN AND COMPARATIVE ANALYSIS OF
% BUTTERWORTH, CHEBYSHEV TYPE-I AND ELLIPTIC IIR FILTERS
%% =========================================================

%% 1. INPUT PARAMETERS

Fs  = 1000;     % Sampling frequency (Hz)
Fp  = 100;      % Passband edge frequency (Hz)
Fst = 150;      % Stopband edge frequency (Hz)
Rp  = 1;        % Passband ripple (dB)
Rs  = 40;       % Stopband attenuation (dB)

% Normalized digital frequencies (0 to 1)
Wp  = Fp/(Fs/2);
Wst = Fst/(Fs/2);

%% 2. PREWARPED ANALOG FREQUENCIES

Omega_p = (2*Fs)*tan(pi*Fp/Fs);
Omega_s = (2*Fs)*tan(pi*Fst/Fs);

%% 3. CHEBYSHEV TYPE-I THEORETICAL ORDER

epsilon = sqrt(10^(Rp/10)-1);

N_formula = acosh(sqrt((10^(Rs/10)-1) / ...
             (10^(Rp/10)-1))) / ...
             acosh(Omega_s/Omega_p);

N_theory = ceil(N_formula);

%% 4. BUTTERWORTH FILTER

[Nb,Wb] = buttord(Wp,Wst,Rp,Rs);
[bB,aB] = butter(Nb,Wb,'low');

%% 5. CHEBYSHEV TYPE-I FILTER

[Nc,Wc] = cheb1ord(Wp,Wst,Rp,Rs);
[bC,aC] = cheby1(Nc,Rp,Wc,'low');

%% 6. ELLIPTIC FILTER

[Ne,We] = ellipord(Wp,Wst,Rp,Rs);
[bE,aE] = ellip(Ne,Rp,Rs,We,'low');

%% 7. DISPLAY INPUT PARAMETERS

fprintf('\n============================================\n');
fprintf(' IIR FILTER COMPARATIVE ANALYSIS\n');
fprintf('============================================\n');

fprintf('\nINPUT PARAMETERS\n');
fprintf('Sampling Frequency = %.2f Hz\n',Fs);
fprintf('Passband Edge = %.2f Hz\n',Fp);
fprintf('Stopband Edge = %.2f Hz\n',Fst);
fprintf('Passband Ripple = %.2f dB\n',Rp);
fprintf('Stopband Attenuation = %.2f dB\n',Rs);

fprintf('\nPREWARPED ANALOG FREQUENCIES\n');
fprintf('Omega_p = %.4f rad/s\n',Omega_p);
fprintf('Omega_s = %.4f rad/s\n',Omega_s);

%% 8. CHEBYSHEV THEORETICAL ORDER

fprintf('\nCHEBYSHEV TYPE-I THEORETICAL CALCULATION\n');
fprintf('Ripple factor epsilon = %.4f\n',epsilon);
fprintf('Calculated order = %.4f\n',N_formula);
fprintf('Theoretical minimum order = %d\n',N_theory);

%% 9. FILTER ORDER COMPARISON

fprintf('\n============================================\n');
fprintf(' FILTER ORDER COMPARISON\n');
fprintf('============================================\n');

fprintf('Butterworth Order = %d\n',Nb);
fprintf('Chebyshev Type-I Order = %d\n',Nc);
fprintf('Elliptic Order = %d\n',Ne);

%% 10. DISPLAY FILTER COEFFICIENTS

fprintf('\nBUTTERWORTH COEFFICIENTS\n');
fprintf('Numerator bB =\n');
disp(bB);
fprintf('Denominator aB =\n');
disp(aB);

fprintf('\nCHEBYSHEV TYPE-I COEFFICIENTS\n');
fprintf('Numerator bC =\n');
disp(bC);
fprintf('Denominator aC =\n');
disp(aC);

fprintf('\nELLIPTIC COEFFICIENTS\n');
fprintf('Numerator bE =\n');
disp(bE);
fprintf('Denominator aE =\n');
disp(aE);

%% 11. FREQUENCY RESPONSES

Nfreq = 8192;

[HB,f] = freqz(bB,aB,Nfreq,Fs);
[HC,~] = freqz(bC,aC,Nfreq,Fs);
[HE,~] = freqz(bE,aE,Nfreq,Fs);

MB = 20*log10(max(abs(HB),1e-12));
MC = 20*log10(max(abs(HC),1e-12));
ME = 20*log10(max(abs(HE),1e-12));

%% 12. PASSBAND RIPPLE

P = (f <= Fp);

Ripple_B = max(MB(P))-min(MB(P));
Ripple_C = max(MC(P))-min(MC(P));
Ripple_E = max(ME(P))-min(ME(P));

%% 13. STOPBAND ATTENUATION

S = (f >= Fst);

Stop_B = -max(MB(S));
Stop_C = -max(MC(S));
Stop_E = -max(ME(S));

%% 14. PERFORMANCE SUMMARY

fprintf('\n============================================\n');
fprintf(' FILTER PERFORMANCE\n');
fprintf('============================================\n');

fprintf('\nPASSBAND RIPPLE\n');
fprintf('Butterworth = %.4f dB\n',Ripple_B);
fprintf('Chebyshev-I = %.4f dB\n',Ripple_C);
fprintf('Elliptic = %.4f dB\n',Ripple_E);

fprintf('\nSTOPBAND ATTENUATION\n');
fprintf('Butterworth = %.4f dB\n',Stop_B);
fprintf('Chebyshev-I = %.4f dB\n',Stop_C);
fprintf('Elliptic = %.4f dB\n',Stop_E);

fprintf('\nSPECIFICATION CHECK\n');

fprintf('Butterworth: %s\n', ...
    passfail(Ripple_B <= Rp+1e-3 && Stop_B >= Rs-1e-3));

fprintf('Chebyshev-I: %s\n', ...
    passfail(Ripple_C <= Rp+1e-3 && Stop_C >= Rs-1e-3));

fprintf('Elliptic: %s\n', ...
    passfail(Ripple_E <= Rp+1e-3 && Stop_E >= Rs-1e-3));

%% 15. TRANSITION BAND

TransitionBW = Fst-Fp;

fprintf('\nTRANSITION CHARACTERISTICS\n');
fprintf('Passband Edge = %.2f Hz\n',Fp);
fprintf('Stopband Edge = %.2f Hz\n',Fst);
fprintf('Transition Bandwidth = %.2f Hz\n',TransitionBW);

%% 16. MAGNITUDE RESPONSE

figure;

plot(f,MB,'LineWidth',1.5);
hold on;
plot(f,MC,'LineWidth',1.5);
plot(f,ME,'LineWidth',1.5);

grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Comparison of IIR Filter Magnitude Responses');

legend('Butterworth','Chebyshev Type-I','Elliptic', ...
       'Location','southwest');

xlim([0 250]);
ylim([-80 5]);

xline(Fp,'--','Fp = 100 Hz');
xline(Fst,'--','Fst = 150 Hz');

yline(-Rp,'--','Passband limit = -1 dB');
yline(-Rs,'--','Stopband limit = -40 dB');

hold off;

%% 17. PHASE RESPONSE

Phase_B = unwrap(angle(HB))*180/pi;
Phase_C = unwrap(angle(HC))*180/pi;
Phase_E = unwrap(angle(HE))*180/pi;

figure;

plot(f,Phase_B,'LineWidth',1.3);
hold on;
plot(f,Phase_C,'LineWidth',1.3);
plot(f,Phase_E,'LineWidth',1.3);

grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Comparison of IIR Filter Phase Responses');

legend('Butterworth','Chebyshev Type-I','Elliptic', ...
       'Location','best');

xlim([0 250]);

hold off;

%% 18. FILTER ORDER GRAPH

figure;

bar([Nb Nc Ne]);

set(gca,'XTick',1:3);
set(gca,'XTickLabel', ...
    {'Butterworth','Chebyshev-I','Elliptic'});

ylabel('Filter Order');
xlabel('Filter Type');
title('Comparison of IIR Filter Orders');

grid on;

%% 19. LOCAL HELPER FUNCTION

function result = passfail(condition)
    if condition
        result = 'PASS';
    else
        result = 'FAIL';
    end
end

