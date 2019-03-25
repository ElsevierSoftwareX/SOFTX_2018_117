function strand_Area = strandArea(grade,nominal_dia, no_of_strands)
% strandArea(Grade ksi,nominal_dia (in), no_of_strands)
% contains information about 270 ksi and 250 ksi 7-wire strands


    % strandInfo = [grade(ksi)     nominal_dia(in or mm)    nominal_area(in2)];
    strandInfo = [  0           0               0
        
                    270        0.375            0.085
                    270        0.438            0.115
                    270        0.500            0.153
					270			0.520			0.167
					270			0.563			0.192
                    270        0.600            0.217
					270			0.700			0.294
                    
                    250         0.250           0.036
                    250         0.313           0.058
                    250         0.375           0.080
                    250         0.438           0.108
                    250         0.500           0.144
                    250         0.600           0.216
                    
                    1725	6.4		23.2
					1725	7.9		37.4
					1725	9.5		51.6
					1725	11.1	69.7
					1725	12.7	92.9
					1725	15.2	139.4
							
					1860	9.53	54.8
					1860	11.11	74.2
					1860	12.7	98.7
					1860	13.2	107.7
					1860	14.29	123.9
					1860	15.24	140
					1860	17.78	189.7
                    ];

    thisStrand = strandInfo(logical((strandInfo(:,1)==grade).*(strandInfo(:,2)==nominal_dia)),:);
    if(isempty(thisStrand))
        strand_Area = 0;
        disp('PRESTRESSING STRAND INFORMATION NOT PRESENT IN THE DATABASE')
    else
        strand_Area = thisStrand(1,3)*no_of_strands;
    end
    
end
