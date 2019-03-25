function sig =  Idealized_UHPC(epsc,fc1,Ec1,alpha1,epscu1,fcr1,gamma1,ftu1,epstu1)
    persistent gamma fcr Ec ftu epstu epscr; % tension parameters
    persistent alpha fc epsce epscu; % compression parameters
    global failureFlag failure
    % tension model parameters: gamma, fcr, Ec, epscr, epstu
        % fcr =  first cracking stress, 0.02% offset method on
                % stress-strain curve
        % cracking strain limit, gamma*epscr = gamma*fcr/Ec
        % Localization stress, ftu
        % Localization strain, epstu
        
    % compression parameters
        % alpha => alpha*fc

    if nargin ~=1
        % Initialize the material parameters upon first call using all the
        % material parameters
        
        % tension parameters
        gamma =  gamma1;
        fcr = gamma*fcr1;
        Ec = Ec1;
        ftu = gamma*ftu1;
        epstu = epstu1;
        
        epscr = fcr/Ec;
                
        % compression parameters
        alpha = alpha1;
        fc =  fc1;
        epscu = epscu1;
        
        epsce = alpha*fc/Ec;   
        
        % return empty stress parameter on initialization
        sig = [];        
    else    
        if epsc<0
            sig = comp_envelope;
        else
            sig = tens_envelope;
        end
    end

    % function definiton for tension envelope
    function sig = tens_envelope
       if epsc <= epscr
           sig = Ec*epsc;
       elseif epsc <= epstu
           sig = fcr + (ftu - fcr)/(epstu - epscr)*(epsc-epscr);
       else
           sig = 0;
       end
    end

    % function definition for compression envelope
    function sig = comp_envelope
        % NOTE: since epsc is negative, the signs for comparison are
        % inverted
        if epsc <= epscu
            sig = 0;
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'Idealized UHPC';
			failure.Strain = epsc;
			failure.Mode = 'Compression';
			
        elseif epsc <= epsce
            sig = alpha*fc;
        else
            sig = Ec*epsc;
        end
    end

end
