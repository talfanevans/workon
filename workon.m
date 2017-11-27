%% Save and reload matlab workspace
%
% Talfan Evans (2016)
%
% *** To install, just go to the directory where you downloaded workon.m ***
% *** and type: 'workon setup' *********************************************
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
% At any time, use 'workon help' to get a reminder of the following:
%
% '''workon new''        : Create new workon file
% '''workon save''       : Update the workon field to reflect the currently open windows
% '''workon add''        : Add a new short note
% '''workon add long''   : Add a new multiline note
% '''workon remove n''   : Remove note n from the workon file, where n is an integer
% '''workon view''       : View the workon notes
% '''workon delete''     : Delete the workon file
% '''workon''            : Don't include an argument to just load the workon file
% '''workon setup''      : Use to setup workon when you first download 

function workon(varargin)

%% Settings
var_size_thresh = 25; % (Mb) The function will flag the user when saving if the total workspace has size greater than this number of Megabytes

%% Main File
d = dir('.workon_*');

% Temporarily wrap lines in the command window if this option isn't set
% already
set = com.mathworks.services.Prefs.getBooleanPref('CommandWindowWrapLines');
if set==0
    com.mathworks.services.Prefs.setBooleanPref('CommandWindowWrapLines',1)
end


if nargin<1
    
    % Load the workspace file located in the current directory
    if ~isempty(d)
        
        load(d(1).name); % Load the workon file
        
        % Clear currently open files
        h = matlab.desktop.editor.getAll;
        h.close

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
            mes = strsplit(wko.message{2}{i},'\\n');
            for w = 1:length(mes)
                fprintf('%s\n',mes{w})
            end
        end
        
    else
        % Alert the user if no workon file found
        fprintf('No working history found\n')
    end
    
    
elseif strcmpi(varargin{1},'setup')
    
    % Add the current directory to the matlab path
    evalc('addpath(pwd)');
    [flag] = savepath();
    if ~flag; fprintf('workon path saved succesfully.\n'); else; fprintf('workon path could not be saved. Check file permissions etc.\n'); end
    
    % Take a tour of workon.m if required
    res = input('Would you like to take a tour? (y/n)\n','s');
    if any(strcmpi(res,{'y','yes'}))
        
        clc;
        
        fprintf(['Hello! Typing ''workon new'' will save a new workon file in the current directory. ',...
                 'The workon file saves the windows currently open, the current variables (this is optional) ',...
                 'and also prompts you to enter some notes describing the current progress of your project.\n\n']); pause
             
        fprintf(['You can try doing this after the demo has finished. After you have done so, ',...
                 'try closing all your windows and clearing your workspace with ''clearvars''. ',...
                 'To re-load your session, type ''workon''.\n\n']); pause
             
        fprintf(['If you want to view the notes without reloading the whole workon file, use ''workon view''.\n\n']); pause
        
        fprintf(['If you want to add additional notes, use ''workon add''. You can remove notes using ''workon remove n'', where n is an integer (this wil beecome clear when you start using workon).\n\n']); pause
        
        fprintf(['***Most importantly, type ''workon h'' or ''workon help'' at any time to get a friendly reminder of all these functions ;)***.\n\n']); pause
        
        fprintf('Done!\n\n')
        
    end    
    
elseif strcmpi(varargin{1},'new')
    
    % Filename for session
    sd = seshdate;
    fname = ['.workon_',sd,'.mat'];
    fname2 = ['.wksp_',sd,'.mat'];
    
    % Get existing history
    oldfile = dir('.workon_*');
    olddata = dir('.wksp_');
    
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
            reply = reply'; reply = reply(:)';
            
            mes = {['1: ',inputdlg('Enter note:','',10)]};
            mes = mes{:};
            mes = [mes,repmat('\n',size(mes,1),1)];
            mes = mes'; mes = mes(:)';
            wko.message{2}{1} = mes;
        elseif strcmpi(varargin{2},'short')
            wko.message{2} = {['1: ',input('Enter note (use ''\\n'' for new lines):\n','s')]};
        end
    else
        wko.message{2} = {['1: ',input('Enter note (use ''\\n'' for new lines):\n','s')]};
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
    % Delete the old file
    for i=1:length(oldfile)
        delete(oldfile(i).name)
    end    
    
    for i=1:length(olddata)
        delete(olddata(i).name)
    end
    
elseif strcmpi(varargin{1},'delete')
    
    % Get existing history
    oldfile = dir('.workon_*');
    olddata = dir('.wksp_*');

    % Delete the old file
    for i=1:length(oldfile)
        delete(oldfile(i).name)
    end    
    
    for i=1:length(olddata)
        delete(olddata(i).name)
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
                reply = inputdlg('Enter note:','',10);
                reply = reply{:};
                reply = [reply,repmat('\n',size(reply,1),1)];
                reply = reply'; reply = reply(:)';
            elseif strcmpi(varargin{2},'short')
                reply = input('Add note (use the ''\\n'' for new line):\n','s');
            end
        else
            reply = input('Enter note (use ''\\n'' for new lines):\n','s');
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
                error('Number not within the bounds of the current number of entries. Use ''workon view'' to see current entries\n')
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
            mes = strsplit(wko.message{2}{i},'\\n');
            for w = 1:length(mes)
                fprintf('%s\n',mes{w})
            end
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
        '''workon delete''     : Delete the workon file',...
        '''workon''            : Don''t include an argument to load the workon file\n'])
end

% Reset the command window wrapping
% Temporarily wrap lines in the command window if this option isn't set
% already
if set==0
    com.mathworks.services.Prefs.setBooleanPref('CommandWindowWrapLines',0)
end

end

