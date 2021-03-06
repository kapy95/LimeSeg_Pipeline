addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))
%addpath(genpath(fullfile('..','Epithelia3D', 'InSilicoModels', 'TubularModel', 'src')));

files = dir('**/Salivary gland/**/Results/3d_layers_info.mat');

resultsFileName = 'glandDividedInSurfaceRatios.mat';
%resultsFileName = 'glandDividedInSurfaceRatios_PredefinedSR.mat';

for numFile = 1:length(files)
    if exist(fullfile(files(numFile).folder, 'dividedGland' ,'glandDividedInSurfaceRatios.mat'), 'file') > 0
        
        files(numFile).folder
        
        load(fullfile(files(numFile).folder, 'valid_cells'));
        filesOf2DUnroll = dir(fullfile(files(numFile).folder, '**', 'verticesInfo.mat'));
        if length(filesOf2DUnroll) ~= 11
            %continue
            load(fullfile(files(numFile).folder, '3d_layers_info'), 'colours');
            load(fullfile(files(numFile).folder, 'dividedGland', 'glandDividedInSurfaceRatios.mat'));
            
            imageOfSurfaceRatios = infoPerSurfaceRatio;
            parfor numPartition = 2:10
                unrollTube(imageOfSurfaceRatios{numPartition, 3}, fullfile(files(numFile).folder, 'dividedGland', ['gland_SR_' num2str(imageOfSurfaceRatios{numPartition, 2})]), noValidCells, colours, 1);
            end
        end
        
        filesOf2DUnroll = dir(fullfile(files(numFile).folder, '**', 'verticesInfo.mat'));
        if exist(fullfile(files(numFile).folder, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'file') == 0
            load(fullfile(files(numFile).folder, 'dividedGland' ,'glandDividedInSurfaceRatios.mat'), 'infoPerSurfaceRatio');
            
            load(fullfile(filesOf2DUnroll(1).folder, 'verticesInfo.mat'));
            apicalLayer = cylindre2DImage;
            infoPerSurfaceRatio{1, 6} = cylindre2DImage;
            [neighboursApical] = getNeighboursFromVertices(newVerticesNeighs2D);
            
            load(fullfile(filesOf2DUnroll(2).folder, 'verticesInfo.mat'));
            basalLayer = cylindre2DImage;
            infoPerSurfaceRatio{11, 6} = cylindre2DImage;
            [neighboursBasal] = getNeighboursFromVertices(newVerticesNeighs2D);
            
            neighboursOfAllSurfaces = cell(11, 1);
            for numSR = 1:11
                numSR
                load(fullfile(filesOf2DUnroll(numSR).folder, 'final3DImg.mat'), 'img3d', 'neighbours');
                load(fullfile(filesOf2DUnroll(numSR).folder, 'verticesInfo.mat'), 'cylindre2DImage', 'newVerticesNeighs2D');
%                 if isempty(newVerticesNeighs2D)
%                     neighbours = calculateNeighbours3D(img3d, 2);
%                     neighbours = checkPairPointCloudDistanceCurateNeighbours(img3d, neighbours.neighbourhood', 1);
%                 end
                [total_neighbours3D] = getNeighboursFromVertices(newVerticesNeighs2D);
                midLayer = cylindre2DImage;
                
                if numSR == 1
                    idToSave = 1;
                elseif numSR == 2
                    idToSave = size(infoPerSurfaceRatio, 1);
                else
                    idToSave = numSR - 1;
                end
                
                infoPerSurfaceRatio{idToSave, 6} = cylindre2DImage;
                [neighboursMid] = getNeighboursFromVertices(newVerticesNeighs2D);
                
                neighbours_data = table(neighboursApical, neighboursMid);
                neighbours_data.Properties.VariableNames = {'Apical','Basal'};
                neighboursOfAllSurfaces{idToSave} = neighboursMid;
                
                [infoPerSurfaceRatio{idToSave, 8}, infoPerSurfaceRatio{idToSave, 7}] = calculate_CellularFeatures(neighbours_data, neighboursApical, neighboursMid, apicalLayer, midLayer, img3d, noValidCells, validCells, [], [], total_neighbours3D);
            end
            
            infoPerSurfaceRatio = cell2table(infoPerSurfaceRatio, 'VariableNames', {'Image3DWithVolumen', 'SR3D', 'Layer3D', 'ApicalBasalCellFeatures3D', 'BasalApicalCellFeatures3D', 'UnrolledLayer2D', 'SR2D', 'ApicalBasalCellFeatures2D'});
            %             save(fullfile(files(numFile).folder, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'cellularFeatures_BasalToApical', 'cellularFeatures_ApicalToBasal', 'meanSurfaceRatio');
            save(fullfile(files(numFile).folder, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'infoPerSurfaceRatio', 'neighboursOfAllSurfaces');
        end
    end
end