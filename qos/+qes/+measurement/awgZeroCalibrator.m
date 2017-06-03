classdef awgZeroCalibrator < qes.measurement.measurement
	% measure awg zero offset
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        showProcess@logical scalar = false
    end
    properties (SetAccess = private, GetAccess = private)
        awg
		chnl
        volt
    end
    methods
        function obj = awgZeroCalibrator(awgObj,awgchnls,voltM)
			if (~isa(awgObj,'qes.hwdriver.sync.awg') &&...
				~isa(awgObj,'qes.hwdriver.async.awg')) ||...
                ~isa(voltM,'qes.measurement.dcVoltage') ||...
				numel(awgchnls) ~= 1
				throw(MException('QOS_iqMixerCalibrator:InvalidInput','Invalud input arguments.'));
			end
            obj = obj@qes.measurement.measurement([]);
			obj.awg = awgObj;
			obj.chnl = awgchnls(1);
            voltM.datafcn = @abs;
            obj.volt = voltM;
            obj.numericscalardata = true;
        end
        function Run(obj)
			Run@qes.measurement.measurement(obj);
            I = qes.waveform.dc(10e3);
            I.awg = obj.awg;
            I.awgchnl = obj.chnl;
            p1 = qes.expParam(I,'dcval');
            p1.callbacks = {@(x_) obj.awg.StopContinuousWv(I), @(x_) I.SendWave(),...
					@(x_) obj.awg.RunContinuousWv(I)};
            f = qes.expFcn(p1,obj.volt);
            x = 0;
            precision = obj.awg.vpp/20;
            stopPrecision = obj.awg.vpp/1e5;
            if obj.showProcess
                h = qes.ui.qosFigure(sprintf('DAC Zeros Offset Calibration | DAC %s, channel %0.0f', obj.awg.name, obj.chnl),true);
                ax = axes('parent',h,'Box','on');
                hl = line(NaN,NaN);
                xlabel(ax,'DC waveform amplitude')
                ylabel(ax,'DAC Output Voltage(mV)');
            end
            x_ = [];
            y_ = [];
            while precision > stopPrecision
                l = f(x-precision);
                c = f(x);
                r = f(x+precision);
                dx = precision*qes.util.minPos(l, c, r);
                if abs(dx) < precision
                    precision = precision/2;
                end
                if obj.showProcess
                    x_ = [x_,x];
                    y_ = [y_,c];
                    try
                        set(hl,'XData',x_,'YData',y_*1e3);
                        drawnow;
                    catch % incase of figure being closed
                    end
                end
                x = x+dx;
            end
            if obj.showProcess
                try
                	title(ax,'Done.')
                catch
                end
            end
			obj.awg.StopContinuousWv(I);
            obj.data = x;
        end
    end
end