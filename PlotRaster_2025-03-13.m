
yourfilename = uigetfile('*.xlsx'); %Brings up a GUI that allows you to select your Excel file

if ~exist(yourfilename, 'file')
        error('File not found: %s', yourfilename);
    end
    
    % Get all sheet names in your behavior datasheet
    [~, sheetNames] = xlsfinfo(yourfilename);
    numSheets = length(sheetNames);
    
    % Initialize the cell array to store worksheets
    worksheets = cell(numSheets, 1);
    worksheetNames = cell(numSheets, 1);
    
    % Import each worksheet
    for i = 1:numSheets
        try
            % Read the data from the current worksheet
            worksheets{i} = readmatrix(yourfilename, 'Sheet', sheetNames{i});
            worksheetNames{i} = sheetNames{i};
            
            % Display progress
            fprintf('Imported worksheet: %s\n', sheetNames{i});
        catch e
            % Handle errors for individual worksheets
            warning('Failed to import worksheet "%s": %s', sheetNames{i}, e.message);
            worksheets{i} = [];
        end
    end
    
    % Add sheet names as properties of the output cell array
    worksheets = struct('Data', {worksheets}, 'SheetNames', {worksheetNames});
    
    fprintf('Completed importing %d worksheets from %s\n', numSheets, yourfilename); 
    
% Calculate and list all the frames spent pushing by each worm 

    numCells = numel(worksheets.Data); %Get the number of cells in the Data cell array

    for p = 1:numCells
    
    inputMatrix = worksheets.Data{p};
    [numRows, numCols] = size(inputMatrix);
    
    if numCols < 2
        error('Input array must have at least 2 columns');
    end
    
    % Initialize the empty array to store all values
    resultPushes = [];
    
    % Process each row
    for i = 1:numRows
        % Get start and end values from columns 1 and 2
        startVal_pushes = inputMatrix(i, 1);
        endVal_pushes = inputMatrix(i, 2);
        
        sequence_pushes = startVal_pushes:1:endVal_pushes; 
        
        % Make sure that your data are listed with the higher value in the
        % second column and lower value in the first column or this will
        % fail

        resultPushes = [resultPushes; sequence_pushes(:)];

    end
    
    pushes{p} = resultPushes;

    end

    % Calculate and list all the frames spent burrowing by each worm 

    for p = 1:numCells
    
    inputMatrix = worksheets.Data{p};
    [numRows, numCols] = size(inputMatrix);
    
    if numCols < 5
        error('Input array must have at least 5 columns');
    end
    
    % Initialize the empty array to store all values
    resultBurrowing = [];
    
    % Process each row
    for i = 1:numRows
        % Get start and end values from columns 1 and 2
        startVal_burrowing = inputMatrix(i, 4);
        endVal_burrowing = inputMatrix(i, 5);
        
        sequence_burrowing = startVal_burrowing:1:endVal_burrowing; 
        
        % Make sure that your data are listed with the higher value in the
        % second column and lower value in the first column or this will
        % fail

        resultBurrowing = [resultBurrowing; sequence_burrowing(:)];

    end
    
    % Remove NaN values
    cleanedResultBurrowing = resultBurrowing(~isnan(resultBurrowing));
    disp(['Removed ' num2str(numel(resultBurrowing) - numel(cleanedResultBurrowing)) ' NaN values from vector.']);
    
    burrowing{p} = cleanedResultBurrowing;

    end

% Store puncture, aborted, and completed frames as distinct single
% column matrices and remove any NaN

for p = 1:numCells
    punctureAll = worksheets.Data{p}(:,3);
    puncture{p} = punctureAll(~isnan(punctureAll));
    abortedAll = worksheets.Data{p}(:,6);
    aborted{p} = abortedAll(~isnan(abortedAll));
    completedAll = worksheets.Data{p}(:,7);
    completed{p} = completedAll(~isnan(completedAll));
end

% Divide all frame numbers by 120 to store the value in minutes

for p = 1:numCells
    pushesmin{p} = (pushes{p})/120;
    puncturemin{p} = (puncture{p})/120;
    burrowingmin{p} = (burrowing{p})/120;
    abortedmin{p} = (aborted{p})/120;
    completedmin{p} = (completed{p})/120;
end

%Plot the behaviors for each worm as a raster plot 
 
pushArray = pushesmin;
punctureArray = puncturemin;
burrowingArray = burrowingmin;
abortedArray = abortedmin;
completedArray = completedmin;

    % Default parameters
    p = inputParser;
    addParameter(p, 'ColorPushes', '#E9CA53');
    addParameter(p, 'ColorPunctures', '#097F98');
    addParameter(p, 'ColorBurrowing', '#F1F0EF');
    addParameter(p, 'ColorAborted', '#E600C7');
    addParameter(p, 'ColorCompleted', '#730012');
    addParameter(p, 'Marker', '|');
    addParameter(p, 'MarkerSize', 10);
    addParameter(p, 'LineWidth1', 1);
    addParameter(p, 'LineWidth2', 2);
    addParameter(p, 'YLabel', 'Worms');
    addParameter(p, 'XLabel', 'Minutes');
    addParameter(p, 'Title', 'Raster Plot');
    addParameter(p, 'YTickLabels', []);
    parse(p);
    
    % Extract parameters
    params = p.Results;
    
    % Create a figure
    figure;
    hold on;
    
    % Loop through each cell and plot its contents
    for i = 1:numCells
        % Get the current cell's data
        data_pushes = pushArray{i};
        data_punctures = punctureArray{i};
        data_burrowing = burrowingArray{i};
        data_aborted = abortedArray{i};
        data_completed = completedArray{i};
        
        % Ensure data is a row vector and if not, transpose it
        if size(data_pushes, 1) > 1 && size(data_pushes, 2) == 1
            data_pushes = data_pushes';
        end

        if size(data_punctures, 1) > 1 && size(data_punctures, 2) == 1
            data_punctures = data_punctures';
        end

        if size(data_burrowing, 1) > 1 && size(data_burrowing, 2) == 1
            data_burrowing = data_burrowing';
        end

        if size(data_aborted, 1) > 1 && size(data_aborted, 2) == 1
            data_aborted = data_aborted';
        end

        if size(data_completed, 1) > 1 && size(data_completed, 2) == 1
            data_completed = data_completed';
        end
        
        % Plot the data for this cell
        plot(data_pushes, i * ones(size(data_pushes)), params.Marker, ...
             'Color', params.ColorPushes, ...
             'MarkerSize', params.MarkerSize, ...
             'LineWidth', params.LineWidth1);
          plot(data_burrowing, i * ones(size(data_burrowing)), params.Marker, ...
             'Color', params.ColorBurrowing, ...
             'MarkerSize', params.MarkerSize, ...
             'LineWidth', params.LineWidth1);
          plot(data_aborted, i * ones(size(data_aborted)), params.Marker, ...
             'Color', params.ColorAborted, ...
             'MarkerSize', params.MarkerSize, ...
             'LineWidth', params.LineWidth1);
          plot(data_punctures, i * ones(size(data_punctures)), params.Marker, ...
             'Color', params.ColorPunctures, ...
             'MarkerSize', params.MarkerSize, ...
             'LineWidth', params.LineWidth1);
          plot(data_completed, i * ones(size(data_completed)), params.Marker, ...
             'Color', params.ColorCompleted, ...
             'MarkerSize', params.MarkerSize, ...
             'LineWidth', params.LineWidth2);
    end
    
    % Set the y-axis limits and direction
    ylim([0.5, numCells + 0.5]);
    set(gca, 'YDir', 'normal'); % Traditional raster plot has index 1 at the top

    %Set the x-axis limits
    xlim([0.0, 5.0])
    
    % Set custom y-tick labels if provided
    if ~isempty(params.YTickLabels)
        if length(params.YTickLabels) ~= numCells
            warning('Length of YTickLabels does not match number of cells. Using default indices.');
        else
            set(gca, 'YTick', 1:numCells, 'YTickLabel', params.YTickLabels);
        end
    else
        set(gca, 'YTick', 1:numCells);
    end
    
    % Set labels and title
    xlabel(params.XLabel);
    ylabel(params.YLabel);
    title(params.Title);
    
    % Add grid lines if you want
    grid off;
    
    hold off;