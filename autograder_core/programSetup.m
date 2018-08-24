function outFile = programSetup(labNum, dueDate, roster, labParts,...
    regrade, manualGrading, pseudoDate)
%============================================BEGIN-HEADER=====
% FILE: programSetup.m
% AUTHOR: Caleb Groves
% DATE: 11 July 2018
%
% PURPOSE:
%   This function calls the autograder function with the appropriate
%   arguments, based on its own inputs. Its primary function is to make
%   sure that original grading is always done before regrading.
%
% INPUTS:
%   labNum - integer representing number for this lab
%
%   roster - structure containing two fields (name, path) for the .csv of
%   the class roster to link submissions to.
%
%   weights - structure with fields code, header, and comments, whose
%   values add up to 1. Used in calculating lab part grades.
%
%   labParts - cell array of structs with the following fields: name
%   (character array), dueDate (datetime object), submissionsDir (character
%   string), graderfile (structure with fields name, path as character
%   arrays)
%
%   regrade - 0: original grading, 1: re-grading mode
%
%   pseudoDate - Matlab datetime that the autograder will interpret as
%   "now" (useful for retroactive grading).
%
%
% OUTPUTS:
%   outFile - structure with fields <name> and <path> for the file created
%   from this grading run.
%
%
% NOTES:
%   
%
%
% VERSION HISTORY TRACKED WITH GIT
%
%==============================================END-HEADER======

% run config file
configVars = configAutograder(labNum);

% Get most recent file in the path for the lab files
[labPath, archivesPath, prevGraded] = getOrCreateLabRecord(labNum, ...
    configVars);

% If original grading (no file to read in)
if ischar(prevGraded)
    master = autograder(labNum, dueDate, roster, configVars, labParts, 0, ...
        manualGrading, pseudoDate); % call without passing in a file
else % if a table is read in
    master = autograder(labNum, dueDate, roster, configVars, labParts, 0, ...
        manualGrading, pseudoDate, prevGraded); % always do original grading first
end

if regrade % if we're going to grade resubmissions
    master = autograder(labNum, dueDate, roster, configVars, labParts, 1, ...
        manualGrading, pseudoDate, master); % run in regrading mode with output generated
    % by original grading run, above
end

%% Checkpoint

% Write out grades to appropriate folder location
answer = questdlg('Do you want to accept this grading effort?','Checkpoint',...
    'Yes','No','No');

% Exit the program if not desired to save the grades
if strcmp(answer,'No')
    return;
end

%% File Writing

% Write out static .csv in top level for uploads
uploadFile = fullfile(labPath,'ME273LabFeedback.csv');
writetable(master, uploadFile);

% Confirm that uploads to learning suite and gmail have been completed
uploadQuestion(1);
uploadQuestion(2);

% flip feedback flags
master = resetFeedbackFlags(master);

% delete upload file
delete(uploadFile);

% save static to archives
staticFilename = ['Lab',num2str(labNum),'Graded',datestr(pseudoDate,...
    '(yyyy-mm-dd HH-MM-SS)'),'.csv'];
writetable(master,fullfile(archivesPath,staticFilename));

% convert static to dynamic
outFile = staticToDynamic(master, configVars);

% save dynamic to top-level lab folder
dynamicFilename = ['Lab',num2str(labNum),'Graded_Current.csv'];
writetable(outFile,fullfile(labPath,dynamicFilename));

end % end of function
    