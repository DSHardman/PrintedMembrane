clear device
device = serialport("COM8",11520);

filestub = "Q1_fixed";


expecteddatalength = 1024;

% system('python TestBoard.py');

data = readline(device);

allreadings = [];
fprintf("Starting...\n")
tic
while toc < 30 %66
    data = readline(device);
    data = str2num(data);

    if length(data) == expecteddatalength
        allreadings = [allreadings; data]; % check orientation
    end
end


save("BoardTests/"+filestub+".mat", "allreadings");


subplot(2,1,2);
[coeff,score,latent,tsquared,explained, mu] = pca(allreadings);
[~,ranking] = sort(mean(coeff(:,1), 2), 'descend');
heatmap(normalize(allreadings(:, ranking), "range", [0 1]).', "colormap", gray); grid off

subplot(2,1,1);
load("BoardTests/A1.mat");
[coeff,score,latent,tsquared,explained, mu] = pca(allreadings);
[~,ranking] = sort(mean(coeff(:,1), 2), 'descend');
heatmap(normalize(allreadings(:, ranking), "range", [0 1]).', "colormap", gray); grid off

% set(gcf, 'color', 'w', 'position', [380   327   724   420]);
% print("BoardTests/"+filestub+'.png','-dpng');

clear all

%%

load("PreliminaryData/Homogen2.mat");

[coeff,score,latent,tsquared,explained, mu] = pca(allreadings);
[~,ranking] = sort(mean(coeff(:,1), 2), 'descend');
data = normalize(allreadings(:, ranking), "range", [0 1]);

channels = [];
for i = 1:1024
    if ~isempty(find(data(:,i)~=0))
        channels = [channels i];
    end
end

heatmap(data(:, channels).', "colormap", gray); grid off
xlabel("Timeframe");
ylabel("Data Channel");

set(gcf, 'position', [316   352   807   420], 'color', 'w');
set(gca, 'fontsize', 18)
colorbar off