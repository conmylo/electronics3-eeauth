%Konstantinos Mylonas 10027 Script%

%% request user input
prompt = 'Enter last two digits of AEM:';
x = input(prompt);
x = round(x);

%% calculate specifications
%all values are in SI
CL = (2 + 0.01 * x) * 10^(-12);         % Fahrad
SR = (18 + 0.01 * x) * 10^(6);          % V/s
VDD= (1.8 + 0.003 * x);                 % V
VSS = -(1.8 + 0.003 * x);               % V
GBmin = (7 + 0.01 * x) * 10^(6);        % Hz
Amin = (20 + 0.01 * x);                 % dB
Pmax = (50 + 0.01 * x) * 10^(-3);       % Watt 

%%% print specifications
fprintf("\n***SPECIFICATIONS***\n\n");
fprintf('CL: %f pF\n', CL * 10^(12));
fprintf('SR: >= %f V/μs\n', SR * 10^(-6));
fprintf('VDD: %f V\n', VDD);
fprintf('VSS: %f\n', VSS);
fprintf('GBmin: > %f MHz\n', GBmin * 10^(-6));
fprintf('Amin: > %f dB\n', Amin);
fprintf('Pmax: < %f mW\n', Pmax * 10^(3));

%% define constants
Kp = 60 * 10^(-6);                      % Kn = 2.9352E05
Kn = 150 * 10^(-6);                     % Kn = 9.6379E05
Vin_max = 0.1;
Vin_min = -0.1;

VTO3_max = 0.9056;
VT1_min = 0.786;
VT1_max = 0.786; 

%% ALGORITHM
fprintf("\n***ALGORITHM***\n\n");

%%% step 1
% 1,5~2 times bigger than 0.35
% For calculation purposes our Length will be 1μm
L = 10^(-6);

fprintf("L: %f m\n", L);

%%% step 2

CC = 0.22 * CL;
CC = ceil(CC / (10^(-12)));

%%%% step 2 - TUNE HERE
t = 0.00;
CC = (CC + t) * 10^(-12);

fprintf("Miller Capacity (CC): %f pF tuned by t = %f \n", CC * 10^(12), t);

%%% step 3
I5 = SR * CC;

fprintf("I5 = %f uA\n", I5 * 10^(6));

%%% step 4
S3 = I5 / (Kp * (VDD - Vin_max - abs(VTO3_max) + VT1_min) ^2);

fprintf("Calculated Value -> S3 = %f\n", S3);

if S3 < 1
    S3 = 1;
end
S4 = S3;

fprintf("Final Values -> S3 = %f S4 = %f\n", S3, S4);

%%% step 5
fprintf("\n***CHECKS***\n\n");

W3 = S3 * L;

Tox = 2.1200 * 10^(-8);         % Thickness of Gate Oxyde  
E0 = 8.854 * 10^(-12);
ER = 3.9;
C_ox = E0 * ER / Tox;           % Cox = 3,45306 * 10^(-3)

I3 = I5 / 2;    

C_gs3 = 0.667 * W3 * L * C_ox;
GBtimes10 = GBmin * 10;
gm3 = sqrt(2 * Kp * S3 * I3);
P3 = gm3 / (2 * C_gs3);
p3 = P3 / (2 * pi);

if (p3 > GBtimes10)
    fprintf('p3: CHECK\n')
else
    fprintf('p3: OOPS\n')
end

%%% step6
gm2 = 2 * pi * GBmin * CC;
gm1 = gm2;                      % Diff Amp. -- Same transistors, same 
                                    %  current => same gm
S1 = (gm1^2) / (Kn * I5);
S2 = S1;

%%% step7
beta1 = Kn * S1;
K5 = Kn;
V_DS5 = Vin_min - VSS - sqrt(I5 / beta1) - VT1_max;

S5 = (2 * I5)/(K5 * V_DS5^2);

S8 = S5;                        % Transistors 5 and 8 are Current Mirror 
                                    % => S5 = S8

%%% step 8
gm6 = 2.2 * gm1 * (CL / CC);
gm3 = sqrt(Kp * S3 * I5);
gm4 = gm3;
S6 = S4 * gm6 / gm3;            % gm4=gm3; 

% step 9
K_6 = Kp;
I6 = (gm6^2) / (2 * K_6 * S6);

% step10
S7 = S5 * I6/I5;
%S7 = round(S7*10);
%S7 = S7 /10

a = 0.09;
b = 0.09;
Astep= (2 * gm2 * gm6) / (I5 * a * I6 *b);
AdB = 20 * log(Astep);
Pdiss = (I5 + I6) * (VDD + abs(VSS));
fprintf("A in dB = %f \n", AdB);
fprintf("Pdiss = %f \n", Pdiss);
fprintf("Vdd = %f \n", VDD);
fprintf("VSS = %f \n", VSS);

if(AdB > Amin)
    fprintf('A: CHECK\n')
else
     fprintf('A: OOPS...\n')
end

if(Pdiss < Pmax)
    fprintf('Pdiss: CHECK\n')
else
    fprintf('Pdiss: OOPS...\n')
end

%% print results
fprintf("\n***RESULTS***\n");
fprintf('\n---SPICE:\n\n')

fprintf("Vin_max: %f\n", Vin_max)
fprintf("Vin_min: %f\n", Vin_min)
fprintf('VDD: %f V\n', VDD);
fprintf('VSS: %f\n', VSS);
fprintf('CL: %f pF\n', CL * 10^(12));
fprintf("L: %f m\n", L);
fprintf("CC: %f pF\n", CC * 10^(12));
fprintf("I5 = %f uA\n", I5 * 10^(6));

fprintf('\n---W:\n\n')
fprintf("W1: %f μm\n", S1)
fprintf("W2: %f μm\n", S2)
fprintf("W3: %f μm\n", S3)
fprintf("W4: %f μm\n", S4)
fprintf("W5: %f μm\n", S5)
fprintf("W6: %f μm\n", S6)
fprintf("W7: %f μm\n", S7)
fprintf("W8: %f μm\n", S8)