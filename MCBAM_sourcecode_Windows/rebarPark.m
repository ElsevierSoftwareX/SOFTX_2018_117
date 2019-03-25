function [fs] = rebarPark(es,fy1,fsu1,Es1,esh1,eult1,E_final_slope_multiplier)
% source: SAP2000 documentation : S-TN-MAT-001.pdf , Rebar parametric
% stress strain curves
	persistent fy fsu Es esh eult E_deg ey e0
    global failureFlag failure
    if nargin ~=1
        % indicates change to steel parameters. So, set the persistent
        % parameters
		fy = fy1;
		fsu = fsu1;
		Es = Es1;
		esh = esh1;
		eult = eult1; 
        E_deg = -abs(E_final_slope_multiplier) * Es;
        ey =  fy/Es;
		
        % calculate the strain when the stress falls to zero beyond the
        % ultimate yield strain (i.e where the linear degradation from eult
        % meets the stress axis)
        e0 = eult - fsu/E_deg ; % - because E_deg is negative
	else

		
        
		sgn = sign(es);
		es = abs(es);
		
		if es <= ey
			fs = es*Es;
		elseif es > ey && es <= esh
			fs = fy;
		elseif es > esh && es <= eult
            r = eult - esh;
            m = ((fsu/fy)*(30*r+1)^2 - 60*r -1)/(15*r^2);
            fs = fy*((m*(es - esh)+2)/(60*(es - esh) +2 )+ (es - esh)*(60-m)/(2*(30*r+1)^2));
        elseif es < e0
			fs = fsu + E_deg*(es-eult);
			
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'Rebar';
			failure.Strain = es*sgn;
			
			if(es*sgn>0)'
				failure.Mode = 'Tension';
			else
				failure.Mode = 'Compression';
			end
        else
            fs = 0;			
			
		end
		
		fs = sgn * fs;
	end
end