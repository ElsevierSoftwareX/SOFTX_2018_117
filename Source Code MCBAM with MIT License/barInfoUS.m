function rebarInfo = barInfoUS(barNo, noOfBars)
% function returns bar diameter if only one input argument is given
% returns total area of bars if two input arguments are given
	if nargin==1
		returnDia =  true;
	else
		returnDia = false;
	end

     %        		bar#   dia(in) area(in2)
    barInformation = [  0	0		0
						3	0.375	0.11
                        4	0.5     0.2
                        5	0.625	0.31
                        6	0.75	0.44
                        7	0.875	0.6
                        8	1       0.79
                        9	1.128	1
                        10	1.27	1.27
                        11	1.41	1.56
                        14	1.693	2.25
                        18	2.257	4];
	
	barInfo = barInformation(logical(barInformation(:,1)==barNo),:);
				
	if (isempty(barInfo))
        rebarInfo = 0;
        disp('barInfoUS: INFORMATION NOT PRESENT IN THE DATABASE')
    elseif returnDia
        rebarInfo = barInfo(1,2);
	else
		rebarInfo = barInfo(1,3)*noOfBars;
	end

end
