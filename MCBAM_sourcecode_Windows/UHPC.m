function sig = UHPC(epsc,fc1, epsc01, fcu1, epscu1, ft1, epst1, epstu1, n1)
    persistent fc epsc0 fcu epscu ft epst epstu n Ec0 eps1 eps2 Eth
    global failureFlag failure
    
% Copyright 2018 Suresh Dhakal, Mohamed A. Moustafa
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the "Software"),
%  to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the 
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
% DEALINGS IN THE SOFTWARE.


    if nargin ~= 1
        % input constant parameters
        fc = fc1;
        epsc0 = epsc01;
        fcu = fcu1;
        epscu = epscu1;
        
        ft = ft1;
        epst = epst1;
        epstu = epstu1;
        
        n = n1;
        
        % computed constant parameters
        Ec0  = (n+1)/n*fc/epsc0;
        
        eps1 = 0.8*ft/Ec0;
        eps2 = eps1 + 0.4*(epst-eps1);
        Eth = (ft - 0.8*ft)/(eps2-eps1);
        
        % return empty stress
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
            Ect = Ec0*(1-alpha);
            sigc = Ec0*(epsc - epsc^(n+1)/((n+1)*epsc0^n));
        else    
            %   linear descending branch between epsc0 and epscu
            if (epsc>epscu)
              sigc = (fcu-fc)*(epsc-epsc0)/(epscu-epsc0)+fc;
              Ect  = (fcu-fc)/(epscu-epsc0);

            elseif (epsc>=1.4*epscu)
                % flat friction branch for strains larger than epscu
                sigc = fcu;
                Ect  = 1.0e-10;
                % Ect  = 0.0
            else
                sigc = 0;
                Ect  = 1.0e-10;
                % Ect  = 0.0

                % change a flag to indicate steel failure
                failureFlag = true;

                failure.Material = 'UHPC';
                failure.Strain = epsc;
                failure.Mode = 'compression';
            end 
        end 
        sig = sigc;	
    end % end of compression envelope function

    % Function definition for tension envelope
    function sig = tension_envelope(epsc)
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
                    Ect =  -ft/(epstu - epst);
                    sigc = ft + Ect * (epsc - epst);
                    else
                        Ect =  1.0e-10;
                        sigc = 0;
                    end
                end
            end
        end % if (epsc<=eps1)
        sig =sigc;
    end % end of tension_envelope function

end
