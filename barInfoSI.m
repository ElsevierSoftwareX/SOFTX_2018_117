function rebarInfo = barInfoSI(barNo, noOfBars)
% function returns bar diameter if only one input argument is given
% returns total area of bars if two input arguments are given
	if nargin==1
		returnDia =  true;
	else
		returnDia = false;
	end

    %        		bar#   dia(mm) area(mm2)
    barInformation = [ 	0	0		0
						10	9.525	71
						13	12.7	129
						16	15.875	200
						19	19.05	284
						22	22.225	387
						25	25.4	509
						29	28.65	645
						32	32.26	819
						36	35.81	1006
						43	43		1452
						57	57.33	2581];
	
	barInfo = barInformation(logical(barInformation(:,1)==barNo),:);
				
	if (isempty(barInfo))
        rebarInfo = 0;
        disp('barInfoSI: INFORMATION NOT PRESENT IN THE DATABASE')
    elseif returnDia
        rebarInfo = barInfo(1,2);
	else
		rebarInfo = barInfo(1,3)*noOfBars;
	end
end