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

if(nargin==0)
    
    %  Generate the settings structure
    stateFunction.order = -Inf;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = filename;
    requestedStates.all = true;
    moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;
else
    
    %  Execute state dependent components
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            filename = mfilename;
            moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));
            fprintf('****************************************************************\n');
            fprintf('pldapsDefaultTrialFunction will be called at priority %d\n',...
                p.trial.(moduleName).stateFunction.order);
            fprintf('****************************************************************\n');
    end
    
    %  Execute pldapsDefaultTrialFunction for all states
    pldapsDefaultTrialFunction(p,state);
end
end

