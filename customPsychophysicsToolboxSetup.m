function settings = customPsychophysicsToolboxSetup(p,state)
%customPsychophysicsToolboxSetup custom PTB settings for running PLDAPS
%
%  modules.customPsychophysicsToolboxSetup(p,state)
%
%  or
%
%  settings = modules.customPsychophysicsToolboxSetup
%
%  This is a PLDAPS module for the openreception branch.  Prior to
%  openScreen I need to set the head to the Datapixx screen so that the
%  beam position queries are directed there.
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  Lee Lovejoy
%  November 2016
%  ll2833@columbia.edu

if(nargin==0)
    %  Generate the settings structure
    stateFunction.order = -Inf;
    stateFunction.acceptsLocationInput = false;
    stateFunction.name = strcat('modules.',mfilename);
    requestedStates = 'experimentPreOpenScreen';
    
    module_name = strcat('module_',mfilename);
    
    settings.(module_name).stateFunction = stateFunction;
    settings.(module_name).use = true;
    settings.(module_name).requestedStates = requestedStates;
else
    %  Execute the state dependent components
    
    switch state
        case p.trial.pldaps.trialStates.experimentPreOpenScreen
            
            fprintf('****************************************************************\n');
            fprintf('Calling module customPsychophysicsToolboxSetup at state experimentPreOpenScreen\n');
            fprintf('Setting head screen to receive beam position queries\n');
            fprintf('****************************************************************\n')

            Screen('Preference','ScreenToHead', p.trial.display.scrnNum, 0, 0);
    end
end
end
