function MPhi
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

clear all
% app to genereate the moment-curvature of user defined material properties

%% Initialize the global variables and variable default values
%     global n fc epsc0 epscu fcu ft epstu epst Ec0
%     global n fc epsc0 epscu ft epstu fcu epst Ec0 tensBarNo compBarNo tensNoOfBars compNoOfBars plotStress plotZ E0 b w h
%     global tensBarNo compBarNo tensNoOfBars compNoOfBars w h
    
    global failureFlag failure
    
%     global M Phi % just for test purposes

    % Initialize variables that area acessed by multiple functions and
    % assign default values to them.
        % Variables used to generate report
            M = [0 0];
            Phi = [0 0];
            MUHPCcomp = [0 0];
            McompSteel = [0 0];
            MUHPCtens = [0 0];
            MtensSteel = [0 0];
            MtensPS = [0 0];  
            pp = 1;
            
            concreteStrain = [];
            concreteStress =[];
            strain_Tens = [];
            stress_Tens = [];
            strain_Comp = [];
            stress_Comp = [];
            PSStress = [];
            PSStrain = [];
                        
        PS_grade = 0;
        sec_coor = []; 
        Eps = 28500; % ksi, Modulus of elasticity of PS strands
        
        %define default units first
        M_Units = '(kip-in)';
        Phi_Units = '(1/in)';
        stress_Units = '(ksi)';
        strain_Units = '(in/in)';
        distance_Units = '(in)';
       
%% Create tabs
   f = figure(5);
        f.Resize = 'off';
		f.Units = 'Pixels';
        f.Position = [0 50 1003 644];
		f.Name = 'MC-BAM';
        f.ToolBar = 'figure';
        f.NumberTitle = 'off';

    f.MenuBar = 'none';
    
    tgroup = uitabgroup('Parent',f,'SelectionChangedFcn',@SelectionChangedFcn_tabGroup);
    ConcreteTab = uitab('Parent',tgroup,'Title','Concrete');
    SteelTab = uitab('Parent',tgroup,'Title','Steel');
    SectionPropertiesTab = uitab('Parent',tgroup,'Title','Section Properties');
    MPhiTab = uitab('Parent',tgroup,'Title','M-Phi');
    AboutTab = uitab('Parent',tgroup,'Title','About');
    tgroup.SelectedTab = ConcreteTab;
        
        
    %% Concrete Tab (ConcreteTab)
    Units_Label = uicontrol('Parent',f,'Style','text');
            Units_Label.HorizontalAlignment = 'right';
            Units_Label.Position = [860 590 30 15];
            Units_Label.String = 'Units';
    
    UnitsDropDown = uicontrol('Parent', f, 'Style', 'popup','callback',@callback_UnitsDropDown);
            UnitsDropDown.String = {'Kip,in','N,mm'};
            UnitsDropDown.Position = [910 585 70 22];            
     
    % Create Concrete_radio radio-button group
    Concrete_radio_buttongroup = uibuttongroup('Parent',ConcreteTab,'SelectionChangedFcn',@SelectionChangedFcn_Concrete_radio_buttongroup);
    Concrete_radio_buttongroup.Units = 'Pixels';
    Concrete_radio_buttongroup.Position = [5 562 800 40];

    % Create UHPCButton
    UHPC_radio = uicontrol('Parent',Concrete_radio_buttongroup,'Style','radio');
    UHPC_radio.String = 'UHPC';
    UHPC_radio.Position = [11 13 56 15];
    

    % Create Concrete02Button
    Concrete02_radio = uicontrol('Parent',Concrete_radio_buttongroup,'Style','radiobutton');
    Concrete02_radio.String = 'Conventional Concrete';
    Concrete02_radio.Position = [123 13 140 15];
 
    % Create Concrete02Button
    Idealized_UHPC_radio = uicontrol('Parent',Concrete_radio_buttongroup,'Style','radiobutton');
    Idealized_UHPC_radio.String = 'Idealized UHPC';
    Idealized_UHPC_radio.Position = [300 13 150 15];
    
    % Create CustomConcreteButton
    CustomConcrete_radio = uicontrol('Parent',Concrete_radio_buttongroup,'Style','radiobutton');
    CustomConcrete_radio.String = 'Custom Concrete';
    CustomConcrete_radio.Position = [450 13 140 15];
    
    % ######################### UHPC PANEL ###############################
    % ---------- INPUT FIELDS, BUTTONS AND BLANK PLOT AXES ----------------
    UHPCPanel = uipanel('Parent',ConcreteTab);
        UHPCPanel.Title = 'UHPC';
        UHPCPanel.TitlePosition = 'centertop';
        UHPCPanel.FontWeight = 'bold';
        UHPCPanel.FontSize = 12;
        UHPCPanel.Units = 'Pixels';
        UHPCPanel.Position = [5 9 385 545];
        UHPCPanel.Visible = 'on';
        
        % Create fc_UHPC_Label
        fc_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            fc_UHPC_Label.HorizontalAlignment = 'right';
            fc_UHPC_Label.Position = [10 491 250 15];
            fc_UHPC_Label.String = 'compressive strength, fc (ksi, or MPa)';
        
         % Create epsc0_UHPC_Label
        epsc0_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            epsc0_UHPC_Label.HorizontalAlignment = 'right';
            epsc0_UHPC_Label.Position =[10 456 250 15];
            epsc0_UHPC_Label.String = 'strain at fc, epsc0';
         
        % Create fcuksi_UHPC_Label
        fcu_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            fcu_UHPC_Label.HorizontalAlignment = 'right';
            fcu_UHPC_Label.Position = [10 417 250 15];
            fcu_UHPC_Label.String = 'ultimate compressive strength, fcu (ksi, or MPa)';
        
        % Create epscu_UHPC_Label
        epscu_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            epscu_UHPC_Label.HorizontalAlignment = 'right';
            epscu_UHPC_Label.Position = [155 383 106 15];
            epscu_UHPC_Label.String = 'strain at fcu, epscu';
        
        % Create ftksi_UHPC_Label
        ft_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            ft_UHPC_Label.HorizontalAlignment = 'right';
            ft_UHPC_Label.Position = [10 340 250 15];
            ft_UHPC_Label.String = 'tensile strength, ft (ksi, or MPa)';

        % Create epstd_UHPC_Label
        epst_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            epst_UHPC_Label.HorizontalAlignment = 'right';
            epst_UHPC_Label.Position = [6 303 255 15];
            epst_UHPC_Label.String = 'tensile strain at the end of tensile plateau, epst';

         % Create epstu_UHPC_Label
        epstu_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            epstu_UHPC_Label.HorizontalAlignment = 'right';
            epstu_UHPC_Label.Position = [103 266 158 15];
            epstu_UHPC_Label.String ='tensile strain at failure, epstu';
        
        % Create n_UHPC_Label
        n_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
        n_UHPC_Label.HorizontalAlignment = 'right';
        n_UHPC_Label.Position = [182.03125 229 79 15];
        n_UHPC_Label.String = 'power term, n';
        n_UHPC_Label.TooltipString = 'where Ec0 = (n+1)/n * fc/epsc0 stress =  E0*epsc (1-1/(n+1)*(epsc/epsc0)^n) ';
        
        % Create E0ksi_UHPC_Label
        Ec0ksi_UHPC_Label = uicontrol('Parent',UHPCPanel,'Style','text');
            Ec0ksi_UHPC_Label.HorizontalAlignment = 'right';
            Ec0ksi_UHPC_Label.Position = [10 192 250 15];
            Ec0ksi_UHPC_Label.String = 'initial modulus of elasticity, Ec0 (ksi, or MPa)';
            
        % Create fc
        fc_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            fc_UHPC_EditField.Position = [276 487 100 22];
            fc_UHPC_EditField.String = -28;

        % Create epsc0
        epsc0_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            epsc0_UHPC_EditField.Position = [276 450 100 22];
            epsc0_UHPC_EditField.String = -0.0035;

        % Create fcu
        fcu_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            fcu_UHPC_EditField.Position = [276 413 100 22];
            fcu_UHPC_EditField.String = -10;

        % Create epscu
        epscu_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            epscu_UHPC_EditField.Position = [276 373 100 22];
            epscu_UHPC_EditField.String = -0.01;

        % Create ft
        ft_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            ft_UHPC_EditField.Position = [276 336 100 22];
            ft_UHPC_EditField.String = 1.5;

        % Create epst
        epst_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            epst_UHPC_EditField.Position = [276 299 100 22];
            epst_UHPC_EditField.String = 0.004;

        % Create epstu
        epstu_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            epstu_UHPC_EditField.Position = [276 262 100 22];
            epstu_UHPC_EditField.String = 0.008;

        % Create nEditField
        n_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            n_UHPC_EditField.Position = [276.03125 225 100 22];
            n_UHPC_EditField.String = 10;
                
        % Create E0ksiEditField
        Ec0_UHPC_EditField = uicontrol('Parent',UHPCPanel,'Style','edit');
            Ec0_UHPC_EditField.Position = [276.03125 188 100 22];
            Ec0_UHPC_EditField.Enable = 'off';
 
        % ----------------- End of UHPC Panel -------------------------
        
   % ######################### Conventional Concrete PANEL ###############################
    % ---------- INPUT FIELDS, BUTTONS AND BLANK PLOT AXES -------------- %
    Concrete02Panel = uipanel('Parent',ConcreteTab);
    Concrete02Panel.Title = 'Conventional Concrete';
    Concrete02Panel.TitlePosition = 'centertop';
    Concrete02Panel.FontWeight = 'bold';
    Concrete02Panel.FontSize = 12;
    Concrete02Panel.Units = 'Pixels';
    Concrete02Panel.Position = [5 9 385 545];
    Concrete02Panel.Visible = 'off';

    % Create fc_Concrete02_Label
    fc_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        fc_Concrete02_Label.HorizontalAlignment = 'right';
        fc_Concrete02_Label.Position = [10 491 250 15];
        fc_Concrete02_Label.String = 'compressive strength, fc (ksi, or MPa)';

     % Create epsc0_Concrete02_Label
    epsc0_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        epsc0_Concrete02_Label.HorizontalAlignment = 'right';
        epsc0_Concrete02_Label.Position =[161 456 100 15];
        epsc0_Concrete02_Label.String = 'strain at fc, epsc0';

    % Create fcuksi_Concrete02_Label
    fcu_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        fcu_Concrete02_Label.HorizontalAlignment = 'right';
        fcu_Concrete02_Label.Position = [10 417 250 15];
        fcu_Concrete02_Label.String = 'ultimate compressive strength, fcu (ksi, or MPa)';

    % Create epscu_Concrete02_Label
    epscu_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        epscu_Concrete02_Label.HorizontalAlignment = 'right';
        epscu_Concrete02_Label.Position = [155 383 106 15];
        epscu_Concrete02_Label.String = 'strain at fcu, epscu';

    % Create ft
    ft_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        ft_Concrete02_Label.HorizontalAlignment = 'right';
        ft_Concrete02_Label.Position = [10 340 250 15];
        ft_Concrete02_Label.String = 'tensile strength, ft (ksi, or MPa)';

     % Create Ets
    Ets_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        Ets_Concrete02_Label.HorizontalAlignment = 'right';
        Ets_Concrete02_Label.Position = [10 303 250 15];
        Ets_Concrete02_Label.String ='Tension softening stiffness, Ets (ksi, or MPa)';

    % Create n_Concrete02_Label
    n_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
    n_Concrete02_Label.HorizontalAlignment = 'right';
    n_Concrete02_Label.Position = [182.03125 266 79 15];
    n_Concrete02_Label.String = 'power term, n';
    n_Concrete02_Label.TooltipString = 'where Ec0 = (n+1)/n * fc/epsc0 stress =  Ec0*epsc (1-1/(n+1)*(epsc/epsc0)^n) ';

    % Create E0ksi_Concrete02_Label
    Ec0ksi_Concrete02_Label = uicontrol('Parent',Concrete02Panel,'Style','text');
        Ec0ksi_Concrete02_Label.HorizontalAlignment = 'right';
        Ec0ksi_Concrete02_Label.Position = [10 229 250 15];
        Ec0ksi_Concrete02_Label.String = 'initial modulus of elasticity, Ec0 (ksi, or MPa)';

    % Create fc
    fc_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        fc_Concrete02_EditField.Position = [276 487 100 22];
        fc_Concrete02_EditField.String = -28;

    % Create epsc0
    epsc0_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        epsc0_Concrete02_EditField.Position = [276 450 100 22];
        epsc0_Concrete02_EditField.String = -0.0035;

    % Create fcu
    fcu_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        fcu_Concrete02_EditField.Position = [276 413 100 22];
        fcu_Concrete02_EditField.String = -10;

    % Create epscu
    epscu_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        epscu_Concrete02_EditField.Position = [276 373 100 22];
        epscu_Concrete02_EditField.String = -0.01;

    % Create ft
    ft_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        ft_Concrete02_EditField.Position = [276 336 100 22];
        ft_Concrete02_EditField.String = 1.5;

    % Create Ets
    Ets_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        Ets_Concrete02_EditField.Position = [276 299 100 22];
        Ets_Concrete02_EditField.String = 1500;

    % Create nEditField
    n_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        n_Concrete02_EditField.Position = [276.03125 262 100 22];
        n_Concrete02_EditField.String = 1;
        n_Concrete02_EditField.Enable = 'off';

    % Create E0ksiEditField
    Ec0_Concrete02_EditField = uicontrol('Parent',Concrete02Panel,'Style','edit');
        Ec0_Concrete02_EditField.Position = [276.03125 225 100 22];
        Ec0_Concrete02_EditField.Enable = 'off';

    % ----------------- End of Concrete02 Panel ------------------------- 

   
    % ######################### FHWA Idealized UHPC PANEL ###############################
    % ---------- INPUT FIELDS, BUTTONS AND BLANK PLOT AXES ----------------
    Idealized_UHPCPanel = uipanel('Parent',ConcreteTab);
    Idealized_UHPCPanel.Title = 'Idealized UHPC';
    Idealized_UHPCPanel.TitlePosition = 'centertop';
    Idealized_UHPCPanel.FontWeight = 'bold';
    Idealized_UHPCPanel.FontSize = 12;
    Idealized_UHPCPanel.Units = 'Pixels';
    Idealized_UHPCPanel.Position = [5 9 385 545];
    Idealized_UHPCPanel.Visible = 'off';

    % Create fc_Idealized_UHPC_Label
    fc_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        fc_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        fc_Idealized_UHPC_Label.Position = [10 491 250 15];
        fc_Idealized_UHPC_Label.String = 'compressive strength, fc (ksi, or MPa)';

     % Create Ec0
    Ec0_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        Ec0_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        Ec0_Idealized_UHPC_Label.Position =[10 456 250 15];
        Ec0_Idealized_UHPC_Label.String = 'Modulus of elasticity, Ec0 (ksi, or MPa)';

    % Create alpha label
    alpha_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        alpha_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        alpha_Idealized_UHPC_Label.Position = [6 417 255 15];
        alpha_Idealized_UHPC_Label.String = 'Compressive stress modification factor, alpha';

    % Create epscu_Idealized_UHPC_Label
    epscu_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        epscu_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        epscu_Idealized_UHPC_Label.Position = [155 383 106 15];
        epscu_Idealized_UHPC_Label.String = 'ultimate strain, epscu';

    % Create fcr
    fcr_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        fcr_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        fcr_Idealized_UHPC_Label.Position = [10 340 250 15];
        fcr_Idealized_UHPC_Label.String = 'first cracking stress, fcr (ksi, or MPa)';

     % Create gamma
    gamma_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        gamma_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        gamma_Idealized_UHPC_Label.Position = [6 303 254 15];
        gamma_Idealized_UHPC_Label.String ='Cracking stress modification factor, gamma';

    % Create ftu_Idealized_UHPC_Label
    ftu_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
    ftu_Idealized_UHPC_Label.HorizontalAlignment = 'right';
    ftu_Idealized_UHPC_Label.Position = [10 266 250 15];
    ftu_Idealized_UHPC_Label.String = 'Localization stress, ftu (ksi, or MPa)';
    
    % Create epstu_Idealized_UHPC_Label
    epstu_Idealized_UHPC_Label = uicontrol('Parent',Idealized_UHPCPanel,'Style','text');
        epstu_Idealized_UHPC_Label.HorizontalAlignment = 'right';
        epstu_Idealized_UHPC_Label.Position = [69.03125 229 192 15];
        epstu_Idealized_UHPC_Label.String = 'Localization strain, epstu';

    % Create fc
    fc_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        fc_Idealized_UHPC_EditField.Position = [276 487 100 22];
        fc_Idealized_UHPC_EditField.String = -28;

    % Create Ec0
    Ec0_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        Ec0_Idealized_UHPC_EditField.Position = [276 450 100 22];
        Ec0_Idealized_UHPC_EditField.String = 8000;

    % Create alpha
    alpha_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        alpha_Idealized_UHPC_EditField.Position = [276 413 100 22];
        alpha_Idealized_UHPC_EditField.String = 0.85;

    % Create epscu
    epscu_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        epscu_Idealized_UHPC_EditField.Position = [276 373 100 22];
        epscu_Idealized_UHPC_EditField.String = -0.01;

    % Create fcr
    fcr_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        fcr_Idealized_UHPC_EditField.Position = [276 336 100 22];
        fcr_Idealized_UHPC_EditField.String = 1.5;

    % Create gamma
    gamma_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        gamma_Idealized_UHPC_EditField.Position = [276 299 100 22];
        gamma_Idealized_UHPC_EditField.String = 0.85;

    % Create ftu
    ftu_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        ftu_Idealized_UHPC_EditField.Position = [276.03125 262 100 22];
        ftu_Idealized_UHPC_EditField.String = 2.0;
        
    % Create epstu
    epstu_Idealized_UHPC_EditField = uicontrol('Parent',Idealized_UHPCPanel,'Style','edit');
        epstu_Idealized_UHPC_EditField.Position = [276.03125 225 100 22];
        epstu_Idealized_UHPC_EditField.String = 0.008;

    % ----------------- End of Idealized_UHPC Panel ------------------------- 
    
    % ---------- INPUT FIELDS, BUTTONS AND BLANK PLOT AXES ----------------
    CustomConcretePanel = uipanel('Parent',ConcreteTab);
        CustomConcretePanel.Title = 'Custom Concrete';
        CustomConcretePanel.TitlePosition = 'centertop';
        CustomConcretePanel.FontWeight = 'bold';
        CustomConcretePanel.FontSize = 12;
        CustomConcretePanel.Units = 'Pixels';
        CustomConcretePanel.Position = [5 9 385 545];
        CustomConcretePanel.Visible = 'off';
        
        % Create custom_stress_strain_label
        custom_stress_strain_label = uicontrol('Parent',CustomConcretePanel,'Style','text');
        custom_stress_strain_label.HorizontalAlignment = 'left';
        custom_stress_strain_label.Position = [10 485 350 22];
        custom_stress_strain_label.String = 'Enter strain(in/in, or mm/mm) and stress(ksi, or MPa) as co-ordinate pairs';
        
        % Create SectionCoordinatesTextArea_Other
        custom_stress_strain_values = uicontrol(CustomConcretePanel,'Style','edit','Max',2);
        custom_stress_strain_values.Position = [50 185 300 300];
        custom_stress_strain_values.HorizontalAlignment = 'left';
        custom_stress_strain_values.TooltipString = sprintf('Enter a pair of strain (in/in) and stress (ksi) as co-ordinates (separated by comma or space or tab) in each line \n eg:\n strain1, stress1\n strain2, stress2');    
        custom_stress_strain_values.String = num2str([  -0.015	-28
                                                -0.004	-28
                                                0	0       
                                                0.005	1   
                                                0.008	1   ]);
                                            
        Ec0_CustomConcrete_Label = uicontrol('Parent',CustomConcretePanel,'Style','text');
        Ec0_CustomConcrete_Label.HorizontalAlignment = 'right';
        Ec0_CustomConcrete_Label.Position =[10 150 230 15];
        Ec0_CustomConcrete_Label.String = 'Modulus of elasticity, Ec0 (ksi, or MPa)';
        
        % Create Ec0
        Ec0_CustomConcrete = uicontrol('Parent',CustomConcretePanel,'Style','edit');
        Ec0_CustomConcrete.Position = [250 145 100 22];
        Ec0_CustomConcrete.String = 7000;


        
    % ------------------- End of Custom_Concrete Panel -------------------
    % Create the push button to plot
    plot_Concrete02_stress_strain_button = uicontrol('Parent',ConcreteTab,'Style','pushbutton','Callback',@callback_plot_concrete_stress_strain_button);
    plot_Concrete02_stress_strain_button.String = 'Plot';
    plot_Concrete02_stress_strain_button.Position = [142 46 100 22];

    % Stress-strain plot
    StressStrainPlotConcrete = axes('Parent',ConcreteTab);
        title(StressStrainPlotConcrete, 'Stress Strain Plot')
        xlabel(StressStrainPlotConcrete, ['strain ' strain_Units])
        ylabel(StressStrainPlotConcrete, ['stress ' stress_Units])
        StressStrainPlotConcrete.Units = 'Pixels';
        StressStrainPlotConcrete.Position = [460 50 475 480];
        box(StressStrainPlotConcrete,'on');
        
%% FUNCTION WRAPPERS FOR SI UNITS
%create function wrappers when:
        % function is unit dependent
        % different functions are defined for different unit systems
        
% NOTE: Function wrappers are initiated for US customary units
barInfo = @barInfoUS;

    %% Steel Tab (SteelTab)
    
            % Create SteelPropertiesPanel
            SteelPropertiesPanel = uipanel(SteelTab);
            SteelPropertiesPanel.Title = 'Steel Properties';
            SteelPropertiesPanel.Units = 'pixels';
            SteelPropertiesPanel.Position = [9 10 442 595];

         
    % Create conventional_rebar_tabs
    conventional_rebar_tabs = uitabgroup('Parent',SteelPropertiesPanel);
    conventional_rebar_tabs.Units = 'pixels';
    conventional_rebar_tabs.Position =  [9 271 428 301];
    Tension_Rebar_Tab = uitab('Parent',conventional_rebar_tabs,'Title','Tension Rebar');
    Compression_Rebar_Tab = uitab('Parent',conventional_rebar_tabs,'Title','Compression Rebar');
    conventional_rebar_tabs.SelectedTab = Tension_Rebar_Tab;
    
    % ------------------- Tension Rebar Tab ------------------------- %
            % Create rebarConstitutiveModelLabel
            rebarConstitutiveModelLabel_TensRebar = uicontrol('Parent', Tension_Rebar_Tab, 'Style', 'text');
            rebarConstitutiveModelLabel_TensRebar.HorizontalAlignment = 'right';
            rebarConstitutiveModelLabel_TensRebar.Position = [10 232 223 15];
            rebarConstitutiveModelLabel_TensRebar.String= 'Constitutive Model';
            
            rebarConstitutiveModelDropdown_TensRebar = uicontrol('Parent', Tension_Rebar_Tab, 'Style', 'popup','callback',@callback_rebarConstitutiveModelDropdown_TensRebar);
            rebarConstitutiveModelDropdown_TensRebar.String = {'Having yield plateau (Park)', 'Without yield plateau','HSS Grade 100'};
            rebarConstitutiveModelDropdown_TensRebar.Position = [250 228 167 22];
            rebarConstitutiveModelDropdown_TensRebar.Value = 1; 

                % ---------------  Create rebarParkPanel ----------------
                rebarParkPanel_TensRebar = uipanel(Tension_Rebar_Tab);
%                 rebarParkPanel.Title = 'Rebar Park Model';
                rebarParkPanel_TensRebar.Units = 'pixels';
                rebarParkPanel_TensRebar.Position =   [0 0 428 222];
                rebarParkPanel_TensRebar.BorderType ='none';
            
                    % Create yieldstressfyksiEditFieldLabel
                    yieldstressfyksiEditFieldLabel_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    yieldstressfyksiEditFieldLabel_TensRebar_Park.HorizontalAlignment = 'right';
                    yieldstressfyksiEditFieldLabel_TensRebar_Park.Position = [10 194 295 15];
                    yieldstressfyksiEditFieldLabel_TensRebar_Park.String= 'yield stress, fy (ksi, or MPa) ';

                    % Create yieldstressfyksiEditField
                    yieldstressfyksiEditField_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    yieldstressfyksiEditField_TensRebar_Park.Position = [317 190 100 22];
                    yieldstressfyksiEditField_TensRebar_Park.String = 69;

                    % Create ultimatestressintensionfuksiEditFieldLabel
                    ultimatestressintensionfuksiEditFieldLabel_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    ultimatestressintensionfuksiEditFieldLabel_TensRebar_Park.HorizontalAlignment = 'right';
                    ultimatestressintensionfuksiEditFieldLabel_TensRebar_Park.Position = [10 157 295 15];
                    ultimatestressintensionfuksiEditFieldLabel_TensRebar_Park.String= 'ultimate stress in tension, fu (ksi, or MPa) ';

                    % Create ultimatestressintensionfuksiEditField
                    ultimatestressintensionfuksiEditField_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    ultimatestressintensionfuksiEditField_TensRebar_Park.Position =  [317 153 100 22];
                    ultimatestressintensionfuksiEditField_TensRebar_Park.String = 95;

                    % Create initialelastictangentEsEditFieldLabel
                    initialelastictangentEsEditFieldLabel_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    initialelastictangentEsEditFieldLabel_TensRebar_Park.HorizontalAlignment = 'right';
                    initialelastictangentEsEditFieldLabel_TensRebar_Park.Position = [10 120 295 15];
                    initialelastictangentEsEditFieldLabel_TensRebar_Park.String= 'initial elastic tangent, Es  (ksi, or MPa)';

                    % Create initialelastictangentEsEditField
                    initialelastictangentEsEditField_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    initialelastictangentEsEditField_TensRebar_Park.Position = [317 116 100 22];
                    initialelastictangentEsEditField_TensRebar_Park.String = 29000;

                    % Create straincorrespondingtoinitialstrainhardeningeshEditFieldLabel
                    initialstrainhardeningstraineshLabel_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    initialstrainhardeningstraineshLabel_TensRebar_Park.HorizontalAlignment = 'right';
                    initialstrainhardeningstraineshLabel_TensRebar_Park.Position =  [10 87 292 15];
                    initialstrainhardeningstraineshLabel_TensRebar_Park.String= 'strain corresponding to initial strain hardening, esh';

                    % Create straincorrespondingtoinitialstrainhardeningeshEditField
                    straincorrespondingtoinitialstrainhardeningesh_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    straincorrespondingtoinitialstrainhardeningesh_TensRebar_Park.Position = [317 83 100 22];
                    straincorrespondingtoinitialstrainhardeningesh_TensRebar_Park.String = 0.02;

                    % Create strainatpeakultimatestresseultEditFieldLabel
                    strainatpeakultimatestresseultLabel_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    strainatpeakultimatestresseultLabel_TensRebar_Park.HorizontalAlignment = 'right';
                    strainatpeakultimatestresseultLabel_TensRebar_Park.Position =  [60 50 242 15];
                    strainatpeakultimatestresseultLabel_TensRebar_Park.String= 'strain at peak ultimate stress, eult';

                    % Create strainatpeakultimatestresseultEditField
                    strainatpeakultimatestresseult_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    strainatpeakultimatestresseult_TensRebar_Park.Position =  [317 46 100 22];
                    strainatpeakultimatestresseult_TensRebar_Park.String = 0.1;
                                        
                    % Create ES_final_slope_multiplier_label
                    ES_final_slope_multiplier_label_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'text');
                    ES_final_slope_multiplier_label_TensRebar_Park.HorizontalAlignment = 'right';
                    ES_final_slope_multiplier_label_TensRebar_Park.Position =  [25 19 277 15];
                    ES_final_slope_multiplier_label_TensRebar_Park.String= 'Final slope multiplier of Es';

                    % Create ES_final_slope_multiplier
                    ES_final_slope_multiplier_TensRebar_Park = uicontrol('Parent', rebarParkPanel_TensRebar, 'Style', 'edit');
                    ES_final_slope_multiplier_TensRebar_Park.Position =  [317 15 100 22];
                    ES_final_slope_multiplier_TensRebar_Park.String = 0.1;
                    
                %----------------------- end of rebarParkPanel -----------%
                
                % Create rebarNOPlateauPanel
                rebarNoPlateauPanel_TensRebar = uipanel(Tension_Rebar_Tab);
%                 rebarParkPanel.Title = 'Rebar without plateau';
                rebarNoPlateauPanel_TensRebar.Units = 'pixels';
                rebarNoPlateauPanel_TensRebar.Position =   [0 0 428 222];
                rebarNoPlateauPanel_TensRebar.BorderType ='none';
                rebarNoPlateauPanel_TensRebar.Visible = 'off';
                    % Create initialelastictangentEsEditFieldLabel
                    initialElasticTangentLabel_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    initialElasticTangentLabel_TensRebar_NP.HorizontalAlignment = 'right';
                    initialElasticTangentLabel_TensRebar_NP.Position = [10 194 295 15];
                    initialElasticTangentLabel_TensRebar_NP.String= 'initial elastic tangent, Es (ksi, or MPa)';

                    % Create initialelastictangentEsEditField
                    initialElasticTangent_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    initialElasticTangent_TensRebar_NP.Position = [317 190 100 22];
                    initialElasticTangent_TensRebar_NP.String = 29000;
                    
                    % Create stressAtTheEndOfLinearRegionLabel
                    stressAtTheEndOfLinearRegionLabel_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    stressAtTheEndOfLinearRegionLabel_TensRebar_NP.HorizontalAlignment = 'right';
                    stressAtTheEndOfLinearRegionLabel_TensRebar_NP.Position = [60 157 242 15];
                    stressAtTheEndOfLinearRegionLabel_TensRebar_NP.String= 'stress at the end of elastic region  (ksi, or MPa)';

                    % Create ultimatestressintensionfuksiEditField
                    stressAtTheEndOfLinearRegion_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    stressAtTheEndOfLinearRegion_TensRebar_NP.Position =  [317 153 100 22];
                    stressAtTheEndOfLinearRegion_TensRebar_NP.String = 70;

                    % Create strainAtTheStartOfEndPlateauLabel
                    strainAtTheStartOfEndPlateauLabel_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    strainAtTheStartOfEndPlateauLabel_TensRebar_NP.HorizontalAlignment = 'right';
                    strainAtTheStartOfEndPlateauLabel_TensRebar_NP.Position = [168 120 134 15];
                    strainAtTheStartOfEndPlateauLabel_TensRebar_NP.String= 'strain at the start of end plateau';

                    % Create strainAtTheStartOfEndPlateau
                    strainAtTheStartOfEndPlateau_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    strainAtTheStartOfEndPlateau_TensRebar_NP.Position = [317 116 100 22];
                    strainAtTheStartOfEndPlateau_TensRebar_NP.String = 0.02;

                    % Create stressAtTheEndPlateauLabel
                    stressAtTheEndPlateauLabel_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    stressAtTheEndPlateauLabel_TensRebar_NP.HorizontalAlignment = 'right';
                    stressAtTheEndPlateauLabel_TensRebar_NP.Position =  [10 87 295 15];
                    stressAtTheEndPlateauLabel_TensRebar_NP.String= 'stress at the end plateau (ksi, or MPa)';

                    % Create stressAtTheEndPlateau
                    stressAtTheEndPlateau_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    stressAtTheEndPlateau_TensRebar_NP.Position = [317 83 100 22];
                    stressAtTheEndPlateau_TensRebar_NP.String = 150;

                    % Create ultimateStrainLabel
                    ultimateStrainLabel_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    ultimateStrainLabel_TensRebar_NP.HorizontalAlignment = 'right';
                    ultimateStrainLabel_TensRebar_NP.Position =  [60 50 242 15];
                    ultimateStrainLabel_TensRebar_NP.String= 'ultimate strain';

                    % Create ultimateStrain
                    ultimateStrain_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    ultimateStrain_TensRebar_NP.Position =  [317 46 100 22];
                    ultimateStrain_TensRebar_NP.String = 0.06;
                                        
                    % Create n_Label
                    n_Label_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'text');
                    n_Label_TensRebar_NP.HorizontalAlignment = 'right';
                    n_Label_TensRebar_NP.Position =  [25 19 277 15];
                    n_Label_TensRebar_NP.String= 'Transition factor, n';

                    % Create n_edit_Field
                    n_edit_Field_TensRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_TensRebar, 'Style', 'edit');
                    n_edit_Field_TensRebar_NP.Position =  [317 15 100 22];
                    n_edit_Field_TensRebar_NP.String = 0.1;
                    
                %----------------------- end of rebarNoPlateauPanel -----------%
            % ------------------- end of Tension_Rebar_Tab -------------- %
            
            % ------------------- Compression Rebar Tab ------------------------- %
            % Create rebarConstitutiveModelLabel
            rebarConstitutiveModelLabel_CompRebar = uicontrol('Parent', Compression_Rebar_Tab, 'Style', 'text');
            rebarConstitutiveModelLabel_CompRebar.HorizontalAlignment = 'right';
            rebarConstitutiveModelLabel_CompRebar.Position = [10 232 223 15];
            rebarConstitutiveModelLabel_CompRebar.String= 'Constitutive Model';
            
            rebarConstitutiveModelDropdown_CompRebar = uicontrol('Parent', Compression_Rebar_Tab, 'Style', 'popupmenu','Callback',@callback_rebarConstitutiveModelDropdown_CompRebar);
            rebarConstitutiveModelDropdown_CompRebar.String = {'Having yield plateau (Park)', 'Without yield plateau','HSS Grade 100'};
            rebarConstitutiveModelDropdown_CompRebar.Position = [250 228 167 22];
            rebarConstitutiveModelDropdown_CompRebar.Value = 1; 

                % ---------------  Create rebarParkPanel ----------------
                rebarParkPanel_CompRebar = uipanel(Compression_Rebar_Tab);
%                 rebarParkPanel.Title = 'Rebar Park Model';
                rebarParkPanel_CompRebar.Units = 'pixels';
                rebarParkPanel_CompRebar.Position =   [0 0 428 222];
                rebarParkPanel_CompRebar.BorderType ='none';
            
                    % Create yieldstressfyksiEditFieldLabel
                    yieldstressfyksiEditFieldLabel_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    yieldstressfyksiEditFieldLabel_CompRebar_Park.HorizontalAlignment = 'right';
                    yieldstressfyksiEditFieldLabel_CompRebar_Park.Position = [10 194 295 15];
                    yieldstressfyksiEditFieldLabel_CompRebar_Park.String= 'yield stress, fy (ksi, or MPa)';

                    % Create yieldstressfyksiEditField
                    yieldstressfyksiEditField_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    yieldstressfyksiEditField_CompRebar_Park.Position = [317 190 100 22];
                    yieldstressfyksiEditField_CompRebar_Park.String = 69;

                    % Create ultimatestressintensionfuksiEditFieldLabel
                    ultimatestressintensionfuksiEditFieldLabel_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    ultimatestressintensionfuksiEditFieldLabel_CompRebar_Park.HorizontalAlignment = 'right';
                    ultimatestressintensionfuksiEditFieldLabel_CompRebar_Park.Position = [10 157 295 15];
                    ultimatestressintensionfuksiEditFieldLabel_CompRebar_Park.String= 'ultimate stress in tension, fu (ksi, or MPa)';

                    % Create ultimatestressintensionfuksiEditField
                    ultimatestressintensionfuksiEditField_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    ultimatestressintensionfuksiEditField_CompRebar_Park.Position =  [317 153 100 22];
                    ultimatestressintensionfuksiEditField_CompRebar_Park.String = 95;

                    % Create initialelastictangentEsEditFieldLabel
                    initialelastictangentEsEditFieldLabel_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    initialelastictangentEsEditFieldLabel_CompRebar_Park.HorizontalAlignment = 'right';
                    initialelastictangentEsEditFieldLabel_CompRebar_Park.Position = [10 120 295 15];
                    initialelastictangentEsEditFieldLabel_CompRebar_Park.String= 'initial elastic tangent, Es (ksi, or MPa)';

                    % Create initialelastictangentEsEditField
                    initialelastictangentEsEditField_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    initialelastictangentEsEditField_CompRebar_Park.Position = [317 116 100 22];
                    initialelastictangentEsEditField_CompRebar_Park.String = 29000;

                    % Create straincorrespondingtoinitialstrainhardeningeshEditFieldLabel
                    initialstrainhardeningstraineshLabel_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    initialstrainhardeningstraineshLabel_CompRebar_Park.HorizontalAlignment = 'right';
                    initialstrainhardeningstraineshLabel_CompRebar_Park.Position =  [10 87 292 15];
                    initialstrainhardeningstraineshLabel_CompRebar_Park.String= 'strain corresponding to initial strain hardening, esh';

                    % Create straincorrespondingtoinitialstrainhardeningeshEditField
                    straincorrespondingtoinitialstrainhardeningesh_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    straincorrespondingtoinitialstrainhardeningesh_CompRebar_Park.Position = [317 83 100 22];
                    straincorrespondingtoinitialstrainhardeningesh_CompRebar_Park.String = 0.02;

                    % Create strainatpeakultimatestresseultEditFieldLabel
                    strainatpeakultimatestresseultLabel_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    strainatpeakultimatestresseultLabel_CompRebar_Park.HorizontalAlignment = 'right';
                    strainatpeakultimatestresseultLabel_CompRebar_Park.Position =  [60 50 242 15];
                    strainatpeakultimatestresseultLabel_CompRebar_Park.String= 'strain at peak ultimate stress, eult';

                    % Create strainatpeakultimatestresseultEditField
                    strainatpeakultimatestresseult_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    strainatpeakultimatestresseult_CompRebar_Park.Position =  [317 46 100 22];
                    strainatpeakultimatestresseult_CompRebar_Park.String = 0.1;
                                        
                    % Create ES_final_slope_multiplier_label
                    ES_final_slope_multiplier_label_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'text');
                    ES_final_slope_multiplier_label_CompRebar_Park.HorizontalAlignment = 'right';
                    ES_final_slope_multiplier_label_CompRebar_Park.Position =  [25 19 277 15];
                    ES_final_slope_multiplier_label_CompRebar_Park.String= 'Final slope multiplier of Es';

                    % Create ES_final_slope_multiplier
                    ES_final_slope_multiplier_CompRebar_Park = uicontrol('Parent', rebarParkPanel_CompRebar, 'Style', 'edit');
                    ES_final_slope_multiplier_CompRebar_Park.Position =  [317 15 100 22];
                    ES_final_slope_multiplier_CompRebar_Park.String = 0.1;
                    
                %----------------------- end of rebarParkPanel -----------%
                
                % Create rebarNOPlateauPanel
                rebarNoPlateauPanel_CompRebar = uipanel(Compression_Rebar_Tab);
%                 rebarParkPanel.Title = 'Rebar without plateau';
                rebarNoPlateauPanel_CompRebar.Units = 'pixels';
                rebarNoPlateauPanel_CompRebar.Position =   [0 0 428 222];
                rebarNoPlateauPanel_CompRebar.BorderType ='none';
                rebarNoPlateauPanel_CompRebar.Visible = 'off';
                    % Create initialelastictangentEsEditFieldLabel
                    initialElasticTangentLabel_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    initialElasticTangentLabel_CompRebar_NP.HorizontalAlignment = 'right';
                    initialElasticTangentLabel_CompRebar_NP.Position = [10 194 295 15];
                    initialElasticTangentLabel_CompRebar_NP.String= 'initial elastic tangent, Es (ksi, or MPa)';

                    % Create initialelastictangentEsEditField
                    initialElasticTangent_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    initialElasticTangent_CompRebar_NP.Position = [317 190 100 22];
                    initialElasticTangent_CompRebar_NP.String = 29000;
                    
                    % Create stressAtTheEndOfLinearRegionLabel
                    stressAtTheEndOfLinearRegionLabel_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    stressAtTheEndOfLinearRegionLabel_CompRebar_NP.HorizontalAlignment = 'right';
                    stressAtTheEndOfLinearRegionLabel_CompRebar_NP.Position = [10 157 295 15];
                    stressAtTheEndOfLinearRegionLabel_CompRebar_NP.String= 'stress at the end of elastic region (ksi, or MPa)';

                    % Create ultimatestressintensionfuksiEditField
                    stressAtTheEndOfLinearRegion_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    stressAtTheEndOfLinearRegion_CompRebar_NP.Position =  [317 153 100 22];
                    stressAtTheEndOfLinearRegion_CompRebar_NP.String = 70;

                    % Create strainAtTheStartOfEndPlateauLabel
                    strainAtTheStartOfEndPlateauLabel_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    strainAtTheStartOfEndPlateauLabel_CompRebar_NP.HorizontalAlignment = 'right';
                    strainAtTheStartOfEndPlateauLabel_CompRebar_NP.Position = [168 120 134 15];
                    strainAtTheStartOfEndPlateauLabel_CompRebar_NP.String= 'strain at the strart of end plateau';

                    % Create strainAtTheStartOfEndPlateau
                    strainAtTheStartOfEndPlateau_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    strainAtTheStartOfEndPlateau_CompRebar_NP.Position = [317 116 100 22];
                    strainAtTheStartOfEndPlateau_CompRebar_NP.String = 0.02;

                    % Create stressAtTheEndPlateauLabel
                    stressAtTheEndPlateauLabel_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    stressAtTheEndPlateauLabel_CompRebar_NP.HorizontalAlignment = 'right';
                    stressAtTheEndPlateauLabel_CompRebar_NP.Position =  [10 87 295 15];
                    stressAtTheEndPlateauLabel_CompRebar_NP.String= 'stress at the end plateau (ksi, or MPa)';

                    % Create stressAtTheEndPlateau
                    stressAtTheEndPlateau_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    stressAtTheEndPlateau_CompRebar_NP.Position = [317 83 100 22];
                    stressAtTheEndPlateau_CompRebar_NP.String = 150;

                    % Create ultimateStrainLabel
                    ultimateStrainLabel_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    ultimateStrainLabel_CompRebar_NP.HorizontalAlignment = 'right';
                    ultimateStrainLabel_CompRebar_NP.Position =  [60 50 242 15];
                    ultimateStrainLabel_CompRebar_NP.String= 'ultimate strain';

                    % Create ultimateStrain
                    ultimateStrain_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    ultimateStrain_CompRebar_NP.Position =  [317 46 100 22];
                    ultimateStrain_CompRebar_NP.String = 0.06;
                                        
                    % Create n_Label
                    n_Label_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'text');
                    n_Label_CompRebar_NP.HorizontalAlignment = 'right';
                    n_Label_CompRebar_NP.Position =  [25 19 277 15];
                    n_Label_CompRebar_NP.String= 'Transition factor, n';

                    % Create n_edit_Field
                    n_edit_Field_CompRebar_NP = uicontrol('Parent', rebarNoPlateauPanel_CompRebar, 'Style', 'edit');
                    n_edit_Field_CompRebar_NP.Position =  [317 15 100 22];
                    n_edit_Field_CompRebar_NP.String = 0.1;
                    
                %----------------------- end of rebarNoPlateauPanel -----------%
         
            % Create PrestressingStrandsPanel
            PrestressingStrandsPanel = uipanel(SteelPropertiesPanel);
            PrestressingStrandsPanel.Title = 'Prestressing Strands';
            PrestressingStrandsPanel.Units = 'pixels';
            PrestressingStrandsPanel.Position = [9 101 428 160];

                  % Create PSgradeLabel
                PSgradeLabel = uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'text');
                PSgradeLabel.HorizontalAlignment = 'right';
                PSgradeLabel.Position =  [260 105 39 15];
                PSgradeLabel.String= 'Grade';
                
                 % for prestressing strands
                PSGradeDropDown = uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'popupmenu','Callback',@callback_PSGradeDropDown);
                PSGradeDropDown.String = {'None', 'Grade 250', 'Grade 270'};
                PSGradeDropDown.Position =  [314 101 100 22];
                PSGradeDropDown.Value = 1;
                
                % Create PSModelLabel
                PSModelLabel= uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'text');
                PSModelLabel.HorizontalAlignment = 'right';
                PSModelLabel.Position =   [217 65 40 15];
                PSModelLabel.String= 'Model';
                
                % Create PSModel
                PSModelDropdown = uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'popupmenu','Callback',@callback_PSModelDropdown);
                PSModelDropdown.String = {'PCI Design Handbook', 'Power Equation'};
                PSModelDropdown.Position =[272 61 142 22];
                PSModelDropdown.Value = 1;                
   
                % Create ModulusofelasticityEpsEditFieldLabel
                ModulusofelasticityEpsEditFieldLabel = uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'text');
                ModulusofelasticityEpsEditFieldLabel.HorizontalAlignment = 'right';
                ModulusofelasticityEpsEditFieldLabel.Position =  [10 25 295 15];
                ModulusofelasticityEpsEditFieldLabel.String = 'Eps  (ksi, or MPa)';

                % Create ModulusofelasticityEpsEditField
                ModulusofelasticityEpsEditField = uicontrol('Parent', PrestressingStrandsPanel, 'Style', 'edit');
                ModulusofelasticityEpsEditField.Position =  [319 21 95 22];
                ModulusofelasticityEpsEditField.String = 28500;
                ModulusofelasticityEpsEditField.Enable = 'off';
            
            % Create PSPowerEqnPanel
            PSPowerEqnPanel = uipanel(PrestressingStrandsPanel);
            PSPowerEqnPanel.Title = 'Power Eqn Parameters';
            PSPowerEqnPanel.Units = 'pixels';
            PSPowerEqnPanel.Position =  [17 19 185 113];
            PSPowerEqnPanel.Visible = 'off';

                % Create Q_Label
                Q_Label = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'text');
                Q_Label.HorizontalAlignment = 'right';
                Q_Label.Position = [9 70 25 15];
                Q_Label.String = 'Q';

                % Create Q_EditField
                Q_EditField = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'edit');
                Q_EditField.Position = [49 66 100 22];
                Q_EditField.String =0.02;
                
                % Create K_Label
                K_Label = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'text');
                K_Label.HorizontalAlignment = 'right';
                K_Label.Position = [9 40 25 15];
                K_Label.String = 'K';

                % Create K_EditField
                K_EditField = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'edit');
                K_EditField.Position =   [49 36 100 22];
                K_EditField.String =1.03;
                
                % Create R_Label
                R_Label = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'text');
                R_Label.HorizontalAlignment = 'right';
                R_Label.Position = [9 9 25 15];
                R_Label.String = 'R';

                % Create R_EditField
                R_EditField = uicontrol('Parent', PSPowerEqnPanel, 'Style', 'edit');
                R_EditField.Position =  [49 6 100 22];
                R_EditField.String =7.33;
               
                
            % Create PlotPanel
            PlotPanel = uipanel(SteelPropertiesPanel);
            PlotPanel.Units = 'pixels';
            PlotPanel.Position =   [9 14 428 79];
            
                % Create PlotButton_3
                SteelPlotButton = uicontrol('Parent', PlotPanel, 'Style', 'pushbutton','Callback',@callback_SteelPlotButton);
                SteelPlotButton.Position =   [70 28 100 22];
                SteelPlotButton.String= 'Plot';

                % Create ConventionalRebarCheckBox
                ConventionalTensRebarCheckBox = uicontrol('Parent',PlotPanel,'Style','checkbox','Callback',@callback_ConventionalTensRebarCheckBox);
                ConventionalTensRebarCheckBox.String = 'Conventional Tension Rebar';
                ConventionalTensRebarCheckBox.Position =  [206 52 170 15];
                ConventionalTensRebarCheckBox.Value = true;
                
                % Create ConventionalRebarCheckBox
                ConventionalCompRebarCheckBox = uicontrol('Parent',PlotPanel,'Style','checkbox','Callback',@callback_ConventionalCompRebarCheckBox);
                ConventionalCompRebarCheckBox.String = 'Conventional Compression Rebar';
                ConventionalCompRebarCheckBox.Position =  [206 32 190 15];
                ConventionalCompRebarCheckBox.Value = true;


                % Create PrestressingStrandsCheckBox
                PrestressingStrandsCheckBox = uicontrol('Parent',PlotPanel,'Style','checkbox','Callback',@callback_PrestressingStrandsCheckBox);
                PrestressingStrandsCheckBox.String = 'Prestressing Strands';
                PrestressingStrandsCheckBox.Position = [206 10 160 15];
                PrestressingStrandsCheckBox.Value = true;

            % Create SteelAxes
            SteelAxes = axes(SteelTab);
            title(SteelAxes, 'Stress-Strain')
            xlabel(SteelAxes, ['strain ' strain_Units])
            ylabel(SteelAxes, ['stress ' stress_Units])
            SteelAxes.Units = 'pixels';
            SteelAxes.Position = [510 50 475 530];
            box(SteelAxes,'on');
        
    %% Section Properties Tab (SectionPropertiesTab)
    
        % Create Section Geometry Button Group
        SectionGeometryButtonGroup = uibuttongroup(SectionPropertiesTab,'SelectionChangedFcn',@SelectionChangedFcn_SectionGeometryButtonGroup);
        SectionGeometryButtonGroup.Title = 'Section Geometry';
        SectionGeometryButtonGroup.FontWeight = 'bold';
        SectionGeometryButtonGroup.Units = 'Pixels';
        SectionGeometryButtonGroup.Position = [6 562 432 53];
  
        % Create RectangularButton
        RectangularButton = uicontrol('Parent',SectionGeometryButtonGroup,'Style','radio');
        RectangularButton.String = 'Rectangular';
        RectangularButton.Position = [11 10 86.71875 15];
        RectangularButton.Value = true;

        % Create CircularButton
        CircularButton = uicontrol('Parent',SectionGeometryButtonGroup,'Style','radio');
        CircularButton.String = 'Circular';
        CircularButton.Position = [174.71875 10 63.34375 15];
        CircularButton.Enable = 'on';

        % Create OtherButton
        OtherButton = uicontrol('Parent',SectionGeometryButtonGroup,'Style','radio');
        OtherButton.String = 'Other';
        OtherButton.Position = [316 10 52.015625 15];
        OtherButton.Enable = 'on';        
 
        %% ============= Rectangular Section Panel ===================%
        % Create RectangularSectionPanel
        RectangularSectionPanel = uipanel(SectionPropertiesTab);
        RectangularSectionPanel.Title = 'Rectangular Section';
        RectangularSectionPanel.FontWeight = 'bold';
        RectangularSectionPanel.Units = 'Pixels';
        RectangularSectionPanel.Position = [7 82 431 468];

            % Create SectionDimensionsPanel
            SectionDimensionsPanel = uipanel(RectangularSectionPanel);
            SectionDimensionsPanel.Title = 'Section Dimensions';
            SectionDimensionsPanel.Units = 'Pixels';
            SectionDimensionsPanel.Position =  [8 369 413 72];
            
                % Create WidthinEditFieldLabel
                WidthEditFieldLabel = uicontrol(SectionDimensionsPanel,'Style','text');
                WidthEditFieldLabel.HorizontalAlignment = 'right';
                WidthEditFieldLabel.Position = [0 24 90 15];
                WidthEditFieldLabel.String = 'Width (in, or mm)';

                % Create WidthinEditField
                WidthEditField = uicontrol(SectionDimensionsPanel, 'Style','edit');
                WidthEditField.Position = [95 20 100 22];
                WidthEditField.String = 10;

                % Create HeightinEditFieldLabel
                HeightEditFieldLabel = uicontrol(SectionDimensionsPanel,'Style','text');
                HeightEditFieldLabel.HorizontalAlignment = 'right';
                HeightEditFieldLabel.Position = [200 24 90 15];
                HeightEditFieldLabel.String = 'Height (in, mm)';

                % Create HeightinEditField
                HeightEditField = uicontrol(SectionDimensionsPanel, 'Style','edit');
                HeightEditField.Position = [300 20 100 22];
                HeightEditField.String = 20;
                
            % Create ConventionalLongitudinalReinforcementPanel_Rectangular
            ConventionalLongitudinalReinforcementPanel_Rectangular = uipanel(RectangularSectionPanel);
            ConventionalLongitudinalReinforcementPanel_Rectangular.Title = 'Conventional Longitudinal Reinforcement';
            ConventionalLongitudinalReinforcementPanel_Rectangular.Units = 'pixels';
            ConventionalLongitudinalReinforcementPanel_Rectangular.Position = [8 170 413 182];

			
				% Create Button group to define the form of input
				AsCGorAsClearCover_Rect_RadioGroup = uibuttongroup(ConventionalLongitudinalReinforcementPanel_Rectangular,'SelectionChangedFcn',@SelectionChangedFcn_AsCGorAsD_Rect_Button);
				AsCGorAsClearCover_Rect_RadioGroup.Units = 'Pixels';
				AsCGorAsClearCover_Rect_RadioGroup.Position = [0 125 413 30];
                AsCGorAsClearCover_Rect_RadioGroup.BorderType ='none';
				
					% Create Define CG of rebars radio
					AsCG_Rect_Radio = uicontrol('Parent',AsCGorAsClearCover_Rect_RadioGroup,'Style','radio');
					AsCG_Rect_Radio.String = 'Define CG of rebars';
					AsCG_Rect_Radio.Position = [11 11 175 15];
					
					% Create Define clear cover radio
					AsClearCover_Rect_Radio = uicontrol('Parent',AsCGorAsClearCover_Rect_RadioGroup,'Style','radiobutton');
					AsClearCover_Rect_Radio.String = 'Define clear cover';
					AsClearCover_Rect_Radio.Position =  [238 11 119 15];
                    AsClearCover_Rect_Radio.Value = 1;
									
			% Define reinfocement distance using CG of layers
			% Create ConventionalLongitudinalReinforcementPanel_Rectangular_CG
            ConventionalLongitudinalReinforcementPanel_Rectangular_CG = uipanel(ConventionalLongitudinalReinforcementPanel_Rectangular);
            ConventionalLongitudinalReinforcementPanel_Rectangular_CG.Units = 'pixels';
            ConventionalLongitudinalReinforcementPanel_Rectangular_CG.Position =  [0 0 414 118];
            ConventionalLongitudinalReinforcementPanel_Rectangular_CG.BorderType = 'none';
			ConventionalLongitudinalReinforcementPanel_Rectangular_CG.Visible = 'off';
                % Create CompressionRebarsLabel
                CompressionRebarsLabel_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'text');
                CompressionRebarsLabel_Rectangular_CG.FontWeight = 'bold';
                CompressionRebarsLabel_Rectangular_CG.Position = [159 99 140 15];
                CompressionRebarsLabel_Rectangular_CG.String = 'Compression Rebars';

                % Create TensionRebarsLabel
                TensionRebarsLabel_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'text');
                TensionRebarsLabel_Rectangular_CG.FontWeight = 'bold';
                TensionRebarsLabel_Rectangular_CG.Position = [304 99 105 15];
                TensionRebarsLabel_Rectangular_CG.String = 'Tension Rebars';

                % Create BarSizeDropDown_3Label
                BarSizeDropDownLabel_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'text');
                BarSizeDropDownLabel_Rectangular_CG.HorizontalAlignment = 'right';
                BarSizeDropDownLabel_Rectangular_CG.Position = [115 74 51 15];
                BarSizeDropDownLabel_Rectangular_CG.String ='Bar Size';
                % Create BarSizeDropDown_3 'Bar Size';

                BarSizeDropDownComp_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'popupmenu');
                BarSizeDropDownComp_Rectangular_CG.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownComp_Rectangular_CG.Position = [181 70 100 22];
                BarSizeDropDownComp_Rectangular_CG.Value = 4;

                % Create BarSizeDropDown_4
                BarSizeDropDownTens_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'popupmenu');
                BarSizeDropDownTens_Rectangular_CG.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Rectangular_CG.Position = [300 70 100 22];
                BarSizeDropDownTens_Rectangular_CG.Value = 8;

                % Create DistanceoflayerfromtopEditFieldLabel
                DistanceoflayerfromtopEditFieldLabel_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'text');
                DistanceoflayerfromtopEditFieldLabel_Rectangular_CG.HorizontalAlignment = 'right';
                DistanceoflayerfromtopEditFieldLabel_Rectangular_CG.Position = [5 45 170 15];
                DistanceoflayerfromtopEditFieldLabel_Rectangular_CG.String = 'Distance of layer from top (in, mm)';

                % Create DistanceoflayerfromtopEditField
                DistanceoflayerfromtopComp_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'edit');
                DistanceoflayerfromtopComp_Rectangular_CG.Position = [179 41 100 22];
                DistanceoflayerfromtopComp_Rectangular_CG.String = '2,5';

                % Create DistanceoflayerfromtopEditField_2
                DistanceoflayerfromtopTens_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'edit');
                DistanceoflayerfromtopTens_Rectangular_CG.Position = [300 41 100 22];
                DistanceoflayerfromtopTens_Rectangular_CG.String = '15,18';

                % Create NoofrebarsineachlayerEditFieldLabel
                NoofrebarsineachlayerEditFieldLabel_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'text');
                NoofrebarsineachlayerEditFieldLabel_Rectangular_CG.HorizontalAlignment = 'right';
                NoofrebarsineachlayerEditFieldLabel_Rectangular_CG.Position = [18 14 147 15];
                NoofrebarsineachlayerEditFieldLabel_Rectangular_CG.String = 'No. of rebars in each layer';

                % Create NoofrebarsineachlayerEditField
                NoofrebarsineachlayerComp_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'edit');
                NoofrebarsineachlayerComp_Rectangular_CG.Position = [180 10 100 22];
                NoofrebarsineachlayerComp_Rectangular_CG.String = '2,3';

                % Create NoofrebarsineachlayerEditField_2
                NoofrebarsineachlayerTens_Rectangular_CG = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_CG, 'Style', 'edit');
                NoofrebarsineachlayerTens_Rectangular_CG.Position = [300 10 100 22];
                NoofrebarsineachlayerTens_Rectangular_CG.String = '4,5';
            
            % Define reinforcement distance using clear cover
			% Create ConventionalLongitudinalReinforcementPanel_Rectangular_clrcover
            ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover = uipanel(ConventionalLongitudinalReinforcementPanel_Rectangular);
            ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.Units = 'pixels';
            ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.Position =  [0 0 414 118];
            ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.BorderType = 'none';
			ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.Visible = 'on';
			
                % Create CompressionRebarsLabel
                CompressionRebarsLabel_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'text');
                CompressionRebarsLabel_Rectangular_clrCover.FontWeight = 'bold';
                CompressionRebarsLabel_Rectangular_clrCover.Position = [159 99 140 15];
                CompressionRebarsLabel_Rectangular_clrCover.String = 'Compression Rebars';

                % Create TensionRebarsLabel
                TensionRebarsLabel_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'text');
                TensionRebarsLabel_Rectangular_clrCover.FontWeight = 'bold';
                TensionRebarsLabel_Rectangular_clrCover.Position = [304 99 105 15];
                TensionRebarsLabel_Rectangular_clrCover.String = 'Tension Rebars';

                % Create BarSizeDropDown_3Label
                BarSizeDropDownLabel_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'text');
                BarSizeDropDownLabel_Rectangular_clrCover.HorizontalAlignment = 'right';
                BarSizeDropDownLabel_Rectangular_clrCover.Position = [115 74 51 15];
                BarSizeDropDownLabel_Rectangular_clrCover.String ='Bar Size';
                % Create BarSizeDropDown_3 'Bar Size';

                BarSizeDropDownComp_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'popupmenu');
                BarSizeDropDownComp_Rectangular_clrCover.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownComp_Rectangular_clrCover.Position = [181 70 100 22];
                BarSizeDropDownComp_Rectangular_clrCover.Value = 4;

                % Create BarSizeDropDown_4
                BarSizeDropDownTens_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'popupmenu');
                BarSizeDropDownTens_Rectangular_clrCover.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Rectangular_clrCover.Position = [300 70 100 22];
                BarSizeDropDownTens_Rectangular_clrCover.Value = 8;

                % Create ClearCoverLabel_Rectangular_clrCover
                ClearCoverLabel_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'text');
                ClearCoverLabel_Rectangular_clrCover.HorizontalAlignment = 'right';
                ClearCoverLabel_Rectangular_clrCover.Position = [5 45 170 15];
                ClearCoverLabel_Rectangular_clrCover.String = 'Clear cover (in, mm)';

                % Create DistanceoflayerfromtopEditField
                ClearCoverComp_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'edit');
                ClearCoverComp_Rectangular_clrCover.Position = [179 41 100 22];
                ClearCoverComp_Rectangular_clrCover.String = 2;

                % Create DistanceoflayerfromtopEditField_2
                ClearCoverTens_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'edit');
                ClearCoverTens_Rectangular_clrCover.Position = [300 41 100 22];
                ClearCoverTens_Rectangular_clrCover.String = 2;

                % Create NoofrebarsineachlayerEditFieldLabel
                NoofrebarsineachlayerEditFieldLabel_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'text');
                NoofrebarsineachlayerEditFieldLabel_Rectangular_clrCover.HorizontalAlignment = 'right';
                NoofrebarsineachlayerEditFieldLabel_Rectangular_clrCover.Position = [18 14 147 15];
                NoofrebarsineachlayerEditFieldLabel_Rectangular_clrCover.String = 'No. of rebars';

                % Create NoofrebarsineachlayerEditField
                NoofrebarsineachlayerComp_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'edit');
                NoofrebarsineachlayerComp_Rectangular_clrCover.Position = [180 10 100 22];
                NoofrebarsineachlayerComp_Rectangular_clrCover.String = 2;

                % Create NoofrebarsineachlayerEditField_2
                NoofrebarsineachlayerTens_Rectangular_clrCover = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover, 'Style', 'edit');
                NoofrebarsineachlayerTens_Rectangular_clrCover.Position = [300 10 100 22];
                NoofrebarsineachlayerTens_Rectangular_clrCover.String = 3;	
			
            % Create PrestressingPanel
            PrestressingPanel_Rectangular = uipanel(RectangularSectionPanel);
            PrestressingPanel_Rectangular.Title = 'Prestressing';
            PrestressingPanel_Rectangular.Units = 'Pixels';
            PrestressingPanel_Rectangular.Position = [8 7 413 151];

                % Create DistanceofreinforcementlayersfromtopfiberEditFieldLabel_4
                DistanceofreinforcementlayersfromtopfiberLabel_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'text');
                DistanceofreinforcementlayersfromtopfiberLabel_Rectangular.HorizontalAlignment = 'right';
                DistanceofreinforcementlayersfromtopfiberLabel_Rectangular.Position = [106 75 152 15];
                DistanceofreinforcementlayersfromtopfiberLabel_Rectangular.String = 'No. of Prestressing Strands';

                % Create NoofPrestressingStrands_Rectangular
                Noofprestressingstrands_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'edit');
                Noofprestressingstrands_Rectangular.Position = [273 71 100 22];
                Noofprestressingstrands_Rectangular.String = 1;

                % Create DistanceofCGofPSstrandsfromtopfiberLabel_Rectangular
                DistanceofCGofPSstrandsfromtopfiberLabel_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'text');
                DistanceofCGofPSstrandsfromtopfiberLabel_Rectangular.HorizontalAlignment = 'right';
                DistanceofCGofPSstrandsfromtopfiberLabel_Rectangular.Position = [0 46 260 15];
                DistanceofCGofPSstrandsfromtopfiberLabel_Rectangular.String = 'Distance of CG of PS strands from top fiber (in, or mm)';

                % Create DistanceofCGofPSstrandsfromtopfiberEditField_Rectangular
                DistanceofCGofPSstrandsfromtopfiber_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'edit');
                DistanceofCGofPSstrandsfromtopfiber_Rectangular.Position = [273 39 100 22];
                DistanceofCGofPSstrandsfromtopfiber_Rectangular.String = 18;

                % Create GradeDropDown_6Label
                GradeDropDownLabel_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'text');
                GradeDropDownLabel_Rectangular.HorizontalAlignment = 'right';
                GradeDropDownLabel_Rectangular.Position = [18 107 39 15];
                GradeDropDownLabel_Rectangular.String = 'Grade';

                % Create GradeDropDown_Rectangular
                PSGradeInfo_Rectangular = uicontrol(PrestressingPanel_Rectangular,'Style','edit');
                PSGradeInfo_Rectangular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Rectangular.Enable = 'off';
                PSGradeInfo_Rectangular.Position = [67 103 100 22];

                % Create DiameterDropDown_3Label
                PSDiameterDropDownLabel_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'text');
                PSDiameterDropDownLabel_Rectangular.HorizontalAlignment = 'right';
                PSDiameterDropDownLabel_Rectangular.Position = [175 107 85 15];
                PSDiameterDropDownLabel_Rectangular.String = 'Diameter (in, mm)';

                % Create DiameterDropDown_Rectangular
                PSDiameterDropDown_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'popupmenu');
                PSDiameterDropDown_Rectangular.Position = [273.03125 103 100 22];
                PSDiameterDropDown_Rectangular.String = {'0'}; 
                PSDiameterDropDown_Rectangular.Value =1;
                % the diameter is dependent upon the prestressing steel grade.
                % The callback functions sets the options for the diameter
                % corresponding to the grade of the PS strand.
                
                % Create StressinPSstrandsafteralllossesLabel_Rectangular
                StressinPSstrandsafteralllossesLabel_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'text');
                StressinPSstrandsafteralllossesLabel_Rectangular.HorizontalAlignment = 'right';
                StressinPSstrandsafteralllossesLabel_Rectangular.Position = [7 11 252 15];
                StressinPSstrandsafteralllossesLabel_Rectangular.String = 'Stress in PS strands after all losses (ksi, or MPa) ';

                % Create StressinPSstrandsafteralllosses_Rectangular
                StressinPSstrandsafteralllosses_Rectangular = uicontrol('Parent', PrestressingPanel_Rectangular, 'Style', 'edit');
                StressinPSstrandsafteralllosses_Rectangular.Position =  [273.03125 7 100 22];
                StressinPSstrandsafteralllosses_Rectangular.String = 200;     
     
        %================= End of Rectangular Section Panel =========%
        
        %% ========== Start of Circular Section Panel ================= %
       % Create CircularSectionPanel
        CircularSectionPanel = uipanel(SectionPropertiesTab);
        CircularSectionPanel.Title = 'Circular Section';
        CircularSectionPanel.FontWeight = 'bold';
        CircularSectionPanel.Units = 'Pixels';
        CircularSectionPanel.Position = [7 82 431 468];
        CircularSectionPanel.Visible = 'off';
        
            % Create SectionDimensionsPanel_Circular
            SectionDimensionsPanel_Circular = uipanel(CircularSectionPanel);
            SectionDimensionsPanel_Circular.Title = 'Section Dimensions';
            SectionDimensionsPanel_Circular.Units = 'pixels';
            SectionDimensionsPanel_Circular.Position = [9 333 413 108];
            
                % Create ExternalDiameterinEditFieldLabel
                ExternalDiameterinEditFieldLabel_Circular = uicontrol('Parent', SectionDimensionsPanel_Circular, 'Style', 'text');
                ExternalDiameterinEditFieldLabel_Circular.HorizontalAlignment = 'right';
                ExternalDiameterinEditFieldLabel_Circular.Position = [15 53 255 15];
                ExternalDiameterinEditFieldLabel_Circular.String = 'External Diameter (in, mm)';

                % Create ExternalDiameterinEditField
                ExternalDiameterinEditField_Circular = uicontrol('Parent', SectionDimensionsPanel_Circular, 'Style', 'edit');
                ExternalDiameterinEditField_Circular.Position = [281.03125 49 100 22];
                ExternalDiameterinEditField_Circular.String = 20;
                
                % Create ClearcoverinEditFieldLabel
                ClearcoverinEditFieldLabel_Circular = uicontrol('Parent', SectionDimensionsPanel_Circular, 'Style', 'text');
                ClearcoverinEditFieldLabel_Circular.HorizontalAlignment = 'right';
                ClearcoverinEditFieldLabel_Circular.Position = [15 16 255 15];
                ClearcoverinEditFieldLabel_Circular.String = 'Clear cover (in, mm)';

                % Create ClearcoverinEditField
                ClearcoverinEditField_Circular = uicontrol('Parent', SectionDimensionsPanel_Circular, 'Style', 'edit');
                ClearcoverinEditField_Circular.Position = [281.03125 12 100 22];
                ClearcoverinEditField_Circular.String = 2;

            % Create ConventionalLongitudinalReinforcementPanel_Circular
            ConventionalLongitudinalReinforcementPanel_Circular = uipanel(CircularSectionPanel);
            ConventionalLongitudinalReinforcementPanel_Circular.Title = 'Conventional Longitudinal Reinforcement';
            ConventionalLongitudinalReinforcementPanel_Circular.Units = 'pixels';
            ConventionalLongitudinalReinforcementPanel_Circular.Position = [9 176 413 144];

                % Create BarDropDown_CircularLabel
                BarDropDownrLabel_Circular = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Circular, 'Style', 'text');
                BarDropDownrLabel_Circular.HorizontalAlignment = 'right';
                BarDropDownrLabel_Circular.Position = [210 56 60 16];
                BarDropDownrLabel_Circular.String = 'Bar Size';

                % Create BarDropDown_Circular
                BarSizeDropDown_Circular = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Circular, 'Style', 'popupmenu');
                BarSizeDropDown_Circular.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDown_Circular.Position = [281 52 100 22];
                BarSizeDropDown_Circular.Value = 4;

                % Create NoofreinforcementbarsineachlayerEditFieldLabel_Circular
                NoofreinforcementbarsEditFieldLabel_Circular = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Circular, 'Style', 'text');
                NoofreinforcementbarsEditFieldLabel_Circular.HorizontalAlignment = 'right';
                NoofreinforcementbarsEditFieldLabel_Circular.Position = [53 19 213 15];
                NoofreinforcementbarsEditFieldLabel_Circular.String = 'No. of reinforcement bars';

                % Create NoofreinforcementbarsineachlayerEditField_Circular
                NoofreinforcementbarsEditField_Circular = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Circular, 'Style', 'edit');
                NoofreinforcementbarsEditField_Circular.Position = [281 15 100 22];
                NoofreinforcementbarsEditField_Circular.String = 15;
                
            % Create PrestressingPanel_Circular
            PrestressingPanel_Circular = uipanel(CircularSectionPanel);
            PrestressingPanel_Circular.Title = 'Prestressing';
            PrestressingPanel_Circular.Units = 'pixels';
            PrestressingPanel_Circular.Position = [9 13 413 147];

                % Create DistanceofreinforcementlayersfromtopfiberEditFieldLabel_4
                DistanceofreinforcementlayersfromtopfiberLabel_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'text');
                DistanceofreinforcementlayersfromtopfiberLabel_Circular.HorizontalAlignment = 'right';
                DistanceofreinforcementlayersfromtopfiberLabel_Circular.Position = [106 75 152 15];
                DistanceofreinforcementlayersfromtopfiberLabel_Circular.String = 'No. of Prestressing Strands';

                % Create NoofPrestressingStrands_Circular
                Noofprestressingstrands_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'edit');
                Noofprestressingstrands_Circular.Position = [273 71 100 22];
                Noofprestressingstrands_Circular.String = 1;

                % Create DistanceofCGofPSstrandsfromtopfiberLabel_Circular
                DistanceofCGofPSstrandsfromtopfiberLabel_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'text');
                DistanceofCGofPSstrandsfromtopfiberLabel_Circular.HorizontalAlignment = 'left';
                DistanceofCGofPSstrandsfromtopfiberLabel_Circular.Position = [5 46 255 15];
                DistanceofCGofPSstrandsfromtopfiberLabel_Circular.String = 'Distance of CG of PS strands from top fiber(in,or mm)';

                % Create DistanceofCGofPSstrandsfromtopfiberEditField_Circular
                DistanceofCGofPSstrandsfromtopfiber_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'edit');
                DistanceofCGofPSstrandsfromtopfiber_Circular.Position = [273 39 100 22];
                DistanceofCGofPSstrandsfromtopfiber_Circular.String = 18;

                % Create GradeDropDown_6Label
                GradeDropDownLabel_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'text');
                GradeDropDownLabel_Circular.HorizontalAlignment = 'right';
                GradeDropDownLabel_Circular.Position = [18 107 39 15];
                GradeDropDownLabel_Circular.String = 'Grade';

                % Create GradeDropDown_Circular
                PSGradeInfo_Circular = uicontrol(PrestressingPanel_Circular,'Style','edit');
                PSGradeInfo_Circular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Circular.Enable = 'off';
                PSGradeInfo_Circular.Position = [67 103 100 22];

                % Create DiameterDropDown_3Label
                PSDiameterDropDownLabel_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'text');
                PSDiameterDropDownLabel_Circular.HorizontalAlignment = 'right';
                PSDiameterDropDownLabel_Circular.Position = [175 107 85 15];
                PSDiameterDropDownLabel_Circular.String = 'Diameter (in, mm)';

                % Create DiameterDropDown_Circular
                PSDiameterDropDown_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'popupmenu');
                PSDiameterDropDown_Circular.Position = [273.03125 103 100 22];
                PSDiameterDropDown_Circular.String = {'0'}; 
                PSDiameterDropDown_Circular.Value =1;
                % the diameter is dependent upon the prestressing steel grade.
                % The callback functions sets the options for the diameter
                % corresponding to the grade of the PS strand.
                
                % Create StressinPSstrandsafteralllossesLabel_Circular
                StressinPSstrandsafteralllossesLabel_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'text');
                StressinPSstrandsafteralllossesLabel_Circular.HorizontalAlignment = 'right';
                StressinPSstrandsafteralllossesLabel_Circular.Position = [7 11 250 15];
                StressinPSstrandsafteralllossesLabel_Circular.String = 'Stress in PS strands after all losses (in, mm)';

                % Create StressinPSstrandsafteralllosses_Circular
                StressinPSstrandsafteralllosses_Circular = uicontrol('Parent', PrestressingPanel_Circular, 'Style', 'edit');
                StressinPSstrandsafteralllosses_Circular.Position =  [273.03125 7 100 22];
                StressinPSstrandsafteralllosses_Circular.String = 200;
            
        % ======== End of Circular Section Panel ======================= % 
        
        %% ============ Start of Other Section Panel ================== %
        % Create OtherSectionPanel
        OtherSectionPanel = uipanel(SectionPropertiesTab);
        OtherSectionPanel.Title = 'Other Section';
        OtherSectionPanel.FontWeight = 'bold';
        OtherSectionPanel.Units = 'pixels';
        OtherSectionPanel.Position = [7 82 431 468];
        OtherSectionPanel.Visible = 'off';

            % Create SectionDimensionsPanel_Other
            SectionDimensionsPanel_Other = uipanel(OtherSectionPanel);
            SectionDimensionsPanel_Other.Title = 'Section Dimensions';
            SectionDimensionsPanel_Other.Units = 'pixels';
            SectionDimensionsPanel_Other.Position = [8 308 413 121];

                % Create SectionCoordinatesTextAreaLabel
                SectionCoordinatesTextAreaLabel = uicontrol('Parent', SectionDimensionsPanel_Other, 'Style', 'text');
                SectionCoordinatesTextAreaLabel.HorizontalAlignment = 'right';
                SectionCoordinatesTextAreaLabel.Position = [85 70 145 15];
                SectionCoordinatesTextAreaLabel.String = 'Section Co-ordinates (in, mm)';

                % Create SectionCoordinatesTextArea_Other
                SectionCoordinatesTextArea_Other = uicontrol(SectionDimensionsPanel_Other,'Style','edit','Max',2);
                SectionCoordinatesTextArea_Other.Position = [247 11 150 76];
                SectionCoordinatesTextArea_Other.HorizontalAlignment = 'left';
                SectionCoordinatesTextArea_Other.TooltipString = sprintf('Enter a pair of x y co-ordinates (separated by comma or space or tab) in each line \n eg:\n x1, y1\n x2, y2');
                PI_Girder =    [   0         0
                                     0    2.0000
                                3.0000    2.0000
                                3.0000    8.0000
                                1.0000    8.0000
                                1.0000   11.0000
                                5.0000   11.0000
                                5.0000    3.0000
                                10.0000    3.0000
                               10.0000   11.0000
                               14.0000   11.0000
                               14.0000    8.0000
                               12.0000    8.0000
                               12.0000    2.0000
                               15.0000    2.0000
                               15.0000         0];
                
                        FHWA_I = [  0      0
                            0       152
                            76      228
                            76      609
                            -76     761
                            -76     913
                            384     913
                            384     761
                            224     609
                            224     228
                            300     152
                            300     0] / 25.4;        
                rect = [0 0;0 20;10 20;10 0];
                SectionCoordinatesTextArea_Other.String = num2str(PI_Girder);
                
                % create InvertSectionCheckbox
                InvertSectionCheckbox = uicontrol(SectionDimensionsPanel_Other,'Style','checkbox','Callback',@callback_InvertSectionCheckbox);
                InvertSectionCheckbox.String = 'Invert Section';
                InvertSectionCheckbox.Position = [120 15 120 15];
                
            % Create ConventionalLongitudinalReinforcementPanel_Other
            ConventionalLongitudinalReinforcementPanel_Other = uipanel(OtherSectionPanel);
            ConventionalLongitudinalReinforcementPanel_Other.Title = 'Conventional Longitudinal Reinforcement';
            ConventionalLongitudinalReinforcementPanel_Other.Units = 'pixels';
            ConventionalLongitudinalReinforcementPanel_Other.Position = [8 163 413 135];

                % Create CompressionRebarsLabel
                CompressionRebarsLabel = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'text');
                CompressionRebarsLabel.FontWeight = 'bold';
                CompressionRebarsLabel.Position = [159 99 140 15];
                CompressionRebarsLabel.String = 'Compression Rebars';

                % Create TensionRebarsLabel
                TensionRebarsLabel_Other = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'text');
                TensionRebarsLabel_Other.FontWeight = 'bold';
                TensionRebarsLabel_Other.Position = [304 99 105 15];
                TensionRebarsLabel_Other.String = 'Tension Rebars';

                % Create BarSizeDropDown_3Label
                BarSizeDropDownLabel_Other = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'text');
                BarSizeDropDownLabel_Other.HorizontalAlignment = 'right';
                BarSizeDropDownLabel_Other.Position = [115 74 51 15];
                BarSizeDropDownLabel_Other.String = 'Bar Size';

                % Create BarSizeDropDown_3
                BarSizeDropDownComp_Other = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'popupmenu');
                BarSizeDropDownComp_Other.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownComp_Other.Position = [181 70 100 22];
                BarSizeDropDownComp_Other.Value = 1;

                % Create BarSizeDropDown_4
                BarSizeDropDownTens_Other = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'popupmenu');
                BarSizeDropDownTens_Other.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Other.Position = [300 70 100 22];
                BarSizeDropDownTens_Other.Value = 4;
                
                % Create Rebar Co-ordinates Label
                RebarCoorLabel_Other = uicontrol('Parent', ConventionalLongitudinalReinforcementPanel_Other, 'Style', 'text');
                RebarCoorLabel_Other.HorizontalAlignment = 'right';
                RebarCoorLabel_Other.Position = [5 41 170 15];
                RebarCoorLabel_Other.String = 'Each rebar co-ordinates (in, mm)';
                
                % Create Rebar Co-ordinates textarea input field
                RebarCoorComp_Other = uicontrol(ConventionalLongitudinalReinforcementPanel_Other,'Style','edit','Max',2);
                RebarCoorComp_Other.Position = [183 8 100 51];
                RebarCoorComp_Other.HorizontalAlignment = 'left';
                RebarCoorComp_Other.TooltipString = sprintf('Enter a pair of x y co-ordinates (separated by comma or space or tab) in each line \n eg:\n x1, y1\n x2, y2');
                
                % Create Rebar Co-ordinates textarea input field for
                % compression rebars
                RebarCoorComp_Other = uicontrol(ConventionalLongitudinalReinforcementPanel_Other,'Style','edit','Max',2);
                RebarCoorComp_Other.Position = [183 8 100 51];
                RebarCoorComp_Other.HorizontalAlignment = 'left';
                RebarCoorComp_Other.TooltipString = sprintf('Enter a pair of x y co-ordinates (separated by comma or space or tab) in each line \n eg:\n x1, y1\n x2, y2');
                            comp_rebars_other = [2,1
                                                13,1];
                RebarCoorComp_Other.String = num2str(comp_rebars_other);
                
                 % Create Rebar Co-ordinates textarea input field for
                 % tension rebars
                RebarCoorTens_Other = uicontrol(ConventionalLongitudinalReinforcementPanel_Other,'Style','edit','Max',2);
                RebarCoorTens_Other.Position = [298 8 100 51];
                RebarCoorTens_Other.HorizontalAlignment = 'left';
                RebarCoorTens_Other.TooltipString = sprintf('Enter a pair of x y co-ordinates (separated by comma or space or tab) in each line \n eg:\n x1, y1\n x2, y2');
                            tens_rebars_other = [   2,10
                                                    2, 9
                                                    4, 10
                                                    11, 10
                                                    13,9
                                                    13,10];
                RebarCoorTens_Other.String = num2str(tens_rebars_other);
              
            % Create PrestressingPanel_Other
            PrestressingPanel_Other = uipanel(OtherSectionPanel);
            PrestressingPanel_Other.Title = 'Prestressing';
            PrestressingPanel_Other.Units = 'pixels';
            PrestressingPanel_Other.Position = [10 8 413 151];
            
                % Create DiameterDropDown_3Label
                PSDiameterDropDownLabel_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'text');
                PSDiameterDropDownLabel_Other.HorizontalAlignment = 'right';
                PSDiameterDropDownLabel_Other.Position = [175 107 90 15];
                PSDiameterDropDownLabel_Other.String = 'Diameter (in, mm)';
                
                % Create DiameterDropDown_Other
                PSDiameterDropDown_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'popupmenu');
                PSDiameterDropDown_Other.Position = [273.03125 103 100 22];
                PSDiameterDropDown_Other.String = {'0'}; 
                PSDiameterDropDown_Other.Value =1;

                % Create DistanceofreinforcementlayersfromtopfiberEditFieldLabel_4
                DistanceofreinforcementlayersfromtopfiberEditFieldLabel_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'text');
                DistanceofreinforcementlayersfromtopfiberEditFieldLabel_Other.HorizontalAlignment = 'right';
                DistanceofreinforcementlayersfromtopfiberEditFieldLabel_Other.Position = [106 75 152 15];
                DistanceofreinforcementlayersfromtopfiberEditFieldLabel_Other.String = 'No. of Prestressing Strands';

                % Create NoofPrestressingStrands_Other
                Noofprestressingstrands_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'edit');
                Noofprestressingstrands_Other.Position = [273 71 100 22];
                Noofprestressingstrands_Other.String = 1;

                % Create DistanceofCGofPSstrandsfromtopfiberLabel_Other
                DistanceofCGofPSstrandsfromtopfiberLabel_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'text');
                DistanceofCGofPSstrandsfromtopfiberLabel_Other.HorizontalAlignment = 'right';
                DistanceofCGofPSstrandsfromtopfiberLabel_Other.Position = [5 46 253 15];
                DistanceofCGofPSstrandsfromtopfiberLabel_Other.String = 'Distance of CG of PS strands from top fiber (in, mm)';

                % Create DistanceofCGofPSstrandsfromtopfiberEditField_Other
                DistanceofCGofPSstrandsfromtopfiber_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'edit');
                DistanceofCGofPSstrandsfromtopfiber_Other.Position = [273 39 100 22];
                DistanceofCGofPSstrandsfromtopfiber_Other.String = 18;

                % Create GradeDropDown_6Label
                GradeDropDownLabel_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'text');
                GradeDropDownLabel_Other.HorizontalAlignment = 'right';
                GradeDropDownLabel_Other.Position = [18 107 39 15];
                GradeDropDownLabel_Other.String = 'Grade';

                % Create GradeDropDown_Other
                PSGradeInfo_Other = uicontrol(PrestressingPanel_Other,'Style','edit');
                PSGradeInfo_Other.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Other.Enable = 'off';
                PSGradeInfo_Other.Position = [67 103 100 22];

                % the diameter is dependent upon the prestressing steel grade.
                % The callback functions sets the options for the diameter
                % corresponding to the grade of the PS strand.
                
                % Create StressinPSstrandsafteralllossesLabel_Other
                StressinPSstrandsafteralllossesLabel_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'text');
                StressinPSstrandsafteralllossesLabel_Other.HorizontalAlignment = 'right';
                StressinPSstrandsafteralllossesLabel_Other.Position = [17 11 240 15];
                StressinPSstrandsafteralllossesLabel_Other.String = 'Stress in PS strands after all losses (in, mm)';

                % Create StressinPSstrandsafteralllosses_Other
                StressinPSstrandsafteralllosses_Other = uicontrol('Parent', PrestressingPanel_Other, 'Style', 'edit');
                StressinPSstrandsafteralllosses_Other.Position =  [273.03125 7 100 22];
                StressinPSstrandsafteralllosses_Other.String = 200;
                
        % =============== End of Other Section Panel ================= %
  
        % convert everything to section co-ordinates. So use single plot
        % button.
        
        % Create PlotSectionButton
        PlotSectionButton = uicontrol('Parent',SectionPropertiesTab,'Style','pushbutton','Callback',@callback_plot_section_button);
        PlotSectionButton.String = 'Plot Section';
        PlotSectionButton.Position = [165 40 100 22];
            
        % Create Plot Axes
        PlotSectionAxes = axes('Parent',SectionPropertiesTab);
        PlotSectionAxes.Units = 'Pixels';
        title(PlotSectionAxes, 'Section Preview');
        xlabel(PlotSectionAxes, ['Width ' distance_Units]);
        ylabel(PlotSectionAxes, ['Height ' distance_Units]);
        set(PlotSectionAxes,'Ydir','reverse');
        PlotSectionAxes.Position = [510 50 475 530];
        box(PlotSectionAxes,'on');
            
    %% M-Phi Tab (MPhiTab)  
    
        % Create CurvaturerangeforanalysisPanel
        CurvaturerangeforanalysisPanel = uipanel('Parent',MPhiTab);
%         CurvaturerangeforanalysisPanel.Title = 'Run Analysis';
        CurvaturerangeforanalysisPanel.FontWeight = 'bold';
        CurvaturerangeforanalysisPanel.Units = 'Pixels';
        CurvaturerangeforanalysisPanel.Position = [17 410 368 183];
        CurvaturerangeforanalysisPanel.BorderType ='none';
 
            % Create RunAnalysisButton
            RunAnalysisButton = uicontrol(CurvaturerangeforanalysisPanel, 'Style','pushbutton','Callback',@callback_RunAnalysisButton);
            RunAnalysisButton.Position = [100 65 150 50];
            RunAnalysisButton.String = 'Run Analysis';
            
        % Create ReportPanel
        ReportPanel = uipanel('Parent',MPhiTab);
        ReportPanel.Title = 'Project Information';
        ReportPanel.FontWeight = 'bold';
        ReportPanel.Units = 'Pixels';
        ReportPanel.Position = [17 130 368 263];
            
    
            % Create ProjectTitleEditFieldLabel
            ProjectTitleEditFieldLabel = uicontrol(ReportPanel,'Style','text');
            ProjectTitleEditFieldLabel.HorizontalAlignment = 'right';
            ProjectTitleEditFieldLabel.Position = [6.03125 210 68 15];
            ProjectTitleEditFieldLabel.String = 'Project Title';

            % Create ProjectTitleEditField
            ProjectTitleEditField = uicontrol(ReportPanel, 'Style','edit');
            ProjectTitleEditField.Position = [89.03125 206 262 22];
            ProjectTitleEditField.HorizontalAlignment = 'left';
            ProjectTitleEditField.String = 'Untitled Project';

            % Create SaveMPhiplotasCheckBox
            SaveMPhiplotasCheckBox = uicontrol(ReportPanel,'Style','text');
            SaveMPhiplotasCheckBox.String = 'Save report as';
            SaveMPhiplotasCheckBox.Position = [11 150 122.71875 15];

            % Create xlsCheckBox
            figCheckBox = uicontrol(ReportPanel,'Style','checkbox');
            figCheckBox.String = '.fig & .png';
            figCheckBox.Position = [148 177 100 15];
            figCheckBox.Value = true;
            
            % Create txtCheckBox
            txtCheckBox = uicontrol(ReportPanel,'Style','checkbox');
            txtCheckBox.String = '.txt';
            txtCheckBox.Position = [148 150 38.015625 15];
            txtCheckBox.Value = true;
            
            % Create xlsCheckBox
            xlsCheckBox = uicontrol(ReportPanel,'Style','checkbox');
            xlsCheckBox.String = '.xls';
            xlsCheckBox.Position = [148 123 48.03125 15];
            xlsCheckBox.Value = true;

            % Create SavetofolderEditFieldLabel
            SavetofolderEditFieldLabel = uicontrol(ReportPanel,'Style','text');
            SavetofolderEditFieldLabel.HorizontalAlignment = 'right';
            SavetofolderEditFieldLabel.Position = [11 97 80 15];
            SavetofolderEditFieldLabel.String = 'Save to folder';

            % Create SavetofolderEditField
            SavetofolderEditField = uicontrol(ReportPanel, 'Style','edit');
            SavetofolderEditField.Position = [104.03125 92 155 22];
            SavetofolderEditField.String = 'Report\';
            SavetofolderEditField.HorizontalAlignment = 'left';
            
            % Create BrowseButton
            BrowseButton = uicontrol('Parent', ReportPanel, 'Style', 'pushbutton','Callback',@callback_BrowseButton);
            BrowseButton.Units = 'Pixels';
            BrowseButton.Position =  [273 92 77 22];
            BrowseButton.String= 'Browse';   
            
                        
            % Create SaveReportButton
            SaveReportButton = uicontrol('Parent', ReportPanel, 'Style', 'pushbutton','Callback',@callback_SaveReportButton);
            SaveReportButton.Units = 'Pixels';
            SaveReportButton.Position =  [134 30 100 22];
            SaveReportButton.String= 'Save Report'; 
            SaveReportButton.Enable = 'off';
        
        % Create Product Information Panel
        ProductInformationPanel = uipanel(MPhiTab);
        ProductInformationPanel.Units = 'pixels';
        ProductInformationPanel.Position = [17 5 964 81];
        ProductInformationPanel.BackgroundColor = 'white';
        
        % Create InfoText
        InfoText = uicontrol(ProductInformationPanel,'Style','text');
        InfoText.Position = [5 5 954 71];
        InfoText.HorizontalAlignment = 'left';
        InfoText.String = '';
        InfoText.BackgroundColor = 'white';
            
        % Create plot for M-Phi
        MPhiPlot = axes(MPhiTab);
        title(MPhiPlot, 'Moment-Curvature');
        xlabel(MPhiPlot, ['Curvature ' Phi_Units]);
        ylabel(MPhiPlot, ['Moment ' M_Units]);
        MPhiPlot.Units = 'Pixels';
        MPhiPlot.Position = [470 135 515 445];
        box(MPhiPlot,'on');
        
    %% About Tab
        AboutText = uicontrol('Parent',AboutTab,'Style','text');
            AboutText.HorizontalAlignment = 'left';
            AboutText.Position = [249 170 508 325];

            AboutText.String = {'Moment-Curvature for Beams with Advanced Materials (MC-BAM) software is developed at the University of Nevada, Reno by the graduate research assisstant Suresh Dhakal under the supervision of Asst. Prof. Mohamed A. Moustafa. '; ''; 'Contact:';''; 'Suresh Dhakal'; 'Graduate Student';'Civil and Environmental Engineering'; 'University of Nevada, Reno'; 'email: sureshdhakal@nevada.unr.edu'; ''; 'Mohamed A. Moustafa, Ph.D., P.E.'; 'Asstistant Professor';'Civil and Environmental Engineering'; 'University of Nevada, Reno'; 'email: mmoustafa@unr.edu'; ''; 'Copyright 2018 Suresh Dhakal, Mohamed A. Moustafa'};
            AboutText.FontSize = 10;           
            
            
 %% CALLBACK FUNCTIONS
    % callback function for units
        % function to convert the user defined units to US Customary Units
        % Note: The software does all the calculations based on US
        % Customary Units. The inputs and outputs are converted to and from
        % the US customary units only for the ease of the user.
    
    % note the last saved popup menu option so that if the user clicks
    % 'N,mm' option when 'N,mm' was already there, all factors are set to 1
    lastUnits = 'Kip,in';
    % lastUnits HAS TO BE initated as 'Kip,in' because all the default
    % values in the textboxes are given in Kip,in
    
        %conversion factors
        MPaToKsi = 0.145038;
        mmToIn = 1/25.4;
        kNmToKin = 8.8507; 
    
        
    function callback_UnitsDropDown(~,~)
        % read values and change to other units when the user changes the
        % dropdown option
        
        %NOTE: stressFactor, distanceFactor, momentFactor are used to
        %toggle bewtween Kipin and Nmm unit conventions. 
        switch UnitsDropDown.String{UnitsDropDown.Value}
            
            case lastUnits
                stressFactor = 1;
                distanceFactor = 1;
                momentFactor = 1;                    
            case 'N,mm'
                stressFactor = 1/MPaToKsi;
                distanceFactor = 1/mmToIn;
                momentFactor = 1/kNmToKin;
                lastUnits = 'N,mm';
                
                %units to save report and fig
                M_Units = '(kN-m)';
                Phi_Units = '(1/mm)';
                stress_Units = '(MPa)';
                strain_Units = '(mm/mm)';
                distance_Units = '(mm)';
                
                % initialize functions
                barInfo = @barInfoSI;
                
                % change rebar info convention
                BarSizeDropDownComp_Rectangular_CG.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDownTens_Rectangular_CG.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDownComp_Rectangular_clrCover.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDownTens_Rectangular_clrCover.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDown_Circular.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDownComp_Other.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                BarSizeDropDownTens_Other.String = {'0','10', '13', '16', '19', '22', '25', '29', '32', '36', '43', '57'};
                
                % for PS strands
                PSGradeDropDown.String = {'None', 'Grade 1725', 'Grade 1860'};
%                 previous_grade_SI = PSGradeDropDown.Value;
                
            case 'Kip,in'
                stressFactor = MPaToKsi;
                distanceFactor = mmToIn;
                momentFactor = kNmToKin;
                lastUnits = 'Kip,in';
                
                %units to save report and fig
                M_Units = '(kip-in)';
                Phi_Units = '(1/in)';
                stress_Units = '(ksi)';
                strain_Units = '(in/in)';
                distance_Units = '(in)';
                
                % initialize functions
                barInfo = @barInfoUS;
                
                % change rebar info convention
                BarSizeDropDownComp_Rectangular_CG.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Rectangular_CG.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownComp_Rectangular_clrCover.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Rectangular_clrCover.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDown_Circular.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownComp_Other.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                BarSizeDropDownTens_Other.String = {'0','3', '4', '5', '6', '7', '8', '9', '10', '11', '14', '18'};
                
                % for PS strands
                PSGradeDropDown.String = {'None', 'Grade 250', 'Grade 270'};
        end
   
        Units_Convention.String = {['Enter stresses in ' stress_Units], ['and lengths in ' distance_Units]};    
          %% ----------------- Read Data from concrete tab ---------------
                % and initialize the concrete = @ConcreteName
            
                    fc = str2double(fc_UHPC_EditField.String)*stressFactor;
                        fc_UHPC_EditField.String = num2str(fc);

                    fcu = str2double(fcu_UHPC_EditField.String)*stressFactor;
                        fcu_UHPC_EditField.String = num2str(fcu);
                    ft = str2double(ft_UHPC_EditField.String)*stressFactor;
                        ft_UHPC_EditField.String = num2str(ft);

					fc = str2double(fc_Concrete02_EditField.String)*stressFactor;
                        fc_Concrete02_EditField.String = num2str(fc);
                    fcu = str2double(fcu_Concrete02_EditField.String)*stressFactor;
                        fcu_Concrete02_EditField.String = num2str(fcu);
                    ft = str2double(ft_Concrete02_EditField.String)*stressFactor;
                        ft_Concrete02_EditField.String = num2str(ft);
                    Ets = str2double(Ets_Concrete02_EditField.String)*stressFactor;
                        Ets_Concrete02_EditField.String = num2str(Ets);

                    fc = str2double(fc_Idealized_UHPC_EditField.String)*stressFactor;
                        fc_Idealized_UHPC_EditField.String = num2str(fc);
                    Ec0 = str2double(Ec0_Idealized_UHPC_EditField.String)*stressFactor;
                        Ec0_Idealized_UHPC_EditField.String =  num2str(Ec0);
                    fcr = str2double(fcr_Idealized_UHPC_EditField.String)*stressFactor;
                        fcr_Idealized_UHPC_EditField.String = num2str(fcr);
                    ftu = str2double(ftu_Idealized_UHPC_EditField.String)*stressFactor;
                        ftu_Idealized_UHPC_EditField.String = num2str(ftu);
                    stress_strain = str2num(custom_stress_strain_values.String);
                        stress_strain(:,2) = stress_strain(:,2)*stressFactor;
                        custom_stress_strain_values.String = num2str(stress_strain);
                    Ec0 = str2double(Ec0_CustomConcrete.String)*stressFactor;
                        Ec0_CustomConcrete.String = num2str(Ec0);

        % ------------------- Read Tension Rebar Parameters ------%
                            fy_Tens = abs(str2double(yieldstressfyksiEditField_TensRebar_Park.String))*stressFactor;
                                yieldstressfyksiEditField_TensRebar_Park.String = num2str(fy_Tens);
                            fu_Tens = abs(str2double(ultimatestressintensionfuksiEditField_TensRebar_Park.String))*stressFactor; 
                                ultimatestressintensionfuksiEditField_TensRebar_Park.String = num2str(fu_Tens);
                            Es_Tens = abs(str2double(initialelastictangentEsEditField_TensRebar_Park.String))*stressFactor; 
                                initialelastictangentEsEditField_TensRebar_Park.String = num2str(Es_Tens);
                            fl_Tens = abs(str2double(stressAtTheEndOfLinearRegion_TensRebar_NP.String))*stressFactor;
                                stressAtTheEndOfLinearRegion_TensRebar_NP.String = num2str(fl_Tens);
                            fp_Tens = abs(str2double(stressAtTheEndPlateau_TensRebar_NP.String))*stressFactor; 
                                stressAtTheEndPlateau_TensRebar_NP.String = num2str(fp_Tens);
                            Es_Tens = abs(str2double(initialElasticTangent_TensRebar_NP.String))*stressFactor; 
                                initialElasticTangent_TensRebar_NP.String = num2str(Es_Tens);
                    % ------------------- Read Compression Rebar Parameters ------%
                            fy_Comp = abs(str2double(yieldstressfyksiEditField_CompRebar_Park.String))*stressFactor;
                                yieldstressfyksiEditField_CompRebar_Park.String = num2str(fy_Comp);
                            fu_Comp = abs(str2double(ultimatestressintensionfuksiEditField_CompRebar_Park.String))*stressFactor;
                                ultimatestressintensionfuksiEditField_CompRebar_Park.String = num2str(fu_Comp);
                            Es_Comp = abs(str2double(initialelastictangentEsEditField_CompRebar_Park.String))*stressFactor; 
                                initialelastictangentEsEditField_CompRebar_Park.String = num2str(Es_Comp);
                            fl_Comp = abs(str2double(stressAtTheEndOfLinearRegion_CompRebar_NP.String))*stressFactor;
                            
                                stressAtTheEndOfLinearRegion_CompRebar_NP.String = num2str(fl_Comp);
                            fp_Comp = abs(str2double(stressAtTheEndPlateau_CompRebar_NP.String))*stressFactor; 
                                stressAtTheEndPlateau_CompRebar_NP.String = num2str(fp_Comp);
                            Es_Comp = abs(str2double(initialElasticTangent_CompRebar_NP.String))*stressFactor; 
                                initialElasticTangent_CompRebar_NP.String = num2str(Es_Comp);
                    
                        Eps = str2double(ModulusofelasticityEpsEditField.String)*stressFactor;      
                            ModulusofelasticityEpsEditField.String = num2str(Eps);
                %% ----------- Read data from Section Properties tab----------
                callback_PSGradeDropDown
                        extDia = str2double(ExternalDiameterinEditField_Circular.String)*distanceFactor;
                            ExternalDiameterinEditField_Circular.String = num2str(extDia);
                        clrCover = str2double(ClearcoverinEditField_Circular.String)*distanceFactor;
                            ClearcoverinEditField_Circular.String = num2str(clrCover);
                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Circular.String)*distanceFactor;
                            DistanceofCGofPSstrandsfromtopfiber_Circular.String = num2str(PS_d);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Circular.String)*stressFactor;
                            StressinPSstrandsafteralllosses_Circular.String = num2str(PS_stress_after_losses);

%                     elseif OtherButton.Value
                        sec_coor = str2num(SectionCoordinatesTextArea_Other.String)*distanceFactor;
                            SectionCoordinatesTextArea_Other.String = num2str(sec_coor);

                        coorTens =  str2num(RebarCoorTens_Other.String)*distanceFactor;
                            RebarCoorTens_Other.String = num2str(coorTens);
                        coorComp = str2num(RebarCoorComp_Other.String)*distanceFactor;
                            RebarCoorComp_Other.String = num2str(coorComp);

                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Other.String)*distanceFactor;
                            DistanceofCGofPSstrandsfromtopfiber_Other.String = num2str(PS_d);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Other.String)*stressFactor;
                            StressinPSstrandsafteralllosses_Other.String = num2str(PS_stress_after_losses);

%                     else RectangularButton.Value
                        w = str2double(WidthEditField.String)*distanceFactor;
                            WidthEditField.String = num2str(w);
                        h = str2double(HeightEditField.String)*distanceFactor;
                            HeightEditField.String = num2str(h);
                            d = str2num(DistanceoflayerfromtopTens_Rectangular_CG.String)*distanceFactor;
                                DistanceoflayerfromtopTens_Rectangular_CG.String = num2str(d);
                            d1 = str2num(DistanceoflayerfromtopComp_Rectangular_CG.String)*distanceFactor;
                                DistanceoflayerfromtopComp_Rectangular_CG.String = num2str(d1);
                            clrCoverTens = str2double(ClearCoverTens_Rectangular_clrCover.String)*distanceFactor;
                                ClearCoverTens_Rectangular_clrCover.String = num2str(clrCoverTens);
                            clrCoverComp = str2double(ClearCoverComp_Rectangular_clrCover.String)*distanceFactor;
                                ClearCoverComp_Rectangular_clrCover.String = num2str(clrCoverComp);
                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Rectangular.String)*distanceFactor;
                            DistanceofCGofPSstrandsfromtopfiber_Rectangular.String = num2str(PS_d);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Rectangular.String)*stressFactor;
                            StressinPSstrandsafteralllosses_Rectangular.String = num2str(PS_stress_after_losses);

    end
 
        %% CALLBACK FUNCTIONS FOR TABGROUP
    function SelectionChangedFcn_tabGroup(~,event)
        switch event.NewValue.Title
            case 'About'
               Units_Label.Visible = 'off';
               UnitsDropDown.Visible = 'off';                
            otherwise
               Units_Label.Visible = 'on';
               UnitsDropDown.Visible = 'on';   
        end
    end
        %% CALLBACK FUNCTIONS FOR CONCRETE TAB 
       
        function SelectionChangedFcn_Concrete_radio_buttongroup(~,event)
        % function to display only the corresponding concrete panel
        % as per the user selection
        
            switch event.NewValue.String
                case 'UHPC'
                    UHPCPanel.Visible = 'on';
                    Concrete02Panel.Visible = 'off';
                    Idealized_UHPCPanel.Visible = 'off';
                    CustomConcretePanel.Visible = 'off';
                case 'Conventional Concrete'
                    UHPCPanel.Visible = 'off';
                    Concrete02Panel.Visible = 'on';
                    Idealized_UHPCPanel.Visible = 'off';
                    CustomConcretePanel.Visible = 'off';
                case 'Idealized UHPC'
                    UHPCPanel.Visible = 'off';
                    Concrete02Panel.Visible = 'off';
                    Idealized_UHPCPanel.Visible = 'on';
                    CustomConcretePanel.Visible = 'off';
                case 'Custom Concrete'
                    UHPCPanel.Visible = 'off';
                    Concrete02Panel.Visible = 'off';
                    Idealized_UHPCPanel.Visible = 'off';
                    CustomConcretePanel.Visible = 'on';
            end
        end
    
        %------------- PLOT Stress Strain for UHPC --------------%
        function callback_plot_concrete_stress_strain_button(~,~)
        	% extract values
            if UHPC_radio.Value
                
                fc = str2double(fc_UHPC_EditField.String);
                epsc0 = str2double(epsc0_UHPC_EditField.String);
                fcu = str2double(fcu_UHPC_EditField.String);
                epscu = str2double(epscu_UHPC_EditField.String);
                ft = str2double(ft_UHPC_EditField.String);
                epst = str2double(epst_UHPC_EditField.String);
                epstu = str2double(epstu_UHPC_EditField.String);
                n = str2double(n_UHPC_EditField.String);

                % display the computed value of Ec0 in the textfield
                Ec0 = (n+1)/n*fc/epsc0;
                Ec0_UHPC_EditField.String = Ec0;

                concreteStrain = [1.4*epscu:(epstu-epscu)/100:epstu];
                concrete = @UHPC;
                concrete([],fc, epsc0, fcu, epscu, ft, epst, epstu, n);
                
%                 stress = arrayfun(@(x) compression_envelope(x),strain);
                
                titleText = 'Stress Strain Plot for UHPC';
            elseif Concrete02_radio.Value
                fc = str2double(fc_Concrete02_EditField.String);
                epsc0 = str2double(epsc0_Concrete02_EditField.String);
                fcu = str2double(fcu_Concrete02_EditField.String);
                epscu = str2double(epscu_Concrete02_EditField.String);
                ft = str2double(ft_Concrete02_EditField.String);
                Ets = str2double(Ets_Concrete02_EditField.String);
                
                n = str2double(n_Concrete02_EditField.String);

                % display the computed value of Ec0 in the textfield
                Ec0 = (n+1)/n*fc/epsc0;
                epstu = ft/Ec0 + ft/Ets;
                
                Ec0_Concrete02_EditField.String = Ec0;
                
                concrete = @Concrete02;
                concrete([],fc, epsc0, fcu, epscu, ft, Ets);
                
                concreteStrain = [1.4*epscu:(epstu-epscu)/100:epstu];
                titleText = 'Stress Strain Plot for Conventional Concrete';
                
            elseif Idealized_UHPC_radio.Value
                fc = str2double(fc_Idealized_UHPC_EditField.String);
                Ec0 = str2double(Ec0_Idealized_UHPC_EditField.String);
                alpha = str2double(alpha_Idealized_UHPC_EditField.String);
                epscu = str2double(epscu_Idealized_UHPC_EditField.String);
                fcr = str2double(fcr_Idealized_UHPC_EditField.String);
                gamma = str2double(gamma_Idealized_UHPC_EditField.String);
                ftu = str2double(ftu_Idealized_UHPC_EditField.String);
                epstu  = str2double(epstu_Idealized_UHPC_EditField.String);
                
                concrete = @Idealized_UHPC;
                concrete([],fc,Ec0,alpha,epscu,fcr,gamma,ftu,epstu);
                
                concreteStrain = [epscu:(epstu-epscu)/100:epstu];
                titleText = 'Stress Strain Plot for Idealized UHPC';
                
            elseif CustomConcrete_radio.Value
                stress_strain = str2num(custom_stress_strain_values.String);
                concreteStrain = min(stress_strain(:,1)):(max(stress_strain(:,1))-min(stress_strain(:,1)))/100:max(stress_strain(:,1));
                
                concrete = @customConcrete;
                concrete([],stress_strain);
                
                titleText = 'Stress Strain Plot for Custom Concrete';
                clear stress_strain;
            end
            
            concreteStress = arrayfun(@(x) concrete(x),concreteStrain);            
                        
            plot(StressStrainPlotConcrete,concreteStrain,concreteStress,'LineWidth',1);
            grid(StressStrainPlotConcrete,'on');
            title(StressStrainPlotConcrete, titleText)
            xlabel(StressStrainPlotConcrete, ['Strain ' strain_Units])
            ylabel(StressStrainPlotConcrete, ['Stress' stress_Units])
            StressStrainPlotConcrete.XLim = [min(concreteStrain)-0.1*(max(concreteStrain)-min(concreteStrain)), max(concreteStrain)+0.1*(max(concreteStrain)-min(concreteStrain))];
            StressStrainPlotConcrete.YLim = [min(concreteStress)-0.1*(max(concreteStress)-min(concreteStress)), max(concreteStress)+0.1*(max(concreteStress)-min(concreteStress))];
            grid(StressStrainPlotConcrete,'minor');
%             saveas(StressStrainPlotConcrete,'Stress Strain for Concrete.jpg')
        end
       
    % End of UHPC Panel
 
    % End of Concrete Tab (ConcreteTab)
    
        %% Callback functions for SteelTab
        % initialize PSPlot and RebarPlot so that their value modified by
        % the callback_SteelPlotButton function can be accessed by the
        % checkbox callback functions : callback_ConventionalRebarCheckBox
        % and callback_PrestressingStrandsCheckBox
        PSPlot = [];
        RebarTensPlot =[];
        RebarCompPlot =[];
        
        % PS_grade =0 initialized so that it can be changed by
        % callback_PSGradeDropDown function and accessed by
        % callback_SteelPlotButton function
        PS_grade = 0;
        
        % callback_PSGradeDropDown function changes PS_grade according to
        % the grade selected by the user
        
        
%         callback_PSGradeDropDown

        %callback_PSGradeDropDown function is defined in 'Callback Functions
        %for Section Properties Tab' Section
        
        function callback_SteelPlotButton(~,~)
%             callback_PSGradeDropDown
            % ------------------- Read Tension Rebar Parameters ------%
            switch rebarConstitutiveModelDropdown_TensRebar.String{rebarConstitutiveModelDropdown_TensRebar.Value}
                
                case 'Having yield plateau (Park)'
                    fy_Tens = abs(str2double(yieldstressfyksiEditField_TensRebar_Park.String));
                    fu_Tens = abs(str2double(ultimatestressintensionfuksiEditField_TensRebar_Park.String)); 
                    Es_Tens = abs(str2double(initialelastictangentEsEditField_TensRebar_Park.String)); 
                    esh_Tens = abs(str2double(straincorrespondingtoinitialstrainhardeningesh_TensRebar_Park.String)); 
                    eult_Tens = abs(str2double(strainatpeakultimatestresseult_TensRebar_Park.String));
                    Es_multiplier_Tens = abs(str2double(ES_final_slope_multiplier_TensRebar_Park.String));
                    
                    rebarTens = @rebarPark;
                    rebarTens([],fy_Tens,fu_Tens,Es_Tens,esh_Tens,eult_Tens,Es_multiplier_Tens);
                   
                    efinal = (eult_Tens + fu_Tens/(Es_multiplier_Tens*Es_Tens));
                    strain_Tens = -efinal:efinal/100:efinal;
                    
                case 'Without yield plateau'
                    fl_Tens = abs(str2double(stressAtTheEndOfLinearRegion_TensRebar_NP.String));
                    fp_Tens = abs(str2double(stressAtTheEndPlateau_TensRebar_NP.String)); 
                    Es_Tens = abs(str2double(initialElasticTangent_TensRebar_NP.String)); 
                    ep_Tens = abs(str2double(strainAtTheStartOfEndPlateau_TensRebar_NP.String)); 
                    eult_Tens = abs(str2double(ultimateStrain_TensRebar_NP.String));
                    n_Tens = abs(str2double(ultimateStrain_TensRebar_NP.String));
                    
                    rebarTens = @SteelNoPlateau;
                    rebarTens([],Es_Tens,fl_Tens,ep_Tens,fp_Tens,eult_Tens,n_Tens);
                    
                    strain_Tens = -eult_Tens:eult_Tens/100:eult_Tens;
                    
                case 'HSS Grade 100'
                    
                    switch UnitsDropDown.String{UnitsDropDown.Value}
                        case 'N,mm'
                            Es_Tens = 29000*(1/MPaToKsi); % ksi
                            rebarTens = @(x) (1/MPaToKsi)*ACIGrade100(x);
                        case 'Kip,in'
                            Es_Tens = 29000; % ksi
                            rebarTens = @ACIGrade100;                            
                    end   
                    strain_Tens = -0.06:0.0006:0.06;
                    
            end
            
            stress_Tens = arrayfun(@(x) rebarTens(x),strain_Tens);
            
            % ------------------- Read Compression Rebar Parameters ------%
            switch rebarConstitutiveModelDropdown_CompRebar.String{rebarConstitutiveModelDropdown_CompRebar.Value}
                
                case 'Having yield plateau (Park)'
                    fy_Comp = abs(str2double(yieldstressfyksiEditField_CompRebar_Park.String));
                    fu_Comp = abs(str2double(ultimatestressintensionfuksiEditField_CompRebar_Park.String)); 
                    Es_Comp = abs(str2double(initialelastictangentEsEditField_CompRebar_Park.String)); 
                    esh_Comp = abs(str2double(straincorrespondingtoinitialstrainhardeningesh_CompRebar_Park.String)); 
                    eult_Comp = abs(str2double(strainatpeakultimatestresseult_CompRebar_Park.String));
                    Es_multiplier_Comp = abs(str2double(ES_final_slope_multiplier_CompRebar_Park.String));
                    
                    rebarComp = @rebarPark;
                    rebarComp([],fy_Comp,fu_Comp,Es_Comp,esh_Comp,eult_Comp,Es_multiplier_Comp);
                   
                    efinal = (eult_Comp + fu_Comp/(Es_multiplier_Comp*Es_Comp));
                    strain_Comp = -efinal:efinal/100:efinal;
                    
                case 'Without yield plateau'
                    fl_Comp = abs(str2double(stressAtTheEndOfLinearRegion_CompRebar_NP.String));
                    fp_Comp = abs(str2double(stressAtTheEndPlateau_CompRebar_NP.String)); 
                    Es_Comp = abs(str2double(initialElasticTangent_CompRebar_NP.String)); 
                    ep_Comp = abs(str2double(strainAtTheStartOfEndPlateau_CompRebar_NP.String)); 
                    eult_Comp = abs(str2double(ultimateStrain_CompRebar_NP.String));
                    n_Comp = abs(str2double(ultimateStrain_CompRebar_NP.String));
                    
                    rebarComp = @SteelNoPlateau;
                    rebarComp([],Es_Comp,fl_Comp,ep_Comp,fp_Comp,eult_Comp,n_Comp);
                    
                    strain_Comp = -eult_Comp:eult_Comp/100:eult_Comp;
                    
                case 'HSS Grade 100'
                    switch UnitsDropDown.String{UnitsDropDown.Value}
                        case 'N,mm'
                            Es_Comp = 29000*(1/MPaToKsi); % ksi
                            rebarComp = @(x) (1/MPaToKsi)*ACIGrade100(x);
                        case 'Kip,in'
                            Es_Comp = 29000; % ksi
                            rebarComp = @ACIGrade100;                            
                    end   
                    strain_Comp = -0.06:0.0006:0.06;
            end
            
            stress_Comp = arrayfun(@(x) rebarComp(x),strain_Comp);
            
            %------- Read prestressing strands properties ---------- %
            Eps = str2double(ModulusofelasticityEpsEditField.String);

            
            callback_PSGradeDropDown % reads PS_grade
            
            RebarTensPlot = plot(SteelAxes,strain_Tens,stress_Tens,'DisplayName','Conventional Tension Rebar','LineWidth',1);
            hold(SteelAxes,'on');
            RebarCompPlot = plot(SteelAxes,strain_Comp,stress_Comp,'DisplayName','Conventional Compression Rebar','LineWidth',1);
            
            if ConventionalTensRebarCheckBox.Value == false
                RebarTensPlot.Visible = 'off';
            else
                RebarTensPlot.Visible = 'on';
            end
            
            if ConventionalCompRebarCheckBox.Value == false
                RebarCompPlot.Visible = 'off';
            else
                RebarCompPlot.Visible = 'on';
            end
            
            % plot stress-strain for prestressing strands
            if PS_grade ~=0
                
                switch PSModelDropdown.String{PSModelDropdown.Value}
                
                    case 'PCI Design Handbook'
                        % since the PCI handbook equation is defined only
                        % in US customary units, calculation is done in US
                        % customary units and post-processed to SI units
                        Eps = 28500;   
                        
                        if PS_grade == 1725
                            PS_grade = 250;
                            PS_PCI([],PS_grade,Eps);
                            PS_sig = @(x) (1/MPaToKsi)*PS_PCI(x);
                        elseif PS_grade == 1860
                            PS_grade = 270;
                            PS_PCI([],PS_grade,Eps);
                            PS_sig = @(x) (1/MPaToKsi)*PS_PCI(x);
                        else
                            PS_PCI([],PS_grade,Eps);
                            PS_sig = @PS_PCI;
                        end
                        
                    case 'Power Equation'
                        Q = str2double(Q_EditField.String);
                        K = str2double(K_EditField.String);
                        R = str2double(R_EditField.String);

                        PS_sig = @PSPowerEqn;
                        PS_sig([],Eps,PS_grade,Q,K,R);
                end
            
                PSStrain = -0.06:0.0006:0.06;
                PSStress = arrayfun(@(x) PS_sig(x),PSStrain);
                                
                hold(SteelAxes,'on');
                PSPlot = plot(SteelAxes,PSStrain,PSStress,'DisplayName','Prestressing Strands','LineWidth',1);
                
                if PrestressingStrandsCheckBox.Value == false
                    PSPlot.Visible = 'off';
                else
                    PSPlot.Visible = 'on';
                end
           end
            hold(SteelAxes,'off');
            
            title(SteelAxes, 'Stress-Strain Plot for Steel')
            xlabel(SteelAxes, ['strain ' strain_Units])
            ylabel(SteelAxes, ['stress' stress_Units])
            grid(SteelAxes,'on');
            legend(SteelAxes,'show','location','east');
            grid(SteelAxes,'minor');
          
        end
    
        % response to checked boxes
        function callback_ConventionalTensRebarCheckBox(~,~)
            if ConventionalTensRebarCheckBox.Value == false
                RebarTensPlot.Visible = 'off';
            else
                RebarTensPlot.Visible = 'on';
            end
        end
    
        function callback_ConventionalCompRebarCheckBox(~,~)
            if ConventionalCompRebarCheckBox.Value == false
                RebarCompPlot.Visible = 'off';
            else
                RebarCompPlot.Visible = 'on';
            end
        end
    
        function callback_PrestressingStrandsCheckBox(~,~)
            if PrestressingStrandsCheckBox.Value == false
                PSPlot.Visible = 'off';
            else
                PSPlot.Visible = 'on';
            end
        end
    
        function callback_rebarConstitutiveModelDropdown_TensRebar(~,event)
            switch rebarConstitutiveModelDropdown_TensRebar.String{rebarConstitutiveModelDropdown_TensRebar.Value}
                    case 'Having yield plateau (Park)'
                        rebarParkPanel_TensRebar.Visible ='on';
                        rebarNoPlateauPanel_TensRebar.Visible = 'off';
                    case 'Without yield plateau'
                        rebarParkPanel_TensRebar.Visible ='off';
                        rebarNoPlateauPanel_TensRebar.Visible = 'on';
                case 'HSS Grade 100'
                    rebarParkPanel_TensRebar.Visible ='off';
                    rebarNoPlateauPanel_TensRebar.Visible = 'off';
            end        
        end

        function callback_rebarConstitutiveModelDropdown_CompRebar(~,event)
            switch rebarConstitutiveModelDropdown_CompRebar.String{rebarConstitutiveModelDropdown_CompRebar.Value}
                    case 'Having yield plateau (Park)'
                        rebarParkPanel_CompRebar.Visible ='on';
                        rebarNoPlateauPanel_CompRebar.Visible = 'off';
                    case 'Without yield plateau'
                        rebarParkPanel_CompRebar.Visible ='off';
                        rebarNoPlateauPanel_CompRebar.Visible = 'on';
                    case 'HSS Grade 100'
                        rebarParkPanel_CompRebar.Visible ='off';
                        rebarNoPlateauPanel_CompRebar.Visible = 'off';
            end        
        end

        function callback_PSModelDropdown(~,~)
            switch PSModelDropdown.String{PSModelDropdown.Value}
                    case 'PCI Design Handbook'
                        PSPowerEqnPanel.Visible ='off';
                    case 'Power Equation'
                        PSPowerEqnPanel.Visible ='on';                        
            end        
        
        end

        %% Callback Functions for Section Properties Tab 
        
        function SelectionChangedFcn_SectionGeometryButtonGroup(~,event)
        % function to display only the corresponding section geometry panel
        % as per the user selection
        
            switch event.NewValue.String
                case 'Rectangular'
                    RectangularSectionPanel.Visible = 'on';
                    CircularSectionPanel.Visible = 'off';
                    OtherSectionPanel.Visible = 'off';
                case 'Circular'
                    RectangularSectionPanel.Visible = 'off';
                    CircularSectionPanel.Visible = 'on';
                    OtherSectionPanel.Visible = 'off';
                case 'Other'
                    RectangularSectionPanel.Visible = 'off';
                    CircularSectionPanel.Visible = 'off';
                    OtherSectionPanel.Visible = 'on';
            end
        end
        
        function SelectionChangedFcn_AsCGorAsD_Rect_Button(~,event) 
                if AsCG_Rect_Radio.Value
                    ConventionalLongitudinalReinforcementPanel_Rectangular_CG.Visible = 'on';
                    ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.Visible = 'off';
                elseif AsClearCover_Rect_Radio.Value
                    ConventionalLongitudinalReinforcementPanel_Rectangular_clrCover.Visible = 'on';
                    ConventionalLongitudinalReinforcementPanel_Rectangular_CG.Visible = 'off'; 
                end
        end
    
        function callback_PSGradeDropDown(~,~)
            % To show the diameter of the PS strands for the corresponding
            % grade chosen by the user
            
            if strcmp(PSGradeDropDown.String{PSGradeDropDown.Value},'None')
                
                set(findall(PrestressingPanel_Rectangular, '-property', 'enable'), 'enable', 'off');
                set(findall(PrestressingPanel_Circular, '-property', 'enable'), 'enable', 'off');
                set(findall(PrestressingPanel_Other, '-property', 'enable'), 'enable', 'off');
                
                PSGradeInfo_Rectangular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Circular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Other.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                
                PSDiameterDropDown_Rectangular.String = {'0'};         
                PSDiameterDropDown_Circular.String ={'0'};    
                PSDiameterDropDown_Other.String = {'0'};
                
                PSDiameterDropDown_Rectangular.Value = 1;         
                PSDiameterDropDown_Circular.Value =1;    
                PSDiameterDropDown_Other.Value = 1;
                
                Noofprestressingstrands_Rectangular.String = 0;
                Noofprestressingstrands_Circular.String = 0;
                Noofprestressingstrands_Other.String = 0;
              
                PS_grade = 0;
            else
                set(findall(PrestressingPanel_Rectangular, '-property', 'enable'), 'enable', 'on');
                set(findall(PrestressingPanel_Circular, '-property', 'enable'), 'enable', 'on');
                set(findall(PrestressingPanel_Other, '-property', 'enable'), 'enable', 'on');
                
                PSDiameterDropDown_Rectangular.Enable = 'on'; 
                PSDiameterDropDown_Circular.Enable = 'on';
                PSDiameterDropDown_Other.Enable = 'on'; 
                
                PSGradeInfo_Rectangular.Enable = 'off';
                PSGradeInfo_Circular.Enable = 'off';
                PSGradeInfo_Other.Enable = 'off';
                
                PSGradeInfo_Rectangular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Circular.String = PSGradeDropDown.String{PSGradeDropDown.Value};
                PSGradeInfo_Other.String = PSGradeDropDown.String{PSGradeDropDown.Value};

                
                switch UnitsDropDown.String{UnitsDropDown.Value}
                    case 'Kip,in'
                        switch PSGradeDropDown.String{PSGradeDropDown.Value}

                            case 'Grade 250'
                                PS_grade = 250;

                                PSDiameterDropDown_Rectangular.String = {'0.250','0.313','0.375','0.438','0.500','0.600'};         
                                PSDiameterDropDown_Circular.String = {'0.250','0.313','0.375','0.438','0.500','0.600'};             
                                PSDiameterDropDown_Other.String = {'0.250','0.313','0.375','0.438','0.500','0.600'};                  
                            case 'Grade 270'
                                PS_grade = 270;

                                PSDiameterDropDown_Rectangular.String = {'0.375','0.438','0.500','0.563','0.600','0.700'};
                                PSDiameterDropDown_Circular.String = {'0.375','0.438','0.500','0.563','0.600','0.700'};
                                PSDiameterDropDown_Other.String = {'0.375','0.438','0.500','0.563','0.600','0.700'};
                        end %switch PSGradeDropDown.String{PSGradeDropDown.Value}
                        
                    case 'N,mm'
                        switch PSGradeDropDown.String{PSGradeDropDown.Value}
                        case 'Grade 1725'
                            PS_grade = 1725;

%                                 PSDiameterDropDown_Rectangular.String = {'0.250','0.313','0.375','0.438','0.500','0.600'};                  
                            PSDiameterDropDown_Rectangular.String = {'6.4','7.9','9.5','11.1','12.7','15.2'};         
                            PSDiameterDropDown_Circular.String = {'6.4','7.9','9.5','11.1','12.7','15.2'};          
                            PSDiameterDropDown_Other.String = {'6.4','7.9','9.5','11.1','12.7','15.2'};                  
                        case 'Grade 1860'
                            PS_grade = 1860;

                            PSDiameterDropDown_Rectangular.String = {'9.53','11.11','12.70','14.29','15.24','17.78'};
                            PSDiameterDropDown_Circular.String = {'9.53','11.11','12.70','14.29','15.24','17.78'};
                            PSDiameterDropDown_Other.String = {'9.53','11.11','12.70','14.29','15.24','17.78'};
                        end % switch PSGradeDropDown.String{PSGradeDropDown.Value}
                end % switch UnitsDropDown.String{UnitsDropDown.Value}

            end %  if strcmp(PSGradeDropDown.String{PSGradeDropDown.Value},'None')
             

        end
        % callback_InvertSectionCheckbox
            function callback_InvertSectionCheckbox(~,~)
                    sec_coor = str2num(SectionCoordinatesTextArea_Other.String);
                    sec_coor = [sec_coor(:,1), -sec_coor(:,2)];
                    SectionCoordinatesTextArea_Other.String = num2str(sec_coor);
                    
                    RebarCoorTens_OtherRead = str2num(RebarCoorTens_Other.String);
                    RebarCoorTens_OtherRead = [RebarCoorTens_OtherRead(:,1), -RebarCoorTens_OtherRead(:,2)];
                    RebarCoorTens_Other.String = num2str(RebarCoorTens_OtherRead);
                    
                    RebarCoorComp_OtherRead = str2num(RebarCoorComp_Other.String);
                    RebarCoorComp_OtherRead = [RebarCoorComp_OtherRead(:,1), -RebarCoorComp_OtherRead(:,2)];
                    RebarCoorComp_Other.String = num2str(RebarCoorComp_OtherRead);
                    
                    h = max(sec_coor(:,2))-min(sec_coor(:,2));
                    DistanceofCGofPSstrandsfromtopfiber_Other.String = h - str2num(DistanceofCGofPSstrandsfromtopfiber_Other.String);
                    
                    callback_plot_section_button                
            end
        
        %--------- Function to Plot Section Preview --------------------%
        function callback_plot_section_button(~,~)
            
        % First convert all inputs into section co-ordinates
        
        % if selected, CircularButton.Value = true                    
            if CircularButton.Value
                  % represent circle by 50 sided regular polygon
                  r = abs(str2double(ExternalDiameterinEditField_Circular.String))/2;
                  sec_shape = nsidedpoly(50,'Center',[r r],'Radius',r);
                  sec_plot = nsidedpoly(50,'Center',[0 0],'Radius',r);
                  issimplified(sec_plot)
                  
                  % reinforcement details
                    clrCover = str2double(ClearcoverinEditField_Circular.String);
                    tensBarNo = str2double(BarSizeDropDown_Circular.String{BarSizeDropDown_Circular.Value});
                    barDiaTens =  barInfo(tensBarNo); % diameter of the bar is used to plot the bar size
                    barDiaComp = 0;
                    howManyBars = str2double(NoofreinforcementbarsEditField_Circular.String);
                    sec_rebar_plot = nsidedpoly(howManyBars,'Center',[0 0],'Radius',r-clrCover-barDiaTens/2);
                    sec_rebar_coor_plot = sec_rebar_plot.Vertices;
                    xTens = sec_rebar_coor_plot(:,1)';
                    yTens = sec_rebar_coor_plot(:,2)';
                    
                    xComp = 0;
                    yComp = 0;
                    
                    % for prestressing strands
                callback_PSGradeDropDown
                
                PS_strand_nominal_dia = str2double(PSDiameterDropDown_Circular.String{PSDiameterDropDown_Circular.Value});
                PS_no_of_strands = str2double(Noofprestressingstrands_Circular.String);
                PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Circular.String)-r;

                A_PS = strandArea(PS_grade, PS_strand_nominal_dia, PS_no_of_strands);
                accum_dia_PS = (4*A_PS/pi)^0.5;
                    
            elseif OtherButton.Value
                sec_coor = str2num(SectionCoordinatesTextArea_Other.String);
                sec_plot = polyshape(sec_coor(:,1),sec_coor(:,2));
                sec_coor = [sec_coor(:,1)-min(sec_coor(:,1)) sec_coor(:,2)-min(sec_coor(:,2))];
                sec_shape = polyshape(sec_coor(:,1),sec_coor(:,2));
                
                % Reinforcement Info
                tensBarNo = str2double(BarSizeDropDownTens_Other.String{BarSizeDropDownTens_Other.Value});
                compBarNo = str2double(BarSizeDropDownComp_Other.String{BarSizeDropDownComp_Other.Value});
                
                barDiaTens = barInfo(tensBarNo);
                barDiaComp =  barInfo(compBarNo);
                
                coorComp = str2num(RebarCoorComp_Other.String);
                xComp = coorComp(:,1)';
                yComp = coorComp(:,2)';
                
                coorTens =  str2num(RebarCoorTens_Other.String);
                xTens = coorTens(:,1)';
                yTens = coorTens(:,2)';
                
                % for prestressing strands
                callback_PSGradeDropDown
                
                PS_strand_nominal_dia = str2double(PSDiameterDropDown_Other.String{PSDiameterDropDown_Other.Value});
                PS_no_of_strands = str2double(Noofprestressingstrands_Other.String);
                PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Other.String)+ min(sec_plot.Vertices(:,2));

                A_PS = strandArea(PS_grade, PS_strand_nominal_dia, PS_no_of_strands);
                accum_dia_PS = (4*A_PS/pi)^0.5;
                
            else RectangularButton.Value
                x = [0 0 abs(str2double(WidthEditField.String)) abs(str2double(WidthEditField.String))];
                y = [0 abs(str2double(HeightEditField.String)) abs(str2double(HeightEditField.String)) 0];
                sec_shape = polyshape(x,y);
                
                % for prestressing strands
                callback_PSGradeDropDown
                
                PS_strand_nominal_dia = str2double(PSDiameterDropDown_Rectangular.String{PSDiameterDropDown_Rectangular.Value});
                PS_no_of_strands = str2double(Noofprestressingstrands_Rectangular.String);
                PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Rectangular.String);

                A_PS = strandArea(PS_grade, PS_strand_nominal_dia, PS_no_of_strands);
                accum_dia_PS = (4*A_PS/pi)^0.5;
                
                    clear x y;
                sec_plot = sec_shape;
                
                % extract rebar information
                if AsCG_Rect_Radio.Value == 1
                    % reinforement info defined as distance upto CG of rebars
                    tensBarNo = str2double(BarSizeDropDownTens_Rectangular_CG.String{BarSizeDropDownTens_Rectangular_CG.Value});
                    tensNoOfBars = str2num(NoofrebarsineachlayerTens_Rectangular_CG.String);
                    d = str2num(DistanceoflayerfromtopTens_Rectangular_CG.String);

                    compBarNo = str2double(BarSizeDropDownComp_Rectangular_CG.String{BarSizeDropDownComp_Rectangular_CG.Value});
                    compNoOfBars = str2num(NoofrebarsineachlayerComp_Rectangular_CG.String);
                    d1 = str2num(DistanceoflayerfromtopComp_Rectangular_CG.String);

                    % only to show the rebars in the section plot for
                    % horizontal spacing
                    clrCoverTens = str2double(ClearCoverTens_Rectangular_clrCover.String);
                    clrCoverComp = clrCoverTens;
                    barDiaTens = barInfo(tensBarNo);
                    barDiaComp =  barInfo(compBarNo);
                    
                    x = arrayfun(@(x) linspace(clrCoverTens+barDiaTens/2,str2double(WidthEditField.String)-clrCoverTens-barDiaTens/2,x),tensNoOfBars,'UniformOutput',false);
                    y = arrayfun(@(x) d(x).*ones(1,tensNoOfBars(x)),[1:length(tensNoOfBars)],'UniformOutput',false);
                    
                    xTens = [x{1:end}];
                    yTens = [y{1:end}];
                    
                    clear x y
                    
                    x = arrayfun(@(x) linspace(clrCoverComp+barDiaComp/2,str2double(WidthEditField.String)-clrCoverComp-barDiaComp/2,x),compNoOfBars,'UniformOutput',false);
                    y = arrayfun(@(x) d1(x).*ones(1,compNoOfBars(x)),[1:length(compNoOfBars)],'UniformOutput',false);
                    
                    xComp = [x{1:end}];
                    yComp = [y{1:end}];
                    
                    clear x y
                else
                    % reinforement info defined as clear cover
                    tensBarNo = str2double(BarSizeDropDownTens_Rectangular_clrCover.String{BarSizeDropDownTens_Rectangular_clrCover.Value});
                    tensNoOfBars = str2num(NoofrebarsineachlayerTens_Rectangular_clrCover.String);
                    clrCoverTens = str2double(ClearCoverTens_Rectangular_clrCover.String);
                    barDiaTens = barInfo(tensBarNo);
                    d = abs(str2double(HeightEditField.String)) - clrCoverTens - barDiaTens/2;

                    compBarNo = str2double(BarSizeDropDownComp_Rectangular_clrCover.String{BarSizeDropDownComp_Rectangular_clrCover.Value});
                    compNoOfBars = str2num(NoofrebarsineachlayerComp_Rectangular_clrCover.String);
                    clrCoverComp = str2double(ClearCoverComp_Rectangular_clrCover.String);
                    barDiaComp =  barInfo(compBarNo);
                    d1 = clrCoverComp + barDiaComp/2;

                    xTens = linspace(clrCoverTens+barDiaTens/2,str2double(WidthEditField.String)-clrCoverTens-barDiaTens/2,tensNoOfBars);
                    yTens = d*ones(tensNoOfBars,1)';

                    xComp = linspace(clrCoverComp+barDiaComp/2,str2double(WidthEditField.String)-clrCoverComp-barDiaComp/2,compNoOfBars);
                    yComp = d1*ones(compNoOfBars,1)';
                end                
            end
            
 
            
            w = max(sec_shape.Vertices(:,1))-min(sec_shape.Vertices(:,1));
            h = max(sec_shape.Vertices(:,2))-min(sec_shape.Vertices(:,2));
  
            box(PlotSectionAxes,'on');
            plot(PlotSectionAxes,sec_plot);
            
            hold(PlotSectionAxes,'on');
            
             % plot prestressing strands
             if A_PS ~=0
                xy_PS = [(max(sec_plot.Vertices(:,1))+min(sec_plot.Vertices(:,1)))/2, PS_d];
                plotRebars(PlotSectionAxes,xy_PS,accum_dia_PS,true);
                    % true indicates plotted rebar is prestressing
                    % strand,so the facecolor is changed to red by the
                    % function
             end
             
             if barDiaComp==0
                    xComp = [];
                    yComp = [];
                else
                    xyComp = num2cell([xComp' yComp'],2);
                    hold(PlotSectionAxes,'on');
                    cellfun(@(x) plotRebars(PlotSectionAxes,x,barDiaComp),xyComp);
                    clear xyComp;
			end

                if barDiaTens==0
                    xTens = [];
                    yTens = [];
                else
                    xyTens = num2cell([xTens' yTens'],2);
                    hold(PlotSectionAxes,'on');
                    cellfun(@(x) plotRebars(PlotSectionAxes,x,barDiaTens),xyTens);
                    clear xyTens;
                end															   
%             end
            
            set(PlotSectionAxes,'Ydir','reverse','xlimmode','auto','ylimmode','auto');
%           pbaspect(PlotSectionAxes,[1 1 1]);
            PlotSectionAxes.DataAspectRatio = [1 1 1];
            title(PlotSectionAxes, 'Section Preview');
            xlabel(PlotSectionAxes, ['Width ' distance_Units]);
            ylabel(PlotSectionAxes, ['Height ' distance_Units]);
            grid(PlotSectionAxes,'minor');
            grid(PlotSectionAxes,'on');
            hold(PlotSectionAxes,'off');
            clear w h xlimit ylimit;
            
			 % function to plot the rebars in the section											
			function plotRebars(plotAxes,xy,dia,PS_plot)
                if nargin ==3   
                    faceColor = 'k';
                else
                    faceColor = 'r';
                end
                x = xy(1);
                y = xy(2);
                th = 0:pi/10:2*pi;
                xunit = dia/2 * cos(th) + x;
                yunit = dia/2 * sin(th) + y;

                plot(plotAxes,polyshape(xunit,yunit),'FaceColor',faceColor,'FaceAlpha',0.5);
                
            %     plot(ployshape(xunit,yunit))
             end							  
        end
           
    % End of Section Properties Tab (SectionPropertiesTab)
    
        %% CALLBACK Function For MPhi Tab 
       
        function callback_RunAnalysisButton(~,~)
            tic
            %% ----------- Read the data and initialize functions ------- %

            %Read values from each tab again, in case the user
            %chooses not to plot anything in the tab, the variables do not
            %become initialized.
            
            % Initialize the concrete, concreteComp, concreteTens functions
            % with peristent variables so that the persistent variables
            % need not be supplied at each iteration.
            
            % initialize the plot point counter to 1 . It is used as index
            % to calculate keep track of moment and curvature indices so
            % that they don't mix and match. 
            % for pp =100, M(pp), Phi(pp), MUHPCtens(pp) etc correspond to
            % values at Phi(pp)
            pp = 1;
                        
            M = [0 0];
            Phi = [0 0];
            MUHPCcomp = [0 0];
            McompSteel = [0 0];
            MUHPCtens = [0 0];
            MtensSteel = [0 0];
            MtensPS = [0 0];
            
                %% ----------------- Read Data from concrete tab ---------------
                % and initialize the concrete = @ConcreteName
                if UHPC_radio.Value

                    fc = str2double(fc_UHPC_EditField.String);
                    epsc0 = str2double(epsc0_UHPC_EditField.String);
                    fcu = str2double(fcu_UHPC_EditField.String);
                    epscu = str2double(epscu_UHPC_EditField.String);
                    ft = str2double(ft_UHPC_EditField.String);
                    epst = str2double(epst_UHPC_EditField.String);
                    epstu = str2double(epstu_UHPC_EditField.String);
                    n = str2double(n_UHPC_EditField.String);

                    % display the computed value of Ec0 in the textfield
                    Ec0 = (n+1)/n*fc/epsc0;
                    Ec0_UHPC_EditField.String = Ec0;

                    concrete = @UHPC;
                    concrete([],fc, epsc0, fcu, epscu, ft, epst, epstu, n);

                elseif Concrete02_radio.Value

                    fc = str2double(fc_Concrete02_EditField.String);
                    epsc0 = str2double(epsc0_Concrete02_EditField.String);
                    fcu = str2double(fcu_Concrete02_EditField.String);
                    epscu = str2double(epscu_Concrete02_EditField.String);
                    ft = str2double(ft_Concrete02_EditField.String);
                    Ets = str2double(Ets_Concrete02_EditField.String);

                    n = str2double(n_Concrete02_EditField.String);

                    % display the computed value of Ec0 in the textfield
                    Ec0 = (n+1)/n*fc/epsc0;

                    Ec0_Concrete02_EditField.String = Ec0;

                    concrete = @Concrete02;
                    concrete([],fc, epsc0, fcu, epscu, ft, Ets);

                elseif Idealized_UHPC_radio.Value

                    fc = str2double(fc_Idealized_UHPC_EditField.String);
                    Ec0 = str2double(Ec0_Idealized_UHPC_EditField.String);
                    alpha = str2double(alpha_Idealized_UHPC_EditField.String);
                    epscu = str2double(epscu_Idealized_UHPC_EditField.String);
                    fcr = str2double(fcr_Idealized_UHPC_EditField.String);
                    gamma = str2double(gamma_Idealized_UHPC_EditField.String);
                    ftu = str2double(ftu_Idealized_UHPC_EditField.String);
                    epstu  = str2double(epstu_Idealized_UHPC_EditField.String);

                    concrete = @Idealized_UHPC;
                    concrete([],fc,Ec0,alpha,epscu,fcr,gamma,ftu,epstu);
                    
                elseif CustomConcrete_radio.Value
                    stress_strain = str2num(custom_stress_strain_values.String);
                    Ec0 = str2double(Ec0_CustomConcrete.String);
                    concrete = @customConcrete;
                    concrete([],stress_strain);
                end

                %% -------------Read data from Steel Tab---------------------


        % ------------------- Read Tension Rebar Parameters ------%
                    switch rebarConstitutiveModelDropdown_TensRebar.String{rebarConstitutiveModelDropdown_TensRebar.Value}

                        case 'Having yield plateau (Park)'
                            fy_Tens = abs(str2double(yieldstressfyksiEditField_TensRebar_Park.String));
                            fu_Tens = abs(str2double(ultimatestressintensionfuksiEditField_TensRebar_Park.String)); 
                            Es_Tens = abs(str2double(initialelastictangentEsEditField_TensRebar_Park.String)); 
                            esh_Tens = abs(str2double(straincorrespondingtoinitialstrainhardeningesh_TensRebar_Park.String)); 
                            eult_Tens = abs(str2double(strainatpeakultimatestresseult_TensRebar_Park.String));
                            Es_multiplier_Tens = abs(str2double(ES_final_slope_multiplier_TensRebar_Park.String));

                            rebarTens = @rebarPark;
                            rebarTens([],fy_Tens,fu_Tens,Es_Tens,esh_Tens,eult_Tens,Es_multiplier_Tens);


                        case 'Without yield plateau'
                            fl_Tens = abs(str2double(stressAtTheEndOfLinearRegion_TensRebar_NP.String));
                            fp_Tens = abs(str2double(stressAtTheEndPlateau_TensRebar_NP.String)); 
                            Es_Tens = abs(str2double(initialElasticTangent_TensRebar_NP.String)); 
                            ep_Tens = abs(str2double(strainAtTheStartOfEndPlateau_TensRebar_NP.String)); 
                            eult_Tens = abs(str2double(ultimateStrain_TensRebar_NP.String));
                            n_Tens = abs(str2double(ultimateStrain_TensRebar_NP.String));

                            rebarTens = @SteelNoPlateau;
                            rebarTens([],Es_Tens,fl_Tens,ep_Tens,fp_Tens,eult_Tens,n_Tens);
                        
                        case 'HSS Grade 100'
                            switch UnitsDropDown.String{UnitsDropDown.Value}
                                case 'N,mm'
                                    Es_Tens = 29000*(1/MPaToKsi); % MPa
                                    rebarTens = @(x) (1/MPaToKsi)*ACIGrade100(x);
                                case 'Kip,in'
                                Es_Tens = 29000; % ksi
                                rebarTens = @ACIGrade100;                                
                            end                            
                    end

                    % ------------------- Read Compression Rebar Parameters ------%
                    switch rebarConstitutiveModelDropdown_CompRebar.String{rebarConstitutiveModelDropdown_CompRebar.Value}

                        case 'Having yield plateau (Park)'
                            fy_Comp = abs(str2double(yieldstressfyksiEditField_CompRebar_Park.String));
                            fu_Comp = abs(str2double(ultimatestressintensionfuksiEditField_CompRebar_Park.String)); 
                            Es_Comp = abs(str2double(initialelastictangentEsEditField_CompRebar_Park.String)); 
                            esh_Comp = abs(str2double(straincorrespondingtoinitialstrainhardeningesh_CompRebar_Park.String)); 
                            eult_Comp = abs(str2double(strainatpeakultimatestresseult_CompRebar_Park.String));
                            Es_multiplier_Comp = abs(str2double(ES_final_slope_multiplier_CompRebar_Park.String));

                            rebarComp = @rebarPark;
                            rebarComp([],fy_Comp,fu_Comp,Es_Comp,esh_Comp,eult_Comp,Es_multiplier_Comp);

                        case 'Without yield plateau'
                            fl_Comp = abs(str2double(stressAtTheEndOfLinearRegion_CompRebar_NP.String));
                            fp_Comp = abs(str2double(stressAtTheEndPlateau_CompRebar_NP.String)); 
                            Es_Comp = abs(str2double(initialElasticTangent_CompRebar_NP.String)); 
                            ep_Comp = abs(str2double(strainAtTheStartOfEndPlateau_CompRebar_NP.String)); 
                            eult_Comp = abs(str2double(ultimateStrain_CompRebar_NP.String));
                            n_Comp = abs(str2double(ultimateStrain_CompRebar_NP.String));

                            rebarComp = @SteelNoPlateau;
                            rebarComp([],Es_Comp,fl_Comp,ep_Comp,fp_Comp,eult_Comp,n_Comp);         
                            
                        case 'HSS Grade 100'
                            switch UnitsDropDown.String{UnitsDropDown.Value}
                                case 'N,mm'
                                    Es_Comp = 29000*(1/MPaToKsi); % MPa
                                    rebarComp = @(x) (1/MPaToKsi)*ACIGrade100(x);
                                case 'Kip,in'
                                Es_Comp = 29000; % ksi
                                rebarComp = @ACIGrade100;                                
                            end   
                    end
                    
                    % for prestressing strands
                        switch PSGradeDropDown.String{PSGradeDropDown.Value}
                        case 'None'
                             PS_grade = 0;       
                        case 'Grade 250'
                            PS_grade = 250;                          
                        case 'Grade 270'
                            PS_grade = 270;
                        case 'Grade 1725'
                            PS_grade = 1725;                          
                        case 'Grade 1860'
                            PS_grade = 1860;    
                        end
                        
                        Eps = str2double(ModulusofelasticityEpsEditField.String);         
         
                        if PS_grade ~=0

                            switch PSModelDropdown.String{PSModelDropdown.Value}

                                case 'PCI Design Handbook'
                                    % since the PCI handbook equation is defined only
                                    % in US customary units, calculation is done in US
                                    % customary units and post-processed to SI units
%                                     Eps = 28500;   

                                    if PS_grade == 1725
%                                         PS_grade = 250;
                                        PS_PCI([],250,28500);
                                        PS_sig = @(x) (1/MPaToKsi)*PS_PCI(x);
                                    elseif PS_grade == 1860
%                                         PS_grade = 270;
                                        PS_PCI([],270,28500);
                                        PS_sig = @(x) (1/MPaToKsi)*PS_PCI(x);
                                    else
                                        PS_PCI([],PS_grade,28500);
                                        PS_sig = @PS_PCI;
                                    end
                                case 'Power Equation'
                                    Q = str2double(Q_EditField.String);
                                    K = str2double(K_EditField.String);
                                    R = str2double(R_EditField.String);

                                    PS_sig = @PSPowerEqn;
                                    PS_sig([],Eps,PS_grade,Q,K,R);
                            end
                        end           

                %% ----------- Read data from Section Properties tab----------

                    if CircularButton.Value
                        % represent circle by 50 sided regular polygon
                        r = abs(str2double(ExternalDiameterinEditField_Circular.String))/2;
                        sec_shape = nsidedpoly(50,'Center',[r r],'Radius',r);

                        % reinforcement details
                        clrCover = str2double(ClearcoverinEditField_Circular.String);
                        tensBarNo = str2double(BarSizeDropDown_Circular.String{BarSizeDropDown_Circular.Value});
                        barDia =  barInfo(tensBarNo);
                        howManyBars = str2double(NoofreinforcementbarsEditField_Circular.String);
                        sec_rebar = nsidedpoly(howManyBars,'Center',[r r],'Radius',r-clrCover-barDia/2);

                        [d,~,ic] = unique(round(sec_rebar.Vertices(:,2),3));
                        d = d';
                        tensNoOfBars = accumarray(ic,1);

                        compBarNo = 0;
                        compNoOfBars = 0;
                        d1 = 2;

                        PS_strand_nominal_dia = str2double(PSDiameterDropDown_Circular.String{PSDiameterDropDown_Circular.Value});
                        PS_no_of_strands = str2double(Noofprestressingstrands_Circular.String);
                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Circular.String);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Circular.String);

                    elseif OtherButton.Value
                        sec_coor = str2num(SectionCoordinatesTextArea_Other.String);
                        sec_coor = [sec_coor(:,1)-min(sec_coor(:,1)) sec_coor(:,2)-min(sec_coor(:,2))];
                        sec_shape = polyshape(sec_coor(:,1),sec_coor(:,2));

                        % reinforcement details

                        coorTens =  str2num(RebarCoorTens_Other.String);
                        coorTens = [coorTens(:,1)-min(sec_coor(:,1)) coorTens(:,2)-min(sec_coor(:,2))];
                        [d,~,ic] = unique(coorTens(:,2));
                        d = d';
                        tensNoOfBars = accumarray(ic,1);
                        tensBarNo = str2double(BarSizeDropDownTens_Other.String{BarSizeDropDownTens_Other.Value});

                        coorComp = str2num(RebarCoorComp_Other.String);
                        coorComp = [coorComp(:,1)-min(sec_coor(:,1)) coorComp(:,2)-min(sec_coor(:,2))];
                        [d1,~,ic] = unique(coorComp(:,2));
                        d1 = d1';
                        compNoOfBars = accumarray(ic,1);
                        compBarNo = str2double(BarSizeDropDownComp_Other.String{BarSizeDropDownComp_Other.Value});

                        PS_strand_nominal_dia = str2double(PSDiameterDropDown_Other.String{PSDiameterDropDown_Other.Value});
                        PS_no_of_strands = str2double(Noofprestressingstrands_Other.String);
                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Other.String);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Other.String);

                    else RectangularButton.Value
                        x = [0 0 abs(str2double(WidthEditField.String)) abs(str2double(WidthEditField.String))];
                        y = [0 abs(str2double(HeightEditField.String)) abs(str2double(HeightEditField.String)) 0];
                        sec_shape = polyshape(x,y);

                        % rebar information
                        if AsCG_Rect_Radio.Value == 1
                            % reinforement info defined as distance upto CG of rebars
                            tensBarNo = str2double(BarSizeDropDownTens_Rectangular_CG.String{BarSizeDropDownTens_Rectangular_CG.Value});
                            tensNoOfBars = str2num(NoofrebarsineachlayerTens_Rectangular_CG.String)';
                            d = str2num(DistanceoflayerfromtopTens_Rectangular_CG.String);

                            compBarNo = str2double(BarSizeDropDownComp_Rectangular_CG.String{BarSizeDropDownComp_Rectangular_CG.Value});
                            compNoOfBars = str2num(NoofrebarsineachlayerComp_Rectangular_CG.String)';
                            d1 = str2num(DistanceoflayerfromtopComp_Rectangular_CG.String);

                        else
                            % reinforement info defined as clear cover
                            tensBarNo = str2double(BarSizeDropDownTens_Rectangular_clrCover.String{BarSizeDropDownTens_Rectangular_clrCover.Value});
                            tensNoOfBars = str2num(NoofrebarsineachlayerTens_Rectangular_clrCover.String);
                            clrCoverTens = str2double(ClearCoverTens_Rectangular_clrCover.String);
                            barDiaTens = barInfo(tensBarNo);
                            d = abs(str2double(HeightEditField.String)) - clrCoverTens - barDiaTens/2;

                            compBarNo = str2double(BarSizeDropDownComp_Rectangular_clrCover.String{BarSizeDropDownComp_Rectangular_clrCover.Value});
                            compNoOfBars = str2num(NoofrebarsineachlayerComp_Rectangular_clrCover.String);
                            clrCoverComp = str2double(ClearCoverComp_Rectangular_clrCover.String);
                            barDiaComp =  barInfo(compBarNo);
                            d1 = clrCoverComp + barDiaComp/2;

                        end

                        PS_strand_nominal_dia = str2double(PSDiameterDropDown_Rectangular.String{PSDiameterDropDown_Rectangular.Value});
                        PS_no_of_strands = str2double(Noofprestressingstrands_Rectangular.String);
                        PS_d  = str2double(DistanceofCGofPSstrandsfromtopfiber_Rectangular.String);
                        PS_stress_after_losses = str2double(StressinPSstrandsafteralllosses_Rectangular.String);

                    end
                    
                    if compBarNo ==0
                        compNoOfBars = 0;
                        d1 = 0;
                    end
                    
                    if tensBarNo == 0
                        tensNoOfBars = 0;
                        d = 0;
                    end
                    
                    % to check the condition of failure of the section when
                    % no reinforcements is provided. Note that the failure
                    % of concrete in tension is not considered a sufficient
                    % condition to determine the failure of the section.
                    % Since sufficient compression force cannot be
                    % generated in an unreinforced section to make it fail
                    % by crushing of concrete in compression, a new
                    % condition of failure has to be determined to check
                    % the failure of unreinforced section. Here, the
                    % failure is taken as the point when the
                    % moment-capacity of the section begins to decrease.
                    
                    
                    if compBarNo==0 && tensBarNo==0 && PS_no_of_strands==0
                        concreteOnlySection = true;
                    else
                        concreteOnlySection = false;
                    end
                    
                %% Initialize functions for persistent parameters

                concreteComp([],[],[],[],sec_shape,concrete);
                concreteTens([],[],[],[],sec_shape,concrete);

                %% Read data from MPhi Tab
                %{
                    kStart = str2double(kFromEditField.String);
                    kMax = str2double(kToEditField.String);
                    kIncr = str2double(kIncrementEditField.String);
                %}
                
                switch UnitsDropDown.String{UnitsDropDown.Value}
                    case 'N,mm'
                        kIncr = 0.00005*mmToIn;
                    case 'Kip,in'
                        kIncr = 0.00005;
                end

                
                % ---------- End of reading data from all four tabs -------- %
            
            %% Extract simple parameters from the data read
                h = max(sec_shape.Vertices(:,2));
                
                % area of rebars and PS strands
                Ast = barInfo(tensBarNo,tensNoOfBars)';
                Asc = barInfo(compBarNo,compNoOfBars)';
                A_PS = strandArea(PS_grade, PS_strand_nominal_dia, PS_no_of_strands);
                
               
                A = area(sec_shape);
                [~, centroid_y] = centroid(sec_shape);
                [~, iner, ~] = polygeom(sec_shape.Vertices(:,1), sec_shape.Vertices(:,2));
                % Note: Ixx is about centroidal axis and is given as Iuu in the polygeom() functon.
                Ixx = iner(4); % for concrete section only, without increasing it for area of reinforcements
              	Ixx  = Ixx + A_PS*(PS_d-centroid_y).^2*(Eps/Ec0-1) + Ast*((d-centroid_y)'.^2)*(Es_Tens/Ec0-1)+ Asc*((d1-centroid_y)'.^2)*(Es_Comp/Ec0-1);

                clear geom iner principal_moment;
                
            %% --------- Start of PS_Only_Mphi.m file ------------------------ %
            if A_PS ==0
                epsc_PS =0;
                phi_neg0 = 0;
            else
                % Step 0
                % Initial condition after all losses
                tensPS = PS_stress_after_losses * A_PS;

                % strain in concrete at the level of PS due to moment due to prestress
                % (i.e, M = P*e)
                
                epsc_PSe = tensPS.*(PS_d-centroid_y)*(h - centroid_y)/(Ixx*Ec0);

                % epsc_PS : strain in the concrete due to the prestressing force applied at the
                % center of the section. i,e, only due to P/A. Strain due to the moment P*e
                % is not considered here.
                %Ec0 is used because it is based on the assumption that the material behavior is linear.
                epsc_PS = -sum(tensPS)/(A*Ec0);

                % strain in PS strands after all losses
                eps0_PS = PS_stress_after_losses/Eps;

                %negative sign for compression
                sigc_top = -sum(tensPS)/A - tensPS.*(PS_d-centroid_y)*(-centroid_y)/(Ixx);
                sigc_bot = -sum(tensPS)/A - tensPS.*(PS_d-centroid_y)*(h-centroid_y)/(Ixx);

%               sigc0_PS = stress in concrete at the level of PS
                sigc0_PS = -sum(tensPS)/A - tensPS.*(PS_d-centroid_y)*(PS_d-centroid_y)/(Ixx);   

                phi_neg0 = (sigc_bot - sigc_top)/(Ec0*h); % -ve value

                Phi(pp) = phi_neg0; % analysed curvature
                M(pp) = 0; % Moment for corresponding Phi above
                pp = pp + 1;
                % Step 1
                % The stage at which the strain in the concrete at the level of prestress is zero.

                % strain in prestressing tendons when the strain in the concrete at the level of prestress is zero
%                 eps1_PS = eps0_PS  + phi_neg0*(NA_zero - PS_d);
                eps1_PS = eps0_PS - sigc0_PS/Ec0 ;
                PS_stress =  PS_sig(eps1_PS);

                tensPS = PS_stress .* A_PS;

                M(pp) = -sigc0_PS * Ixx / (PS_d-centroid_y);


                sigc_top = -sum(tensPS)/A - tensPS.*(PS_d-centroid_y)*(-centroid_y)/(Ixx) - M(pp)*(centroid_y)/Ixx;

                sigc_bot = -sum(tensPS)/A - tensPS.*(PS_d-centroid_y)*(h-centroid_y)/(Ixx) + M(pp)*(h-centroid_y)/Ixx;


                Phi(pp) = (sigc_bot - sigc_top)/(Ec0*h);

                kStart = Phi(pp)+kIncr;
                pp = pp + 1;
            end
        % ----------- End of PS_Only_MPhi.m file ------------------ %
            
            %% ----------- Start of PolygonMPhiPrestress.m file ---------- %
            
                stress = [];
                strain = [];
                failureFlag = false;
                failure = struct;
                
                % failure is a structure such that it hold the following
                % information about the mode of failure as in the example
                % below
                    % failure.Material = 'Concrete' or 'Rebar' or 'PS Strands'
                    % failure.Mode = 'Tension' or 'Compression'
                    % failure.Strain = strain value in the failure.Material at faiulre
                
                na = centroid_y + (sign(d(1)-centroid_y)*Ast*d' + sign(d1(1)-centroid_y)*Asc*d1' + sign(PS_d(1)-centroid_y)*A_PS*PS_d')*(29000/Ec0)/A;
                
%                 if A_PS == 0
%                     na = centroid_y; % assume the neutral axis to be at h/10
%                 else
%                     na = PS_d;
%                 end
                
                % Phi and M are initiated in the PS_Only_MPhi file
                % Phi = []; % analysed curvature
                % M = []; % Moment for corresponding Phi above

                i=0; % counter to plot the stress-strain diagram for the section

%                 for phi1=kStart:kIncr:kMax
                if A_PS ==0
                    phi1 = eps;
                else
                    phi1 = kStart;
                end
                
                while failureFlag == false
%                     diff = 1000;
                    CompTensRatio = 1.5;
                    InfoText.String = ['Calculating moment for Phi = ',num2str(phi1)];
                    drawnow;
%                     if phi1>0
                        phi = phi1;

                      while CompTensRatio >1.05 || CompTensRatio<0.95
                          
                        if A_PS ~=0
                            epsc_PS = eps1_PS + phi*(PS_d-na);
%                             PS_stress = PS_sig(eps1_PS + phi*(PS_d-na));
                            PS_stress = PS_sig(epsc_PS);
                            tensPS =  PS_stress .* A_PS;
                        else
                            PS_stress = 0;
                            tensPS = 0;
                            epsc_PS = 0;
                        end

                        % do not change the order of calculation compUHPC, tensUHPC because
                        % it changes the stress-strain plot
                        
                            [compConcrete,cCentroid] = concreteComp(phi,na,0);
                            [tensConcrete,tCentroid] = concreteTens(phi,na,0);
                            
%                         tensSteel = Ast.*arrayfun(@(x) steel01(phi*(x-na)),d)
%                         compSteel = Asc.*arrayfun(@(x) steel01(phi*(x-na)),d1)
                        
                        % To avoid falsely detecting the failure of steel       
                        if sum(Ast)~=0
%                             tensSteel = Ast.*arrayfun(@(x) steel01(phi*(x-na)),d);
                            tensSteel = Ast.*arrayfun(@(x) rebarTens(phi*(x-na)),d);
                        else
                            tensSteel = 0;
                        end
                        
                        if sum(Asc)~=0
%                             compSteel = Asc.*arrayfun(@(x) steel01(phi*(x-na)),d1);
                            compSteel = Asc.*arrayfun(@(x) rebarComp(phi*(x-na)),d1);
                        else
                            compSteel = 0;
                        end


                        if failureFlag==true
                           break; 
                        end

                        CompForce = sum(compConcrete(compConcrete<0)) + sum(compSteel(compSteel<0)) + sum(tensPS(tensPS<0)) + sum(tensConcrete(tensConcrete<0)) + sum(tensSteel(tensSteel<0));
                        TensForce = sum(compConcrete(compConcrete>0)) + sum(compSteel(compSteel>0)) + sum(tensPS(tensPS>0)) + sum(tensConcrete(tensConcrete>0)) + sum(tensSteel(tensSteel>0));
                        CompTensRatio = abs(CompForce/TensForce);
                        
                        unchangedNA = na; % unchanged na

%                         if phi>0
%                             if diff>0 
                            if CompTensRatio > 1.05 % compression > tension
                                na = na - 0.01*h;
%                                 if CompTensRatio > 100
%                                     CompTensRatio = 100;
%                                 end
%                                 na = na - (1.0101^CompTensRatio)*h/500; % if compression is greater, decrease depth of NA
                            elseif CompTensRatio <0.95
                                na = na + 0.003*h;
%                                 if (1/CompTensRatio) > 100
%                                     CompTensRatio = 1/100;
%                                 end
%                                 na = na + (1.0101^(1/CompTensRatio))*h/500;
                            end

                    end
%                     diff
%                     na
% phi
% h-na
% tCentroid


%                             NA = [NA na];
%                             Ratio = [Ratio CompTensRatio];
                            % UHPCtens1 = [UHPCtens1 UHPCtens];
                            % UHPCcomp1 = [UHPCcomp1 UHPCcomp];
                            % tensPS1 = [tensPS1 sum(tensPS)];

                    mom = (-(compConcrete*cCentroid) -(compSteel*(unchangedNA-d1)')+ tensConcrete*tCentroid + tensSteel*(d-unchangedNA)' + tensPS*(PS_d-unchangedNA)');

                    
                    M(pp) = mom;
                    Phi(pp) = phi1;
                    
                    MUHPCcomp(pp) = -compConcrete*cCentroid;
                    McompSteel(pp) = -compSteel*(unchangedNA-d1)';
                    MUHPCtens(pp) =  tensConcrete*tCentroid;
                    MtensSteel(pp) = tensSteel*(d-unchangedNA)';
                    MtensPS(pp) = tensPS*(PS_d-unchangedNA)';
                    

                    % check if section without reinforcement has failed.
                    % Failure is when the moment capacity begins the decline.
                    
                    if concreteOnlySection && pp>2
                        if M(pp)<M(pp-1)
                            failureFlag = true;

                            failure.Material = 'concrete';
                            failure.Mode = 'tension'
                            InfoText.String = ['The section failed due to failure of ',failure.Material,' in ',failure.Mode];
                        end
                    end
                    
                    pp = pp+1;
                    %% TO plot the stress variation throughout the section depth
%{                    
                    if phi1 >= kStart + (kMax-kStart)/9*i
                       [UHPCcomp,cCentroid] = PolygonCompUHPC(sec_coor,phi,unchangedNA,epsc_PS,true); % true =  plot stress variation in the section
                       [UHPCtens,tCentroid] = PolygonTensUHPC(sec_coor,phi,unchangedNA,epsc_PS,true);

                       figure(1)
                       subplot(2,5,i+1)
                       [B, I] = sort(plotZ);
                       plotStress = plotStress(I);

                       plotZ = plotZ(I);
                       if phi1<0
                            plotZ = h-plotZ;
                       end

                       clear B I

                       plot([plotStress(1) 0 0 plotStress(end)],[0 0 h h],'linewidth',1);
                       set(gca, 'YDir','reverse')
                       hold on
                       plot(plotStress,plotZ,'linewidth',1);


                       xlabel('\sigma (ksi)');
                       ylabel('height of section (in)');
                       titleText = {strcat('\phi=',num2str(phi1)),strcat('M=',num2str(mom)),strcat('NA=',num2str(unchangedNA),' in')};
                       title(titleText);
                       hold off
                       clear titleText
                       i=i+1;
                    end
%}                  
                    phi1 = phi1 + kIncr;
                end % while failure == false

            %% Plot the MPhi Diagram and display the failure mode
            if ~concreteOnlySection
                %Info text for concreteOnly section is provided separately.
                InfoText.String = ['The section failed due to failure of ',failure.Material,' in ',failure.Mode,' at a strain of ',num2str(failure.Strain),' in/in '];
            end
            
            Phi = Phi - phi_neg0;
            Phi = [0 Phi(3:end)];
            M = [0 M(3:end)];

            MUHPCcomp = [0 MUHPCcomp(3:end)];
            McompSteel = [0 McompSteel(3:end)];
            MUHPCtens = [0 MUHPCtens(3:end)];
            MtensSteel = [0 MtensSteel(3:end)];
            MtensPS = [0 MtensPS(3:end)];
            
            switch UnitsDropDown.String{UnitsDropDown.Value}
                
                case 'N,mm'
                    M = M*10^(-6); % converting N-mm to kN-m
                    MUHPCcomp = MUHPCcomp*10^(-6);
                    McompSteel = McompSteel*10^(-6);
                    MUHPCtens = MUHPCtens*10^(-6);
                    MtensSteel = MtensSteel*10^(-6);
                    MtensPS = MtensPS*10^(-6);
                    
            end
            plot(MPhiPlot,Phi,M,'DisplayName','Composite Section');
            hold (MPhiPlot,'on')
            
            plot(MPhiPlot,Phi,MUHPCcomp,'-.r','Displayname','Concrete Compression');
            plot(MPhiPlot,Phi,McompSteel,'-r','Displayname','Rebar Compression');
            plot(MPhiPlot,Phi,MUHPCtens,':k','Displayname','Concrete Tension');
            plot(MPhiPlot,Phi,MtensSteel,'--k','Displayname','Rebar Tension');
            plot(MPhiPlot,Phi,MtensPS,'--b','Displayname','Prestress Tension');
            hold (MPhiPlot,'off'); 
            
            grid(MPhiPlot,'on');
            grid(MPhiPlot,'minor');
            title(MPhiPlot, ['Moment-Curvature for ' ProjectTitleEditField.String]);
            xlabel(MPhiPlot, ['Curvature ' Phi_Units]);
            ylabel(MPhiPlot, ['Moment ' M_Units]);
            legend(MPhiPlot,'show','location','best');
            box(MPhiPlot,'on');
toc            
            %% Activate the Save Report Button
            SaveReportButton.Enable = 'on';
            
        end 
        
        function callback_BrowseButton(~,~)
            selectedPath = uigetdir;
            SavetofolderEditField.String = selectedPath;
        end
    
        function callback_SaveReportButton(~,~)
            
            % run the callback functions for Plot of steel and concrete so
            % that the variables concreteStrain,concreteStress,strain_Tens
            % stress_Tens, PSStress, PSStrain are populated and also the
            % corresponding plots are plotted in the corresponding axes as
            % per the latest data updated by the user. Plotting will help
            % to save the plotted stress-strain curves for the steel and
            % concrete.
            InfoText.String = 'Saving Report in Progress...';
            callback_SteelPlotButton;
            callback_plot_concrete_stress_strain_button;
            callback_plot_section_button;
            
            if figCheckBox.Value
                % save the moment curvature and stress-strain plots as fig and
                % png images

                % save images in Figures folder
                FiguresFolder = [SavetofolderEditField.String '\Figures'];
                if ~exist(FiguresFolder)
                    mkdir(FiguresFolder);
                end

                tempPlot = figure('Visible','off');

                % Concrete Stress Strain Plot
                title(StressStrainPlotConcrete, ['Stress-Strain Plot for Concrete for ' ProjectTitleEditField.String]);
                newAxes = copyobj(StressStrainPlotConcrete, tempPlot);
                newAxes.Units = 'Normalized';
                newAxes.OuterPosition = [0 0 1 1];
                set(newAxes,'CreateFcn','set(gcbf,''Visible'',''on'')'); % Make it visible upon loading
                saveas(tempPlot,[FiguresFolder '\' 'Concrete Stress Strain Plot for ' ProjectTitleEditField.String '.fig']);
                saveas(tempPlot,[FiguresFolder '\' 'Concrete Stress Strain Plot for ' ProjectTitleEditField.String '.png']);

                % Steel Stress Strain Plot
                clf(tempPlot);
                title(SteelAxes, ['Stress-Strain Plot for Steel for ' ProjectTitleEditField.String]);
                newAxes = copyobj(SteelAxes, tempPlot);
                newAxes.Units = 'Normalized';
                newAxes.OuterPosition = [0 0 1 1];
                set(newAxes,'CreateFcn','set(gcbf,''Visible'',''on'')'); % Make it visible upon loading
                saveas(tempPlot,[FiguresFolder '\' 'Steel Stress Strain Plot for ' ProjectTitleEditField.String '.fig']);
                saveas(tempPlot,[FiguresFolder '\' 'Steel Stress Strain Plot for ' ProjectTitleEditField.String '.png']);

                % Section Plot
                clf(tempPlot);
                title(PlotSectionAxes, ['Section Preview for ' ProjectTitleEditField.String]);
                newAxes = copyobj(PlotSectionAxes, tempPlot);
                newAxes.Units = 'Normalized';
                newAxes.OuterPosition = [0 0 1 1];
                newAxes.DataAspectRatio = [1 1 1];
                set(newAxes,'CreateFcn','set(gcbf,''Visible'',''on'')'); % Make it visible upon loading
                saveas(tempPlot,[FiguresFolder '\' 'Section Geometry for ' ProjectTitleEditField.String '.fig']);
                saveas(tempPlot,[FiguresFolder '\' 'Section Geometry for ' ProjectTitleEditField.String '.png']);

                % MPhi Plot
                clf(tempPlot);
                title(MPhiPlot, ['Moment-Curvature for ' ProjectTitleEditField.String]);
                newAxes = copyobj(MPhiPlot, tempPlot);
                newAxes.Units = 'Normalized';
                newAxes.OuterPosition = [0 0 1 1];            
                set(newAxes,'CreateFcn','set(gcbf,''Visible'',''on'')'); % Make it visible upon loading
                
                saveas(tempPlot,[FiguresFolder '\' 'Moment Curvature Plot for ' ProjectTitleEditField.String '.fig']);
                saveas(tempPlot,[FiguresFolder '\' 'Moment Curvature Plot for ' ProjectTitleEditField.String '.png']);            

                delete(tempPlot);
                delete(newAxes);
            end
            
            % generate text and/or excel report as per the user selection
            if txtCheckBox.Value
                fullFilePath  = [SavetofolderEditField.String '\' ProjectTitleEditField.String '.txt'];
                reportFileTxt = fopen(fullFilePath,'w');
                
                % Moment-curvature values
                fprintf(reportFileTxt,'%s\r\n%s\r\n','Moment curvature for the section',...
                                                    '================================');
                fprintf(reportFileTxt,'%s\t%s\r\n','Curvature','Moment');
                fprintf(reportFileTxt,'%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                fprintf(reportFileTxt,'%s\t%s\r\n','-------  ','--------');
                fprintf(reportFileTxt,'%.7f\t%.3f\r\n',[Phi;M]);
                
                fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Moment curvature contribution of indivual components',...
                                                                '====================================================');
                
                    fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Compression Concrete Contribution',...
                                                                    '==================================');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','Curvature','Moment)');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','-------  ','-------');
                    fprintf(reportFileTxt,'\t\t%.7f\t%.3f\r\n',[Phi; MUHPCcomp]);
                    
                    fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Tension Concrete Contribution',...
                                                                    '==================================');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','Curvature','Moment)');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','-------  ','-------');
                    fprintf(reportFileTxt,'\t\t%.7f\t%.3f\r\n',[Phi; MUHPCtens]);
                    
                    fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Tension Steel Contribution',...
                                                                    '===========================');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','Curvature','Moment)');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','-------  ','-------');
                    fprintf(reportFileTxt,'\t\t%.7f\t%.3f\r\n',[Phi; MtensSteel]);
                    
                    fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Compression Steel Contribution',...
                                                                    '===============================');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','Curvature','Moment)');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','-------  ','-------');
                    fprintf(reportFileTxt,'\t\t%.7f\t%.3f\r\n',[Phi; McompSteel]);
                    
                    fprintf(reportFileTxt,'\r\n\t\t%s\r\n\t\t%s\r\n','Prestressing Strands Contribution',...
                                                                    '===============================');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','Curvature','Moment)');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n',[Phi_Units ,'      ',M_Units],' ');
                    fprintf(reportFileTxt,'\t\t%s\t%s\r\n','-------  ','-------');
                    fprintf(reportFileTxt,'\t\t%.7f\t%.3f\r\n',[Phi; MtensPS]);
                    
                % Material stress-strain properties
                % For concrete
                fprintf(reportFileTxt,'\r\n%s\r\n%s\r\n','Stress Strain for Concrete',...
                                                    '===========================');
                fprintf(reportFileTxt,'%s\t%s\r\n','Strain     ','Stress');
                fprintf(reportFileTxt,'%s\t%s\r\n',[strain_Units,'     ',stress_Units,' ']);
                fprintf(reportFileTxt,'%s\t%s\r\n','-------   ','--------');
                fprintf(reportFileTxt,'%.7f\t%.3f\r\n',[concreteStrain;concreteStress]);
                
                % For Conventional Tension Steel
                fprintf(reportFileTxt,'\r\n%s\r\n%s\r\n','Stress Strain for Conventional Tension Rebar',...
                                                    '=============================================');
                fprintf(reportFileTxt,'%s\t%s\r\n','Strain     ','Stress');
                fprintf(reportFileTxt,'%s\t%s\r\n',[strain_Units,'     ',stress_Units,' ']);
                fprintf(reportFileTxt,'%s\t%s\r\n','-------   ','--------');
                fprintf(reportFileTxt,'%.7f\t%.3f\r\n',[strain_Tens;stress_Tens]);
                
                % For Conventional Compression Steel
                fprintf(reportFileTxt,'\r\n%s\r\n%s\r\n','Stress Strain for Conventional Compression Rebar',...
                                                    '=================================================');
                fprintf(reportFileTxt,'%s\t%s\r\n','Strain     ','Stress');
                fprintf(reportFileTxt,'%s\t%s\r\n',[strain_Units,'     ',stress_Units,' ']);
                fprintf(reportFileTxt,'%s\t%s\r\n','-------   ','--------');
                fprintf(reportFileTxt,'%.7f\t%.3f\r\n',[strain_Comp;stress_Comp]);
                    
                % For Prestressing strands
                fprintf(reportFileTxt,'\r\n%s\r\n%s\r\n','Stress Strain for Prestressing Strands',...
                                                    '=======================================');
                fprintf(reportFileTxt,'%s\t%s\r\n','Strain     ','Stress');
                fprintf(reportFileTxt,'%s\t%s\r\n',[strain_Units,'     ',stress_Units,' ']);
                fprintf(reportFileTxt,'%s\t%s\r\n','-------   ','--------');
                fprintf(reportFileTxt,'%.7f\t%.3f\r\n',[PSStrain;PSStress]); 
                
                fclose(reportFileTxt);
            end
            
            if xlsCheckBox.Value
                fullFilePath  = [SavetofolderEditField.String '\' ProjectTitleEditField.String '.xls'];
                
                %check and delete if previous report with the same filename
                %exists in the same location. Not deleting the file somehow
                %resulted in inconsistencies with the data update.
                
                if exist(fullFilePath,'file')==2
                    delete(fullFilePath);
                end
                
                % moment curvature report
                % syntax: xlswrite(fullFilePath,data,name_of_worksheet,xlrange)
                xlswrite(fullFilePath,{'For entire section','','', 'Compression concrete contribution','','','Tension concrete contribution','','','Tension rebar contribution','','','Compression rebar contribution','','','Prestressing strands contribution'},'Moment-Curvature','A1');
                xlswrite(fullFilePath,{'Curvature', 'Moment','','Curvature', 'Moment','','Curvature', 'Moment','','Curvature', 'Moment','','Curvature', 'Moment','','Curvature', 'Moment'},'Moment-Curvature','A2');
                xlswrite(fullFilePath,{Phi_Units, M_Units,'',Phi_Units, M_Units,'',Phi_Units, M_Units,'',Phi_Units, M_Units,'',Phi_Units, M_Units,'',Phi_Units, M_Units},'Moment-Curvature','A3');
                xlswrite(fullFilePath,[Phi' M' ],'Moment-Curvature','A5');
                xlswrite(fullFilePath,[Phi' MUHPCcomp'],'Moment-Curvature','D5');
                xlswrite(fullFilePath,[Phi' MUHPCtens'],'Moment-Curvature','G5');
                xlswrite(fullFilePath,[Phi' MtensSteel' ],'Moment-Curvature','J5');
                xlswrite(fullFilePath,[Phi' McompSteel'],'Moment-Curvature','M5');
                xlswrite(fullFilePath,[Phi' MtensPS'],'Moment-Curvature','P5');
                
                
                    % Material stress-strain properties report
                    xlswrite(fullFilePath,{'For Concrete','','','For Conventional Tension Rebars','','','For Conventional Compression Rebars','','','For Prestressing Strands'},'Stress-Strain','A1');
                    xlswrite(fullFilePath,{'Strain','Stress','','Strain','Stress','','Strain','Stress','','Strain','Stress'},'Stress-Strain','A2');
                    xlswrite(fullFilePath,{strain_Units,stress_Units,'',strain_Units,stress_Units,'',strain_Units,stress_Units,'',strain_Units,stress_Units},'Stress-Strain','A3');
                    xlswrite(fullFilePath,[concreteStrain' concreteStress'],'Stress-Strain','A5');
                    xlswrite(fullFilePath,[strain_Tens' stress_Tens'],'Stress-Strain','D5');
                    xlswrite(fullFilePath,[strain_Comp' stress_Comp'],'Stress-Strain','G5');
                    if PS_grade~=0
                    xlswrite(fullFilePath,[PSStrain' PSStress'],'Stress-Strain','J5');  
                    end
            end
            
            InfoText.String = 'Report successfully saved!';
            
        end        
    
        % End of M-Phi Tab (MPhiTab)
%}       

end