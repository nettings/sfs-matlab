function [x,y,P] = wave_field_mono_point_source(X,Y,xs,ys,f,conf)
%WAVE_FIELD_MONO_POINT_SOURCE simulates a wave field for a point source
%   Usage: [x,y,P] = wave_field_mono_point_source(X,Y,xs,ys,f,conf)
%          [x,y,P] = wave_field_mono_point_source(X,Y,xs,ys,f)
%
%   Input parameters:
%       X           - length of the X axis (m); single value or [xmin,xmax]
%       Y           - length of the Y axis (m); single value or [ymin,ymax]
%       xs          - x position of point source (m)
%       ys          - y position of point source (m)
%       f           - monochromatic frequency (Hz)
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       x           - corresponding x axis
%       y           - corresponding y axis
%       P           - Simulated wave field
%
%   WAVE_FIELD_MONO_POINT_SOURCE(X,Y,xs,ys,f,conf) simulates a wave 
%   field of a point source positioned at xs,ys. 
%   To plot the result use plot_wavefield(x,y,P).
%
%   References:
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: plot_wavefield, wave_field_imp_point_source 

% AUTHOR: Hagen Wierstorf


%% ===== Checking of input  parameters ==================================
nargmin = 5;
nargmax = 6;
error(nargchk(nargmin,nargmax,nargin));
isargvector(X,Y);
isargscalar(xs,ys);
isargpositivescalar(f);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end


%% ===== Configuration ==================================================
% Reference position for the amplitude (correct reproduction of amplitude
% at y = yref).
yref = conf.yref;
% xy resolution
xysamples = conf.xysamples;
% Plotting result
useplot = conf.useplot;


%% ===== Variables ======================================================
% Setting x- and y-axis
[X,Y] = setting_xy_ranges(X,Y,conf);
% Geometry
x = linspace(X(1),X(2),xysamples);
y = linspace(Y(1),Y(2),xysamples);


%% ===== Computation ====================================================
% Check if yref is in the given y space
if yref>max(y)
    error('%s: yref has be smaller than max(y) = %.2f',...
        upper(mfilename),max(y));
end
% Create a x-y-grid to avoid a loop
[X,Y] = meshgrid(x,y);
% Source model for a point source G(x,omega)
P = point_source(X,Y,xs,ys,f);
% Scale signal (at yref)
P = norm_wave_field(P,x,y,conf);


% ===== Plotting =========================================================
if(useplot)
    plot_wavefield(x,y,P,conf);
end