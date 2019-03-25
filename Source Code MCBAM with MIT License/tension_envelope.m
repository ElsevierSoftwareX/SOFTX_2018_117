function sig = tension_envelope(epsc)
    global fc epsc0 fcu epscu lambda ft epst epstu % UHPC input parameters
    global Ec0 % UHPC computed parameters
	global failureFlag failure

    % if due to prestress, the section assumed to be in tension 
    % falls in compression, the following if loop takes care of it.
    if epsc<0
        sig = compression_envelope(epsc);
        return;
    end
    
	% eps0 = ft/Ec0;
	% epsu = ft*(1.0/Ets+1.0/Ec0
	eps1 = 0.8*ft/Ec0;
	eps2 = eps1 + 0.4*(epst-eps1);
	Eth = (ft - 0.8*ft)/(eps2-eps1);
	
   if (epsc<=eps1)
    sigc = epsc*Ec0;
    Ect  = Ec0;
  else
      if(epsc <= eps2)
		sigc = 0.8*ft + Eth*(epsc - eps1);
			
		Ect = Eth;
      else 
		if(epsc <=epst)
			sigc = ft;
			Ect = 1.0e-10; % ie practically zero
        else
			if (epsc<=epstu)
			Ect =  (0.7*ft-ft)/(epstu - epst);
			sigc = ft + Ect * (epsc - epst);
            else
				Ect =  1.0e-10;
				sigc = 0;
				
				% change a flag to indicate steel failure
				% failureFlag = true;
				
				% failure.Material = 'Concrete';
				% failure.Strain = epsc;
				% failure.Mode = 'Tension';
				
            end
            
        end
      end
  end
sig =sigc;

end