function log = import_pres_log(logfiles,start)
% IMPORT_PRES_LOG(LOGFILES) imports data from Presentation log files as
% Matlab variables. LOGFILES must be a string and can be either the name of a 
% single log file (e.g. 'exp1_s01.log') or the name of a directory
% containing one or more log files (e.g. '/Users/P/Documents/').
% 
% The function returns the cell structure LOG (one cell per logfile) which
% contains the fields NAME (= the filename) as well as the vectors EVENT,
% CODE, and TIME which contain data from the corresponding columns in the 
% log file. TIME values are converted into seconds.
%
% START (optional) must be a string that corresponds to the value of the 
% "Event Type" column of the beginning line of the experiment (e.g.
% 'Start'). Preceding lines are discarded for EVENT, CODE, and TIME.
% The default is to start with the first line after the column names.
%
% Philipp Ludersdorfer (philipp.ludersdorfer@gmail.com)
% Last edited 18/10/2016


%% Check input arguments
if exist(logfiles,'dir') % 'logfiles' is a directory
    filelist = cellstr(ls([logfiles,'\*.log']));
    filepath = logfiles;
    if length(filelist)==1 && isempty(filelist{1})
        error('There are no logfiles in the directory!')
    end
elseif exist(logfiles,'file') % 'logfiles' is a file
    if strcmp(logfiles(end-3:end),'.log')
        [filepath,name,ext] = fileparts(logfiles);
        filelist{1} = [name ext];
    else
        error('Filename is not a valid logfile!')
    end
else % 'logfiles' is not valid
    error('Name is not an existing file or directory!')
end

if (nargin < 2); start = ''; end % if not provided set 'start' to default


for fileindex = 1:length(filelist) % loop over files
            
    %% Get format of logfile
    %  Theoretically, all presentation logfiles should have the same format: 
    %  2 line header, then an empty line followed by x lines with 9 columns. 
    %  But you never know. Therefore the following code finds out 1) the index 
    %  of the first line after the header and 2) the format of the file (= a 
    %  string in the form of "%s %s %s ..." where "%s" represents a string 
    %  and "\t" represents a tabulator.
    
    % Open file
    fid = fopen(fullfile(filepath,filelist{fileindex}));
    % Look for empty line (= end of header)
    emptyline = 0; l_index = 0; 
    while ~emptyline
        l_index = l_index + 1;  % and automatically jumps to next line 
        line = fgetl(fid);      % fgetl reads current(!) line of text file 
        if isempty(line)
            line = fgetl(fid); % read first line following the empty line
            ncol = sum(uint8(line)==9)+1; % get number of columns by counting tabs (+1)
            fstr = ''; % initialize format string
            for iCol = 1:ncol 
                fstr = [fstr '%s']; % save format string into colstr
            end
            emptyline = 1; % exit while loop
        end
    end
    fclose(fid); % close log-file
    clear fid emptyline line ncol lineofinterest iCol
    
    %% Get data from logfile
    %  After obtaining the file format we can move on to read in the data
    
    % Open file (again)
    fid = fopen(fullfile(filepath,filelist{fileindex}));
    % Write into string variable strdata using the format string (fstr) from above 
    strdata = textscan(fid,fstr,'Delimiter','\t','Headerlines',l_index); 
    % Close file
    fclose(fid);
    
    % Get data from string
    for iCount = 1:length(strdata)
        if find(ismember(strdata{iCount},'Time')) % find "Time" column 
            time = str2double(strdata{4}(2:end)); % save numerical vector
        end
        if find(ismember(strdata{iCount},'Code')) % find "Code" column
            code = strdata{iCount}(2:end); % save string (cell) vector
        end
        if find(ismember(strdata{iCount},'Event Type')) % find "Event type" column
            event = strdata{iCount}(2:end); % save string (cell) vector
        end
    end
    
    %% Adjust time vector to start with zero and change units to seconds
    
    if ~isempty(start) % In case a specific start line was provided
        startind = find(strcmp(start,code));
        time = time(startind:end);
        event = event(startind:end);
        code = code(startind:end);
    end
    
    % Subtract start time from time and change units to seconds
    time = (time-time(1))/10000; 
    
    %% Save data
    log(fileindex).name = filelist{fileindex};
    log(fileindex).time = time;
    log(fileindex).event = event;
    log(fileindex).code = code;
end