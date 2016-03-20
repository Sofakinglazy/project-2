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
clear;
clc; 
stockDir = dir('stock');
names = {stockDir(3: length(stockDir)).name};
stock = cell(length(stockDir) - 2, 1);
for i = 1: length(stockDir)-2
    stock{i} = importdata(fullfile('stock', names{i}));
end

save('stock.mat', 'stock');

%% Evaluate Call and Put Price

clear;
clc; 
load('stock.mat');

option = 2;
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

%% 




