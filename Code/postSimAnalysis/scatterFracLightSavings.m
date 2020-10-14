function [fracLight, savings] = scatterFracLightSavings(path, color, varargin)
    [fracLight, savings, ~, ~, labels] = ...
        fracLightVsTotalSavings(path);

    for k=1:length(labels)
        name = labels{k};
        locations{k} = upper(name(end-6:end-4));
    end
    locations=locations(1:2:end);

    scatter(fracLight,savings,70,color,varargin{:});
    text(fracLight+0.3,savings-0.3,locations,'Color',color,'FontSize', 12);
end