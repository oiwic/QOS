function varargout = spectroscopy111_zpa(varargin)
% spectroscopy111: qubit spectroscopy
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
% 
% <_o_> = spectroscopy111_zpa('biasQubit',_c&o_,'biasAmp',<[_f_]>,...
%       'driveQubit',_c&o_,'driveFreq',<[_f_]>,...
%       'readoutQubit',_c&o_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.spectroscopy111_zpa'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'driveFreq',[],'gui',false,'notes','','save',true});
[readoutQubit, biasQubit, driveQubit] = data_taking.public.util.getQubits(...
    args,{'readoutQubit','biasQubit','driveQubit'});
if isempty(args.driveFreq)
    args.driveFreq = driveQubit.f01-3*driveQubit.t_spcFWHM_est:...
        driveQubit.t_spcFWHM_est/10:driveQubit.f01+3*driveQubit.t_spcFWHM_est;
end

X = op.mwDrive4Spectrum(driveQubit);
X.Run();
R = measure.resonatorReadout_ss(readoutQubit);
R.delay = X.length;
R.state = 2;
Z = op.zBias4Spectrum(biasQubit);

x = expParam(Z,'amp');
x.name = [biasQubit.name,' z bias amplitude'];
x.callbacks ={@(x_) x_.expobj.Run()};
x.deferCallbacks = true;
y = expParam(X.mw_src{1},'frequency');
y.offset = -driveQubit.spc_sbFreq;
y.name = [driveQubit.name,' driving frequency (Hz)'];
y.auxpara = X;
y.callbacks ={@(x_)expParam.RunCallbacks(x),@(x_)x_.auxpara.Run()};

s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.driveFreq;
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s%s[%s]', biasQubit.name, driveQubit.name, readoutQubit.name);
if ~args.gui
    e.showctrlpanel = false;
    e.plotdata = false;
end
if ~args.save
    e.savedata = false;
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
e.Run();
varargout{1} = e;
end
