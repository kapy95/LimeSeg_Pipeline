clear all
close all

addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath(fullfile('..','Epithelia3D', 'InSilicoModels', 'TubularModel', 'src')));

% files = dir('**/Salivary gland/**/Results/3d_layers_info.mat');
% 
% nonDiscardedFiles = cellfun(@(x) contains(lower(x), 'discarded') == 0, {files.folder});
% files = files(nonDiscardedFiles);
% 
% surfLayers = {'apical','basal'};
% 
% polyDistApical = cell(size(files,1),1);
% polyDistBasal = cell(size(files,1),1);
% logNormAreaApical = cell(size(files,1),1);
% logNormAreaBasal = cell(size(files,1),1);
% normAreaApical = cell(size(files,1),1);
% normAreaBasal = cell(size(files,1),1);
% normVolumeCells = cell(size(files,1),1);
% totalSidesCellsApical = cell(size(files,1),1);
% totalSidesCellsBasal = cell(size(files,1),1);
% totalSidesCells = cell(size(files,1),1);
% neighExchanges = zeros(size(files,1),1);
% percScutoids = zeros(size(files,1),1); 
% 
% 
% for nFile = 1 : size(files,1)
%       
%     for nSurf = 1:2
%         load([files(nFile).folder '\' surfLayers{nSurf} '\final3DImg.mat'],'img3d')
%         load([files(nFile).folder '\' surfLayers{nSurf} '\verticesInfo.mat'],'validCellsFinal','newVerticesNeighs2D')
% 
%         neighsCells = cell(1,max(newVerticesNeighs2D(:)));
%         for nCell = 1 : max(newVerticesNeighs2D(:))
%         	 [nRow,nCol]=find(ismember(newVerticesNeighs2D,nCell));
%              cellsNeigh = unique(newVerticesNeighs2D(nRow,:));
%              cellsNeigh = cellsNeigh(cellsNeigh~=nCell);
%              neighsCells{nCell} = cellsNeigh;             
%         end
%         sidesCells = cellfun(@(x) length(x), neighsCells);
%         [polyDist]=calculate_polygon_distribution(sidesCells,validCellsFinal);
%         
%         volumePerim = regionprops3(img3d,'Volume');
%         areaCells = cat(1,volumePerim.Volume);
%         areaValidCells = areaCells(validCellsFinal);
%         
%         
%         
%         if nSurf == 1
%             polyDistApical{nFile} = polyDist(2,:);
%             logNormAreaApical{nFile} = log10(areaValidCells./(mean(areaValidCells)));
%             normAreaApical{nFile} = areaValidCells./(mean(areaValidCells));
%             totalSidesCellsApical{nFile} = sidesCells(validCellsFinal);
%             neighsCellsApical = neighsCells;
%         else
%             polyDistBasal{nFile} = polyDist(2,:);
%             logNormAreaBasal{nFile} = log10(areaValidCells./(mean(areaValidCells)));
%             normAreaBasal{nFile} = areaValidCells./(mean(areaValidCells));
%             totalSidesCellsBasal{nFile} = sidesCells(validCellsFinal);
%             neighsCellsBasal = neighsCells;
%             
%             neighChanges = cellfun(@(x,y) length(setxor(x,y)),neighsCellsBasal(validCellsFinal),neighsCellsApical(validCellsFinal));
%             numScutoids = cellfun(@(x,y) ~isempty(setxor(x,y)),neighsCellsBasal(validCellsFinal),neighsCellsApical(validCellsFinal));
%             
%             totalSidesCells{nFile} = cellfun(@(x,y) length(unique([x;y])),neighsCellsBasal(validCellsFinal),neighsCellsApical(validCellsFinal));
% 
%             
%             neighExchanges(nFile) = sum(neighChanges)/length(validCellsFinal);
%             percScutoids(nFile) = sum(numScutoids)/length(validCellsFinal);
%             
%             
%         end
%     end
%     load([files(nFile).folder '\3d_layers_info.mat'],'labelledImage')
%     
%     volumeCells = regionprops3(labelledImage,'Volume');
%     volumeCells = cat(1,volumeCells.Volume);
%     volumeValidCells = volumeCells(validCellsFinal);
%     normVolumeCells{nFile} = volumeValidCells./(mean(volumeValidCells));
% end
% 
% polyDistBasal = cell2mat(vertcat(polyDistBasal{:}));
% meanPolyDistBasal = mean(polyDistBasal);
% stdPolyDistBasal = std(polyDistBasal);
% 
% polyDistApical = cell2mat(vertcat(polyDistApical{:}));
% meanPolyDistApical = mean(polyDistApical);
% stdPolyDistApical = std(polyDistApical);
% 
% dispersionLogNormAreaBasal = vertcat(logNormAreaBasal{:});
% dispersionLogNormAreaApical = vertcat(logNormAreaApical{:});
% 
% dispersionNormAreaBasal = vertcat(normAreaBasal{:});
% dispersionNormAreaApical = vertcat(normAreaApical{:});
% dispersionNormVolume = vertcat(normVolumeCells{:});
% 
% listPolygons = 3:23;
% 
% relationNormArea_numSidesBasal = [horzcat(totalSidesCellsBasal{:})',dispersionNormAreaBasal];
% relationNormArea_numSidesApical = [horzcat(totalSidesCellsApical{:})',dispersionNormAreaApical];
% relationNormVol_numSidesVolume = [horzcat(totalSidesCells{:})',dispersionNormVolume];
% 
% 
% %relationNsidesApical-basal
% totalSidesCells = horzcat(totalSidesCells{:})';
% totalSidesTotalApical = arrayfun(@(x) totalSidesCells(horzcat(totalSidesCellsApical{:})' == x),4:9,'UniformOutput',false);
% 
% uniqSidesBasal = unique(horzcat(totalSidesCellsBasal{:}));
% uniqSidesApical = unique(horzcat(totalSidesCellsApical{:}));
% uniqSides3D = unique(totalSidesCells);
% 
% 
% lewisBasal_NormArea = [uniqSidesBasal;arrayfun(@(x) mean(relationNormArea_numSidesBasal(ismember(relationNormArea_numSidesBasal(:,1),x),2)),uniqSidesBasal);
%     arrayfun(@(x) std(relationNormArea_numSidesBasal(ismember(relationNormArea_numSidesBasal(:,1),x),2)),uniqSidesBasal)];
% 
% lewisApical_NormArea = [uniqSidesApical;arrayfun(@(x) mean(relationNormArea_numSidesApical(ismember(relationNormArea_numSidesApical(:,1),x),2)),uniqSidesApical);
%     arrayfun(@(x) std(relationNormArea_numSidesApical(ismember(relationNormArea_numSidesApical(:,1),x),2)),uniqSidesApical)];
% 
% lewis3D_NormVol = [uniqSides3D';arrayfun(@(x) mean(relationNormVol_numSidesVolume(ismember(relationNormVol_numSidesVolume(:,1),x),2)),uniqSides3D)';
%     arrayfun(@(x) std(relationNormVol_numSidesVolume(ismember(relationNormVol_numSidesVolume(:,1),x),2)),uniqSides3D)'];
% 
% 
% meanScutoids = mean(percScutoids);
% stdScutoids = std(percScutoids);
% meanNeighExchanges = mean(neighExchanges);
% stdNeighExchanges = std(neighExchanges);
% 
% 
% save(['docs\figuresMathPaper\lewis2D_3D_averagePolygon_AreasDistribution_' date '.mat'],'meanScutoids','stdScutoids','meanNeighExchanges','stdNeighExchanges','meanPolyDistBasal','stdPolyDistBasal','meanPolyDistApical','stdPolyDistApical','dispersionLogNormAreaBasal','dispersionLogNormAreaApical','dispersionNormAreaBasal','dispersionNormAreaApical','dispersionNormVolume','listPolygons','lewisBasal_NormArea','lewisApical_NormArea','lewis3D_NormVol','totalSidesTotalApical')
% 


%%Represent figures
folderSalGland = 'docs\figuresMathPaper\lewis2D_3D_averagePolygon_AreasDistribution_29-Mar-2019.mat';
load(folderSalGland)

%%  figure 1C area distribution
%% tube apical
% folderTube8 = 'D:\Pedro\Epithelia3D\InSilicoModels\TubularModel\data\tubularCVT\Data\512x4096_200seeds\polygonDistribution_diag_8.mat';
path2save = 'docs\figuresMathPaper\';
% load(folderTube)
% 
% h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
% fD = fitdist(dispersionLogNormArea,'Normal');
% x_values = -0.3:0.02:0.3;
% y = pdf(fD,x_values);
% y = y/sum(y);
% histogram(dispersionLogNormArea,'BinWidth',0.02,'Normalization','probability','FaceColor',[79/255,209/255,255/255],'EdgeAlpha',0,'FaceAlpha',0); 
% hold on
% plot(x_values,y,'LineWidth',3,'Color',[79/255,209/255,255/255])

%% tube basal - 1.8
folderTube8 = 'D:\Pedro\Epithelia3D\InSilicoModels\TubularModel\data\tubularVoronoiModel\expansion\512x4096_200seeds\diagram8\';
load([folderTube8 'polygonDistribution_diag_8sr1.8.mat']);
apicalSidesCellsTube18 = apicalSidesCells;
totalSidesCellsTube18 = totalSidesCells;

% dispersionLogNormAreaBasal18 = dispersionLogNormArea;
% 
% % h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
% fD = fitdist(dispersionLogNormAreaBasal18,'Stable');
% y = pdf(fD,x_values);
% y = y/sum(y);
% hold on
% histogram(dispersionLogNormAreaBasal18,'BinWidth',0.02,'Normalization','probability','FaceColor',[0,112/255,192/255],'EdgeAlpha',0,'FaceAlpha',0); 
% hold on
% plot(x_values,y,'LineWidth',3,'Color',[0,112/255,192/255])

%% tube basal - 4
load([folderTube8 'polygonDistribution_diag_8sr4.mat'])
apicalSidesCellsTube4 = apicalSidesCells;
totalSidesCellsTube4 = totalSidesCells;

% dispersionLogNormAreaBasal4 = dispersionLogNormArea;
% 
% % h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
% 
% fD = fitdist(dispersionLogNormAreaBasal4,'Stable');
% y = pdf(fD,x_values);
% y = y/sum(y);
% hold on
% histogram(dispersionLogNormAreaBasal4,'BinWidth',0.02,'Normalization','probability','FaceColor',[27/255,39/255,201/255],'EdgeAlpha',0,'FaceAlpha',0); 
% hold on
% plot(x_values,y,'LineWidth',3,'Color',[27/255,39/255,201/255])
% 
% 
% %% S.Glands basal
% % h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
%  
% x_values = -0.8:0.02:0.4;
% fD = fitdist(dispersionLogNormAreaBasal,'Stable');
% y = pdf(fD,x_values);
% y = y/sum(y);
% hold on
% histogram(dispersionLogNormAreaBasal,'BinWidth',0.02,'Normalization','probability','FaceColor',[0,0.4,0.2],'EdgeAlpha',0,'FaceAlpha',0); 
% hold on
% plot(x_values,y,'LineWidth',3,'Color',[0,0.4,0.2])
% 
% %% S.Glands apical
% % h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
% fD = fitdist(dispersionLogNormAreaApical,'Stable');
% y = pdf(fD,x_values);
% y = y/sum(y);
% hold on
% histogram(dispersionLogNormAreaApical,'BinWidth',0.02,'Normalization','probability','FaceColor',[0.2,0.8,0],'EdgeAlpha',0,'FaceAlpha',0); 
% plot(x_values,y,'LineWidth',3,'Color',[0.2,0.8,0])
% 
% xlim([-0.4,0.4])
% ylim([0,0.1])
% title('Area distribution')
% xlabel('log10(normalized area)')
% ylabel('proportion')
% set(gca,'FontSize', 24,'FontName','Helvetica','YGrid','on','TickDir','out','Box','off');
% print(h,[path2save 'fig1C_' date '_noLegend'],'-dtiff','-r300')
% 
% legend({'Voronoi tube 8 - apical','Voronoi tube 8 - apical', 'Voronoi tube 8 - basal - sr 1.8','Voronoi tube 8 - basal - sr 1.8', 'Voronoi tube 8 - basal - sr 4','Voronoi tube 8 - basal - sr 4','S.Glands - basal','S.Glands - basal', 'S.Glands - apical','S.Glands - apical'})
% 
% print(h,[path2save 'fig1C_' date '_legend'],'-dtiff','-r300')
    
%%  figure 2. Relation apical - basal nSides. Violin
totalSidesCellsTube18 = horzcat(totalSidesCellsTube18{:});
totalSidesCellsTube4 = horzcat(totalSidesCellsTube4{:});

sidesTotalTub18 = arrayfun(@(x) totalSidesCellsTube18(horzcat(apicalSidesCellsTube18{:})' == x)-x,4:9,'UniformOutput',false);
sidesTotalTub4 = arrayfun(@(x) totalSidesCellsTube4(horzcat(apicalSidesCellsTube4{:})' == x)-x,4:9,'UniformOutput',false);
totalSidesTotalApical = arrayfun(@(x) totalSidesTotalApical{x-3}-x,4:9,'UniformOutput',false);

% sidesTotalTub18 = arrayfun(@(x) totalSidesCellsTube18(horzcat(apicalSidesCellsTube18{:})' == x),4:9,'UniformOutput',false);
% sidesTotalTub4 = arrayfun(@(x) totalSidesCellsTube4(horzcat(apicalSidesCellsTube4{:})' == x),4:9,'UniformOutput',false);


h = figure('units','normalized','outerposition',[0 0 1 1],'Visible','on');
hold on

% nApicalGland = cellfun(@(x,y) ones(size(x))*y,totalSidesTotalApical,[{4},{5},{6},{7},{8},{9}],'UniformOutput',false);
% relGland = [vertcat(nApicalGland{:}),vertcat(totalSidesTotalApical{:})];
% 
% nApicalTube18 = cellfun(@(x,y) (ones(size(x))*y),sidesTotalTub18,[{4},{5},{6},{7},{8},{9}],'UniformOutput',false);
% relTube18 = [horzcat(nApicalTube18{:});horzcat(sidesTotalTub18{:})]';
% 
% nApicalTube4 = cellfun(@(x,y) (ones(size(x))*y),sidesTotalTub4,[{4},{5},{6},{7},{8},{9}],'UniformOutput',false);
% relTube4 = [horzcat(nApicalTube4{:});horzcat(sidesTotalTub4{:})]';

x = [totalSidesTotalApical{1};sidesTotalTub18{1}';sidesTotalTub4{1}';...
    totalSidesTotalApical{2};sidesTotalTub18{2}';sidesTotalTub4{2}';...
    totalSidesTotalApical{3};sidesTotalTub18{3}';sidesTotalTub4{3}';...
    totalSidesTotalApical{4};sidesTotalTub18{4}';sidesTotalTub4{4}';...
    totalSidesTotalApical{5};sidesTotalTub18{5}';sidesTotalTub4{5}'];

g = [zeros(length(totalSidesTotalApical{1}), 1); ones(length(sidesTotalTub18{1}), 1);2*ones(length(sidesTotalTub4{1}), 1);...
    3*ones(length(totalSidesTotalApical{2}), 1); 4*ones(length(sidesTotalTub18{2}), 1);5*ones(length(sidesTotalTub4{2}), 1);...
    6*ones(length(totalSidesTotalApical{3}), 1); 7*ones(length(sidesTotalTub18{3}), 1);8*ones(length(sidesTotalTub4{3}), 1);...
    9*ones(length(totalSidesTotalApical{4}), 1); 10*ones(length(sidesTotalTub18{4}), 1);11*ones(length(sidesTotalTub4{4}), 1);...
    12*ones(length(totalSidesTotalApical{5}), 1); 13*ones(length(sidesTotalTub18{5}), 1);14*ones(length(sidesTotalTub4{5}), 1)];

% G = iosr.statistics.boxPlot(x',g');

H = notBoxPlot(x,g,'markMedian',true,'jitter', 0.3);

set([H.data],'MarkerSize',4,...
    'markerFaceColor','none',...
    'markerEdgeColor', 'none')
%mean line color
set([H.mu],'color','k')

for ii=1:length(H)
    set(H(ii).perc1,'FaceColor','none',...
                   'EdgeColor','k','lineStyle','-')
               
    set(H(ii). perc1,'FaceColor','none',...
                   'EdgeColor','k','lineStyle','-')           
    set(H(ii).sd,'FaceColor','none',...
                   'EdgeColor',[0.6 0.6 0.6],'lineStyle',':')        
    set(H(ii).sd1,'Color',[0.6 0.6 0.6])     
    set(H(ii).sd2,'Color',[0.6 0.6 0.6])            
%     set(H(ii).sdPtch,'FaceColor','none',...
%                    'EdgeColor','k')
%     set(H(ii).semPtch,'FaceColor','none',...
%                    'EdgeColor','k')
end

typeOfPoly = 4:8;
for nSideAp = 1:15 %(4:8)
    switch nSideAp
        case {1,4,7,10,13}
            freqSides = totalSidesTotalApical{ceil(nSideAp/3)};
            c = [0.2,0.8,0];
        case {2,5,8,11,14}
            freqSides = sidesTotalTub18{ceil(nSideAp/3)};
            c = [0,112/255,192/255];
        otherwise
            freqSides = sidesTotalTub4{ceil(nSideAp/3)};
            c = [27/255,39/255,201/255];
    end
    
    typeCell = typeOfPoly(ceil(nSideAp/3));
    
    numbers=unique(freqSides);       %list of elements
    countN=hist(freqSides,numbers); 
    countP = countN./sum(countN);
    
    for nUniqSides = 1:length(numbers)
        hold on
%         scatter(nSideAp-1, numbers(nUniqSides),2300*countP(nUniqSides), 'filled','MarkerFaceColor',c, 'MarkerEdgeColor', 'k','MarkerFaceAlpha',0.5)
%         text(nSideAp-1,numbers(nUniqSides),num2str(countN(nUniqSides)),'HorizontalAlignment','center')
    end
end


xlim([-1 15])
ylim([-1 7])
title('relation apical sides - added neigh')
xlabel('number of sides - apical')
ylabel('number gain total')
% set(gca,'FontSize', 24,'FontName','Helvetica','YGrid','on','TickDir','out','Box','off');
set(gca,'FontSize', 24,'FontName','Helvetica','YGrid','off','TickDir','out','Box','off');

xticklabels({'','4','','','5','','','6','','','7','','','8',''})



print(h,[path2save 'fig_sidesRelationApicalGainSides_boxes_' date],'-dtiff','-r300')










