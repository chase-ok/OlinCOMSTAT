function [X Y] = depthVsCoverage(results)
    X = (1:length(results.Coverage)).*results.Voxel(3); 
    Y = results.Coverage;
end