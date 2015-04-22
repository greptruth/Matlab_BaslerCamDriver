function make(varargin)
%MAKE: compile the MATLAB Basler Camera Driver
% 19.04.2015 / Hannes Badertscher
% Usage:
%          make            Compiles the driver
%          make clean      Removes all autogenerated files
%

%% Files to build
% Driver functions
drivers = {                             ...
            'baslerFindCameras.cpp';    ...
            'baslerSetParameter.cpp';   ...
            'baslerGetParameter.cpp';   ...
          };

% Shared libraries:   path           name         additional flags
libraries = {  'basler_helper', 'basler_helper.cpp',      '-c';      ...
               'private',  'baslerGetRawCameraParams.cpp', '';       ...
            };
libraryObjects = { 'basler_helper/basler_helper.obj'; ...
            };

% MEX and compiler flags
flags = {   '-largeArrayDims',...
            '"CXXFLAGS=$CXXFLAGS -std=c++0x -fpermissive -fPIC -DNDEBUG"', ...
            ... '-g', ...      % debug symbols
            ... '-v', ...      % verbose
        };

%% Additional Paths
% Include paths
ipaths = [  '-I"',fullfile(getenv('PYLON_ROOT'),'include'),'"' ...
            ' ',...
            '-I"',fullfile(getenv('PYLON_GENICAM_ROOT'),'library\CPP\include'),'"', ...
            ' ',...
            '-I"',fullfile(getenv('BOOST_ROOT')),'"',...
         ];

% Library paths
lpaths = [  '-L"',fullfile(getenv('PYLON_ROOT'),'lib\x64'),'"', ...
            ' ','"',fullfile(getenv('PYLON_GENICAM_ROOT'),'\library\CPP\Lib\win64_x64'),'"', ...
            ' ','"',fullfile(getenv('BOOST_ROOT'),'stage\lib'),'"', ...
         ];

%% Build!
switch nargin
    case 0 % BUILD

        % Build libraries
        fprintf('=> Creating Libraries\n');
        for k=1:size(libraries,1)
            cd(libraries{k,1})
            mex(flags{:},libraries{k,3},ipaths,lpaths,libraries{k,2})   % build
            cd('..');
        end

        % Build drivers
        fprintf('=> Creating Functions\n');
        for k=1:size(drivers,1)
            mex(flags{:},ipaths,lpaths,libraryObjects{:},drivers{k})
        end
        
    case 1 %CLEAN
        if strcmp(varargin{1},'clean')
            delete('*.pdb','*.mex*','*.obj');
            for k=1:size(libraries,1)
                cd(libraries{k,1});
                delete('*.pdb','*.mex*','*.obj');
                cd('..');
            end
        end
        
    otherwise %DO NOTHING!

end
    
end