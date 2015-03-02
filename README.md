glider_toolbox
==============

The [glider toolbox][toolbox] is a set of MATLAB/Octave scripts and functions
developed at [SOCIB][socib] to manage the data collected by a glider fleet.
They cover the main stages of the data management process both in real 
time and delayed time mode: metadata aggregation, data download,
data processing, and generation of data products and figures.

  [toolbox]: http://github.com/socib/glider_toolbox
  [socib]: http://www.socib.es


Features
--------

The following features are already implemented in the glider toolbox:

  - Two main scripts to perform real time and delayed time data processing:
      - [`main_glider_data_processing_rt`][main_script_rt]
      - [`main_glider_data_processing_dt`][main_script_dt]
  - Support for different glider models:
      - Slocum G1 and G2
      - Seaglider
  - Deployment metadata gathering from virtually any database.
  - File retrieval from multiple dockservers/basestations for real time processing.
  - Improved Slocum raw data loading from ascii files (`.dba`).
  - Improved Seaglider raw data loading from ascii files (`.log` and `.eng`).
  - Data processing, including:
      - unit conversions
      - factory calibrations
      - corrections, with optional parameter estimation
      - derivations
  - Data interpolation over instantaneous regular vertical profiles.
  - Generation of figure products.
  - Generation of NetCDF data products. 
  - Configuration of every processing stage:
    - raw data retrieval, storage and load options
    - parameters for conversions, calibrations, derivations, 
      corrections, interpolations and filters
    - parameters for data gridding
    - customizable standard NetCDF product and figure outputs

The following features are planned:

  - automatic quality control of processed data.

  [main_script_rt]: http://www.socib.es/users/glider/glider_toolbox/doc/m/main_glider_data_processing_rt
  [main_script_dt]: http://www.socib.es/users/glider/glider_toolbox/doc/m/main_glider_data_processing_dt


Documentation
-------------

The toolbox is exhaustively self-documented using the standard documentation 
comment system. Hence the help pages are available using the documentation 
browser or the `help` command.

An automatically generated copy of the documentation is available [online][doc].
These pages are generated by [m2html][m2html], and may be built from source 
by running `make doc` from the toolbox top directory.

  [doc]: http://www.socib.es/users/glider/glider_toolbox/doc
  [m2html]: http://www.artefact.tk/software/matlab/m2html/


Outline
-------

This [diagram][outline] outlines the flow in the delayed time processing script
[`main_glider_data_processing_dt`][main_script_dt]. The real time processing 
script [`main_glider_data_processing_rt`][main_script_dt] is similar but 
includes steps to retrieve the glider data files from the basestations/dockservers. 
For further details about the processing and its configuration,
please refer to the documentation of those scripts
(in other words: read the docs! ;-).

  [outline]: http://www.socib.es/users/glider/glider_toolbox/notes/glider_data_processing_outline_delayed_time.png


Hidden gems
-----------

Some [common utilities][common_tools] included in the toolbox might be useful
even when the burden of an operational set of scripts and functions
developed to automatically process the data from a glider fleet is not needed:

  - Slocum data file API:
    [`dba2mat`][dba2mat], [`dbacat`][dbacat], and [`dbamerge`][dbamerge]
  - Seaglider data file API: 
    [`sglog2mat`][sglog2mat], [`sglogcat`][sglogcat], 
    [`sgeng2mat`][sgeng2mat], [`sgengcat`][sgengcat], 
    and [`sglogenmerge`][sglogengmerge]
  - More convenient [NetCDF interface][netcdf_dsl]:
    [`loadnc`][loadnc] and [`savenc`][savenc]
  - RFC-compliant [JSON interface][json_rfc]:
    [`loadjson`][loadjson] and [`savejson`][savejson]
  - C-style character array conversion:
    [`strc`][strc]
  - String formatting of scalar structs:
    [`strfstruct`][strfstruct]
  - [SFTP interface][sftp_libssh] compatible with native FTP:
    [`sftp`][@sftp]

  [common_tools]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/menu.html
  [dba2mat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/dba2mat
  [dbacat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/dbacat
  [dbamerge]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/dbamerge
  [sglog2mat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/sglog2mat
  [sglogcat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/sglogcat
  [sgeng2mat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/sgeng2mat
  [sgengcat]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/sgengcat
  [sglogengmerge]: http://www.socib.es/users/glider/glider_toolbox/doc/m/reading_tools/sglogengmerge
  [netcdf_dsl]: http://repository.socib.es/repository/entry/show/Top/Public+Staff/jbeltran/Octave+and+MATLAB/Octave+and+MATLAB+notes#Load%20and%20save%20data%20in%20NetCDF%20format
  [loadnc]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/loadnc
  [savenc]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/savenc
  [json_rfc]: http://repository.socib.es/repository/entry/show/Top/Public+Staff/jbeltran/Octave+and+MATLAB/Octave+and+MATLAB+notes#Load%20and%20save%20data%20in%20JSON%20format
  [loadjson]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/loadjson
  [savejson]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/savejson
  [strc]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/strc
  [strfstruct]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/strfstruct
  [sftp_libssh]: http://repository.socib.es/repository/entry/show/Top/Public+Staff/jbeltran/Octave+and+MATLAB/Octave+and+MATLAB+notes#Connect%20to%20an%20SFTP%20remote%20server
  [@sftp]: http://www.socib.es/users/glider/glider_toolbox/doc/m/common_tools/@sftp/sftp


Bugs, issues and contributions
------------------------------

Contributions and criticism are welcome.

If you have any doubt or problem, please fill an [issue][issues]!

If you fix something or want to add some contribution, many thanks in advance!

**A note on style:** the MATLAB/Octave code in the toolbox follows these 
[coding style guidelines][coding_style]. If you have your own style don't worry.
But if you don't, please consider following them. You may also save some typing
using the function and script [template helpers][template_helpers] there!

  [issues]: https://github.com/socib/glider_toolbox/issues
  [coding_style]: http://repository.socib.es/repository/entry/show/Top/Public+Staff/jbeltran/Octave+and+MATLAB/Octave+and+MATLAB+notes?entryid=49c25a41-ca67-48e3-94ef-2c5703c232c9#Coding%20style
  [template_helpers]: http://repository.socib.es/repository/entry/show/Top/Public+Staff/jbeltran/Octave+and+MATLAB/Octave+and+MATLAB+notes?entryid=49c25a41-ca67-48e3-94ef-2c5703c232c9#Function%20and%20script%20templates


Legacy
------

This toolbox is based on the previous code developed at [IMEDEA][imedea]
and [SOCIB][socib] by Tomeu Garau. He is the true glider man.

  [imedea]: http://imedea.uib-csic.es


Copyright
---------

Copyright (C) 2013-2015
ICTS SOCIB - Servei d'observació i predicció costaner de les Illes Balears
<http://www.socib.es>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
