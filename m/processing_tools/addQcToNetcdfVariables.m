function out_struct = addQcToNetcdfVariables(variable_list)
%ADDQCTONETCDFVARIABLES  Adds QC structs for NetCDF generation.
%
%  Syntax:
%    OUT_STRUCT = ADDQCTONETCDFVARIABLES(VARIABLE_LIST)
%
%  Description:
%    Uses existing variable list from a configDTOutputNetCDF to add QC
%    structs to use the QC outputs for the netcdf generation.
%    Adds the string identifier QC_ and QC_Identifier_ to the variable
%    structs. Uses the long_name and standard_name inputs from the linked
%    variable list for clearness.
%
%  Notes:
%    Currently QC_Identifier_ disabled, since writing of cell arrays
%    (strings) into the NetCDF variables is not possible. 
%
%  Examples:
%    out_struct = addQcToNetcdfVariables(variable_list)
%
%  See also:
%    CONFIGDTOUTPUTNETCDFL1
%    CONFIGDTOUTPUTNETCDFL2
%    GENERATEOUTPUTNETCDF
%    COMBINEDATAANDQC
%
%  Authors:
%    Andreas Krietemeyer  <akrietemeyer@socib.es>

%  Copyright (C) 2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
%  <http://www.socib.es>
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

out_struct = struct();

names = fieldnames(variable_list);
for i=1:numel(names)
    %% Add original variable data
    out_struct.(names{i}) = variable_list.(names{i});
    %% Add _QC
    new_name = strcat('QC_', names{i});
    out_struct.(new_name).dimensions = variable_list.(names{i}).dimensions;
    out_struct.(new_name).attributes = struct();
    out_struct.(new_name).attributes(1,1).name = variable_list.(names{i}).attributes(1).name;
    out_struct.(new_name).attributes(1,1).value = strcat('QC of: ', variable_list.(names{i}).attributes(1).value);
    out_struct.(new_name).attributes(2,1).name = variable_list.(names{i}).attributes(2).name;
    out_struct.(new_name).attributes(2,1).value = strcat('QC of: ', variable_list.(names{i}).attributes(2).value);
    
    %% Add _QC_Identifier
%     out_struct.(strcat(names{i}, '_QC_Identifier')).dimensions = variable_list.(names{i}).dimensions;
%     out_struct.(strcat(names{i}, '_QC_Identifier')).attributes = struct();
%     out_struct.(strcat(names{i}, '_QC_Identifier')).attributes(1,1).name = variable_list.(names{i}).attributes(1).name;
%     out_struct.(strcat(names{i}, '_QC_Identifier')).attributes(1,1).value = strcat('QC_Identifier', variable_list.(names{i}).attributes(1).value);
%     out_struct.(strcat(names{i}, '_QC_Identifier')).attributes(2,1).name = variable_list.(names{i}).attributes(2).name;
%     out_struct.(strcat(names{i}, '_QC_Identifier')).attributes(2,1).value = strcat('QC_Identifier', variable_list.(names{i}).attributes(2).value);
end

end