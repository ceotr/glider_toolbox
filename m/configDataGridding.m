function gridding_options = configDataGridding()
%CONFIGDATAGRIDDING  Configure glider data gridding.
%
%  GRIDDING_OPTIONS = CONFIGDATAGRIDDING() should return a struct setting the 
%  options for glider data gridding as needed by the function GRIDGLIDERDATA.
%
%  Examples:
%    gridding_options = configDataGridding()
%
%  See also:
%    GRIDGLIDERDATA
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

%  Copyright (C) 2013
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(0, 0, nargin, 'struct'));

  gridding_options = struct();

  gridding_options.profile = {'profile_index'};
  
  gridding_options.time = {'time'};

  gridding_options.position(1).latitude = 'latitude';
  gridding_options.position(1).longitude = 'longitude';

  gridding_options.depth = {'depth'};

  gridding_options.depth_step = 1;

  gridding_options.variables = { 
    'conductivity'
    'temperature'
    'pressure'
    'chlorophyll'
    'turbidity'
    'oxygen_concentration'
    'oxygen_saturation'
    'conductivity_corrected_thermal'
    'temperature_corrected_thermal'
    'salinity'
    'density'
    'salinity_corrected_thermal'
    'density_corrected_thermal'
  };

end
