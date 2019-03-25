function [tensConcrete, centroid] = concreteTensCompForce(phi,na,epsc_PS,plotStressStrain,sec_shape1,concrete1)
    persistent sec_shape concrete
    global plotStress plotZ; % plotStress and plotZ are initialized as empty array in concreteComp
   
    if nargin == 6
        % initialize the function so that it stores the sec_shape and the
        % concrete function to be used
        sec_shape = sec_shape1;
        concrete = concrete1;
        
        tensConcrete = true;
        centroid = true;
        return;
    elseif nargin <4
        plotStressStrain = false;
    end

    zincr = (max(sec_shape.Vertices(:,2))-na)/100;
    
    % Initialization
    Z = zeros(1,100);
    stress = zeros(1,100);
    area_strip = zeros(1,100);
        
    xmax = max(sec_shape.Vertices(:,1));
    xmin = min(sec_shape.Vertices(:,1));
    
    intersecting_strip_x = [xmin xmin xmax xmax];
    intersecting_strip_y = [0 zincr zincr 0] + na;
    clear xmax xmin
    
    i=1; % counter
    
    for z = zincr:zincr:max(sec_shape.Vertices(:,2))
        currentStress = concrete(phi*z + epsc_PS); %epsc_PS = -tensPS/(A*Ec0);
        
            Z(i) = z;
            stress(i) = currentStress;
        
        intersecting_strip = polyshape(intersecting_strip_x,intersecting_strip_y);
        intersecting_strip_y = intersecting_strip_y + zincr;
        area_strip(i) = area(intersect(intersecting_strip,sec_shape));
        
        
        i=i+1;
    end
    
    if plotStressStrain == true
                plotZ = [plotZ na+Z(end:-1:1)];
                plotStress = [plotStress stress(end:-1:1)];
                
    end
    
    tensConcrete= area_strip*stress';

    %centroid of tensile force from the neutral axis
    centroid = (area_strip.*stress)*Z'/(tensConcrete); 
end
