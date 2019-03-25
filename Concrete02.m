function sig = Concrete02(epsc,fc1, epsc01, fcu1, epscu1, ft1, Ets1)
    persistent fc epsc0 fcu epscu ft Ets n Ec0 epst epstu
    global failureFlag failure
	
% Reference: Mohd Hisham Mohd Yassin, "Nonlinear Analysis of Prestressed Concrete Structures under Monotonic and % Cycling Loads", PhD dissertation, University of California, Berkeley, 1994.
% Code reference taken from OpenSees
% Reference: Mazzoni, Silvia, et al. "OpenSees command language manual." Pacific Earthquake Engineering 
% Research (PEER) Center 264 (2006).
    
    if nargin ~= 1
        % input constant parameters
        fc = fc1;
        epsc0 = epsc01;
        fcu = fcu1;
        epscu = epscu1;
        
        ft = ft1;
        Ets = Ets1;
        
        n = 1;
        
        % computed constant parameters
        Ec0  = (n+1)/n*fc/epsc0;
        epst = ft/Ec0;
        epstu = epst + ft/Ets; % tensile strain at zero stress
        
        sig = [];
    else
    
        if epsc > 0
           sig = tension_envelope(epsc);
        else
            sig = compression_envelope(epsc);
        end
    end
    
    % function definition for compression envelope
    function sig = compression_envelope(epsc)
   
        if (epsc>=epsc0) % epsc >= epsc0 because it is a negative envelope
            alpha = (epsc/epsc0)^n; % SD degradation factor for E
            sig = Ec0*(epsc - epsc^(n+1)/((n+1)*epsc0^n));
        else    
            %   linear descending branch between epsc0 and epscu
            if (epsc>epscu)
              sig = (fcu-fc)*(epsc-epsc0)/(epscu-epsc0)+fc;

            elseif (epsc>=1.4*epscu)
                % flat friction branch for strains larger than epscu
                sig = fcu;
            else
                sig = 0;

                % change a flag to indicate steel failure
                failureFlag = true;

                failure.Material = 'concrete';
                failure.Strain = epsc;
                failure.Mode = 'compression';
            end 
        end 
    end % end of compression envelope function

    % Function definition for tension envelope
    function sig = tension_envelope(epsc)
        if (epsc<=epst)
            sig = epsc*Ec0;
        elseif epsc <= epstu
            sig = ft - Ets*(epsc-epst);  
        else
            sig = 0;
        end
    end % end of tension_envelope function

end
