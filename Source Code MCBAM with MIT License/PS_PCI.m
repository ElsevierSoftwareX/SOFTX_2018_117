function sig = PS_PCI(strn,grade1,E_ps1)
% function to return the stress in the prestressing strand
% PS_sig(prestressing steel grade in ksi, strain (+ve))
% E_ps = 28500 ksi

% Definition as per PCI Design Hanbook
% Reference: L. D. Martin and C. J. Perry, Eds., PCI Design Hanbook, 6 ed., Chicago: Precast/Prestressed Concrete Institute, 2004. 

persistent grade E_ps
global failureFlag failure


	if nargin ~=1
		grade = grade1;
		E_ps = E_ps1;
		sig = 0;
	else

		sgn = sign(strn);
		strn = abs(strn);
		
		if grade ==0
			sig = 0;
		elseif strn <= 0.008
			sig = E_ps .* strn;
		elseif strn > 0.04
			sig = 0;
			
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'PS Strands';
			failure.Strain = strn*sgn;
			
			if(strn*sgn>0)'
				failure.Mode = 'Tension';
			else
				failure.Mode = 'Compression';
			end
			
		else
			if (grade == 270)
				sig = 268 - 0.075./(strn - 0.0065);

				if sig > 0.98 * 270
					sig = 0.98*270;
				end

			elseif (grade == 250)
				sig = 248 - 0.058./(strn - 0.006);

				if sig > 0.98 * 250
					sig = 0.98*250;
				end
			end
		end
		
		sig = sgn * sig;
	end

end