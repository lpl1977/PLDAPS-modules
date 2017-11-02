function settings = callDefaultTrialFunction(p,state)
%callDefaultTrialFunction call default trial function at a specified
%priority
%
%  settings = callDefaultTrialFunction
%
%  This is a PLDAPS module for the openreception branch.  This module calls
%  the default trial function.
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  Lee Lovejoy
%  January 2017
%  ll2833@columbia.edu
%
%  November 2017 fixed some errors in module settings

if(nargin==0)
    
    %  Generate the settings structure for the module
    moduleName = 'moduleCallDefaultTrialFunction';
    
    settings.(moduleName).use = true;
    settings.(moduleName).stateFunction.name = 'callDefaultTrialFunction';
    settings.(moduleName).stateFunction.order = 0;
    settings.(moduleName).stateFunction.acceptsLocationInput = false;
    settings.(moduleName).stateFunction.requestedStates = struct(...
        'experimentAfterTrials',true,...
        'experimentCleanUp',true,...
        'experimentPostOpenScreen',true,...
        'experimentPreOpenScreen',true,...
        'trialCleanUpandSave',true,...
        'trialItiDraw',false,...
        'frameFlip',true,...
        'frameDrawingFinished',true,...
        'frameDraw',false,...
        'framePrepareDrawing',false,...
        'frameUpdate',true,...
        'trialPrepare',true,...
        'trialSetup',true);
else
    
    %  Execute state dependent components
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            fprintf('****************************************************************\n');
            fprintf('pldapsDefaultTrialFunction will be called by module\n');
            fprintf('****************************************************************\n');
    end
    
    %  Execute pldapsDefaultTrialFunction for all states called
    pldapsDefaultTrialFunction(p,state);
end
end

