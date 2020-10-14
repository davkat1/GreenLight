function gl = createCropModel(indoor, startTime)
%CREATEGREENLIGHTMODEL Create a DynamicModel object based on the crop componenet of the GreenLight model
% The GreenLight model is based on the model by Vanthoor et al, with the addition
% of toplights, interlights, grow pipes, and a blackout screen.
%
% Literature used:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363-377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378-395 (2011).
% 	In particular note the electronic appendices of these two publications.
% These are also available in
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
%
% indoor is indoor climate, soretd as 
%   [time rad temp co2] 
%   where rad is W/m2 outside, temp is tCan, co2 is ppm
%
%   startTime       date and time of starting point (datetime)

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    if ~exist('indoor','var')
        indoor = [];
    end

    gl = DynamicModel();
    setGlParams(gl); % define parameters and nominal values based on the Vanthoor model
    setInput(gl, indoor);  % define and set inputs
    setGlTime(gl, startTime); % define time phase
    setStates(gl); % define states 
        
    setAux(gl); % define auxiliary states
    
    setOdes(gl); % define odes - must be done after the aux states and control rules are set
    setInit(gl, indoor); % set initial values for the states
    
end

function setInput(gl, indoor)
%SETGLINPUT Set inputs for a GreenLight crop model
%
% Function inputs:
% 	gl 					 A DynamicModel object representing the GreenLight model
% indoor is [time rad temp co2] where rad is W/m2 outside, temp is
% tCan, co2 is ppm
%
% The inputs are then converted and copied to the following fields:
%   d.iGlob                  Radiation from the sun [W m^{-2}]
%   d.tCan                   Canopy temperature [°C]
%   d.co2InPpm               CO2 concentration [ppm]

    % Global radiation [W m^{-2}]
    d.iGlob = DynamicElement('d.iGlob');
    
    % Crop temperature [°C]
    d.tCan = DynamicElement('d.tCan');
    
    % co2 concentration [mg m^{-3}]
    d.co2InPpm = DynamicElement('d.co2InPpm');
        
    time = indoor(:,1);
    d.iGlob.val = [time indoor(:,2)];
    d.tCan.val = [time indoor(:,3)];
    d.co2InPpm.val = [time indoor(:,4)];
	gl.d = d;
end

function setStates(gl)
%SETGLSTATES Set states for the GreenLight crop model

    x.tCan24 = DynamicElement('x.tCan24');
    
    % Time since beginning simulation [s]
    x.time = DynamicElement('x.time');
    
    %% Crop model    
    % Carbohydrates in buffer [mg{CH2O} m^{-2}]
    x.cBuf = DynamicElement('x.cBuf');
    
    % Carbohydrates in leaves [mg{CH2O} m^{-2}]
    x.cLeaf = DynamicElement('x.cLeaf');
    
    % Carbohydrates in stem [mg{CH2O} m^{-2}]
    x.cStem = DynamicElement('x.cStem');
    
    % Carbohydrates in fruit [mg{CH2O} m^{-2}]
    x.cFruit = DynamicElement('x.cFruit');
    
    % Crop development stage [°C day]
    x.tCanSum = DynamicElement('x.tCanSum');
	
	gl.x = x;
end

function setAux(gl)
%SETGLAUX Set auxiliary states for a GreenLight crop model
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
    
    % Leaf area index [m^2{leaf} m^{-2}]
    % Equation 5 [2]
    addAux(gl, 'lai', p.sla*x.cLeaf); 
    
    %% Global, PAR, and NIR heat fluxes - Section 5.1 [1]
    
    % PAR above the canopy from the sun [W m^{-2}]
    % Equation 27 [1]
    addAux(gl, 'rParGhSun', (1-p.etaGlobAir).*0.6.*p.etaGlobPar.*d.iGlob); 
    
    % PAR from the sun directly absorbed by the canopy [W m^{-2}]
    % Equation 26 [1]
    addAux(gl, 'rParSunCanDown', gl.a.rParGhSun.*(1-p.rhoCanPar).*(1-exp(-p.k1Par*gl.a.lai)));
    
    % PAR from the sun absorbed by the canopy after reflection from the floor [W m^{-2}]
    % Equation 28 [1]
    addAux(gl, 'rParSunFlrCanUp', mulNoBracks(gl.a.rParGhSun,exp(-p.k1Par*gl.a.lai)*p.rhoFlrPar* ...
        (1-p.rhoCanPar).*(1-exp(-p.k2Par*gl.a.lai))));
    
    % Total PAR from the sun absorbed by the canopy [W m^{-2}]
    % Equation 25 [1]
    addAux(gl, 'rParSunCan', gl.a.rParSunCanDown + gl.a.rParSunFlrCanUp);
    
    %% Canopy photosynthesis - Section 4.1 [2]
	
	% PAR absorbed by the canopy [umol{photons} m^{-2} s^{-1}]
	% Equation 17 [2]
    addAux(gl, 'parCan', p.parJtoUmolSun*gl.a.rParSunCan);
    
	% Maximum rate of electron transport rate at 25C [umol{e-} m^{-2} s^{-1}]
	% Equation 16 [2]
    addAux(gl, 'j25CanMax', gl.a.lai*p.j25LeafMax);
    
	% CO2 compensation point [ppm]
	% Equation 23 [2]
    addAux(gl, 'gamma', divNoBracks(p.j25LeafMax,(gl.a.j25CanMax)*1).*p.cGamma.*d.tCan + ...
        20*p.cGamma.*(1-divNoBracks(p.j25LeafMax,(gl.a.j25CanMax)*1)));
    
	% CO2 concentration in the stomata [ppm]
	% Equation 21 [2]
    addAux(gl, 'co2Stom', p.etaCo2AirStom*gl.d.co2InPpm);
    
	% Potential rate of electron transport [umol{e-} m^{-2} s^{-1}]
	% Equation 15 [2]
	% Note that R in [2] is 8.314 and R in [1] is 8314
    addAux(gl, 'jPot', gl.a.j25CanMax.*exp(p.eJ*(d.tCan+273.15-p.t25k)./(1e-3*p.R*(d.tCan+273.15)*p.t25k)).*...
        (1+exp((p.S*p.t25k-p.H)./(1e-3*p.R*p.t25k)))./...
        (1+exp((p.S*(d.tCan+273.15)-p.H)./(1e-3*p.R*(d.tCan+273.15)))));
    
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
    addAux(gl, 'hTCan', 1./(1+exp(-0.869*(d.tCan-p.tCanMin))).* ...
        1./(1+exp(0.5793*(d.tCan-p.tCanMax))));
    
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
    % Leaf pruning [mg{CH2O} m^{-2] s^{-1}]
    % Equation B.5
    addAux(gl, 'mcLeafHar', smoothHar(x.cLeaf, p.cLeafMax, 1e4, 5e4));
    
    % Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
    addAux(gl, 'mcFruitHar', smoothHar(x.cFruit, p.cFruitMax, 1e4, 5e4));
    
	%% CO2 Fluxes - Section 7 [1]
	
    % Net crop assimilation [mg{CO2} m^{-2} s^{-1}]
    % It is assumed that for every mol of CH2O in net assimilation, a mol
    % of CO2 is taken from the air, thus the conversion uses molar masses
    addAux(gl, 'mcAirCan', (p.mCo2/p.mCh2o)*(gl.a.mcAirBuf-gl.a.mcBufAir-gl.a.mcOrgAir));
    
    
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

function setOdes(gl)
%SETGLODES Define ODEs for the GreenLight crop model
%
% Based on the electronic appendices (the case of a Dutch greenhouse) of:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378–395 (2011).
% These are also available as Chapters 8 and 9, respecitvely, of
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
%
% Inputs:
%   gl    - a DynamicModel object to be used as a GreenLight model.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

	x = gl.x;
    p = gl.p;
    a = gl.a;
    u = gl.u;
    d = gl.d;
        
    %% Carbon balance
    
    
    % Date and time [datenum, days since 0-0-0000]
    setOde(gl, 'time', '1/86400');
        
    % Average canopy temperature in last 24 hours
    % Equation 9 [2]
    setOde(gl, 'tCan24', 1/86400*(d.tCan-x.tCan24));
       
    
    %% Crop model
    
    % Carbohydrates in buffer [mg{CH2O} m^{-2} s^{-1}]
    % Equation 1 [2]
    setOde(gl, 'cBuf', a.mcAirBuf-a.mcBufFruit-a.mcBufLeaf-a.mcBufStem-a.mcBufAir);
    
    % Carbohydrates in leaves [mg{CH2O} m^{-2} s^{-1}]
    % Equation 4 [2]
    setOde(gl, 'cLeaf', a.mcBufLeaf - a.mcLeafAir - a.mcLeafHar);
    
    % Carbohydrates in stem [mg{CH2O} m^{-2} s^{-1}]
    % Equation 6 [2]
    setOde(gl, 'cStem', a.mcBufStem - a.mcStemAir);
    
    % Carbohydrates in fruit [mg{CH2O} m^{-2} s^{-1}]
    % Equation 2 [2]
    setOde(gl, 'cFruit', a.mcBufFruit - a.mcFruitAir - a.mcFruitHar);
    
    % Crop development stage [°C day s^{-1}]
    % Equation 8 [2]
    setOde(gl, 'tCanSum', 1/86400*d.tCan);
        
end

function setInit(gl, indoor)
%SETGLINIT Set the initial values for the GreenLight crop model.
%
% Typical usage:
%   setGlInit(gl, indoor)
% Inputs:
%   gl - a DynamicModel element, with its parameters already set by using
%       setGlParams(m)
%   indoor is [time rad temp co2] where rad is W/m2 outside, temp is
%   tCan, co2 is ppm

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    x = gl.x;
    p = gl.p;
    d = gl.d;
       
    x.tCan24.val = indoor(1,3);
  
    %% crop model
    x.cBuf.val = 0;
    
    % start with 3.12 plants/m2, assume they are each 2 g = 6240 mg/m2.
    x.cLeaf.val = 0.7*6240;
    x.cStem.val = 0.25*6240;
    x.cFruit.val = 0.05*6240;
    
    x.tCanSum.val = 0;
    
    %% Time
    x.time.val = datenum(gl.t.label);
	
	gl.x = x;
end


