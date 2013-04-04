<<<<<<< HEAD
function [x,y,P,win] = wave_field_mono_wfs_2d(X,Y,Z,xs,src,f,L,conf)
%WAVE_FIELD_MONO_WFS_25D simulates a wave field for 2D WFS
%
%   Usage: [x,y,P] = wave_field_mono_wfs_2d(X,Y,Z,xs,L,f,src,[conf])
=======
function [x,y,P,x0,win] = wave_field_mono_wfs_2d(X,Y,xs,src,f,L,conf)
%WAVE_FIELD_MONO_WFS_25D simulates a wave field for 2D WFS
%
%   Usage: [x,y,P,x0,win] = wave_field_mono_wfs_2d(X,Y,xs,L,f,src,[conf])
>>>>>>> driving_functions
%
%   Input parameters:
%       X           - [xmin,xmax]
%       Y           - [ymin,ymax]
%       Z           - [zmin,zmax]
%       xs          - position of point source (m)
%       src         - source type of the virtual source
%                         'pw' - plane wave (xs, ys are the direction of the
%                                plane wave in this case)
%                         'ps' - point source
%                         'fs' - focused source
%       f           - monochromatic frequency (Hz)
%       L           - array length (m)
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       x           - corresponding x axis
%       y           - corresponding y axis
%       P           - Simulated wave field
%       x0          - secondary sources
%       win         - tapering window
%
%   WAVE_FIELD_MONO_WFS_2D(X,Y,Z,xs,src,f,L,conf) simulates a wave
%   field of the given source type (src) using a WFS 2 dimensional driving
%   function in the temporal domain. This means by calculating the integral for
%   P with a summation.
%   To plot the result use plot_wavefield(x,y,z,P).
%
%   References:
%       Spors2009 - Physical and Perceptual Properties of Focused Sources in
%           Wave Field Synthesis (AES127)
%       Williams1999 - Fourier Acoustics (Academic Press)
%
%   see also: plot_wavefield, driving_function_mono_wfs_2d

%*****************************************************************************
% Copyright (c) 2010-2013 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013      Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************

% FIXME: this works only for a constant Z at the moment


%% ===== Checking of input  parameters ==================================
nargmin = 7;
nargmax = 8;
narginchk(nargmin,nargmax);
isargvector(X,Y,Z);
xs = position_vector(xs);
isargpositivescalar(L,f);
isargchar(src);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end


%% ===== Configuration ==================================================
xref = position_vector(conf.xref);
fs = conf.fs;
useplot = conf.useplot;


%% ===== Computation ====================================================
% Get secondary sources
x0 = secondary_source_positions(L,conf);
x0 = secondary_source_selection(x0,xs,src,xref);
% Generate tapering window
win = tapering_window(x0,conf);

% Get driving signals
D = driving_function_mono_wfs_2d(x0,xs,src,f,conf) .* win;

% disable plotting in order to integrate the tapering window
conf.useplot = 0;
% Calculate wave field
[x,y,z,P] = wave_field_mono(X,Y,Z,x0,'ls',D,f,conf);


%% ===== Plotting ========================================================
if useplot
    plot_wavefield(x,y,z,P,x0,win,conf);
end
