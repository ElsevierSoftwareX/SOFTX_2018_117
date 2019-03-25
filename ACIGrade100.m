function [fs] = ACIGrade100(es)
% source: Design Guide for the Use of ASTM A1035/A1035M Grade 100 (690)
%           Steel Bars for Structural Concrete (ACI ITG-6R-10)
% NOTE: For Grade 100 only

	global failureFlag failure
    Es = 29000;
    
		sgn = sign(es);
		es = abs(es);
		
		if es <= 0.0024
			fs = es*Es;
		elseif es > 0.0024 && es <= 0.02
			fs = 170 - 0.43/(es + 0.0019);
		elseif es > 0.02 && es <= 0.06
            fs = 150;
       else
            fs = 0;
			
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'Rebar';
			failure.Strain = es*sgn;
			
			if(es*sgn>0)'
				failure.Mode = 'Tension';
			else
				failure.Mode = 'Compression';
			end
		end
		
		fs = sgn * fs;	
end