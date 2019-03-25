function stress = customConcrete(strain,curve_values)
persistent stress_strain;
    if nargin ~=1
        stress_strain = curve_values;
        stress = [];
    end

    if strain <min(stress_strain(:,1)) | strain>max(stress_strain(:,1))
        stress = 0;
    else
        stress = interp1(stress_strain(:,1),stress_strain(:,2),strain,'Linear');
    end
end

    
