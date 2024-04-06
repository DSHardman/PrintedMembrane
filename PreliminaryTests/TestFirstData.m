% addeventrow("Homogen.mat", 1);
% addeventrow("Grid.mat", 2);
% addeventrow("Radial.mat", 3);
addeventrow("PartRadial.mat", 4);

% for i = 1:32
%     plot(mean(abs(allreadings(:,i:32:end)).')-mean(abs(allreadings(1,i:32:end).')))
%     hold on
% end

% load("PartRadial.mat");


% responses = zeros([16, 1]);
% for i = 1:16
%     line = mean(allreadings(:,(i-1)*32+1:i*32).')-mean(allreadings(1,(i-1)*32+1:i*32).');
%     responses(i) = abs(mean(line(26:27))-mean(line(22:23)));
%     % plot(line);
%     % hold on
% end
% 
% bar(responses);
% set(gcf, 'color', 'w', 'Position', [470   519   714   238]);
% ylabel("Mean Response (V)");
% xlabel("Electrode Pair");



function addeventrow(filename, row)
    load(filename);
    stimindices = [5 6; 9 10; 12 13; 15 16; 19 20; 26 27; 31 32];
    freeindices = [2 3; 2 3; 2 3; 2 3; 2 3; 22 23; 35 36];

    for i = 1:7
        subplot(4, 7, (row-1)*7+i);
        heatmap(abs(reshape(mean(allreadings(stimindices(i,1):stimindices(i,2), :))-...
        mean(allreadings(freeindices(i,1):freeindices(i,2), :)), [32, 32])));

        grid off
        clim([0 0.6])
        colorbar('off')
    end

    set(gcf, 'position', [47 98 1476 799]);
end