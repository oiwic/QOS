function [varargout] = OneMeasComplex_2DMap_Phase_X(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
   % plot function for data:
   % OneMeasComplex_2DMap_Phase plots 3D spectrum data to a 2D map with color scale
   % for the third dimension, subtract background(linear, global background, not individual slice) along the x axes(the second sweep).
   % application: spectrum
   % varargout: data parsed from QES format to simple x, y and z,
   % varargout{1} is x, varargout{2} is y, varargout{3} is z, if
   % not exist in data, an empty matrix is returned, for example,
   % varargout{3} will be an empty matrix if there is no z data.
   
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    x = [];
    y = [];
    z = [];
    if isempty(Data) || isempty(Data{1}) || isempty(SweepVals) ||...
            (iscell(Data{1}) && isempty(Data{1}{1}))
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = z;
        plot(AX,NaN,NaN);
        XLIM = get(AX,'XLim');
        YLIM = get(AX,'YLim');
        text('Parent',AX,'Position',[mean(XLIM),mean(YLIM)],'String','Empty data',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
        return;
    end
    if length(Data) > 1
        error('OneMeasComplex_* only handles data of experiments with one measurement.');
    end

    x = SweepVals{1}{MainParam(1)}(:)';
    y = SweepVals{2}{MainParam(2)}(:)';
    Data = Data{1};
    if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
        sz = size(Data);
        for ii = 1:sz(1)
            for jj = 1:sz(2)
                if isempty(Data{ii,jj})
                    Data{ii,jj} = NaN;
                end
            end
        end
        z = cell2mat(Data);
    else
        sz = size(Data);
        z = Data;
    end
    warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
%     for ii = 1:sz(2)
%         z_(:,ii) = unwrap(z_(:,ii));
%         z_(:,ii) = z_(:,ii) - polyval(polyfit(x', z_(:,ii), 1), x');
%     end
%     
    sz = size(z);
    z_ = angle(z);
    for uu = 1:2
        for ii = 1:sz(2)
            z_(:,ii) = unwrap(z_(:,ii));
            z_(:,ii) = z_(:,ii) - z_(1,ii);
        end
        xf =(0:(sz(1)-1)).';
        P = polyfit(xf,mean(z_,2),1);
        for ii = 1:sz(2)
            z_(:,ii) = z_(:,ii) - polyval(P,xf);
        end
    end
    warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
    imagesc(x,y,mod(z_,2*pi)','Parent',AX);
    set(AX,'YDir','normal');
    if nargin < 7
        IsPreview = false;
    end
    if ~IsPreview
        colormap(jet);
        colorbar('peer',AX);
        xlabel(AX,ParamNames{1}{MainParam(1)});
        ylabel(AX,ParamNames{2}{MainParam(2)});
    end
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end