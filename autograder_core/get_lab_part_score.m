function score_text = get_lab_part_score(configVars)
%============================================BEGIN-HEADER=====
% FILE: 
% AUTHOR: Caleb Groves
% DATE: 5 June 2018
%
% PURPOSE:
%   Write out a string interpretable by spreadsheet programs for
%   calculating the lab part score based on weights for the code, header,
%   and comments.
%
% INPUTS:
%   weights - a Matlab structure with fields: code, header, and comments,
%   whose values add up to 1.0
% 
%   r - integer value of the current spreadsheet row
% 
%   s - integer value of the current lab part starting column
%
%
% OUTPUTS:
%   score_text - character array with references to "cells" in a
%   spreadsheet using the Excel RxCy format.
%
%
% NOTES:
%   
%
%
% VERSION HISTORY TRACKED WITH GIT
%
%==============================================END-HEADER======

% expression for the score
score = [num2str(configVars.weights.code),'*RC[1]+',num2str(configVars.weights.header),...
    '*RC[2]+',num2str(configVars.weights.comments),'*RC[3]'];

score_text = ['=IF(RC[-1]=1,IF(',score,'>=0.8,0.8,',score,'),',...
    score,')'];

end % end of function