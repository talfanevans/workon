%% Save and reload matlab workspace
%
% Talfan Evans (2016)
%
% Saves the files currently open and the workspace variables. If workspace
% variables sum to greater than a threshold size (in Mb, see 'Settings'),
% the user is flagged and given the option whether or not to save the
% workspace variables (set this to your preferred size).
%
% When creating a new workon file, the user is also prompted to enter a
% note. For short notes, use 'workon add' (notes are entered in the command
% line). For longer notes, use 'workon add long' (notes entered in a dialog
% box).
%
% To create a new workon file, use 'workon new'. The workon file is stored
% as a hidden file in the curent directory.
%
% '''workon new''        : Create new workon file
% '''workon save''       : Update the workon field to reflect the currently open windows
% ''workon add''         : Add a new short note
% '''workon add long''   : Add a new long note
% '''workon remove n''   : Remove note n from the workon file, where n is an integer
% '''workon view''       : View the workon notes
% '''workon''            : Don't include an argument to just load the workon file

function workon(varargin)

%% Settings
var_size_thresh = 25; % (Mb) The function will flag the user when saving if the total workspace has size greater than this number of Megabytes

%% Main File
d = dir('.workon_*');

if nargin<1
    
    % Load the workspace file located in the current directory
    if ~isempty(d)
        
        load(d(1).name); % Load the workon file
        
        % Open the files
        if isfield(wko,'fnames')
            for i = 1:length(wko.fnames)
                edit(wko.fnames{i});
            end
        end
        
        % Load the workspace
        if wko.workspace == 1
            d = dir('.wksp_*');
            if ~isempty(d)
                evalin('base',['load(''',d(1).name,''')'])
            end
        end
        
        % Display the notes
        disp(wko.message{1})
        for i = 1:length(wko.message{2})
            fprintf('%s\n',regexprep(wko.message{2}{i},'\\n','\\\n'))
        end
        
    else
        % Alert the user if no workon file found
        fprintf('No working history found\n')
    end
    
    
elseif strcmpi(varargin{1},'new')
    
    % Filename for session
    sd = seshdate;
    fname = ['.workon_',sd,'.mat'];
    fname2 = ['.wksp_',sd,'.mat'];
    
    % Get existing history
    oldhist = dir('.workon_*');
    
    % Load the open files from last time
    fls = matlab.desktop.editor.getAll;
    for i = 1:length(fls)
        wko.fnames{i} = fls(i).Filename;
    end
    
    % Save a message for next time the workspace is opened
    wko.message{1} = datestr(datetime,'dd_mm_yy_ss_MM_HH');
    %wko.message{2} = {['1: ',input('Leave a message:\n','s')]};
    if nargin>1
        if strcmpi(varargin{2},'long')
    mes = {['1: ',inputdlg('Press TAB then RETURN to finish entry','',10)]};
    mes = mes{:};
    mes = [mes,repmat('\n',size(mes,1),1)];
    tmp = []; for t=1:size(mes,1); tmp=[tmp,mes(t,:)]; end
    mes = tmp;
    wko.message{2} = mes;
        elseif strcmpi(varargin{2},'short')
            wko.message{2} = input('Enter note (use ''\\n'' for new lines):\n');
        end
    else
        wko.message{2} = input('Enter note (use ''\\n'' for new lines):\n');
    end
    
    % Save the workspace variables if required
    wks = evalin('base', 'whos');
    sz = sum([wks(:).bytes]);
    if (sz/1e6)>25
        reply = input(['Workspace variables sum to ',num2str(floor(sz/1e6)),' Mb. Save (Y/N)?: '],'s');
        if strcmpi(reply,'y')
            wko.workspace = 1;
            evalin('base', ['save(''',fname2,''')']);
            fileattrib(fname2,'+h'); % Set as hidden
        else
            wko.workspace = 0;
        end
    else
        wko.workspace = 1;
        evalin('base', ['save(''',fname2,''')']);
        fileattrib(fname2,'+h'); % Set as hidden
    end
    
    % Save the workon file
    save(fname,'wko')
    fileattrib(fname,'+h'); % Set as hidden
    
    % Delete the old file
    for i=1:length(oldhist)
        delete(oldhist(i).name)
    end
    
elseif strcmpi(varargin{1},'save')
    if ~isempty(d)
        load(d(1).name);
        
        sd = seshdate;
        fname2 = ['.wksp_',sd,'.mat'];
        
        % Save open tabs
        fls = matlab.desktop.editor.getAll;
        wko.fnames = {};
        for i = 1:length(fls)
            wko.fnames{i} = fls(i).Filename;
        end
        
        % Save the workspace variables if required
        wks = evalin('base', 'whos');
        sz = sum([wks(:).bytes]);
        if (sz/1e6)>var_size_thresh
            reply = input(['Workspace variables sum to ',num2str(floor(sz/1e6)),' Mb. Save (Y/N)?: '],'s');
            if strcmpi(reply,'y')
                wko.workspace = 1;
                evalin('base', ['save(''',fname2,''')']);
                fileattrib(fname2,'+h'); % Set as hidden
            else
                wko.workspace = 0;
            end
        else
            wko.workspace = 1;
            evalin('base', ['save(''',fname2,''')']);
            fileattrib(fname2,'+h'); % Set as hidden
        end
        
        delete(d(1).name)
        save(d(1).name,'wko')
        fileattrib(d(1).name,'+h'); % Set as hidden
    else
        fprintf('No working history found\n')
    end
    
elseif strcmpi(varargin{1},'add')
    if ~isempty(d)
        load(d(1).name);
        %reply = input('Add note:\n','s');
        if nargin>1
            if strcmpi(varargin{2},'long')
        reply = inputdlg('Press TAB then RETURN to finish entry','',10);
        reply = reply{:};
        reply = [reply,repmat('\n',size(reply,1),1)];
        tmp = []; for t=1:size(reply,1); tmp=[tmp,reply(t,:)]; end
        reply = tmp;
            elseif strcmpi(varargin{2},'short')
                reply = input('Add note (use the ''\\n'' for new line):\n');
            end
        else
            wko.message{2} = input('Enter note (use ''\\n'' for new lines):\n');
        end
        wko.message{2} = [wko.message{2},{[num2str(length(wko.message{2})+1),': ',reply]}];
        delete(d(1).name)
        save(d(1).name,'wko')
        fileattrib(d(1).name,'+h'); % Set as hidden
    else
        fprintf('No working history found\n')
    end
    
elseif strcmpi(varargin{1},'remove')
    if ~isempty(d)
        load(d(1).name);
        if nargin~=2
            error('Enter ''remove'' followed by a number to remove an entry.')
        end
        
        if isnumeric(varargin{2})
            num = varargin{2};
        elseif ischar(varargin{2})
            num = str2num(varargin{2});
            if isempty(num)
                error('Enter ''remove'' followed by a number to remove an entry.')
            elseif ~((num>0) && (num<=length(wko.message{2})))
                error('Enter ''remove'' followed by a number to remove an entry.')
            end
        else
            error('Enter ''remove'' followed by a number to remove an entry.')
        end
        
        wko.message{2} = wko.message{2}(setdiff(1:length(wko.message{2}),num));
        for i=1:length(wko.message{2})
            str = strsplit(wko.message{2}{i},':');
            wko.message{2}{i} = [num2str(i),':',str{2}];
        end
        delete(d(1).name)
        save(d(1).name,'wko')
        fileattrib(d(1).name,'+h'); % Set as hidden
    else
        fprintf('No working history found\n')
    end
    
elseif strcmpi(varargin{1},'view')
    if ~isempty(d)
        load(d(1).name);
        disp(wko.message{1})
        for i = 1:length(wko.message{2})
            fprintf('%s\n',regexprep(wko.message{2}{i},'\\n','\\\n'))
        end
    else
        fprintf('No working history found\n')
    end
    
else
    fprintf(['Command not found. Try:\n',...
        '''workon new''        : Create new workon file\n',...
        '''workon save''       : Update the workon field to reflect the currently open windows\n',...
        '''workon add''        : Add a new short note\n',...
        '''workon add long''   : Add a new long note\n',...
        '''workon remove n''   : Remove note n from the workon file, where n is an integer\n',...
        '''workon view''       : View the workon notes\n',...
        '''workon''            : Don''t include an argument to load the workon file\n'])
end

end

