function settings = moduleTable(p,~)
%moduleTable display a table of modules in experimentPostOpenScreen
%
%  settings = moduleTable
%
%  Lee Lovejoy
%  November 2017
%  ll2833@columbia.edu

if(nargin==0)
    
    %  Generate the settings structure for the module
    moduleName = 'moduleTable';
    
    settings.(moduleName).use = true;
    settings.(moduleName).stateFunction.name = 'moduleTable';
    settings.(moduleName).stateFunction.order = -Inf;
    settings.(moduleName).stateFunction.acceptsLocationInput = false;
    settings.(moduleName).stateFunction.requestedStates = struct(...
        'experimentPostOpenScreen',true);
else
    
    [modulesNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs,moduleOrder] = getModules(p);
    
    fprintf('****************************************************************\n');
    fprintf('Using modular state functions:\n');
    fprintf('%s %-6s %-40s %-40s %s\n','#','order','module name','function handle','accepts location input');
    for i=1:numel(modulesNames)
        fprintf('%d %-6d %-40s %-40s %d\n',i,moduleOrder(i),modulesNames{i},strcat('@',func2str(moduleFunctionHandles{i})),moduleLocationInputs(i));
    end
    fprintf('\nRequested states:\n');
    disp(moduleRequestedStates)
    fprintf('****************************************************************\n');
end

end