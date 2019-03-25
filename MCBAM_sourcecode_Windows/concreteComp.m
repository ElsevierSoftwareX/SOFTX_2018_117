function [compConcrete, centroid] = concreteComp( phi,na,epsc_PS,plotStressStrain,sec_shape1,concrete1)
% function [UHPCcomp, centroid] = concreteComp( phi,na,epsc_PS,plotStressStrain,sec_shape,concrete)
% gives compression force for concrete and its centroid
% 
% Usage: 
% 1) First initialize the function with the sec_shape and concrete
% as input concreteComp( [],[],[],[],sec_shape,concrete) using 6 input
% parameters
% 2) to get  [ConcreteComp, centroid], input only the first 3
% parameters, eg: concreteComp( phi,na,epsc_PS)
% 3) to store data to plot stress-variation along the section depth, set 
% plotStressStrain = true, eg: concreteComp( phi,na,epsc_PS,true)

persistent sec_shape concrete
global plotStress plotZ;
    
% make sure the concreteComp is run before concreteTens, because it would
% otherwise delete the plotZ and plotStress data from the tension part.
    plotStress = [];
    plotZ = [];

    if nargin == 6
        % initialize the function so that it stores the sec_shape and the
        % concrete function to be used
        sec_shape = sec_shape1;
        concrete = concrete1;
        
        compConcrete = true;
        centroid = true;
        return;
    elseif nargin <4
        plotStressStrain = false;
    end
    
    zincr = na/100;
    
    % Initialization
    Z = zeros(1,floor(na/zincr));
    stress = zeros(1,floor(na/zincr));
    area_strip = zeros(1,floor(na/zincr));
    
    xmax = max(sec_shape.Vertices(:,1));
    xmin = min(sec_shape.Vertices(:,1));
    
    intersecting_strip_x = [xmin xmin xmax xmax];
    intersecting_strip_y = [0 zincr zincr 0];
    clear xmax xmin
    
    i=1; % counter
    
    if na>max(sec_shape.Vertices(:,2))
       na = max(sec_shape.Vertices(:,2));
    end
    for z = na:-zincr:zincr % z varies from the top concrete fiber to the neutra axis; ie z=na indicates top compression fiber
        currentStress = concrete(-phi*z + epsc_PS); % epsc_PS = -tensPS/(A*Ec0);
        Z(i) = z;
        stress(i) = currentStress;
   
        % intersecting strip
        intersecting_strip = polyshape(intersecting_strip_x,intersecting_strip_y);
        intersecting_strip_y = intersecting_strip_y + zincr;
        
        area_strip(i) = area(intersect(intersecting_strip,sec_shape));

        i=i+1;
    end

    if plotStressStrain == true
        plotZ = [na-Z];
        plotStress = [stress];
    end
    

    compConcrete = area_strip*stress';
    %centroid of compression force from the neutral axis
	if abs(compConcrete)<0.0001
		centroid = 0;
	else
		centroid = (area_strip.*stress)*Z'/(compConcrete);
	end
    
    
end
