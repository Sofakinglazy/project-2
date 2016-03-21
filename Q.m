%% Profit and Asset Price 
N = 100;
profit = zeros(1, N);
for i = 1:N
    if i <= 40
        profit(i) = 40 - i;
    elseif i > 40 && i < 45 
        profit(i) = 0;
    elseif i >= 45 
        profit(i) = i - 45;
    end
end

figure(1), clf,
plot(1:100, profit, 'LineWidth', 2);
grid on,
axis([30, 55, 0, 12]);
title('Relationship of Profit and Asset Price');
xlabel('Asset Price');
ylabel('Profit');

%% Import Stock Data
% clear;
% clc; 
% stockDir = dir('stock');
% names = {stockDir(3: length(stockDir)).name};
% stock = cell(length(stockDir) - 2, 1);
% for i = 1: length(stockDir)-2
%     stock{i} = importdata(fullfile('stock', names{i}));
% end
% 
% save('stock.mat', 'stock');

%% Evaluate Call and Put Price

clear;
clc; 
load('stock.mat');

option = 5;
close = stock{option}(:, 3);
call = stock{option}(:, 2);
put = stock{option + 5}(:, 2);

from = floor(length(close)/4) + 1;
to = length(close);

trueCall = call(from:to, 1);
truePut = put(from:to, 1);

K = [2925, 3025, 3125, 3225, 3325];
S0 = close(from: to, 1);
r = 0.06;

period34 = length(S0);
period14 = floor(period34/3);
sigma = zeros(period34, 1);

maturity = zeros(period34, 1);
for i = 1:period34
    maturity(i) = (period34-i+1)/252;
end

logclose = zeros(length(close)-1, 1);
for i = 1:length(close)-1
    logclose(i) = log(close(i+1)/close(i));
end
for i = 1:period34 
    sigma(i) = std(logclose(i: i+period14-1, 1));
    sigma(i) = sigma(i) * sqrt(252);
end

pcall = zeros(period34, 1);
pput = zeros(period34, 1);
for i = 1:period34
    [pcall(i), pput(i)] = blsprice(S0(i), K(option), r, maturity(i), sigma(i));
end

figure(2), clf, 
plot(from: to, trueCall, 'LineWidth', 2);
hold on, grid on, grid minor,
plot(from: to, pcall, 'LineWidth', 2);
title('Evaluation of Black-Sholes Call Option');
xlabel('Time(T/4+1 to T)');
ylabel('Option Price');
legend('True Price', 'Predicted Price')
axis([56, 222, 0, inf]);

figure(3), clf, 
plot(from: to, truePut, 'LineWidth', 2);
hold on, grid on, grid minor,
plot(from: to, pput, 'LineWidth', 2);
title('Evaluation of Black-Sholes Call Option');
xlabel('Time(T/4+1 to T)');
ylabel('Option Price');
legend('True Price', 'Predicted Price')
axis([56, 222, 0, inf]);

%% Implied Volatilities 

N = 30;
index = randperm(period34, N);
S0r = S0(index);
callr = trueCall(index);
maturity = (period34*ones(1, N) - index)./252;

impv = zeros(N, 1);
% for i = 1:N
%     impv(i) = blsimpv(S0r(i), K(option), r, maturity(i), callr(i));
% end
for i = 1:N
    [impv(i), C] = calcBSImpVol(1, callr(i), S0r(i), K(option), maturity(i), r, 0.04);
end

hisv = sigma(index);

figure(4), clf, 
scatter(hisv, impv, 'LineWidth', 2);
grid on, grid minor, hold on, 
title('Relationship of Implied Volatilities and Estimated Volatilities');
xlabel('Estimated Volatility');
ylabel('Implied Volatility');
% axis([0.1, 0.15, 0.1, 0.15]);

%% Volatility Smile

N = 100; 
Kr = linspace(3200, 5000, N);
index = randperm(period34, 1);
S0r = S0(index);
callr = trueCall(index);
maturity = (period34 - index)/252; 

impv = zeros(N, 1);
% for i = 1:N
%     impv(i) = blsimpv(S0r, Kr(i), r, maturity, callr);
% end
for i = 1:N
    [impv(i), C] = calcBSImpVol(1, callr, S0r, Kr(i), maturity, r, 0.04);
end

figure(4), clf, 
plot(Kr, impv, 'LineWidth', 2);
grid on, grid minor, hold on, 
title('Relationship of Implied Volatilities and Strike Price');
xlabel('Estimated Volatility');
ylabel('Strike Price');


%% Example

%   Example 1
%       S = 100; K = (40:25:160)'; T = (0.25:0.25:1)'; % Define Key Variables
%       cp = [ones(4,3),-ones(4,2)]; % [Calls[4,3],Puts[4,2]]
%       R = 0.01*repmat([1.15;1.10;1.05;1],1,5); % 
%       Q = 0.03*repmat([1.3;1.2;1.1;1],1,5);
%       P = ...
%           [[59.1445725607811,34.2167401269277,10.1798771553458,16.1224863211251,40.5779719086946];
%           [58.4355054500906,33.5945826994415,10.7977275764632,17.4776751735401,41.1533978186314];
%           [57.8694061672804,33.1636044111551,11.3636963648521,18.6294544130139,41.7369813312724];
%           [57.4444414750070,32.9126689586500,11.9027988146694,19.5839252875422,42.2704830992694]];
%       [mK,mT] = meshgrid(K,T);
%       [sigma,C] = calcBSImpVol(cp,P,S,mK,mT,R,Q);
% %       sigma = blsimpv(S,mK,R,mT,P,Q);
%       figure,clf,
%       mesh(mK,mT,sigma);
%       hold on; scatter3(mK(:),mT(:),sigma(:),60,[0,0,0],'filled'); hold off
%       xlabel('Strike'); ylabel('Expiry'); zlabel('Volatility');
