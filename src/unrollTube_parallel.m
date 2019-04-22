function unrollTube_parallel(selpath)
%UNROLLTUBE_PARALLEL Summary of this function goes here
%   Detailed explanation goes here

    idName_splitted = strsplit(selpath, filesep);
    idName = strjoin(idName_splitted(end-3:end-1), '_');
    
    load(fullfile(selpath, '3d_layers_info.mat'), 'labelledImage', 'apicalLayer', 'basalLayer', 'colours', 'glandOrientation', 'lumenImage');
    load(fullfile(selpath, 'valid_cells.mat'), 'validCells', 'noValidCells');
    
    if exist(strcat(selpath, '\', idName ,'_samirasFormat.xls'), 'file') == 0
        
        %% Unrolling
        if exist(fullfile(selpath, 'dividedGland' ,'glandDividedInSurfaceRatios.mat'), 'file') > 0
            %% Apical and basal and all the artificial surface ratios
            load(fullfile(selpath, 'dividedGland', 'glandDividedInSurfaceRatios.mat'));
            
            mkdir(fullfile(selpath, 'unrolledGlands', 'gland_SR_1'));
            [samiraTablePerSR{1}, apicalAreaValidCells, rotationsOriginal] = unrollTube(infoPerSurfaceRatio{1, 3}, fullfile(selpath, 'unrolledGlands', 'gland_SR_1'), fullfile(selpath, 'valid_cells.mat'), fullfile(selpath, '3d_layers_info.mat'));
            areaValidCells{1} = apicalAreaValidCells;
            %addAttachedFiles(gcp, fullfile(selpath, 'valid_cells.mat'))
            
            surfaceRatioOfGland = vertcat(infoPerSurfaceRatio{:,2})';
            nSR = length(surfaceRatioOfGland);
            parfor numPartition = 2:nSR
                if numPartition ~= nSR
                    [samiraTablePerSR{numPartition}, areaValidCells{numPartition}] = unrollTube(infoPerSurfaceRatio{numPartition, 3}, fullfile(selpath, 'unrolledGlands', ['gland_SR_' num2str(numPartition)]), fullfile(selpath, 'valid_cells.mat'), fullfile(selpath, '3d_layers_info'), apicalAreaValidCells, rotationsOriginal);
                else
                    [samiraTablePerSR{numPartition}, areaValidCells{numPartition}] = unrollTube(infoPerSurfaceRatio{numPartition, 3}, fullfile(selpath, 'unrolledGlands', 'gland_SR_basal'), fullfile(selpath, 'valid_cells.mat'), fullfile(selpath, '3d_layers_info'), apicalAreaValidCells, rotationsOriginal);
                end
            end
            
            %% Calculate theoretical surface ratio
%             samiraTable = vertcat(samiraTablePerSR{:});
%             surfaceRatioOfGland_real = unique([samiraTable{:, 1}]);
%             totalPartitions = 10;
%             initialPartitions = (1:(totalPartitions-1))/totalPartitions;
%             surfaceRatioOfGland = surfaceRatioOfGland_real;
%             surfaceRatioOfGland(2:10) = initialPartitions * (surfaceRatioOfGland_real(end) - 1) + 1;
            
            for numPartition = 2:nSR
                sT_Actual = samiraTablePerSR{numPartition};
                sT_Actual(:, 1) = {surfaceRatioOfGland(numPartition)};
                samiraTablePerSR{numPartition} = sT_Actual;
            end
            
            samiraTable = vertcat(samiraTablePerSR{:});
        end
        
        %% Creating samira table
        samiraTableT = cell2table(samiraTable, 'VariableNames',{'Radius', 'CellIDs', 'TipCells', 'BorderCell','verticesValues_x_y'});
        
        newCrossesTable = lookFor4cellsJunctionsAndExportTheExcel(samiraTableT);
        
        writetable(samiraTableT, strcat(selpath, '\', idName ,'_samirasFormat.xls'));
        writetable(newCrossesTable, strcat(selpath, '\', idName ,'_VertCrosses.xls'));
    end
        
    %% Saving final information
    filesOf2DUnroll = dir(fullfile(selpath, '**', 'verticesInfo.mat'));
    if exist(fullfile(selpath, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'file') == 0 && length(filesOf2DUnroll) == 11
        load(fullfile(selpath, 'dividedGland' ,'glandDividedInSurfaceRatios.mat'), 'infoPerSurfaceRatio');
        
        load(fullfile(filesOf2DUnroll(1).folder, 'verticesInfo.mat'));
        apicalLayer = cylindre2DImage;
        infoPerSurfaceRatio{1, 6} = cylindre2DImage;
        [neighboursApical] = getNeighboursFromVertices(newVerticesNeighs2D);
        
        load(fullfile(filesOf2DUnroll(3).folder, 'verticesInfo.mat'));
        basalLayer = cylindre2DImage;
        infoPerSurfaceRatio{nSR, 6} = cylindre2DImage;
        [neighboursBasal] = getNeighboursFromVertices(newVerticesNeighs2D);
        
        neighboursOfAllSurfaces = cell(nSR, 1);
        for numSR = 1:nSR
            load(fullfile(filesOf2DUnroll(numSR).folder, 'final3DImg.mat'), 'img3d', 'neighbours');
            load(fullfile(filesOf2DUnroll(numSR).folder, 'verticesInfo.mat'), 'cylindre2DImage', 'newVerticesNeighs2D');
            %                 if isempty(newVerticesNeighs2D)
            %                     neighbours = calculateNeighbours3D(img3d, 2);
            %                     neighbours = checkPairPointCloudDistanceCurateNeighbours(img3d, neighbours.neighbourhood', 1);
            %                 end
            [total_neighbours3D] = getNeighboursFromVertices(newVerticesNeighs2D);
            midLayer = cylindre2DImage;
            
            splittedFolder = strsplit(filesOf2DUnroll(numSR).folder, '_');
            idToSave = str2double(splittedFolder{end});
            
            disp(['id to save: ' num2str(idToSave)])
            
            infoPerSurfaceRatio{idToSave, 6} = cylindre2DImage;
            [neighboursMid] = getNeighboursFromVertices(newVerticesNeighs2D);
            
            neighbours_data = table(neighboursApical, neighboursMid);
            neighbours_data.Properties.VariableNames = {'Apical','Basal'};
            neighboursOfAllSurfaces{idToSave} = neighboursMid;
            
            [infoPerSurfaceRatio{idToSave, 8}, infoPerSurfaceRatio{idToSave, 7}] = calculate_CellularFeatures(neighbours_data, neighboursApical, neighboursMid, apicalLayer, midLayer, img3d, noValidCells, validCells, [], [], total_neighbours3D);
            
        end
        
        %% Calculate theoretical surface ratio
        surfaceRatioOfGland_real = vertcat(infoPerSurfaceRatio{:, 7})';
%         totalPartitions = nSR;
%         initialPartitions = (1:(totalPartitions-1))/totalPartitions;
%         surfaceRatioOfGland = surfaceRatioOfGland_real;
%         surfaceRatioOfGland(2:10) = initialPartitions * (surfaceRatioOfGland_real(end) - 1) + 1;
        infoPerSurfaceRatio(:, 7) = num2cell(surfaceRatioOfGland_real)';
        
        infoPerSurfaceRatio = cell2table(infoPerSurfaceRatio, 'VariableNames', {'Image3DWithVolumen', 'SR3D', 'Layer3D', 'ApicalBasalCellFeatures3D', 'BasalApicalCellFeatures3D', 'UnrolledLayer2D', 'SR2D', 'ApicalBasalCellFeatures2D'});
        %             save(fullfile(selpath, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'cellularFeatures_BasalToApical', 'cellularFeatures_ApicalToBasal', 'meanSurfaceRatio');
        save(fullfile(selpath, 'glandDividedInSurfaceRatios_AllUnrollFeatures.mat'), 'infoPerSurfaceRatio', 'neighboursOfAllSurfaces');
    end
end

