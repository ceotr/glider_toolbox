%MAIN_GLIDER_DATA_PROCESSING_DT  Run delayed time glider processing chain.
%
%  This script develops the full processing chain for delayed time glider data:
%    - Check for configured deployments to process in delayed mode.
%    - Convert deployment binary files to human readable format, if needed.
%    - Load data from all files in a single and consistent structure.
%    - Preprocess raw data applying simple unit conversions data without 
%      modifying it:
%        -- NMEA latitude and longitude to decimal degrees.
%    - Generate standarized product version of raw data (NetCDF level 0).
%    - Process raw data to obtain well referenced trajectory data with new 
%      derived measurements and corrections. The following steps are applied:
%        -- Select reference sensors for time and space coordinates.
%        -- Select extra navigation sensors: waypoints, pitch, depth...
%        -- Select sensors of interest: CTD, oxygen, ocean color...
%        -- Identify transect boundaries at waypoint changes.
%        -- Identify cast boundaries from vertical direction changes.
%        -- General sensor processings: sensor lag correction, interpolation...
%        -- Process CTD data: pressure filtering, thermal lag correction...
%        -- Derive new measurements: depth, salinity, density, ...
%    - Generate standarized product version of trajectory data (NetCDF level 1).
%    - Generate descriptive figures from trajectory data.
%    - Interpolate/bin trajectory data to obtain gridded data (vertical 
%      instantaneous profiles of already processed data).
%    - Generate standarized product version of gridded data (NetCDF level 2).
%    - Generate descriptive figures from gridded data.
%    - Copy generated data products to its public location, if needed.
%    - Copy generated figures to its public location and generate figure
%      information service file, if needed.
%
%  Deployment information is queried from a data base with GETDBDEPLOYMENTINFO.
%  Data base access parameters may be configured in CONFIGDBACCESS.
%  Selected deployments and their metadata fields may be configured in 
%  CONFIGDTDEPLOYMENTINFOQUERY.
%
%  Input deployment raw data is loaded from a directory of raw text files with 
%  LOADSLOCUMDATA. For Slocum gliders a directory of raw binary files may be 
%  specified, and automatic conversion to text file format may be enabled.
%  The conversion is performed by function XBD2DBA, which is called with each
%  binary file in specified binary directory, and with a renaming pattern to
%  specify the name of the resulting text file. Input file conversion and data 
%  loading options may be configured in CONFIGDTFILEOPTIONSSLOCUM.
%  Output products, figures and processing logs are generated to local paths.
%  Input and output paths may be configured using expressions built upon
%  deployment field value replacements in CONFIGDTPATHSLOCAL.
%
%  For each deployment, the messages produced during each processing step are
%  recorded to a log file. This recording is enabled just before the processing
%  of the deployment starts, and is turned off when the processing finishes,
%  with the function DIARY.
%
%  Raw data is preprocessed to apply some simple unit conversions with the
%  function PREPROCESSGLIDERDATA. The preprocessing options and its parameters 
%  may be configured in CONFIGDATAPREPROCESSING.
%
%  Preprocessed data is processed with PROCESSGLIDERDATA to obtain properly 
%  referenced data with in a trajectory data set structure. The desired 
%  processing actions (interpolations, filterings, corrections and derivations) 
%  and its parameters may be configured in CONFIGDATAPROCESSING.
%
%  Processed data is interpolated/binned with GRIDGLIDERDATA to obtain a data 
%  set with the structure of a trajectory of instantaneous vertical profiles 
%  sampled at a common set of regular depth levels. The desired gridding 
%  parameters may be configured in CONFIGDATAGRIDDING.
%
%  Preprocessed data is stored in NetCDF format as level 0 output product with
%  GENERATEOUTPUTNETCDFL0. This file mimics the appearance of raw data text 
%  files, but gathering all useful data in a single place. Hence, the structure 
%  of the resulting NetCDF file will vary with each type of glider, and may be 
%  configured in CONFIGDTOUTPUTNETCDFL0. Processed and gridded are stored in
%  NetCDF format as level 1 and level 2 output products respectively. The 
%  structure of these files does not depent on the type of glider the data comes 
%  from, and it may be configured in CONFIGDTOUTPUNETCDFL1 and
%  CONFIGDTOUTPUTNETCDFL2 respectively.
%
%  Figures describing the collected glider data may be generated from processed
%  data and from gridded data. Figures are generated by GENERATEGLIDERFIGURES,
%  and may be configured in CONFIGFIGURES. Available plots are: scatter plots of
%  measurements on vertical transect sections, temperature-salinity diagrams,
%  trajectory and current maps, and profile statistics plots. Other plot 
%  functions may be used, provided that their call syntax is coherent with the 
%  design of GENERATEGLIDERFIGURES.
%
%  Selected data output products and figures may be copied to a public location
%  for distribution purposes. For figures, a service file describing the
%  available figures and their public location may also be generated. This file
%  is generated by function WRITEJSON with the figure information returned by
%  GENERATEGLIDERFIGURES adapted to reflect the new public location. Public
%  products and figures to copy and their locations may be configured in
%  CONFIGDTPATHSPUBLIC.
%
%  See also:
%    CONFIGDBACCESS
%    CONFIGDTDEPLOYMENTINFOQUERY
%    CONFIGDTPATHSLOCAL
%    CONFIGDTFILEOPTIONSSLOCUM
%    CONFIGDATAPREPROCESSING
%    CONFIGDATAPROCESSING
%    CONFIGDATAGRIDDING
%    CONFIGDTOUTPUTNETCDFL0
%    CONFIGDTOUTPUTNETCDFL1
%    CONFIGDTOUTPUTNETCDFL2
%    CONFIGFIGURES
%    GETDBDEPLOYMENTINFO
%    LOADSLOCUMDATA
%    PREPROCESSGLIDERDATA
%    PROCESSGLIDERDATA
%    GRIDGLIDERDATA
%    GENERATEOUTPUTNETCDFL0
%    GENERATEOUTPUTNETCDFL1
%    GENERATEOUTPUTNETCDFL2
%    GENERATEFIGURES
%    DIARY
%    STRFGLIDER
%    XBD2DBA
%    WRITEJSON
%
%  Notes:
%    This script is based on the previous work by Tomeu Garau. He is the true
%    glider man.
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


%% Configure toolbox and configuration file path.
glider_toolbox_dir = configGliderToolboxPath();


%% Configure deployment data paths.
config.paths_public = configDTPathsPublic();
config.paths_local = configDTPathsLocal();


%% Configure figure outputs.
[config.figures_proc, config.figures_grid] = configFigures();


%% Configure NetCDF outputs.
config.output_netcdf_l0 = configDTOutputNetCDFL0();
config.output_netcdf_l1 = configDTOutputNetCDFL1();
config.output_netcdf_l2 = configDTOutputNetCDFL2();


%% Configure processing options.
config.preprocessing_options = configDataPreprocessing();
config.processing_options = configDataProcessing();
config.gridding_options = configDataGridding();


%% Configure Slocum file downloading and conversion, and Slocum data loading.
config.slocum_options = configDTFileOptionsSlocum();


%% Configure data base deployment information source.
config.db_access = configDBAccess();
[config.db_query, config.db_fields] = configDTDeploymentInfoQuery();


%% Get list of deployments to process from database.
disp('Querying information of glider deployments...');
deployment_list = ...
  getDBDeploymentInfo(config.db_access, config.db_query, config.db_fields);
if isempty(deployment_list)
  disp('Selected glider deployments are not available.');
  return
else
  disp(['Selected deployments found: ' num2str(numel(deployment_list)) '.']);
end


%% Process active deployments.
for deployment_idx = 1:numel(deployment_list)
  %% Set deployment field shortcut variables and initialize other ones.
  % Initialization of big data variables may reduce out of memory problems,
  % provided memory is properly freed and not fragmented.
  disp(['Processing deployment ' num2str(deployment_idx) '...']);
  deployment = deployment_list(deployment_idx);
  deployment_name = deployment.deployment_name;
  deployment_id = deployment.deployment_id;
  deployment_start = deployment.deployment_start;
  deployment_end = deployment.deployment_end;
  glider_name = deployment.glider_name;
  processing_log = strfglider(config.paths_local.processing_log, deployment);
  binary_dir = strfglider(config.paths_local.binary_path, deployment);
  cache_dir = strfglider(config.paths_local.cache_path, deployment);
  log_dir = strfglider(config.paths_local.log_path, deployment);
  ascii_dir = strfglider(config.paths_local.ascii_path, deployment);
  figure_dir = strfglider(config.paths_local.figure_path, deployment);
  netcdf_l0_file = strfglider(config.paths_local.netcdf_l0, deployment);
  netcdf_l1_file = strfglider(config.paths_local.netcdf_l1, deployment);
  netcdf_l2_file = strfglider(config.paths_local.netcdf_l2, deployment);
  meta_raw = [];
  data_raw = [];
  data_preprocessed = [];
  data_processed = [];
  data_gridded = [];
  outputs = [];
  figures = [];


  %% Start deployment processing logging.
  % DIARY will fail if log file base directory does not exist.
  % Create the base directory first, if needed.
  % This is an ugly hack (the best known way) to check if the directory exists.
  [processing_log_dir, ~, ~] = fileparts(processing_log);  
  [status, attrout] = fileattrib(processing_log_dir);
  if ~status 
    [status, message] = mkdir(processing_log_dir);
  elseif ~attrout.directory
    status = false;
    message = 'not a directory';
  end
  % Enable log only if directory was already there or has been created properly.
  if status
    try
      diary(processing_log);
      diary('on');
    catch exception
      disp(['Error enabling processing log diary ' processing_log ':']);
      disp(getReport(exception, 'extended'));
    end
  else
    disp(['Error creating processing log directory ' processing_log_dir ':']);
    disp(message);
  end
  disp(['Deployment processing start time: ' ...
        datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);


  %% Report deployment information.
  disp('Deployment information:')
  disp(['  Glider name          : ' glider_name]);
  disp(['  Deployment identifier: ' num2str(deployment_id)]);
  disp(['  Deployment name      : ' deployment_name]);
  disp(['  Deployment start     : ' datestr(deployment_start)]);
  if isempty(deployment_end)
    disp(['  Deployment end       : ' 'undefined']);
  else
    disp(['  Deployment end       : ' datestr(deployment_end)]);
  end


  %% Convert binary glider files to ascii human readable format, if needed.
  % Check deployment files available in binary directory,
  % convert them to ascii format in the ascii directory,
  % and store the returned absolute path for later use.
  % Since some conversion may fail use a cell array of string cell arrays and
  % flatten it when finished, leaving only the succesfully created dbas.
  % Give a second try to failing files, because they might have failed due to 
  % a missing cache file generated later.
  if config.slocum_options.format_conversion
    % Look for xbds in binary directory.
    disp('Converting new deployment binary files...');
    bin_dir_contents = dir(binary_dir);
    xbd_sel = ~[bin_dir_contents.isdir] ...
      & ~cellfun(@isempty, regexp({bin_dir_contents.name}, config.slocum_options.bin_name_pattern));
    xbd_names = {bin_dir_contents(xbd_sel).name};
    xbd_sizes = [bin_dir_contents(xbd_sel).bytes];
    disp(['Binary files found: ' num2str(numel(xbd_names)) ...
         ' (' num2str(sum(xbd_sizes)*2^-10) ' kB).']);
    new_dbas = cell(size(xbd_names));
    for conversion_retry = 1:2
      for xbd_idx = 1:numel(xbd_names)
        if isempty(new_dbas{xbd_idx})
          xbd_name_ext = xbd_names{xbd_idx};
          dba_name_ext = regexprep(xbd_name_ext, ...
                                   config.slocum_options.bin_name_pattern, ...
                                   config.slocum_options.dba_name_replacement);
          xbd_fullfile = fullfile(binary_dir, xbd_name_ext);
          dba_fullfile = fullfile(ascii_dir, dba_name_ext);
          try
            new_dbas{xbd_idx} = ...
              {xbd2dba(xbd_fullfile, dba_fullfile, 'cache', cache_dir)};
          catch exception
            new_dbas{xbd_idx} = {};
            if conversion_retry == 2
              disp(['Error converting binary file ' xbd_name_ext ':']);
              disp(getReport(exception, 'extended'));
            end
          end
        end
      end
    end
    new_dbas = [new_dbas{:}];
    disp(['Binary files converted: ' ...
          num2str(numel(new_dbas)) ' of ' num2str(numel(xbd_names)) '.']);
  end


  %% Load data from ascii deployment glider files.
  disp('Loading raw deployment data from text files...');
  try
    load_start = utc2posixtime(deployment_start);
    load_end = posixtime();
    if ~isempty(deployment_end)
      load_end = utc2posixtime(deployment_end);
    end
    [meta_raw, data_raw] = ...
      loadSlocumData(ascii_dir, ...
                     config.slocum_options.dba_name_pattern_nav, ...
                     config.slocum_options.dba_name_pattern_sci, ...
                     'timenav', config.slocum_options.dba_time_sensor_nav, ...
                     'timesci', config.slocum_options.dba_time_sensor_sci, ...
                     'sensors', config.slocum_options.dba_sensors, ...
                     'period', [load_start load_end], ...
                     'format', 'struct');
    disp(['Slocum files loaded: ' num2str(numel(meta_raw.sources)) '.']);
  catch exception
    disp('Error loading Slocum data:');
    disp(getReport(exception, 'extended'));
  end


  %% Add source files to deployment structure if loading succeeded.
  if isempty(meta_raw) || isempty(meta_raw.headers)
    disp('No deployment data, processing and product generation will be skipped.');
  else
    deployment.source_files = sprintf('%s\n', meta_raw.headers.filename_label);
  end


  %% Preprocess raw glider data.
  if ~isempty(data_raw)
    disp('Preprocessing raw data...');
    try
      data_preprocessed = ...
        preprocessGliderData(data_raw, config.preprocessing_options);
    catch exception
      disp('Error preprocessing glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate L0 NetCDF file (raw/preprocessed data), if needed and possible.
  if ~isempty(data_preprocessed) && ~isempty(netcdf_l0_file)
    disp('Generating NetCDF L0 output...');
    try
      outputs.netcdf_l0 = ...
        generateOutputNetCDFL0(netcdf_l0_file, data_preprocessed, ...
                               config.output_netcdf_l0.var_meta, ...
                               config.output_netcdf_l0.dim_names, ...
                               config.output_netcdf_l0.global_atts, ...
                               deployment);
      disp(['Output NetCDF L0 (preprocessed data) generated: ' ...
            outputs.netcdf_l0 '.']);
    catch exception
      disp(['Error generating NetCDF L0 (preprocessed data) output ' ...
            netcdf_l0_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Process preprocessed glider data.
  if ~isempty(data_preprocessed)
    disp('Processing glider data...');
    try
      data_processed = ...
        processGliderData(data_preprocessed, config.processing_options);
    catch exception
      disp('Error processing glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate L1 NetCDF file (processed data), if needed and possible.
  if ~isempty(data_processed) && ~isempty(netcdf_l1_file)
    disp('Generating NetCDF L1 output...');
    try
      outputs.netcdf_l1 = ...
        generateOutputNetCDFL1(netcdf_l1_file, data_processed, ...
                               config.output_netcdf_l1.var_meta, ...
                               config.output_netcdf_l1.dim_names, ...
                               config.output_netcdf_l1.global_atts, ...
                               deployment);
      disp(['Output NetCDF L1 (processed data) generated: ' ...
            outputs.netcdf_l1 '.']);
    catch exception
      disp(['Error generating NetCDF L1 (processed data) output ' ...
            netcdf_l1_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate processed data figures.
  if ~(isempty(figure_dir) || isempty(data_processed))
    disp('Generating figures from processed data...');
    try
      figures.figproc = ...
        generateGliderFigures(data_processed, config.figures_proc, ...
                              'dirname', figure_dir);
    catch exception
      disp('Error generating processed data figures:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Grid processed glider data.
  if ~isempty(data_processed)
    disp('Gridding glider data...');
    try
      data_gridded = gridGliderData(data_processed, config.gridding_options);
    catch exception
      disp('Error gridding glider deployment data:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate L2 (gridded data) netcdf file, if needed and possible.
  if ~isempty(data_gridded) && ~isempty(netcdf_l2_file)
    disp('Generating NetCDF L2 output...');
    try
      outputs.netcdf_l2 = ...
        generateOutputNetCDFL2(netcdf_l2_file, data_gridded, ...
                               config.output_netcdf_l2.var_meta, ...
                               config.output_netcdf_l2.dim_names, ...
                               config.output_netcdf_l2.global_atts, ...
                               deployment);
      disp(['Output NetCDF L2 (gridded data) generated: ' ...
            outputs.netcdf_l2 '.']);
    catch exception
      disp(['Error generating NetCDF L2 (gridded data) output ' ...
            netcdf_l2_file ':']);
      disp(getReport(exception, 'extended'));
    end
  end


  %% Generate gridded data figures.
  if ~(isempty(figure_dir) || isempty(data_gridded))
    disp('Generating figures from gridded data...');
   try
      figures.figgrid = ...
        generateGliderFigures(data_gridded, config.figures_grid, ...
                              'dirname', figure_dir);
    catch exception
      disp('Error generating gridded data figures:');
      disp(getReport(exception, 'extended'));
    end
  end


  %% Copy selected products to corresponding public location, if needed.
  if ~isempty(outputs)
    disp('Copying public outputs...');
    output_name_list = fieldnames(outputs);
    for output_name_idx = 1:numel(output_name_list)
      output_name = output_name_list{output_name_idx};
      if isfield(config.paths_public, output_name) ...
           && ~isempty(config.paths_public.(output_name))
        output_local_file = outputs.(output_name);
        output_public_file = ...
          strfglider(config.paths_public.(output_name), deployment);
        output_public_dir = fileparts(output_public_file);
        [status, attrout] = fileattrib(output_public_dir);
        if ~status
          [status, message] = mkdir(output_public_dir);
        elseif ~attrout.directory
          status = false;
          message = 'not a directory';
        end
        if status
          [success, message] = copyfile(output_local_file, output_public_file);
          if success
            disp(['Public output ' output_name ' succesfully copied: ' ...
                  output_public_file '.']);
          else
            disp(['Error creating public copy of deployment product ' ...
                  output_name ': ' output_public_file '.']);
            disp(message);
          end
        else
          disp(['Error creating public output directory ' ...
                output_public_dir ':']);
          disp(message);
        end
      end
    end
  end


  %% Copy selected figures to its public location, if needed.
  % Copy all generated figures or only the ones in the include list (if any) 
  % excluding the ones in the exclude list. 
  if ~isempty(figures) ...
      && isfield(config.paths_public, 'figure_dir') ...
      && ~isempty(config.paths_public.figure_dir)
    disp('Copying public figures...');
    public_figure_baseurl = ...
      strfglider(config.paths_public.figure_url, deployment);
    public_figure_dir = ...
      strfglider(config.paths_public.figure_dir, deployment);
    public_figure_include_all = true;
    public_figure_exclude_none = true;
    public_figure_include_list = [];
    public_figure_exclude_list = [];
    if isfield(config.paths_public, 'figure_include')
      public_figure_include_all = false;
      public_figure_include_list = config.paths_public.figure_include;
    end
    if isfield(config.paths_public, 'figure_exclude')
      public_figure_exclude_none = false;
      public_figure_exclude_list = config.paths_public.figure_exclude;
    end
    public_figures = struct();
    public_figures_local = struct();
    figure_output_name_list = fieldnames(figures);
    for figure_output_name_idx = 1:numel(figure_output_name_list)
      figure_output_name = figure_output_name_list{figure_output_name_idx};
      figure_output = figures.(figure_output_name);
      figure_name_list = fieldnames(figure_output);
      for figure_name_idx = 1:numel(figure_name_list)
        figure_name = figure_name_list{figure_name_idx};
        if (public_figure_include_all ...
            || ismember(figure_name, public_figure_include_list)) ...
            && (public_figure_exclude_none ...
            || ~ismember(figure_name, public_figure_exclude_list))
          if isfield(public_figures_local, figure_name)
            disp(['Warning: figure ' figure_name ' appears to be duplicated.']);
          else
            public_figures_local.(figure_name) = figure_output.(figure_name);
          end
        end
      end
    end
    public_figure_name_list = fieldnames(public_figures_local);
    if ~isempty(public_figure_name_list)
      [status, attrout] = fileattrib(public_figure_dir);
      if ~status
        [status, message] = mkdir(public_figure_dir);
      elseif ~attrout.directory
        status = false;
        message = 'not a directory';
      end
      if status
        for public_figure_name_idx = 1:numel(public_figure_name_list)
          public_figure_name = public_figure_name_list{public_figure_name_idx};
          figure_local = public_figures_local.(public_figure_name);
          figure_public = figure_local;
          figure_public.url = ...
            [public_figure_baseurl '/' ...
             figure_public.filename '.' figure_public.format];
          figure_public.dirname = public_figure_dir;
          figure_public.fullfile = ...
            fullfile(figure_public.dirname, ...
                     [figure_public.filename '.' figure_public.format]);
          [success, message] = ...
            copyfile(figure_local.fullfile, figure_public.fullfile);
          if success
            public_figures.(public_figure_name) = figure_public;
            disp(['Public figure ' public_figure_name ' succesfully copied.']);
          else
            disp(['Error creating public copy of figure ' ...
                  public_figure_name ': ' figure_public.fullfile '.']);
            disp(message);
          end
        end
      else
        disp(['Error creating public figure directory ' public_figure_dir ':']);
        disp(message);
      end
    end
    % Write the figure information to the JSON service file.
    if isfield(config.paths_public, 'figure_info') ...
        && ~isempty(config.paths_public.figure_info)
      disp('Generating figure information service file...');
      public_figure_info_file = ...
        strfglider(config.paths_public.figure_info, deployment);
      try
        writeJSON(public_figures, public_figure_info_file);
        disp(['Figure information service file successfully generated: ' ...
              public_figure_info_file]);
      catch exception
        disp(['Error creating figure information service file ' ...
              public_figure_info_file ':']);
        disp(message);
      end
    end
  end


  %% Stop deployment processing logging.
  disp(['Deployment processing end time: ' ...
        datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00')]);
  diary('off');

end