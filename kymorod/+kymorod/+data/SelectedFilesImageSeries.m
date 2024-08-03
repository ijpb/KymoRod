classdef SelectedFilesImageSeries < kymorod.data.ImageSeries
% Gather the information necessary to retrieve a sequence of images.
%
%   Keeps the path name of the image as well as some selection info (index
%   of first and last image, step between images...), and provides methods
%   to load image data 'on the fly'.
%
%   Example
%     IS = SelectedFilesImageSeries('images', '*.jpg');
%     IS = SelectedFilesImageSeries('images', '*.jpg', 10, 50, 2);
%     IS = SelectedFilesImageSeries('images', '*.jpg', 10, 50, 2, 'green');
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-03,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    % The directory to read images from, as char array.
    Directory = '';
    % The file pattern to read imagess, as a char array (default '*.*').
    FileNamePattern = '*.*';
    
    % The index of the first image in file list. Default is 1.
    IndexFirst = 1;
    % The index of the last image in file list. Default is 1.
    IndexLast = 1;
    % The increment of files between images. Default is 1.
    IndexStep = 1;
    
    % For color images, the channel to read data from.
    Channel = 'red';
    
    % Boolean flag indicating whether data should be stored in totality, 
    % or loaded only when requested (lazy loading). Default is TRUE.
    LazyLoading = true;
    
    % The full list of image names.
    FileNameList = {};

    % The list of selected image file names (from pattern and indices)
    ImageFileNameList = {};

    % The list of images, if lazy loading is false and data are initialized.
    ImageList = {};
    
end % end properties


%% Constructor
methods
    function obj = SelectedFilesImageSeries(varargin)
        % Constructor for SelectedFilesImageSeries class.
        %
        % IS = SelectedFilesImageSeries(DIR, PATTERN);
        % IS = SelectedFilesImageSeries(DIR, PATTERN, FIRST, LAST, STEP);
        % IS = SelectedFilesImageSeries(DIR, PATTERN, FIRST, LAST, STEP, CHANNEL);
        %
        
        % empty constructor
        if isempty(varargin)
            return;
        end
        
        % copy constructor
        if isa(varargin{1}, 'kymorod.data.SelectedFilesImageSeries')
            sfis = varargin{1};
            obj.Directory       = sfis.Directory;
            obj.FileNamePattern = sfis.FileNamePattern;
            obj.IndexFirst      = sfis.IndexBegin;
            obj.IndexLast       = sfis.IndexEnd;
            obj.IndexStep       = sfis.IndexStep;
            obj.Channel         = sfis.Channel;
            return;
        end
        
        % setup directory and optional file pattern
        obj.Directory = varargin{1};
        if nargin > 1
            obj.FileNamePattern = varargin{2};
        end

        % initialize indices
        if nargin < 3
            % if indices are not specified, read the full range
            fileList = getFileList(obj);
            obj.IndexFirst = 1;
            obj.IndexLast = length(fileList);
            obj.IndexStep = 1;
        else
            % otherwise, copy input arguments
            obj.IndexFirst = varargin{3};
            obj.IndexLast = varargin{4};
            obj.IndexStep = varargin{5};
        end
        
        % optional channel name
        if nargin > 5
            obj.Channel = varargin{6};
        end

        computeFileNameList(obj);
    end

end % end constructors


%% Methods
methods
    function n = imageCount(obj)
        % Returns the number of images in the list.
        n = length(obj.FileNameList);
    end
    
    function img = getImage(obj, index)
        % Returns the image corresponding to the given index.
        
        if isempty(obj.FileNameList)
            computeFileNameList(obj);
        end
        
        if obj.LazyLoading
            filePath = fullfile(obj.Directory, obj.FileNameList{index});
            img = imread(filePath);
        else
            img = this.imageList{index};
        end
        
        if ~isempty(obj.Channel)
            if strcmpi(obj.Channel, 'Red')
                img = img(:,:,1);
            elseif strcmpi(obj.Channel, 'Green')
                img = img(:,:,2);
            elseif strcmpi(obj.Channel, 'Blue')
                img = img(:,:,3);
            elseif strcmpi(obj.Channel, 'Intensity')
                img = img(:,:,2);
            else
                error('Unable to interpret channel name');
            end
        end
    end
    
end % end methods


%% Methods specific to class
methods
    function computeImageFileNameList(obj)
        % Select files corresponding to image selection indices.

        if isempty(obj.FileNameList)
            computeFileNameList(obj);
        end

        fileList = getFileList(obj);
        indices = obj.IndexFirst:obj.IndexStep:obj.IndexLast;
        obj.ImageFileNameList = fileList(indices);
    end
    
    function updateImageData(obj)
        % Refresh either image names or image list, depending on lazy loading.
        
        if isempty(obj.ImageFileNameList)
            computeImageFileNameList(obj);
        end
        
        % optionnally load images into memory
        if ~obj.LazyLoading
            nImages = length(obj.ImageFileNameList);
            obj.ImageList = cell(1, nImages);
            for i = 1:nImages
                fileName = obj.ImageFileNameList{i};
                obj.ImageList{i} = imread(fullfile(obj.Directory, fileName));
            end
        end
    end

    function inds = selectedFileIndices(obj)
        % Return the indices of selected files from index selection.
        inds = obj.IndexFirst:obj.IndexStep:obj.IndexLast;
    end

    function computeFileNameList(obj)
        % Computes the list of file names from dir+pattern.
        %
        
        fileList = getFileList(obj);
        
        % convert struct array to cell array of strings
        nImages = length(fileList);
        obj.FileNameList = cell(nImages, 1);
        for i = 1:nImages
            obj.FileNameList{i} = fileList(i).name;
        end
    end
    
    function fileList = getFileList(obj)
        % Return the list of files from dir+pattern, as a struct array.
        %
        % fileList = getFileList(OBJ);
        %

        if isempty(obj.FileNamePattern)
            error('Requires a valid file pattern');
        end
        
        % find all matched files in input directory
        fileList = dir(fullfile(obj.Directory, obj.FileNamePattern));
        
        % ensure no directory is loaded
        fileList = fileList(~[fileList.isdir]);
    end

    function clear(obj)
        % Reset all properties to default state.
        obj.Directory = '';
        obj.FileNamePattern = '*.*';
        obj.Channel = 'Red';
        obj.IndexFirst = 1;
        obj.IndexLast = 1;
        obj.IndexStep = 1;
        obj.FileNameList = {};
        obj.ImageFileNameList = {};
        obj.ImageList = {};
    end
end


%% Serialization methods
methods
    function write(obj, fileName, varargin)
        % Writes object instance into a JSON file.
        % Requires implementation of the "toStruct" method.
        if exist('savejson', 'file') == 0
            error('Requires the jsonlab library');
        end
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end
    
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        
        str = struct('Type', 'kymorod.data.SelectedFilesImageSeries');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            
            if strcmpi(name, 'ImageList')
                % do not save images in json files
                continue;
            else
                str.(name) = obj.(name);
            end
        end
    end
end

methods (Static)
    function res = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        res = kymorod.data.SelectedFilesImageSeries.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kymorod.data.SelectedFilesImageSeries();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmpi(name, 'Type')
                continue;
            elseif strcmpi(name, 'ImageList')
                % do nothing...
            else
                obj.(name) = str.(name);
            end
        end
    end
end

end % end classdef

