function fps =PSPowerEqn(eps,E_ps1,fpy1,Q1,K1,R1)
% Function definition based on the Power Equation presented by Skogman et al.
% (1998)
% Source: B. C. Skogman, M. K. Tadros and R. Grasmick, "Flexural Strength 
% of Prestressed Concrete Members," PCI Journal, vol. 33, no. 5, pp. 96-123, September-October 1998. 

	persistent E_ps fpy Q K R;
	global failureFlag failure
	
	if nargin ~=1
        E_ps = E_ps1;
		fpy = fpy1;
		Q = Q1;
		K = K1;
		R = R1;
		
	else
		sgn = sign(eps);
		eps = abs(eps);
		
		if eps<=0.05
			fps = eps*E_ps*(Q + (1-Q)/(1+((E_ps*eps)/(K*fpy))^R)^(1/R));
		else
			fps = 0;
		
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'PS Strands';
			failure.Strain = eps*sgn;
			
			if(eps*sgn>0)'
				failure.Mode = 'Tension';
			else
				failure.Mode = 'Compression';
			end
		
		end
		fps = sgn*fps;
	end
end
