function setGlAux(gl)
%SETGLAUX Set auxiliary states for the GreenLight greenhouse model
%
% Based on the electronic appendices of:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378–395 (2011).
% These are also available as Chapters 8 and 9, respecitvely, of
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
% Other sources are:
%   [4] De Zwart, H. F. Analyzing energy-saving options in greenhouse cultivation 
%       using a simulation model. (Landbouwuniversiteit Wageningen, 1996).
% The model is described and evaluated in:
%   [5] Katzin, D., van Mourik, S., Kempkes, F., & Van Henten, E. J. (2020). 
%       GreenLight - An open source model for greenhouses with supplemental 
%       lighting: Evaluation of heat requirements under LED and HPS lamps. 
%       Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
% Additional components are taken from:
%   [6] Righini, I., Vanthoor, B., Verheul, M. J., Naseer, M., Maessen, H., 
%       Persson, T., & Stanghellini, C. (2020). A greenhouse climate-yield 
%       model focussing on additional light, heat harvesting and its validation. 
%       Biosystems Engineering, (194), 1–15. https://doi.org/10.1016/j.biosystemseng.2020.03.009
% The model is further described in:
%   [7] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434
% Some control decisions are described in:
%   [8] Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%       Energy savings in greenhouses by transition from high-pressure sodium 
%       to LED lighting. Applied Energy, 281, 116019. 
%       https://doi.org/10.1016/j.apenergy.2020.116019
% Inputs:
%   gl    - a DynamicModel object to be used as a GreenLight model.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
    
    % shorthands for easier reading
    x = gl.x;
    p = gl.p;
    u = gl.u;
    d = gl.d;    
    
    
    %% lumped cover layers  - Section 3 [1], Section A.1 [5]
    % shadow screen and permanent shadow screen
    
    % PAR transmission coefficient of the shadow screen layer [-]
    addAux(gl, 'tauShScrPar', 1-u.shScr*(1-p.tauShScrPar));
    
    % PAR transmission coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'tauShScrPerPar', 1-u.shScrPer*(1-p.tauShScrPerPar));
    
    % PAR reflection coefficient of the shadow screen layer [-]
    addAux(gl, 'rhoShScrPar', u.shScr*p.rhoShScrPar);
    
    % PAR reflection coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'rhoShScrPerPar', u.shScrPer*p.rhoShScrPerPar);
        
    % PAR transmission coefficient of the shadow screen and semi permanent shadow screen layer [-]
    % Equation 16 [1]
    addAux(gl, 'tauShScrShScrPerPar', tau12(gl.a.tauShScrPar, gl.a.tauShScrPerPar, ...
        gl.a.rhoShScrPar, gl.a.rhoShScrPar, gl.a.rhoShScrPerPar, gl.a.rhoShScrPerPar));
    
    % PAR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the top [-]
    % Equation 17 [1]
    addAux(gl, 'rhoShScrShScrPerParUp', rhoUp(gl.a.tauShScrPar, gl.a.tauShScrPerPar, ...
        gl.a.rhoShScrPar, gl.a.rhoShScrPar, gl.a.rhoShScrPerPar, gl.a.rhoShScrPerPar));
    
    % PAR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the bottom [-]
    % Equation 17 [1]
    addAux(gl, 'rhoShScrShScrPerParDn', rhoDn(gl.a.tauShScrPar, gl.a.tauShScrPerPar, ...
        gl.a.rhoShScrPar, gl.a.rhoShScrPar, gl.a.rhoShScrPerPar, gl.a.rhoShScrPerPar));
    
    % NIR transmission coefficient of the shadow screen layer [-]
    addAux(gl, 'tauShScrNir', 1-u.shScr*(1-p.tauShScrNir));
    
    % NIR transmission coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'tauShScrPerNir', 1-u.shScrPer*(1-p.tauShScrPerNir));
    
    % NIR reflection coefficient of the shadow screen layer [-]
    addAux(gl, 'rhoShScrNir', u.shScr*p.rhoShScrNir);
    
    % NIR reflection coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'rhoShScrPerNir', u.shScrPer*p.rhoShScrPerNir);
        
    % NIR transmission coefficient of the shadow screen and semi permanent shadow screen layer [-]
    addAux(gl, 'tauShScrShScrPerNir', tau12(gl.a.tauShScrNir, gl.a.tauShScrPerNir, ...
        gl.a.rhoShScrNir, gl.a.rhoShScrNir, gl.a.rhoShScrPerNir, gl.a.rhoShScrPerNir));
    
    % NIR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the top [-]
    addAux(gl, 'rhoShScrShScrPerNirUp', rhoUp(gl.a.tauShScrNir, gl.a.tauShScrPerNir, ...
        gl.a.rhoShScrNir, gl.a.rhoShScrNir, gl.a.rhoShScrPerNir, gl.a.rhoShScrPerNir));
    
    % NIR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the bottom [-]
    addAux(gl, 'rhoShScrShScrPerNirDn', rhoDn(gl.a.tauShScrNir, gl.a.tauShScrPerNir, ...
        gl.a.rhoShScrNir, gl.a.rhoShScrNir, gl.a.rhoShScrPerNir, gl.a.rhoShScrPerNir));
    
    % FIR  transmission coefficient of the shadow screen layer [-]
    addAux(gl, 'tauShScrFir', 1-u.shScr*(1-p.tauShScrFir));
    
    % FIR transmission coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'tauShScrPerFir', 1-u.shScrPer*(1-p.tauShScrPerFir));
    
    % FIR reflection coefficient of the shadow screen layer [-]
    addAux(gl, 'rhoShScrFir', u.shScr*p.rhoShScrFir);
    
    % FIR reflection coefficient of the semi-permanent shadow screen layer [-]
    addAux(gl, 'rhoShScrPerFir', u.shScrPer*p.rhoShScrPerFir);
        
    % FIR transmission coefficient of the shadow screen and semi permanent shadow screen layer [-]
    addAux(gl, 'tauShScrShScrPerFir', tau12(gl.a.tauShScrFir, gl.a.tauShScrPerFir, ...
        gl.a.rhoShScrFir, gl.a.rhoShScrFir, gl.a.rhoShScrPerFir, gl.a.rhoShScrPerFir));
    
    % FIR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the top [-]
    addAux(gl, 'rhoShScrShScrPerFirUp', rhoUp(gl.a.tauShScrFir, gl.a.tauShScrPerFir, ...
        gl.a.rhoShScrFir, gl.a.rhoShScrFir, gl.a.rhoShScrPerFir, gl.a.rhoShScrPerFir));
    
    % FIR reflection coefficient of the shadow screen and semi permanent shadow screen layer towards the bottom [-]
    addAux(gl, 'rhoShScrShScrPerFirDn', rhoDn(gl.a.tauShScrFir, gl.a.tauShScrPerFir, ...
        gl.a.rhoShScrFir, gl.a.rhoShScrFir, gl.a.rhoShScrPerFir, gl.a.rhoShScrPerFir));
    
    % thermal screen and roof
    % PAR

    % PAR transmission coefficient of the thermal screen [-]
    addAux(gl, 'tauThScrPar', 1-u.thScr*(1-p.tauThScrPar));
    
    % PAR reflection coefficient of the thermal screen [-]
    addAux(gl, 'rhoThScrPar', u.thScr*p.rhoThScrPar);
    
    % PAR transmission coefficient of the thermal screen and roof [-]
    addAux(gl, 'tauCovThScrPar', tau12(p.tauRfPar, gl.a.tauThScrPar, ...
        p.rhoRfPar, p.rhoRfPar, gl.a.rhoThScrPar, gl.a.rhoThScrPar));
    
    % PAR reflection coefficient of the thermal screen and roof towards the top [-]
    addAux(gl, 'rhoCovThScrParUp', rhoUp(p.tauRfPar, gl.a.tauThScrPar, ...
        p.rhoRfPar, p.rhoRfPar, gl.a.rhoThScrPar, gl.a.rhoThScrPar));
    
    % PAR reflection coefficient of the thermal screen and roof towards the bottom [-]
    addAux(gl, 'rhoCovThScrParDn', rhoDn(p.tauRfPar, gl.a.tauThScrPar, ...
        p.rhoRfPar, p.rhoRfPar, gl.a.rhoThScrPar, gl.a.rhoThScrPar));
   
    % NIR
    % NIR transmission coefficient of the thermal screen [-]
    addAux(gl, 'tauThScrNir', 1-u.thScr*(1-p.tauThScrNir));
    
    % NIR reflection coefficient of the thermal screen [-]
    addAux(gl, 'rhoThScrNir', u.thScr*p.rhoThScrNir);
    
    % NIR transmission coefficient of the thermal screen and roof [-]
    addAux(gl, 'tauCovThScrNir', tau12(p.tauRfNir, gl.a.tauThScrNir, ...
        p.rhoRfNir, p.rhoRfNir, gl.a.rhoThScrNir, gl.a.rhoThScrNir));
    
    % NIR reflection coefficient of the thermal screen and roof towards the top [-]
    addAux(gl, 'rhoCovThScrNirUp', rhoUp(p.tauRfNir, gl.a.tauThScrNir, ...
        p.rhoRfNir, p.rhoRfNir, gl.a.rhoThScrNir, gl.a.rhoThScrNir));
    
    % NIR reflection coefficient of the thermal screen and roof towards the top [-]
    addAux(gl, 'rhoCovThScrNirDn', rhoDn(p.tauRfNir, gl.a.tauThScrNir, ...
        p.rhoRfNir, p.rhoRfNir, gl.a.rhoThScrNir, gl.a.rhoThScrNir));
        
    % all 4 layers of the Vanthoor model
    % Vanthoor PAR transmission coefficient of the cover [-]
    addAux(gl, 'tauCovParOld', tau12(gl.a.tauShScrShScrPerPar, gl.a.tauCovThScrPar, ...
        gl.a.rhoShScrShScrPerParUp, gl.a.rhoShScrShScrPerParDn, ...
        gl.a.rhoCovThScrParUp, gl.a.rhoCovThScrParDn));
    
    % Vanthoor PAR reflection coefficient of the cover towards the top [-]
    addAux(gl, 'rhoCovParOldUp', rhoUp(gl.a.tauShScrShScrPerPar, gl.a.tauCovThScrPar, ...
        gl.a.rhoShScrShScrPerParUp, gl.a.rhoShScrShScrPerParDn, ...
        gl.a.rhoCovThScrParUp, gl.a.rhoCovThScrParDn));
    
    % Vanthoor PAR reflection coefficient of the cover towards the bottom [-]
    addAux(gl, 'rhoCovParOldDn', rhoDn(gl.a.tauShScrShScrPerPar, gl.a.tauCovThScrPar, ...
        gl.a.rhoShScrShScrPerParUp, gl.a.rhoShScrShScrPerParDn, ...
        gl.a.rhoCovThScrParUp, gl.a.rhoCovThScrParDn));
    
    % Vanthoor NIR transmission coefficient of the cover [-]
    addAux(gl, 'tauCovNirOld', tau12(gl.a.tauShScrShScrPerNir, gl.a.tauCovThScrNir, ...
        gl.a.rhoShScrShScrPerNirUp, gl.a.rhoShScrShScrPerNirDn, ...
        gl.a.rhoCovThScrNirUp, gl.a.rhoCovThScrNirDn));
    
    % Vanthoor NIR reflection coefficient of the cover towards the top [-]
    addAux(gl, 'rhoCovNirOldUp', rhoUp(gl.a.tauShScrShScrPerNir, gl.a.tauCovThScrNir, ...
        gl.a.rhoShScrShScrPerNirUp, gl.a.rhoShScrShScrPerNirDn, ...
        gl.a.rhoCovThScrNirUp, gl.a.rhoCovThScrNirDn));
    
    % Vanthoor NIR reflection coefficient of the cover towards the bottom [-]
    addAux(gl, 'rhoCovNirOldDn', rhoDn(gl.a.tauShScrShScrPerNir, gl.a.tauCovThScrNir, ...
        gl.a.rhoShScrShScrPerNirUp, gl.a.rhoShScrShScrPerNirDn, ...
        gl.a.rhoCovThScrNirUp, gl.a.rhoCovThScrNirDn));
    
    % Vanthoor cover with blackout screen
    % PAR transmission coefficient of the blackout screen [-]
    addAux(gl, 'tauBlScrPar', 1-u.blScr*(1-p.tauBlScrPar));
    
    % PAR reflection coefficient of the blackout screen [-]
    addAux(gl, 'rhoBlScrPar', u.blScr*p.rhoBlScrPar);
    
    % PAR transmission coefficient of the old cover and blackout screen [-]
	% Equation A9 [5]
    addAux(gl, 'tauCovBlScrPar', tau12(gl.a.tauCovParOld, gl.a.tauBlScrPar, ...
        gl.a.rhoCovParOldUp, gl.a.rhoCovParOldDn, ...
        gl.a.rhoBlScrPar, gl.a.rhoBlScrPar));
    
    % PAR up reflection coefficient of the old cover and blackout screen [-]
	% Equation A10 [5]
    addAux(gl, 'rhoCovBlScrParUp', rhoUp(gl.a.tauCovParOld, gl.a.tauBlScrPar, ...
        gl.a.rhoCovParOldUp, gl.a.rhoCovParOldDn, ...
        gl.a.rhoBlScrPar, gl.a.rhoBlScrPar));
    
    % PAR down reflection coefficient of the old cover and blackout screen [-]
	% Equation A11 [5]
    addAux(gl, 'rhoCovBlScrParDn', rhoDn(gl.a.tauCovParOld, gl.a.tauBlScrPar, ...
        gl.a.rhoCovParOldUp, gl.a.rhoCovParOldDn, ...
        gl.a.rhoBlScrPar, gl.a.rhoBlScrPar));
    
    % NIR transmission coefficient of the blackout screen [-]
    addAux(gl, 'tauBlScrNir', 1-u.blScr*(1-p.tauBlScrNir));
    
    % NIR reflection coefficient of the blackout screen [-]
    addAux(gl, 'rhoBlScrNir', u.blScr*p.rhoBlScrNir);
    
    % NIR transmission coefficient of the old cover and blackout screen [-]
    addAux(gl, 'tauCovBlScrNir', tau12(gl.a.tauCovNirOld, gl.a.tauBlScrNir, ...
        gl.a.rhoCovNirOldUp, gl.a.rhoCovNirOldDn, ...
        gl.a.rhoBlScrNir, gl.a.rhoBlScrNir));
    
    % NIR up reflection coefficient of the old cover and blackout screen [-]
    addAux(gl, 'rhoCovBlScrNirUp', rhoUp(gl.a.tauCovNirOld, gl.a.tauBlScrNir, ...
        gl.a.rhoCovNirOldUp, gl.a.rhoCovNirOldDn, ...
        gl.a.rhoBlScrNir, gl.a.rhoBlScrNir));
    
    % NIR down reflection coefficient of the old cover and blackout screen [-]
    addAux(gl, 'rhoCovBlScrNirDn', rhoDn(gl.a.tauCovNirOld, gl.a.tauBlScrNir, ...
        gl.a.rhoCovNirOldUp, gl.a.rhoCovNirOldDn, ...
        gl.a.rhoBlScrNir, gl.a.rhoBlScrNir));
    
    % all layers
    % PAR transmission coefficient of the cover [-]
	 % Equation A12 [5]
    addAux(gl, 'tauCovPar', tau12(gl.a.tauCovBlScrPar, p.tauLampPar, ...
        gl.a.rhoCovBlScrParUp, gl.a.rhoCovBlScrParDn, ...
        p.rhoLampPar, p.rhoLampPar));
    
    % PAR reflection coefficient of the cover [-]
	% Equation A13 [5]
    addAux(gl, 'rhoCovPar', rhoUp(gl.a.tauCovBlScrPar, p.tauLampPar, ...
        gl.a.rhoCovBlScrParUp, gl.a.rhoCovBlScrParDn, ...
        p.rhoLampPar, p.rhoLampPar));
    
    % NIR transmission coefficient of the cover [-]
    addAux(gl, 'tauCovNir', tau12(gl.a.tauCovBlScrNir, p.tauLampNir, ...
        gl.a.rhoCovBlScrNirUp, gl.a.rhoCovBlScrNirDn, ...
        p.rhoLampNir, p.rhoLampNir));
    
    % NIR reflection coefficient of the cover [-]
    addAux(gl, 'rhoCovNir', rhoUp(gl.a.tauCovBlScrNir, p.tauLampNir, ...
        gl.a.rhoCovBlScrNirUp, gl.a.rhoCovBlScrNirDn, ...
        p.rhoLampNir, p.rhoLampNir));
    
    % FIR transmission coefficient of the cover, excluding screens and lamps [-]
    addAux(gl, 'tauCovFir', tau12(gl.a.tauShScrShScrPerFir, p.tauRfFir, ...
        gl.a.rhoShScrShScrPerFirUp, gl.a.rhoShScrShScrPerFirDn, ...
        p.rhoRfFir, p.rhoRfFir));
    
    % FIR reflection coefficient of the cover, excluding screens and lamps [-]
    addAux(gl, 'rhoCovFir', rhoUp(gl.a.tauShScrShScrPerFir, p.tauRfFir, ...
        gl.a.rhoShScrShScrPerFirUp, gl.a.rhoShScrShScrPerFirDn, ...
        p.rhoRfFir, p.rhoRfFir));   
    
    % PAR absorption coefficient of the cover [-]
    addAux(gl, 'aCovPar', 1-gl.a.tauCovPar-gl.a.rhoCovPar);
    
    % NIR absorption coefficient of the cover [-]
    addAux(gl, 'aCovNir', 1-gl.a.tauCovNir-gl.a.rhoCovNir);
    
    % FIR absorption coefficient of the cover [-]
    addAux(gl, 'aCovFir', 1-gl.a.tauCovFir-gl.a.rhoCovFir);
    
    % FIR emission coefficient of the cover [-]
    % See comment before equation 18 [1]
    addAux(gl, 'epsCovFir', gl.a.aCovFir);
    
    % Heat capacity of the lumped cover [J K^{-1} m^{-2}]
    % Equation 18 [1]
    addAux(gl, 'capCov', cosd(p.psi)*(u.shScrPer*p.hShScrPer*p.rhoShScrPer*p.cPShScrPer+ ...
        p.hRf*p.rhoRf*p.cPRf));
    
	%% Capacities - Section 4 [1]
    
    % Leaf area index [m^2{leaf} m^{-2}]
    % Equation 5 [2]
    addAux(gl, 'lai', p.sla*x.cLeaf); 
    
    % Heat capacity of canopy [J K^{-1} m^{-2}]
    % Equation 19 [1]
    addAux(gl, 'capCan', p.capLeaf*gl.a.lai);
    
    % Heat capacity of external and internal cover [J K^{-1} m^{-2}]
    % Equation 20 [1]
    addAux(gl, 'capCovE', 0.1*gl.a.capCov);
    addAux(gl, 'capCovIn', 0.1*gl.a.capCov);
    
    % Vapor capacity of main compartment [kg m J^{-1}] 
    % Equation 24 [1]
    addAux(gl, 'capVpAir', p.mWater*p.hAir./(p.R*(x.tAir+273.15)));
    
    % Vapor capacity of top compartment [kg m J^{-1}] 
    addAux(gl, 'capVpTop', p.mWater*(p.hGh-p.hAir)./(p.R*(x.tTop+273.15)));
    
    %% Global, PAR, and NIR heat fluxes - Section 5.1 [1]
    
    % Lamp electrical input [W m^{-2}]
    % Equation A16 [5]
    addAux(gl, 'qLampIn', p.thetaLampMax*u.lamp);
    
    % Interlight electrical input [W m^{-2}]
    % Equation A26 [5]
    addAux(gl, 'qIntLampIn', p.thetaIntLampMax*u.intLamp);
    
    % PAR above the canopy from the sun [W m^{-2}]
    % Equation 27 [1], Equation A14 [5]
    addAux(gl, 'rParGhSun', (1-p.etaGlobAir).*gl.a.tauCovPar.*p.etaGlobPar.*d.iGlob); 
    
    % PAR above the canopy from the lamps [W m^{-2}] 
    % Equation A15 [5]
    addAux(gl, 'rParGhLamp', p.etaLampPar*gl.a.qLampIn);
    
    % PAR outside the canopy from the interlights [W m^{-2}] 
    % Equation 7.7, 7.14 [7]
    addAux(gl, 'rParGhIntLamp', p.etaIntLampPar*gl.a.qIntLampIn);
    
    % Global radiation above the canopy from the sun [W m^{-2}]
    % (PAR+NIR, where UV is counted together with NIR)
    % Equation 7.24 [7]
    addAux(gl, 'rCanSun', (1-p.etaGlobAir).*d.iGlob.*...
        (p.etaGlobPar*gl.a.tauCovPar+p.etaGlobNir*gl.a.tauCovNir));
                                    % perhaps tauHatCovNir should be used here?
    
    % Global radiation above the canopy from the lamps [W m^{-2}]
    % (PAR+NIR, where UV is counted together with NIR)
    % Equation 7.25 [7]
    addAux(gl, 'rCanLamp', (p.etaLampPar+p.etaLampNir)*gl.a.qLampIn);    
    
    % Global radiation outside the canopy from the interlight lamps [W m^{-2}]
    % (PAR+NIR, where UV is counted together with NIR)
    % Equation 7.26 [7]
    addAux(gl, 'rCanIntLamp', (p.etaIntLampPar+p.etaIntLampNir)*gl.a.qIntLampIn);    
    
    % Global radiation above and outside the canopy [W m^{-2}]
    % (PAR+NIR, where UV is counted together with NIR)
    % Equation 7.23 [7]
    addAux(gl, 'rCan', gl.a.rCanSun+gl.a.rCanLamp+gl.a.rCanIntLamp);    
    
    % PAR from the sun directly absorbed by the canopy [W m^{-2}]
    % Equation 26 [1]
    addAux(gl, 'rParSunCanDown', gl.a.rParGhSun.*(1-p.rhoCanPar).*(1-exp(-p.k1Par*gl.a.lai)));
    
    % PAR from the lamps directly absorbed by the canopy [W m^{-2}]
    % Equation A17 [5]
    addAux(gl, 'rParLampCanDown', gl.a.rParGhLamp.*(1-p.rhoCanPar).*(1-exp(-p.k1Par*gl.a.lai)));
    
    % Fraction of PAR from the interlights reaching the canopy [-]
    % Equation 7.13 [7]
    addAux(gl, 'fIntLampCanPar', 1-p.fIntLampDown*exp(-p.k1IntPar*p.vIntLampPos*gl.a.lai) + ...
        (p.fIntLampDown-1)*exp(-p.k1IntPar*(1-p.vIntLampPos)*gl.a.lai));
        % Fraction going up and absorbed is (1-p.fIntLampDown)*(1-exp(-p.k1IntPar*(1-p.vIntLampPos)*gl.a.lai))
        % Fraction going down and absorbed is p.fIntLampDown*(1-exp(-p.k1IntPar*p.vIntLampPos*gl.a.lai))
        % This is their sum
        % e.g., if p.vIntLampPos==1, the lamp is above the canopy
        %   fraction going up and abosrbed is 0
        %   fraction going down and absroebd is p.fIntLampDown*(1-exp(-p.k1IntPar*gl.a.lai))
    
    % Fraction of NIR from the interlights reaching the canopy [-]
    % Analogous to Equation 7.13 [7]
    addAux(gl, 'fIntLampCanNir', 1-p.fIntLampDown*exp(-p.kIntNir*p.vIntLampPos*gl.a.lai) + ...
        (p.fIntLampDown-1)*exp(-p.kIntNir*(1-p.vIntLampPos)*gl.a.lai));
    
    % PAR from the interlights directly absorbed by the canopy [W m^{-2}]
    % Equation 7.16 [7]
    addAux(gl, 'rParIntLampCanDown', gl.a.rParGhIntLamp.*gl.a.fIntLampCanPar.*(1-p.rhoCanPar));
    
    % PAR from the sun absorbed by the canopy after reflection from the floor [W m^{-2}]
    % Equation 28 [1]
    addAux(gl, 'rParSunFlrCanUp', mulNoBracks(gl.a.rParGhSun,exp(-p.k1Par*gl.a.lai)*p.rhoFlrPar* ...
        (1-p.rhoCanPar).*(1-exp(-p.k2Par*gl.a.lai))));
    
    % PAR from the lamps absorbed by the canopy after reflection from the floor [W m^{-2}]
    % Equation A18 [5]
    addAux(gl, 'rParLampFlrCanUp', gl.a.rParGhLamp.*exp(-p.k1Par*gl.a.lai)*p.rhoFlrPar* ...
        (1-p.rhoCanPar).*(1-exp(-p.k2Par*gl.a.lai)));
    
    % PAR from the interlights absorbed by the canopy after reflection from the floor [W m^{-2}]
    % Equation 7.18 [7]
    addAux(gl, 'rParIntLampFlrCanUp', gl.a.rParGhIntLamp.*p.fIntLampDown.*...
        exp(-p.k1IntPar*p.vIntLampPos.*gl.a.lai).*p.rhoFlrPar* ...
        (1-p.rhoCanPar).*(1-exp(-p.k2IntPar*gl.a.lai)));
        % if p.vIntLampPos==1, the lamp is above the canopy, light loses
        % exp(-k*LAI) on its way to the floor.
        % if p.vIntLampPos==0, the lamp is below the canopy, no light is
        % lost on the way to the floor
    
    % Total PAR from the sun absorbed by the canopy [W m^{-2}]
    % Equation 25 [1]
    addAux(gl, 'rParSunCan', gl.a.rParSunCanDown + gl.a.rParSunFlrCanUp);
    
    % Total PAR from the lamps absorbed by the canopy [W m^{-2}]
    % Equation A19 [5]
    addAux(gl, 'rParLampCan', gl.a.rParLampCanDown + gl.a.rParLampFlrCanUp);
        
    % Total PAR from the interlights absorbed by the canopy [W m^{-2}]
    % Equation A19 [5], Equation 7.19 [7]
    addAux(gl, 'rParIntLampCan', gl.a.rParIntLampCanDown + gl.a.rParIntLampFlrCanUp);
    
    % Virtual NIR transmission for the cover-canopy-floor lumped model [-]
    % Equation 29 [1]
    addAux(gl, 'tauHatCovNir', 1-gl.a.rhoCovNir);
    addAux(gl, 'tauHatFlrNir', 1-p.rhoFlrNir);
    
    % NIR transmission coefficient of the canopy [-]
    % Equation 30 [1]   
    addAux(gl, 'tauHatCanNir', exp(-p.kNir*gl.a.lai));
    
    % NIR reflection coefficient of the canopy [-]
    % Equation 31 [1]
    addAux(gl, 'rhoHatCanNir', p.rhoCanNir*(1-gl.a.tauHatCanNir));
    
    % NIR transmission coefficient of the cover and canopy [-]
    addAux(gl, 'tauCovCanNir', tau12(gl.a.tauHatCovNir, gl.a.tauHatCanNir, gl.a.rhoCovNir, gl.a.rhoCovNir, gl.a.rhoHatCanNir, gl.a.rhoHatCanNir));
    
    % NIR reflection coefficient of the cover and canopy towards the top [-]
    addAux(gl, 'rhoCovCanNirUp', rhoUp(gl.a.tauHatCovNir, gl.a.tauHatCanNir, gl.a.rhoCovNir, gl.a.rhoCovNir, gl.a.rhoHatCanNir, gl.a.rhoHatCanNir));
    
    % NIR reflection coefficient of the cover and canopy towards the bottom [-]
    addAux(gl, 'rhoCovCanNirDn', rhoDn(gl.a.tauHatCovNir, gl.a.tauHatCanNir, gl.a.rhoCovNir, gl.a.rhoCovNir, gl.a.rhoHatCanNir, gl.a.rhoHatCanNir));
    
    % NIR transmission coefficient of the cover, canopy and floor [-]
    addAux(gl, 'tauCovCanFlrNir', tau12(gl.a.tauCovCanNir, gl.a.tauHatFlrNir, gl.a.rhoCovCanNirUp, gl.a.rhoCovCanNirDn, p.rhoFlrNir, p.rhoFlrNir));
    
    % NIR reflection coefficient of the cover, canopy and floor [-]
    addAux(gl, 'rhoCovCanFlrNir', rhoUp(gl.a.tauCovCanNir, gl.a.tauHatFlrNir, gl.a.rhoCovCanNirUp, gl.a.rhoCovCanNirDn, p.rhoFlrNir, p.rhoFlrNir));
    
    % The calculated absorption coefficient equals m.a.aCanNir [-]
    % pg. 23 [1]
    addAux(gl, 'aCanNir', 1 - gl.a.tauCovCanFlrNir - gl.a.rhoCovCanFlrNir);
    
    % The calculated transmission coefficient equals m.a.aFlrNir [-]
    % pg. 23 [1]
    addAux(gl, 'aFlrNir', gl.a.tauCovCanFlrNir);
    
    % NIR from the sun absorbed by the canopy [W m^{-2}]
    % Equation 32 [1]
    addAux(gl, 'rNirSunCan', (1-p.etaGlobAir).*gl.a.aCanNir.*p.etaGlobNir.*d.iGlob);
    
    % NIR from the lamps absorbed by the canopy [W m^{-2}]
    % Equation A20 [5]
    addAux(gl, 'rNirLampCan', p.etaLampNir.*gl.a.qLampIn.*(1-p.rhoCanNir).*(1-exp(-p.kNir*gl.a.lai)));
            
    % NIR from the interlights absorbed by the canopy [W m^{-2}]
    % Equation 7.20 [7]
    addAux(gl, 'rNirIntLampCan', p.etaIntLampNir.*gl.a.qIntLampIn.*gl.a.fIntLampCanNir.*(1-p.rhoCanNir));

    % NIR from the sun absorbed by the floor [W m^{-2}]
    % Equation 33 [1]
    addAux(gl, 'rNirSunFlr', (1-p.etaGlobAir).*gl.a.aFlrNir.*p.etaGlobNir.*d.iGlob);
    
    % NIR from the lamps absorbed by the floor [W m^{-2}]
    % Equation A22 [5]
    addAux(gl, 'rNirLampFlr', (1-p.rhoFlrNir).*exp(-p.kNir*gl.a.lai).*p.etaLampNir.*gl.a.qLampIn);
    
    % NIR from the interlights absorbed by the floor [W m^{-2}]
    % Equation 7.21 [7]
    addAux(gl, 'rNirIntLampFlr', p.fIntLampDown.*(1-p.rhoFlrNir).*...
        exp(-p.kIntNir*gl.a.lai.*p.vIntLampPos).*...
        p.etaIntLampNir.*gl.a.qIntLampIn);
        % if p.vIntLampPos==1, the lamp is above the canopy, light loses
        % exp(-k*LAI) on its way to the floor.
        % if p.vIntLampPos==0, the lamp is below the canopy, no light is
        % lost on the way to the floor
    
    % PAR from the sun absorbed by the floor [W m^{-2}]
    % Equation 34 [1]
    addAux(gl, 'rParSunFlr', (1-p.rhoFlrPar).*exp(-p.k1Par*gl.a.lai).*gl.a.rParGhSun);
    
    % PAR from the lamps absorbed by the floor [W m^{-2}]
    % Equation A21 [5]
    addAux(gl, 'rParLampFlr', (1-p.rhoFlrPar).*exp(-p.k1Par*gl.a.lai).*gl.a.rParGhLamp);
    
    % PAR from the interlights absorbed by the floor [W m^{-2}]
    % Equation 7.17 [7]
    addAux(gl, 'rParIntLampFlr', gl.a.rParGhIntLamp.*p.fIntLampDown.*(1-p.rhoFlrPar).*...
        exp(-p.k1IntPar*gl.a.lai.*p.vIntLampPos));
    
	% PAR and NIR from the lamps absorbed by the greenhouse air [W m^{-2}]
    % Equation A23 [5]
	addAux(gl, 'rLampAir', (p.etaLampPar+p.etaLampNir)*gl.a.qLampIn - gl.a.rParLampCan - ...
		gl.a.rNirLampCan - gl.a.rParLampFlr - gl.a.rNirLampFlr);
	
    % PAR and NIR from the interlights absorbed by the greenhouse air [W m^{-2}]
    % Equation 7.22 [7]
	addAux(gl, 'rIntLampAir', (p.etaIntLampPar+p.etaIntLampNir)*gl.a.qIntLampIn - gl.a.rParIntLampCan - ...
		gl.a.rNirIntLampCan - gl.a.rParIntLampFlr - gl.a.rNirIntLampFlr);
    
    % Global radiation from the sun absorbed by the greenhouse air [W m^{-2}]
    % Equation 35 [1]
    addAux(gl, 'rGlobSunAir', p.etaGlobAir*d.iGlob.*...
        (gl.a.tauCovPar*p.etaGlobPar+(gl.a.aCanNir+gl.a.aFlrNir)*p.etaGlobNir));
    
    % Global radiation from the sun absorbed by the cover [W m^{-2}]
    % Equation 36 [1]
    addAux(gl, 'rGlobSunCovE', (gl.a.aCovPar*p.etaGlobPar+gl.a.aCovNir*p.etaGlobNir).*d.iGlob);
    
    %% FIR heat fluxes - Section 5.2 [1]
	
	% FIR transmission coefficient of the thermal screen
	% Equation 38 [1]
    addAux(gl, 'tauThScrFirU', (1-u.thScr*(1-p.tauThScrFir)));
	
    % FIR transmission coefficient of the blackout screen
    addAux(gl, 'tauBlScrFirU', (1-u.blScr*(1-p.tauBlScrFir)));   
    
	% Surface of canopy per floor area [-]
	% Table 3 [1]
    addAux(gl, 'aCan', 1-exp(-p.kFir*gl.a.lai));
	
	% FIR between greenhouse objects [W m^{-2}]
	% Table 7.4 [7]. Based on Table 3 [1] and Table A1 [5]
	
	% FIR between canopy and cover [W m^{-2}]
    addAux(gl, 'rCanCovIn', fir(gl.a.aCan, p.epsCan, gl.a.epsCovFir, ...
        p.tauLampFir*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU,...
        x.tCan, x.tCovIn));
	
	% FIR between canopy and sky [W m^{-2}]
    addAux(gl, 'rCanSky', fir(gl.a.aCan, p.epsCan, p.epsSky, ...
        p.tauLampFir*gl.a.tauCovFir.*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU,...
        x.tCan, d.tSky));
	
	% FIR between canopy and thermal screen [W m^{-2}]
    addAux(gl, 'rCanThScr', fir(gl.a.aCan, p.epsCan, p.epsThScrFir, ...
        p.tauLampFir*u.thScr.*gl.a.tauBlScrFirU, x.tCan, x.tThScr));
    
	% FIR between canopy and floor [W m^{-2}]
	addAux(gl, 'rCanFlr', fir(gl.a.aCan, p.epsCan, p.epsFlr, ...
        p.fCanFlr, x.tCan, x.tFlr));
	
	% FIR between pipes and cover [W m^{-2}]
    addAux(gl, 'rPipeCovIn', fir(p.aPipe, p.epsPipe, gl.a.epsCovFir, ...
        p.tauIntLampFir*p.tauLampFir*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU*0.49.*...
        exp(-p.kFir*gl.a.lai), x.tPipe, x.tCovIn));
		
	% FIR between pipes and sky [W m^{-2}]
    addAux(gl, 'rPipeSky', fir(p.aPipe, p.epsPipe, p.epsSky, ...
        p.tauIntLampFir*p.tauLampFir*gl.a.tauCovFir.*gl.a.tauThScrFirU.*...
        gl.a.tauBlScrFirU*0.49.*exp(-p.kFir*gl.a.lai), x.tPipe, d.tSky));
		
	% FIR between pipes and thermal screen [W m^{-2}]
    addAux(gl, 'rPipeThScr', fir(p.aPipe, p.epsPipe, p.epsThScrFir, ...
        p.tauIntLampFir*p.tauLampFir*u.thScr.*gl.a.tauBlScrFirU*0.49.*...
        exp(-p.kFir*gl.a.lai), x.tPipe, x.tThScr));
		
	% FIR between pipes and floor [W m^{-2}]
    addAux(gl, 'rPipeFlr', fir(p.aPipe, p.epsPipe, p.epsFlr, 0.49, x.tPipe, x.tFlr));
	
	% FIR between pipes and canopy [W m^{-2}]
    addAux(gl, 'rPipeCan', fir(p.aPipe, p.epsPipe, p.epsCan, ...
        0.49.*(1-exp(-p.kFir*gl.a.lai)), x.tPipe, x.tCan));
		
	% FIR between floor and cover [W m^{-2}]
    addAux(gl, 'rFlrCovIn', fir(1, p.epsFlr, gl.a.epsCovFir, ...
        p.tauIntLampFir*p.tauLampFir*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU*...
        (1-0.49*pi*p.lPipe*p.phiPipeE).*exp(-p.kFir*gl.a.lai), x.tFlr, x.tCovIn));
    
	% FIR between floor and sky [W m^{-2}]
	addAux(gl, 'rFlrSky', fir(1, p.epsFlr, p.epsSky, ...
        p.tauIntLampFir*p.tauLampFir*gl.a.tauCovFir.*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU*...
        (1-0.49*pi*p.lPipe*p.phiPipeE).*exp(-p.kFir*gl.a.lai), x.tFlr, d.tSky));
    
	% FIR between floor and thermal screen [W m^{-2}]
	addAux(gl, 'rFlrThScr', fir(1, p.epsFlr, p.epsThScrFir, ...
        p.tauIntLampFir*p.tauLampFir*u.thScr.*gl.a.tauBlScrFirU*(1-0.49*pi*p.lPipe*p.phiPipeE).*...
        exp(-p.kFir*gl.a.lai), x.tFlr, x.tThScr));
    
	% FIR between thermal screen and cover [W m^{-2}]
	addAux(gl, 'rThScrCovIn', fir(1, p.epsThScrFir, gl.a.epsCovFir, ...
        u.thScr, x.tThScr, x.tCovIn));
    
	% FIR between thermal screen and sky [W m^{-2}]
	addAux(gl, 'rThScrSky', fir(1, p.epsThScrFir, p.epsSky, ...
        gl.a.tauCovFir.*u.thScr, x.tThScr, d.tSky));
    
	% FIR between cover and sky [W m^{-2}]
	addAux(gl, 'rCovESky', fir(1, gl.a.aCovFir, p.epsSky, 1, x.tCovE, d.tSky));
    
    % FIR between lamps and floor [W m^{-2}]
    addAux(gl, 'rFirLampFlr', fir(p.aLamp, p.epsLampBottom, p.epsFlr, ...
        p.tauIntLampFir.*(1-0.49*pi*p.lPipe*p.phiPipeE).*exp(-p.kFir*gl.a.lai), x.tLamp, x.tFlr));
    
    % FIR between lamps and pipe [W m^{-2}]
    addAux(gl, 'rLampPipe', fir(p.aLamp, p.epsLampBottom, p.epsPipe, ...
        p.tauIntLampFir.*0.49*pi*p.lPipe*p.phiPipeE.*exp(-p.kFir*gl.a.lai), x.tLamp, x.tPipe));
    
    % FIR between lamps and canopy [W m^{-2}]
    addAux(gl, 'rFirLampCan', fir(p.aLamp, p.epsLampBottom, p.epsCan, ...
        gl.a.aCan, x.tLamp, x.tCan));
    
    % FIR between lamps and thermal screen [W m^{-2}]
    addAux(gl, 'rLampThScr', fir(p.aLamp, p.epsLampTop, p.epsThScrFir, ...
        u.thScr.*gl.a.tauBlScrFirU, x.tLamp, x.tThScr));
    
    % FIR between lamps and cover [W m^{-2}]
    addAux(gl, 'rLampCovIn', fir(p.aLamp, p.epsLampTop, gl.a.epsCovFir, ...
        gl.a.tauThScrFirU.*gl.a.tauBlScrFirU, x.tLamp, x.tCovIn));
    
    % FIR between lamps and sky [W m^{-2}]
    addAux(gl, 'rLampSky', fir(p.aLamp, p.epsLampTop, p.epsSky, ...
        gl.a.tauCovFir.*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU, x.tLamp, d.tSky));
    
    % FIR between grow pipes and canopy [W m^{-2}]
    addAux(gl, 'rGroPipeCan', fir(p.aGroPipe, p.epsGroPipe, p.epsCan, 1, x.tGroPipe, x.tCan));
    
    % FIR between blackout screen and floor [W m^{-2}]	
    addAux(gl, 'rFlrBlScr', fir(1, p.epsFlr, p.epsBlScrFir, ...
        p.tauIntLampFir*p.tauLampFir*u.blScr*(1-0.49*pi*p.lPipe*p.phiPipeE).*...
        exp(-p.kFir*gl.a.lai), x.tFlr, x.tBlScr));
    
    % FIR between blackout screen and pipe [W m^{-2}]
    addAux(gl, 'rPipeBlScr', fir(p.aPipe, p.epsPipe, p.epsBlScrFir, ...
        p.tauIntLampFir*p.tauLampFir*u.blScr*0.49.*exp(-p.kFir*gl.a.lai), x.tPipe, x.tBlScr));
    
    % FIR between blackout screen and canopy [W m^{-2}]
    addAux(gl, 'rCanBlScr', fir(gl.a.aCan, p.epsCan, p.epsBlScrFir, ...
        p.tauLampFir*u.blScr, x.tCan, x.tBlScr));
    
    % FIR between blackout screen and thermal screen [W m^{-2}]
    addAux(gl, 'rBlScrThScr', fir(u.blScr, p.epsBlScrFir, ...
        p.epsThScrFir, u.thScr, x.tBlScr, x.tThScr)); 
    
    % FIR between blackout screen and cover [W m^{-2}]
    addAux(gl, 'rBlScrCovIn', fir(u.blScr, p.epsBlScrFir, gl.a.epsCovFir, ...
        gl.a.tauThScrFirU, x.tBlScr, x.tCovIn));
    
    % FIR between blackout screen and sky [W m^{-2}]
    addAux(gl, 'rBlScrSky', fir(u.blScr, p.epsBlScrFir, p.epsSky, ...
        gl.a.tauCovFir.*gl.a.tauThScrFirU, x.tBlScr, d.tSky));
    
    % FIR between blackout screen and lamps [W m^{-2}]
    addAux(gl, 'rLampBlScr', fir(p.aLamp, p.epsLampTop, p.epsBlScrFir, ...
        u.blScr, x.tLamp, x.tBlScr));
    
    % Fraction of radiation going up from the interlight to the canopy [-]
    % Equation 7.29 [7]
    addAux(gl, 'fIntLampCanUp', 1-exp(-p.kIntFir*(1-p.vIntLampPos).*gl.a.lai));
    
    % Fraction of radiation going down from the interlight to the canopy [-]
    % Equation 7.30 [7]
    addAux(gl, 'fIntLampCanDown', 1-exp(-p.kIntFir*p.vIntLampPos.*gl.a.lai));
    
    % FIR between interlights and floor [W m^{-2}]
    addAux(gl, 'rFirIntLampFlr', fir(p.aIntLamp, p.epsIntLamp, p.epsFlr, ...
        (1-0.49*pi*p.lPipe*p.phiPipeE).*(1-gl.a.fIntLampCanDown),...
        x.tIntLamp, x.tFlr));
    
    % FIR between interlights and pipe [W m^{-2}]
    addAux(gl, 'rIntLampPipe', fir(p.aIntLamp, p.epsIntLamp, p.epsPipe, ...
        0.49*pi*p.lPipe*p.phiPipeE.*(1-gl.a.fIntLampCanDown),...
        x.tIntLamp, x.tPipe));
    
    % FIR between interlights and canopy [W m^{-2}]
    addAux(gl, 'rFirIntLampCan', fir(p.aIntLamp, p.epsIntLamp, p.epsCan, ...
        gl.a.fIntLampCanDown+gl.a.fIntLampCanUp, x.tIntLamp, x.tCan));
    
    % FIR between interlights and toplights [W m^{-2}]
    addAux(gl, 'rIntLampLamp', fir(p.aIntLamp, p.epsIntLamp, p.epsLampBottom, ...
        (1-gl.a.fIntLampCanUp).*p.aLamp, x.tIntLamp, x.tLamp));
        
    % FIR between interlights and blackout screen [W m^{-2}]
    addAux(gl, 'rIntLampBlScr', fir(p.aIntLamp, p.epsIntLamp, p.epsBlScrFir, ...
        u.blScr.*p.tauLampFir.*(1-gl.a.fIntLampCanUp), x.tIntLamp, x.tBlScr));
        % if p.vIntLampPos==0, the lamp is above the canopy, no light is
        % lost on its way up
        % if p.vIntLampPos==1, the lamp is below the canopy, the light
        % loses exp(-k*LAI) on its way up
    
    % FIR between interlights and thermal screen [W m^{-2}]
    addAux(gl, 'rIntLampThScr', fir(p.aIntLamp, p.epsIntLamp, p.epsThScrFir, ...
        u.thScr.*gl.a.tauBlScrFirU.*p.tauLampFir.*(1-gl.a.fIntLampCanUp),...
        x.tIntLamp, x.tThScr));
    
    % FIR between interlights and cover [W m^{-2}]
    addAux(gl, 'rIntLampCovIn', fir(p.aIntLamp, p.epsIntLamp, gl.a.epsCovFir, ...
        gl.a.tauThScrFirU.*gl.a.tauBlScrFirU.*p.tauLampFir.*(1-gl.a.fIntLampCanUp),...
        x.tIntLamp, x.tCovIn));
    
    % FIR between interlights and sky [W m^{-2}]
    addAux(gl, 'rIntLampSky', fir(p.aIntLamp, p.epsIntLamp, p.epsSky, ...
        gl.a.tauCovFir.*gl.a.tauThScrFirU.*gl.a.tauBlScrFirU.*p.tauLampFir.*(1-gl.a.fIntLampCanUp),...
        x.tIntLamp, d.tSky));

	%% Natural ventilation - Section 9.7 [1]
    
	% Aperture of the roof [m^{2}]
	% Equation 67 [1]
    addAux(gl, 'aRoofU', u.roof*p.aRoof);
    addAux(gl, 'aRoofUMax', p.aRoof);
    addAux(gl, 'aRoofMin', DynamicElement('0',0));
	
	% Aperture of the sidewall [m^{2}]
	% Equation 68 [1] 
	% (this is 0 in the Dutch greenhouse)
    addAux(gl, 'aSideU', u.side*p.aSide); 
    
	% Ratio between roof vent area and total ventilation area [-]
	% (not very clear in the reference [1], but always 1 if m.a.aSideU == 0)
%     addAux(m, 'etaRoof', m.a.aRoofU./max(m.a.aRoofU+m.a.aSideU,0.01)); 
    addAux(gl, 'etaRoof', '1'); 
    addAux(gl, 'etaRoofNoSide', '1');
	
    % Ratio between side vent area and total ventilation area [-]
	% (not very clear in the reference [1], but always 0 if m.a.aSideU == 0)    
    addAux(gl, 'etaSide', '0'); 
	
    
	% Discharge coefficient [-]
	% Equation 73 [1]
    addAux(gl, 'cD', p.cDgh*(1-p.etaShScrCd*u.shScr));
	
	% Discharge coefficient [-]
	% Equation 74 [-]
    addAux(gl, 'cW', p.cWgh*(1-p.etaShScrCw*u.shScr));
    
	% Natural ventilation rate due to roof ventilation [m^{3} m^{-2} s^{-1}]
	% Equation 64 [1]
    addAux(gl, 'fVentRoof2', u.roof*p.aRoof.*gl.a.cD/(2.*p.aFlr).*...
        sqrt(abs(p.g*p.hVent*(x.tAir-d.tOut)./(2*(0.5*x.tAir+0.5*d.tOut+273.15))+gl.a.cW.*d.wind.^2)));
    addAux(gl, 'fVentRoof2Max', p.aRoof.*gl.a.cD/(2.*p.aFlr).*...
        sqrt(abs(p.g*p.hVent*(x.tAir-d.tOut)./(2*(0.5*x.tAir+0.5*d.tOut+273.15))+gl.a.cW.*d.wind.^2)));
    addAux(gl, 'fVentRoof2Min', DynamicElement('0',0));
    
    
	% Ventilation rate through roof and side vents [m^{3} m^{-2} s^{-1}]
	% Equation 65 [1]
    addAux(gl, 'fVentRoofSide2', gl.a.cD/p.aFlr.*sqrt(...
        (gl.a.aRoofU.*gl.a.aSideU./sqrt(max(gl.a.aRoofU.^2+gl.a.aSideU.^2,0.01))).^2 .* ...
        (2*p.g*p.hSideRoof*(x.tAir-d.tOut)./(0.5*x.tAir+0.5*d.tOut+273.15))+...
        ((gl.a.aRoofU+gl.a.aSideU)/2).^2.*gl.a.cW.*d.wind.^2));
    
	% Ventilation rate through sidewall only [m^{3} m^{-2} s^{-1}]
	% Equation 66 [1]
    addAux(gl, 'fVentSide2', gl.a.cD.*gl.a.aSideU.*d.wind/(2*p.aFlr).*sqrt(gl.a.cW));
    
	% Leakage ventilation [m^{3} m^{-2} s^{-1}]
	% Equation 70 [1]
    addAux(gl, 'fLeakage', ifElse('d.wind<p.minWind',p.minWind*p.cLeakage,p.cLeakage*d.wind));
    
	% Total ventilation through the roof [m^{3} m^{-2} s^{-1}]
	% Equation 71 [1], Equation A42 [5]
    addAux(gl, 'fVentRoof', ifElse([getDefStr(gl.a.etaRoof) '>=p.etaRoofThr'],p.etaInsScr*gl.a.fVentRoof2+p.cLeakTop*gl.a.fLeakage,...
        p.etaInsScr*(max(u.thScr,u.blScr).*gl.a.fVentRoof2+(1-max(u.thScr,u.blScr)).*gl.a.fVentRoofSide2.*gl.a.etaRoof)...
        +p.cLeakTop*gl.a.fLeakage));
    
	% Total ventilation through side vents [m^{3} m^{-2} s^{-1}]
	% Equation 72 [1], Equation A43 [5]
    addAux(gl, 'fVentSide', ifElse([getDefStr(gl.a.etaRoof) '>=p.etaRoofThr'],p.etaInsScr*gl.a.fVentSide2+(1-p.cLeakTop)*gl.a.fLeakage,...
        p.etaInsScr*(max(u.thScr,u.blScr).*gl.a.fVentSide2+(1-max(u.thScr,u.blScr)).*gl.a.fVentRoofSide2.*gl.a.etaSide)...
        +(1-p.cLeakTop)*gl.a.fLeakage));
    
    %% Control rules  
	
    % Hours since midnight [h]
    addAux(gl, 'timeOfDay', 24*(x.time-floor(x.time))); 
    
    % Day of year [d]
    addAux(gl, 'dayOfYear', mod(x.time, 365.2425));
    
    % Control of the lamp according to the time of day [0/1]
    % if p.lampsOn < p.lampsOff, lamps are on from p.lampsOn to p.lampsOff each day
    % if p.lampsOn > p.lampsOff, lamps are on from p.lampsOn until p.lampsOff the next day
    % if p.lampsOn == p.lampsOff, lamps are always off
    % for continuous light, set p.lampsOn = -1, p.lampsOff = 25
    addAux(gl, 'lampTimeOfDay', ((p.lampsOn<=p.lampsOff).* ...
        (p.lampsOn < gl.a.timeOfDay & gl.a.timeOfDay < p.lampsOff) + ... 
        (1-(p.lampsOn<=p.lampsOff)).*(p.lampsOn<gl.a.timeOfDay | gl.a.timeOfDay<p.lampsOff))...
        .*1); % multiply by 1 to convert from logical to double
        
    % Control of the lamp according to the day of year [0/1]
    % if p.dayLampStart < p.dayLampStop, lamps are on from p.dayLampStart to p.dayLampStop
    % if p.dayLampStart > p.dayLampStop, lamps are on from p.lampsOn until p.lampsOff the next year
    % if p.dayLampStart == p.dayLampStop, lamps are always off
    % for no influence of day of year, set p.dayLampStart = -1, p.dayLampStop > 366
    addAux(gl, 'lampDayOfYear', ((p.dayLampStart<=p.dayLampStop).* ...
        (p.dayLampStart < gl.a.dayOfYear & gl.a.dayOfYear < p.dayLampStop) + ... 
        (1-(p.dayLampStart<=p.dayLampStop)).*(p.dayLampStart<gl.a.dayOfYear | gl.a.dayOfYear<p.dayLampStop))...
        .*1); % multiply by 1 to convert from logical to double
    
    % Control for the lamps disregarding temperature and humidity constraints
    % Chapter 4 Section 2.3.2, Chapter 5 Section 2.4 [7]
    % Section 2.3.2 [8]
    % This variable is used to decide if the greenhouse is in the light period
    % ("day inside"), needed to set the climate setpoints. 
    % However, the lamps may be switched off if it is too hot or too humid
    % in the greenhouse. In this case, the greenhouse is still considered
    % to be in the light period
    addAux(gl, 'lampNoCons', 1.*(gl.d.iGlob < gl.p.lampsOffSun).* ... % lamps are off if sun is not too bright
        (gl.d.dayRadSum < gl.p.lampRadSumLimit).* ... % and the predicted daily radiation sum is less than the predefined limit 
        gl.a.lampTimeOfDay.* ... % and the time of day is within the lighting period
        gl.a.lampDayOfYear); % and the day of year is within the lighting season
        
    %% Smoothing of control of the lamps
    % To allow smooth transition between day and night setpoints
    
    % Linear version of lamp switching on: 
    % 1 at lampOn, 0 one hour before lampOn, with linear transition
    % Note: this current function doesn't do a linear interpolation if
    % lampOn == 0
    addAux(gl, 'linearLampSwitchOn', max(0,min(1,gl.a.timeOfDay-p.lampsOn+1)));
    
    % Linear version of lamp switching on: 
    % 1 at lampOff, 0 one hour after lampOff, with linear transition
    % Note: this current function doesn't do a linear interpolation if
    % lampOff == 24
    addAux(gl, 'linearLampSwitchOff', max(0,min(1,p.lampsOff-gl.a.timeOfDay+1)));
    
    % Combination of linear transitions above
    % if p.lampsOn < p.lampsOff, take the minimum of the above
    % if p.lampsOn > p.lampsOn, take the maximum
    % if p.lampsOn == p.lampsOff, set at 0
    addAux(gl, 'linearLampBothSwitches', ...
        (p.lampsOn~=p.lampsOff).*((p.lampsOn<p.lampsOff).*min(gl.a.linearLampSwitchOn,gl.a.linearLampSwitchOff) ...
        + (1-(p.lampsOn<p.lampsOff)).*max(gl.a.linearLampSwitchOn,gl.a.linearLampSwitchOff)));
    
    % Smooth (linear) approximation of the lamp control
    % To allow smooth transition between light period and dark period setpoints
    % 1 when lamps are on, 0 when lamps are off, with a linear
    % interpolation in between
    % Does not take into account the lamp switching off due to 
    % instantaenous sun radiation, excess heat or humidity
    addAux(gl, 'smoothLamp', gl.a.linearLampBothSwitches.* ... % linear transition between lamp on and off
        (gl.d.dayRadSum < gl.p.lampRadSumLimit).* ... % lamps off if the predicted daily radiation sum is more than the predefined limit 
        gl.a.lampDayOfYear); % lamps off if day of year is not within the lighting season

    % Indicates whether daytime climate settings should be used, i.e., if
    % the sun is out or the lamps are on
    % 1 if day, 0 if night. If lamps are on it is considered day
    addAux(gl, 'isDayInside', max(gl.a.smoothLamp,d.isDay));
    
    % Decision on whether mechanical cooling and dehumidification is allowed to work
    % (0 - not allowed, 1 - allowed)
    % By default there is no mechanical cooling and dehumidification
    addAux(gl, 'mechAllowed', '0');
            
    % Decision on whether heating from buffer is allowed to run
    % (0 - not allowed, 1 - allowed)
    % By default there is no heating from the buffer
    addAux(gl, 'hotBufAllowed', '0');
        % Only runs if the hot buffer is not empty 
        
    % Heating set point [°C]
    % Chapter 5, Section 2.4, point 6 [7]
    % Chapter 4, Section 2.3.2, point 3 and Section 2.3.3 [7]
    % Section 2.3.2, point 3 and Section 2.3.3 [8]
    addAux(gl, 'heatSetPoint', gl.a.isDayInside*p.tSpDay + (1-gl.a.isDayInside)*p.tSpNight ...
        + p.heatCorrection*gl.a.lampNoCons); % correction for LEDs when lamps are on
    
    % Ventilation setpoint due to excess heating set point [°C]
    % Chapter 5, Section 2.4, point 8 [7]
    % Chapter 4, Section 2.3.2, point 4 [7]
    % Section 2.3.2, point 4 [8]
    addAux(gl, 'heatMax', gl.a.heatSetPoint + p.heatDeadZone);    
    
    % CO2 set point [ppm]
    % Chapter 5, Section 2.4, point 5 [7]
    % Chapter 4, Section 2.3.2, point 2 [7]
    % Section 2.3.2, point 2 [8]
    addAux(gl, 'co2SetPoint', gl.a.isDayInside*p.co2SpDay);
    
    % CO2 concentration in main compartment [ppm]
    addAux(gl, 'co2InPpm', co2dens2ppm(x.tAir,1e-6*x.co2Air)); 
    
    % Ventilation due to excess heat [0-1, 0 means vents are closed]
    addAux(gl, 'ventHeat', proportionalControl(x.tAir, ...
        gl.a.heatMax, p.ventHeatPband, 0, 1));
    
    % Relative humidity [%]
    addAux(gl, 'rhIn', 100*x.vpAir./satVp(x.tAir));
    
    % Ventilation due to excess humidity [0-1, 0 means vents are closed]
    % Chapter 5, Section 2.4, point 7 [7]
    % Chapter 4, Section 2.3.2, point 4 [7]
    % Section 2.3.2, point 4 [8]
    addAux(gl, 'ventRh', proportionalControl(gl.a.rhIn, ...
        p.rhMax+gl.a.mechAllowed.*p.mechDehumidPband, ...
        p.ventRhPband, 0, 1));
        % the setpoint of when to start ventilating depends on the mechanical dehumidification:
        % if it is on (a.mechAllowed == 1), start ventilating only when 
        % mechanical dehumidification is at full capacity. 
        % If it is off (a.mechAllowed == 0)
        % start at the normal setpoint
    
    % Ventilation closure due to too cold temperatures 
    % [0-1, 0 means vents are closed because it's too cold inside to ventilate,
    % better to raise the RH by heating]
    % Chapter 5, Section 2.4, point 7 [7]
    % Chapter 4, Section 2.3.2, point 4 [7]
    % Section 2.3.2, point 4 [8]
    addAux(gl, 'ventCold', proportionalControl(x.tAir, gl.a.heatSetPoint-p.tVentOff, p.ventColdPband, 1, 0));
        
    % Setpoint for closing the thermal screen [°C]
    % Chapter 5, Section 2.4, point 4 [7]
    % Chapter 4, Section 2.3.2, point 5 [7]
    % Section 2.3.2, point 5 [8]
    addAux(gl, 'thScrSp', gl.d.isDay.*p.thScrSpDay+(1-gl.d.isDay).*p.thScrSpNight);
    
    % Closure of the thermal screen based on outdoor temperature [0-1, 0 is fully open]
    % Chapter 5, Section 2.4, point 4 [7]
    % Chapter 4, Section 2.3.2, point 5 [7]
    % Section 2.3.2, point 5 [8]
    addAux(gl, 'thScrCold', proportionalControl(d.tOut, gl.a.thScrSp, p.thScrPband, 0, 1));
    
    % Opening of thermal screen closure due to too high temperatures 
    % Chapter 5, Section 2.4, point 4 [7]
    % Chapter 4, Section 2.3.2, point 5 [7]
    % Section 2.3.2, point 5 [8]
    addAux(gl, 'thScrHeat', proportionalControl(x.tAir, ...
        gl.a.heatSetPoint+p.thScrDeadZone, ...
        -p.thScrPband, 1, 0));
    
    % Opening of thermal screen due to high humidity [0-1, 0 is fully open]
    % Chapter 5, Section 2.4, point 4 [7]
    % Chapter 4, Section 2.3.2, point 5 [7]
    % Section 2.3.2, point 5 [8]
    addAux(gl, 'thScrRh', max(proportionalControl(gl.a.rhIn, ...
        p.rhMax+p.thScrRh, p.thScrRhPband, 1, 0), ...
        1-gl.a.ventCold));
        % if 1-a.ventCold == 0 (it's too cold inside to ventilate)
        % don't force to open the screen (even if RH says it should be 0)
        % Better to reduce RH by increasing temperature
    
    % Control for the top lights: 
    % 1 if lamps are on, 0 if lamps are off
    addAux(gl, 'lampOn', gl.a.lampNoCons.* ... % Lamps should be on
        proportionalControl(gl.x.tAir, gl.a.heatMax+gl.p.lampExtraHeat, -0.5, 0, 1).* ... % Switch lamp off if too hot inside
        ...                                            % Humidity: only switch off if blackout screen is used 
        (gl.d.isDaySmooth + (1-gl.d.isDaySmooth).* ... % Blackout sceen is only used at night 
            max(proportionalControl(gl.a.rhIn, gl.p.rhMax+gl.p.blScrExtraRh, -0.5, 0, 1),... % Switch lamp off if too humid inside
                        1-gl.a.ventCold))); % Unless ventCold == 0
                        % if ventCold is 0 it's too cold inside to ventilate, 
                        % better to raise the RH by heating. 
                        % So don't open the blackout screen and 
                        % don't stop illuminating in this case. 
        
    % Control for the interlights: 
    % 1 if interlights are on, 0 if interlights are off
    addAux(gl, 'intLampOn', gl.a.lampNoCons.* ... % Lamps should be on
        proportionalControl(gl.x.tAir, gl.a.heatMax+gl.p.lampExtraHeat, -0.5, 0, 1).* ... % Switch lamp off if too hot inside
        ... % Humidity: only switch off if blackout screen is used 
        (gl.d.isDaySmooth + (1-gl.d.isDaySmooth).* ... % Blackout sceen is only used at night 
            max(proportionalControl(gl.a.rhIn, gl.p.rhMax+gl.p.blScrExtraRh, -0.5, 0, 1),... % Switch lamp off if too humid inside
                        1-gl.a.ventCold))); 
                        % if ventCold is 0 it's too cold inside to ventilate, 
                        % better to raise the RH by heating. 
                        % So don't open the blackout screen and 
                        % don't stop illuminating in this case. 
    
    %% Convection and conduction - Section 5.3 [1]
    
    % density of air as it depends on pressure and temperature, see
    % https://en.wikipedia.org/wiki/Density_of_air
    addAux(gl, 'rhoTop', p.mAir*p.pressure./((x.tTop+273.15)*p.R));
    addAux(gl, 'rhoAir', p.mAir*p.pressure./((x.tAir+273.15)*p.R));
    
    % note a mistake in [1] - says rhoAirMean is the mean density "of the
    % greenhouse and the outdoor air". See [4], where rhoMean is "the mean
    % density of air beneath and above the screen".
    addAux(gl, 'rhoAirMean', 0.5*(gl.a.rhoTop+gl.a.rhoAir));
    
	% Air flux through the thermal screen [m s^{-1}]
	% Equation 40 [1], Equation A36 [5]
    % There is a mistake in [1], see equation 5.68, pg. 91, [4]
    % tOut, rhoOut, should be tTop, rhoTop
    % There is also a mistake in [4], whenever sqrt is taken, abs should be included
    addAux(gl, 'fThScr', u.thScr*p.kThScr.*(abs((x.tAir-x.tTop)).^0.66) + ... 
        ((1-u.thScr)./gl.a.rhoAirMean).*sqrt(0.5*gl.a.rhoAirMean.*(1-u.thScr).*p.g.*abs(gl.a.rhoAir-gl.a.rhoTop)));
    
    % Air flux through the blackout screen [m s^{-1}]
	% Equation A37 [5]
    addAux(gl, 'fBlScr', u.blScr*p.kBlScr.*(abs((x.tAir-x.tTop)).^0.66) + ... 
        ((1-u.blScr)./gl.a.rhoAirMean).*sqrt(0.5*gl.a.rhoAirMean.*(1-u.blScr).*p.g.*abs(gl.a.rhoAir-gl.a.rhoTop)));
    
    % Air flux through the screens [m s^{-1}]
	% Equation A38 [5]
    addAux(gl, 'fScr', min(gl.a.fThScr,gl.a.fBlScr));
    
	%% Convective and conductive heat fluxes [W m^{-2}]
	% Table 4 [1]
    
    % Forced ventilation (doesn't exist in current gh)
    addAux(gl, 'fVentForced', DynamicElement('0', 0));
    
	% Between canopy and air in main compartment [W m^{-2}]
    addAux(gl, 'hCanAir', sensible(2*p.alfaLeafAir*gl.a.lai, x.tCan, x.tAir));
	
	% Between air in main compartment and floor [W m^{-2}]
    addAux(gl, 'hAirFlr', sensible(...
        ifElse('x.tFlr>x.tAir',1.7*nthroot(abs(x.tFlr-x.tAir),3),1.3*nthroot(abs(x.tAir-x.tFlr),4)),...
        x.tAir,x.tFlr));
		
	% Between air in main compartment and thermal screen [W m^{-2}]
    addAux(gl, 'hAirThScr', sensible(1.7.*u.thScr.*nthroot(abs(x.tAir-x.tThScr),3),...
        x.tAir,x.tThScr));
    
	% Between air in main compartment and blackout screen [W m^{-2}]
	% Equations A28, A32 [5]
    addAux(gl, 'hAirBlScr', sensible(1.7.*u.blScr.*nthroot(abs(x.tAir-x.tBlScr),3),...
        x.tAir,x.tBlScr));
		
	% Between air in main compartment and outside air [W m^{-2}]
    addAux(gl, 'hAirOut', sensible(p.rhoAir*p.cPAir*(gl.a.fVentSide+gl.a.fVentForced),...
        x.tAir, d.tOut));
		
	% Between air in main and top compartment [W m^{-2}]
    addAux(gl, 'hAirTop', sensible(p.rhoAir*p.cPAir*gl.a.fScr, x.tAir, x.tTop));
	
	% Between thermal screen and top compartment [W m^{-2}]
    addAux(gl, 'hThScrTop', sensible(1.7.*u.thScr.*nthroot(abs(x.tThScr-x.tTop),3),...
        x.tThScr,x.tTop));
    
    % Between blackout screen and top compartment [W m^{-2}]
    addAux(gl, 'hBlScrTop', sensible(1.7.*u.blScr.*nthroot(abs(x.tBlScr-x.tTop),3),...
        x.tBlScr,x.tTop));
		
	% Between top compartment and cover [W m^{-2}]
    addAux(gl, 'hTopCovIn', sensible(p.cHecIn*nthroot(abs(x.tTop-x.tCovIn),3)*p.aCov/p.aFlr,...
        x.tTop,x.tCovIn));
		
	% Between top compartment and outside air [W m^{-2}]
    addAux(gl, 'hTopOut', sensible(p.rhoAir*p.cPAir*gl.a.fVentRoof, x.tTop, d.tOut));
	
	% Between cover and outside air [W m^{-2}]
    addAux(gl, 'hCovEOut', sensible(...
        p.aCov/p.aFlr*(p.cHecOut1+p.cHecOut2*d.wind.^p.cHecOut3),...
        x.tCovE, d.tOut));
	
	% Between pipes and air in main compartment [W m^{-2}]
    addAux(gl, 'hPipeAir', sensible(...
        1.99*pi*p.phiPipeE*p.lPipe*(abs(x.tPipe-x.tAir)).^0.32,...
        x.tPipe, x.tAir));
		
	% Between floor and soil layer 1 [W m^{-2}]
    addAux(gl, 'hFlrSo1', sensible(...
        2/(p.hFlr/p.lambdaFlr+p.hSo1/p.lambdaSo),...
        x.tFlr, x.tSo1));
	
	% Between soil layers 1 and 2 [W m^{-2}]
    addAux(gl, 'hSo1So2', sensible(2*p.lambdaSo/(p.hSo1+p.hSo2),...
        x.tSo1, x.tSo2));
    
	% Between soil layers 2 and 3 [W m^{-2}]
    addAux(gl, 'hSo2So3', sensible(2*p.lambdaSo/(p.hSo2+p.hSo3), x.tSo2, x.tSo3));
    
	% Between soil layers 3 and 4 [W m^{-2}]
    addAux(gl, 'hSo3So4', sensible(2*p.lambdaSo/(p.hSo3+p.hSo4), x.tSo3, x.tSo4));
    
	% Between soil layers 4 and 5 [W m^{-2}]
    addAux(gl, 'hSo4So5', sensible(2*p.lambdaSo/(p.hSo4+p.hSo5), x.tSo4, x.tSo5));
    
    % Between soil layer 5 and the external soil temperature [W m^{-2}]
    % See Equations 4 and 77 [1]
    addAux(gl, 'hSo5SoOut', sensible(2*p.lambdaSo/(p.hSo5+p.hSoOut), x.tSo5, d.tSoOut));
    
    % Conductive heat flux through the lumped cover [W K^{-1} m^{-2}]
    % See comment after Equation 18 [1]
    addAux(gl, 'hCovInCovE', sensible(...
        1./(p.hRf/p.lambdaRf+u.shScrPer*p.hShScrPer/p.lambdaShScrPer),...
        x.tCovIn, x.tCovE));

    % Between lamps and air in main compartment [W m^{-2}]
    % Equation A29 [5]
    addAux(gl, 'hLampAir', sensible(p.cHecLampAir, x.tLamp, x.tAir));
    
    % Between grow pipes and air in main compartment [W m^{-2}]
    % Equations A31, A33 [5]
    addAux(gl, 'hGroPipeAir', sensible(...
        1.99*pi*p.phiGroPipeE*p.lGroPipe*(abs(x.tGroPipe-x.tAir)).^0.32, ...
        x.tGroPipe, x.tAir));
        
   % Between interlights and air in main compartment [W m^{-2}]
   % Equation A30 [5]
    addAux(gl, 'hIntLampAir', sensible(p.cHecIntLampAir, x.tIntLamp, x.tAir));
  
    %% Canopy transpiration - Section 8 [1]
    
	% Smooth switch between day and night [-]
	% Equation 50 [1]
    addAux(gl, 'sRs', 1./(1+exp(p.sRs.*(gl.a.rCan-p.rCanSp))));
        
	% Parameter for co2 influence on stomatal resistance [ppm{CO2}^{-2}]
	% Equation 51 [1]
    addAux(gl, 'cEvap3', p.cEvap3Night*(1-gl.a.sRs)+p.cEvap3Day*gl.a.sRs);
		
	% Parameter for vapor pressure influence on stomatal resistance [Pa^{-2}]
    addAux(gl, 'cEvap4', p.cEvap4Night*(1-gl.a.sRs)+p.cEvap4Day*gl.a.sRs);
    
	% Radiation influence on stomatal resistance [-]
	% Equation 49 [1]
    addAux(gl, 'rfRCan', (gl.a.rCan+p.cEvap1)./(gl.a.rCan+p.cEvap2));
    
	% CO2 influence on stomatal resistance [-]
	% Equation 49 [1]
    addAux(gl, 'rfCo2', min(1.5,1+gl.a.cEvap3.*(p.etaMgPpm*x.co2Air-200).^2));
        % perhpas replace p.etaMgPpm*x.co2Air with a.co2InPpm
    
	% Vapor pressure influence on stomatal resistance [-]
	% Equation 49 [1]
    addAux(gl, 'rfVp', min(5.8, 1+gl.a.cEvap4.*(satVp(x.tCan)-x.vpAir).^2));
    
	% Stomatal resistance [s m^{-1}]
	% Equation 48 [1]
    addAux(gl, 'rS', p.rSMin.*gl.a.rfRCan.*gl.a.rfCo2.*gl.a.rfVp);
    
	% Vapor transfer coefficient of canopy transpiration [kg m^{-2} Pa^{-1} s^{-1}]
	% Equation 47 [1]
    addAux(gl, 'vecCanAir', 2*p.rhoAir*p.cPAir*gl.a.lai./...
        (p.L*p.gamma*(p.rB+gl.a.rS)));
    
	% Canopy transpiration [kg m^{-2} s^{-1}]
	% Equation 46 [1]
    addAux(gl, 'mvCanAir', (satVp(x.tCan)-x.vpAir).*gl.a.vecCanAir); 
        
	%% Vapor fluxes  - Section 6 [1]
	
	% Vapor fluxes currently not included in the model - set at 0
    addAux(gl, 'mvPadAir', DynamicElement('0', 0));
    addAux(gl, 'mvFogAir', DynamicElement('0', 0));
    addAux(gl, 'mvBlowAir', DynamicElement('0', 0));
    addAux(gl, 'mvAirOutPad', DynamicElement('0', 0));
    
    
    % Condensation from main compartment on thermal screen [kg m^{-2} s^{-1}]
	% Table 4 [1], Equation 42 [1]
    addAux(gl, 'mvAirThScr', cond(1.7*u.thScr.*nthroot(abs(x.tAir-x.tThScr),3), ...
        x.vpAir, satVp(x.tThScr)));
    
    % Condensation from main compartment on blackout screen [kg m^{-2} s^{-1}]
    % Equatio A39 [5], Equation 7.39 [7]
    addAux(gl, 'mvAirBlScr', cond(1.7*u.blScr.*nthroot(abs(x.tAir-x.tBlScr),3), ...
        x.vpAir, satVp(x.tBlScr)));
    
    % Condensation from top compartment to cover [kg m^{-2} s^{-1}]
	% Table 4 [1]
    addAux(gl, 'mvTopCovIn', cond(p.cHecIn*nthroot(abs(x.tTop-x.tCovIn),3)*p.aCov/p.aFlr,...
        x.vpTop, satVp(x.tCovIn)));
    
	% Vapor flux from main to top compartment [kg m^{-2} s^{-1}]
    addAux(gl, 'mvAirTop', airMv(gl.a.fScr, x.vpAir, x.vpTop, x.tAir, x.tTop));
	
	% Vapor flux from top compartment to outside [kg  m^{-2} s^{-1}]
    addAux(gl, 'mvTopOut', airMv(gl.a.fVentRoof, x.vpTop, d.vpOut, x.tTop, d.tOut));
	
	% Vapor flux from main compartment to outside [kg m^{-2} s^{-1}]
    addAux(gl, 'mvAirOut', airMv(gl.a.fVentSide+gl.a.fVentForced, x.vpAir, ...
        d.vpOut, x.tAir, d.tOut));
    
    %% Latent heat fluxes - Section 5.4 [1]
	% Equation 41 [1]
	
	% Latent heat flux by transpiration [W m^{-2}]
    addAux(gl, 'lCanAir', p.L*gl.a.mvCanAir);
	
	% Latent heat flux by condensation on thermal screen [W m^{-2}]
    addAux(gl, 'lAirThScr', p.L*gl.a.mvAirThScr);
    
    % Latent heat flux by condensation on blackout screen [W m^{-2}]
    addAux(gl, 'lAirBlScr', p.L*gl.a.mvAirBlScr);
	
	% Latent heat flux by condensation on cover [W m^{-2}]
    addAux(gl, 'lTopCovIn', p.L*gl.a.mvTopCovIn);
    
    %% Canopy photosynthesis - Section 4.1 [2]
	
	% PAR absorbed by the canopy [umol{photons} m^{-2} s^{-1}]
	% Equation 17 [2]
    addAux(gl, 'parCan', p.zetaLampPar*gl.a.rParLampCan + p.parJtoUmolSun*gl.a.rParSunCan + ...
        p.zetaIntLampPar*gl.a.rParIntLampCan);
    
	% Maximum rate of electron transport rate at 25C [umol{e-} m^{-2} s^{-1}]
	% Equation 16 [2]
    addAux(gl, 'j25CanMax', gl.a.lai*p.j25LeafMax);
    
	% CO2 compensation point [ppm]
	% Equation 23 [2]
    addAux(gl, 'gamma', divNoBracks(p.j25LeafMax,(gl.a.j25CanMax)*1).*p.cGamma.*x.tCan + ...
        20*p.cGamma.*(1-divNoBracks(p.j25LeafMax,(gl.a.j25CanMax)*1)));
    
	% CO2 concentration in the stomata [ppm]
	% Equation 21 [2]
    addAux(gl, 'co2Stom', p.etaCo2AirStom*gl.a.co2InPpm);
    
	% Potential rate of electron transport [umol{e-} m^{-2} s^{-1}]
	% Equation 15 [2]
	% Note that R in [2] is 8.314 and R in [1] is 8314
    addAux(gl, 'jPot', gl.a.j25CanMax.*exp(p.eJ*(x.tCan+273.15-p.t25k)./(1e-3*p.R*(x.tCan+273.15)*p.t25k)).*...
        (1+exp((p.S*p.t25k-p.H)./(1e-3*p.R*p.t25k)))./...
        (1+exp((p.S*(x.tCan+273.15)-p.H)./(1e-3*p.R*(x.tCan+273.15)))));
    
	% Electron transport rate [umol{e-} m^{-2} s^{-1}]
	% Equation 14 [2]
    addAux(gl, 'j', (1/(2*p.theta))*(gl.a.jPot+p.alpha*gl.a.parCan-...
        sqrt((gl.a.jPot+p.alpha*gl.a.parCan).^2-4*p.theta*gl.a.jPot.*p.alpha.*gl.a.parCan)));
    
	% Photosynthesis rate at canopy level [umol{co2} m^{-2} s^{-1}]
	% Equation 12 [2]
    addAux(gl, 'p', gl.a.j.*(gl.a.co2Stom-gl.a.gamma)./(4*(gl.a.co2Stom+2*gl.a.gamma)));
	
	% Photrespiration [umol{co2} m^{-2} s^{-1}]
	% Equation 13 [2]
    addAux(gl, 'r', gl.a.p.*gl.a.gamma./gl.a.co2Stom);
    
	% Inhibition due to full carbohydrates buffer [-]
    % Equation 11, Equation B.1, Table 5 [2]
    addAux(gl, 'hAirBuf', 1./(1+exp(5e-4*(x.cBuf-p.cBufMax))));
    
	% Net photosynthesis [mg{CH2O} m^{-2} s^{-1}]
	% Equation 10 [2]
    addAux(gl, 'mcAirBuf', p.mCh2o*gl.a.hAirBuf.*(gl.a.p-gl.a.r));
    
    %% Carbohydrate buffer
    % Temperature effect on structural carbon flow to organs
    % Equation 28 [2]
    addAux(gl, 'gTCan24', 0.047*x.tCan24+0.06);
    
    % Inhibition of carbohydrate flow to the organs
    % Equation B.3 [2]
    addAux(gl, 'hTCan24', 1./(1+exp(-1.1587*(x.tCan24-p.tCan24Min))).* ...
        1./(1+exp(1.3904*(x.tCan24-p.tCan24Max))));
    
    % Inhibition of carbohydrate flow to the fruit
    % Equation B.3 [2]
    addAux(gl, 'hTCan', 1./(1+exp(-0.869*(x.tCan-p.tCanMin))).* ...
        1./(1+exp(0.5793*(x.tCan-p.tCanMax))));
    
    % Inhibition due to development stage 
    % Equation B.6 [2]
    addAux(gl, 'hTCanSum', 0.5*(x.tCanSum/p.tEndSum+...
        sqrt((x.tCanSum./p.tEndSum).^2+1e-4)) - ...
        0.5*((x.tCanSum-p.tEndSum)./p.tEndSum+...
        sqrt(((x.tCanSum-p.tEndSum)/p.tEndSum).^2 + 1e-4)));
    
    % Inhibition due to insufficient carbohydrates in the buffer [-]
    % Equation 26 [2]
    addAux(gl, 'hBufOrg', 1./(1+exp(-5e-3*(x.cBuf-p.cBufMin))));
    
    % Carboyhdrate flow from buffer to leaves [mg{CH2O} m^{2} s^{-1}]
    % Equation 25 [2]
    addAux(gl, 'mcBufLeaf', gl.a.hBufOrg.*gl.a.hTCan24.*gl.a.gTCan24.*gl.p.rgLeaf);
    
    % Carboyhdrate flow from buffer to stem [mg{CH2O} m^{2} s^{-1}]
    % Equation 25 [2]
    addAux(gl, 'mcBufStem', gl.a.hBufOrg.*gl.a.hTCan24.*gl.a.gTCan24.*gl.p.rgStem);
    
    % Carboyhdrate flow from buffer to fruit [mg{CH2O} m^{2} s^{-1}]
    % Equation 24 [2]
    addAux(gl, 'mcBufFruit', gl.a.hBufOrg.*...
        gl.a.hTCan.*gl.a.hTCan24.*gl.a.hTCanSum.*gl.a.gTCan24.*gl.p.rgFruit);
    
    %% Growth and maintenance respiration - Section 4.4 [2]
	
	% Growth respiration [mg{CH2O} m^{-2] s^{-1}]
	% Equations 43-44 [2]
    addAux(gl, 'mcBufAir', p.cLeafG*gl.a.mcBufLeaf + p.cStemG*gl.a.mcBufStem ...
        +p.cFruitG*gl.a.mcBufFruit);
    
	% Leaf maintenance respiration [mg{CH2O} m^{-2} s^{-1}]
	% Equation 45 [2]
    addAux(gl, 'mcLeafAir', (1-exp(-p.cRgr*p.rgr)).*p.q10m.^(0.1*(x.tCan24-25)).* ...
        x.cLeaf*p.cLeafM);
    
    % Stem maintenance respiration [mg{CH2O} m^{-2} s^{-1}]
	% Equation 45 [2]
    addAux(gl, 'mcStemAir', (1-exp(-p.cRgr*p.rgr)).*p.q10m.^(0.1*(x.tCan24-25)).* ...
        x.cStem*p.cStemM);
    
    % Fruit maintenance respiration [mg{CH2O} m^{-2} s^{-1}]
	% Equation 45 [2]
    addAux(gl, 'mcFruitAir', (1-exp(-p.cRgr*p.rgr)).*p.q10m.^(0.1*(x.tCan24-25)).* ...
        x.cFruit*p.cFruitM);
    
    % Total maintenance respiration [mg{CH2O} m^{-2} s^{-1}]
	% Equation 45 [2]
    addAux(gl, 'mcOrgAir', gl.a.mcLeafAir+gl.a.mcStemAir+gl.a.mcFruitAir);
    
    %% Leaf pruning and fruit harvest
    % A new smoothing function has been applied here to avoid stiffness
    % Leaf pruning [mg{CH2O} m^{-2] s^{-1}]
    % Equation B.5 [2]
    addAux(gl, 'mcLeafHar', smoothHar(x.cLeaf, p.cLeafMax, 1e4, 5e4));
    
    % Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
	% Equation A45 [5], Equation 7.45 [7]
    addAux(gl, 'mcFruitHar', smoothHar(x.cFruit, p.cFruitMax, 1e4, 5e4));
    
	%% CO2 Fluxes - Section 7 [1]
	
    % Net crop assimilation [mg{CO2} m^{-2} s^{-1}]
    % It is assumed that for every mol of CH2O in net assimilation, a mol
    % of CO2 is taken from the air, thus the conversion uses molar masses
    addAux(gl, 'mcAirCan', (p.mCo2/p.mCh2o)*(gl.a.mcAirBuf-gl.a.mcBufAir-gl.a.mcOrgAir));
    
    % Other CO2 flows [mg{CO2} m^{-2} s^{-1}]
	% Equation 45 [1]
	
	% From main to top compartment 
    addAux(gl, 'mcAirTop', airMc(gl.a.fScr, x.co2Air, x.co2Top));
	
	% From top compartment outside
    addAux(gl, 'mcTopOut', airMc(gl.a.fVentRoof, x.co2Top, d.co2Out));
    
	% From main compartment outside
	addAux(gl, 'mcAirOut', airMc(gl.a.fVentSide+gl.a.fVentForced, x.co2Air, d.co2Out));
    
    %% Heat from boiler - Section 9.2 [1]
	
	% Heat from boiler to pipe rails [W m^{-2}]
	% Equation 55 [1]
    addAux(gl, 'hBoilPipe', u.boil*p.pBoil/p.aFlr);
    
    % Heat from boiler to grow pipes [W m^{-2}]
    addAux(gl, 'hBoilGroPipe', u.boilGro*p.pBoilGro/p.aFlr);
    
    %% External CO2 source - Section 9.9 [1]
	
	% CO2 injection [mg m^{-2} s^{-1}]
	% Equation 76 [1]
    addAux(gl, 'mcExtAir', u.extCo2*p.phiExtCo2/p.aFlr);
    
    %% Objects not currently included in the model
    addAux(gl, 'mcBlowAir', DynamicElement('0',0));
    addAux(gl, 'mcPadAir', DynamicElement('0',0));
    addAux(gl, 'hPadAir', DynamicElement('0',0));
    addAux(gl, 'hPasAir', DynamicElement('0',0));
    addAux(gl, 'hBlowAir', DynamicElement('0',0));
    addAux(gl, 'hAirPadOut', DynamicElement('0',0));
    addAux(gl, 'hAirOutPad', DynamicElement('0',0));
    addAux(gl, 'lAirFog', DynamicElement('0',0));
    addAux(gl, 'hIndPipe', DynamicElement('0',0));
    addAux(gl, 'hGeoPipe', DynamicElement('0',0));
    
    %% Lamp cooling
	% Equation A34 [5], Equation 7.34 [7]
    addAux(gl, 'hLampCool', p.etaLampCool*gl.a.qLampIn);
    
    %% Heat harvesting, mechanical cooling and dehumidification
    % By default there is no mechanical cooling or heat harvesting
    % see addHeatHarvesting.m for mechanical cooling and heat harvesting
    addAux(gl, 'hecMechAir', '0');
    addAux(gl, 'hAirMech', '0');
    addAux(gl, 'mvAirMech', '0');
    addAux(gl, 'lAirMech', '0');
    addAux(gl, 'hBufHotPipe', '0');
end

function de = tau12(tau1, tau2, ~, rho1Dn, rho2Up, ~)
% Transmission coefficient of a double layer [-]
% Equation 14 [1], Equation A4 [5]
    de = tau1.*tau2./(1-rho1Dn.*rho2Up);    
end

function de = rhoUp(tau1, ~, rho1Up, rho1Dn, rho2Up, ~)
% Reflection coefficient of the top layer of a double layer [-]
% Equation 15 [1], Equation A5 [5]
    de = rho1Up + (tau1.^2.*rho2Up)./(1-rho1Dn.*rho2Up);
end

function de = rhoDn(~, tau2, ~, rho1Dn, rho2Up, rho2Dn)
% Reflection coefficient of the top layer of a double layer [-]
% Equation 15 [1], Equation A6 [5]
    de = rho2Dn + (tau2.^2.*rho1Dn)./(1-rho1Dn.*rho2Up);
end

function de = fir(a1,eps1,eps2,f12,t1,t2)
% Net far infrared flux from 1 to 2 [W m^{-2}]
% Equation 37 [1]
    
    sigma = 5.67e-8;
    kelvin = 273.15;
    
    de = a1.*eps1.*eps2.*f12*sigma.*...
         ( (t1+kelvin).^4 - (t2+kelvin).^4 );
end

function de = sensible(hec, t1, t2)
% Sensible heat flux (convection or conduction) [W m^{-2}]
% Equation 39 [1]

    de = abs(hec).*(t1-t2);
end

function de = airMv(f12, vp1, vp2, t1, t2)
% Vapor flux accompanying an air flux [kg m^{-2} s^{-1}]
% Equation 44 [1]

    mWater = 18;
    r = 8.314e3;
	kelvin = 273.15;
    
    de = (mWater/r)*abs(f12).*(vp1./(t1+kelvin)-vp2./(t2+kelvin));
end

function de = airMc(f12, c1, c2)
% Co2 flux accompanying an air flux [kg m^{-2} s^{-1}]
% Equation 45 [1]
    
    de = abs(f12).*(c1-c2);
end

function de = smoothHar(processVar, cutOff, smooth, maxRate)
% Define a smooth function for harvesting (leaves, fruit, etc)
% processVar - the DynamicElement to be controlled
% cutoff     - the value at which the processVar should be harvested
% smooth     - smoothing factor. The rate will go from 0 to max at
%              a range with approximately this width
% maxRate    - the maximum harvest rate

    de = maxRate./(1+exp(-(processVar-cutOff)*2*log(100)./smooth));

end