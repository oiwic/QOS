function varargout = rabi_long1(varargin)
% rabi_long1: Rabi oscillation by changing the pi pulse length
% bias, drive and readout all one qubit
% 
% <_o_> = rabi_long1('qubit',_c&o_,'biasAmp',[_f_],'biasLonger',<_i_>,...
%       'xyDriveAmp',[_f_],'driveTyp',<_c_>,...
%       'dataTyp','_c_',...   % S21 or P
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
% GM, 2017/04/15


fcn_name = 'data_taking.public.xmon.rabi_long1'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasLonger',0,'driveTyp','X','dataTyp','P',...
    'r_avg',[],'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if ~isempty(args.r_avg) %add by GM, 20170414
    q.r_avg=args.r_avg;
end

q.spc_zLonger = args.biasLonger;
X = op.mwDrive4Spectrum(q);
X.amp = args.xyDriveAmp;
Z = op.zBias4Spectrum(q);
Z.amp = args.biasAmp;
function proc = procFactory(ln)
	X.ln = ln;
	Z.ln = ln+2*args.biasLonger;
    proc = X.*Z;
end

R = measure.resonatorReadout_ss(q);

switch args.dataTyp
    case 'P'
        R.state = 2;
        % pass
    case 'S21'
        R.swapdata = true;
        R.name = '|S21|';
        R.datafcn = @(x)mean(abs(x));
    otherwise
        throw(MException('QOS_rabi_long1',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end

y = expParam(@procFactory);
y.name = [q.name,' xy Drive Pulse Length'];
y.callbacks ={@(x_) x_.expobj.Run()};
y_s = expParam(R,'delay');
y_s.offset = 2*args.biasLonger;

s2 = sweep([y,y_s]);
s2.vals = {args.xyDriveLength,args.xyDriveLength};
e = experiment();
e.sweeps = s2;
e.measurements = R;
e.name = 'Rabi Long';
e.datafileprefix = sprintf('[%s]_rabi', q.name);

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