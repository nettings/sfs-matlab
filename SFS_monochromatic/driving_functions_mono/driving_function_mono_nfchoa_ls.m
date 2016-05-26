function D = driving_function_mono_nfchoa_ls(x0,xs,f,N,conf)
%DRIVING_FUNCTION_MONO_NFCHOA_LS returns the driving signal D for a line source
%in NFCHOA
%
%   Usage: D = driving_function_mono_nfchoa_ls(x0,xs,f,N,conf)
%
%   Input parameters:
%       x0          - position of the secondary sources / m [nx3]
%       xs          - position and orientation of virtual line source / m [nx3]
%                     or [nx6]
%       f           - frequency of the monochromatic source / Hz
%       N           - maximum order of spherical harmonics
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       D           - driving function signal [nx1]
%
%   DRIVING_FUNCTION_MONO_NFCHOA_LS(x0,xs,f,N,conf) returns NFCHOA driving
%   signals for the given secondary sources, the virtual line source position
%   and the frequency f.
%
%   References:
%       N. Hahn, S. Spors (2015) - "Sound Field Synthesis of Virtual Cylindrical
%       Waves Using Circular and Spherical Loudspeaker Arrays", in Proc. of
%       138th AES Convention, Paper 9324
%
%   See also: driving_function_mono_nfchoa, driving_function_imp_nfchoa_ls

%*****************************************************************************
% The MIT License (MIT)                                                      *
%                                                                            *
% Copyright (c) 2010-2016 SFS Toolbox Developers                             *
%                                                                            *
% Permission is hereby granted,  free of charge,  to any person  obtaining a *
% copy of this software and associated documentation files (the "Software"), *
% to deal in the Software without  restriction, including without limitation *
% the rights  to use, copy, modify, merge,  publish, distribute, sublicense, *
% and/or  sell copies of  the Software,  and to permit  persons to whom  the *
% Software is furnished to do so, subject to the following conditions:       *
%                                                                            *
% The above copyright notice and this permission notice shall be included in *
% all copies or substantial portions of the Software.                        *
%                                                                            *
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR *
% IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF MERCHANTABILITY, *
% FITNESS  FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT. IN NO EVENT SHALL *
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
% LIABILITY, WHETHER  IN AN  ACTION OF CONTRACT, TORT  OR OTHERWISE, ARISING *
% FROM,  OUT OF  OR IN  CONNECTION  WITH THE  SOFTWARE OR  THE USE  OR OTHER *
% DEALINGS IN THE SOFTWARE.                                                  *
%                                                                            *
% The SFS Toolbox  allows to simulate and  investigate sound field synthesis *
% methods like wave field synthesis or higher order ambisonics.              *
%                                                                            *
% http://sfstoolbox.org                                 sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 5;
nargmax = 5;
narginchk(nargmin,nargmax);
isargmatrix(x0,xs);
isargpositivescalar(f,N);
isargstruct(conf);


%% ===== Configuration ==================================================
xref = conf.xref;
c = conf.c;
dimension = conf.dimension;
driving_functions = conf.driving_functions;
X0 = conf.secondary_sources.center;


%% ===== Computation ====================================================
% Calculate the driving function in time-frequency domain
[xs,nxs] = get_position_and_orientation_ls(xs,conf);

% secondary source positions
x00 = bsxfun(@minus,x0,X0);
[phi0,rho0,~] = cart2pol(x00(:,1),x00(:,2),x00(:,3)); 

% line source position
[phi,rho,~] = cart2pol(xs(:,1),xs(:,2),xs(:,3));

% wave number
omega = 2*pi*f;
% initialize empty driving signal
D = zeros(size(x0,1),1);

if strcmp('2D',dimension)

    % === 2-Dimensional ==================================================

    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % 2D line source, (no reference yet)
        %
        %                      _N_       (2)
        %                1     \        Hm(w/c rho)
        % D(phi0,w) = -------- /__     ------------ e^(i m (phi0-phi))
        %             2pi rho0 m=-N      (2)
        %                               Hm(w/c rho0)
        %
        for m=-N:N
            D = D + (1/2/pi./rho0) .* besselh(m,2,omega/c*rho) ./ ...
                besselh(m,2,omega/c*rho0) .* exp(1i*m*(phi0-phi));
        end
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2D line source.'],upper(mfilename),driving_functions);
    end


elseif strcmp('2.5D',dimension)

    % === 2.5-Dimensional ================================================

    % Reference point
%     xref = repmat(xref,[size(x0,1) 1]);
    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % 2.5D line source, after Hahn(2015) Eq.(23)
        %
        %                   _N_              (2)
        %               1   \     i^(m-|m|) Hm(w/c r)
        % D(phi0,w) = ----- /__   -------------------- e^(im(phi0-phi))
        %              2r0  m=-N    w/c    (2)
        %                                 h|m|(w/c r0)
        %
        for m=-N:N
        D = D + 1/2./rho0 * 1i^(m-abs(m)) .* besselh(m,2,omega/c*rho) ...
            ./ (omega/c*sphbesselh(abs(m),2,omega/c*rho0)) .* exp(1i*m*(phi0-phi));
        end
    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 2.5D line source.'],upper(mfilename),driving_functions);
    end


elseif strcmp('3D',dimension)

    % === 3-Dimensional ==================================================
    % rotating xs and x00 by (-alphan,pi/2-betan)
    [alphan,betan,~] = cart2sph(nxs(1,1),nxs(1,2),nxs(1,3));
    R = rotation_matrix(alphan,3,'counterclockwise') ...
        * rotation_matrix(betan-pi/2,2,'counterclockwise');
    x00 = x00*R;
    xs = xs*R;
    [alpha0,beta0,r0] = cart2sph(x00(:,1),x00(:,2),x00(:,3));
    [alpha,~,~] = cart2sph(xs(:,1),xs(:,2),xs(:,3));


    if strcmp('default',driving_functions)
        % --- SFS Toolbox ------------------------------------------------
        % 3D line source, after Hahn(2015) Eq.(20)
        %
        %                   _N_  _n_           (2)
        %               1   \    \    i^(m-n) Hm(w/c r)     -m
        % D(phi0,w) = ----- /__  /__  -------------------- Yn(pi/2,alpha) ...
        %            2r0^2  n=0  m=-n  w/c     (2)
        %                                     hn(w/c r0)
        %               m
        %            x Yn(beta0,alpha0)
        %
        for n=-N:N
            for m=-n:n
                D = D + (1/2./r0)*(1i)^(m-n).*besselh(m,2,omega/c*rho) ...
                    .*conj(sphharmonics(n,m,0,alpha)) ...
                    ./(omega/c*sphbesselh(n,2,omega/c*r0)) ...
                    .* sphharmonics(n,m,beta0,alpha0);
                %D = D * sqrt(1i*omega/c); % equalization (optional)
            end
        end

    else
        error(['%s: %s, this type of driving function is not implemented ', ...
            'for a 3D line source.'],upper(mfilename),driving_functions);
    end

else
    error('%s: the dimension %s is unknown.',upper(mfilename),dimension);
end
