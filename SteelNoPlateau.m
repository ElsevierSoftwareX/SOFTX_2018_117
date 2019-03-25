function [fs] = SteelNoPlateau(es, Es1,fl1,ep1,fp1,eult1,n1)

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
%   fp        .------------------- <-- eult
%          .  ^ ep 
%        .  
%      . <-- el
%     /
%    /
%   /
%  /
% /

% el = strain at the end of linear region
% ep = strain at the beginning of the plateau
% eult = strain at the end of the plateau
	global failureFlag failure
    persistent Es el fl ep fp eult n Es_factor
    
     if nargin ~=1
        % indicates change to steel parameters. So, set the persistent
        % parameters
        
        Es = Es1;
        fl = fl1;
        ep = ep1;
        fp = fp1;
        eult = eult1;
        n = n1;
        
        el = fl/Es;
        
        % calculate the ES_factor such that the curve between the end of
        % the elastic limit and the beginning of the plastic limit becomes
        % a continuous line that is tangent at both the extreme points i.e,
        % tangent at the end of the elastic range and also tangent at the
        % beginning of the flat plateau 
        es =  ep;
        fs = Es * (es - (es - el)^(n+1)/((n+1)*(ep - el)^n));
        Es_factor = (fp - fl)/(fs-fl);
%         Es_factor = 1;
        
     else
        
		sgn = sign(es);
		es = abs(es);
		
		if es <= el % el = e_linear
			fs = es*Es;
		elseif es > el && es <= ep
% 			fs = Es * (es - (es - el)^(n+1)/((n+1)*(ep - el)^n));
            fs = Es * (es - (es - el)^(n+1)/((n+1)*(ep - el)^n));
            fs = (fs - fl)*Es_factor + fl;
%             fs = fl+ (fp - fl)*((es - el)/(ep - el))^2;
		elseif es > ep && es <= eult
            fs = fp;
       else
            fs = 0;
			
			% change a flag to indicate steel failure
			failureFlag = true;
			
			failure.Material = 'Rebar';
			failure.Strain = es*sgn;
			
			if(es*sgn>0)
				failure.Mode = 'Tension';
			else
				failure.Mode = 'Compression';
			end
		end
		
		fs = sgn * fs;	
        
     end
end