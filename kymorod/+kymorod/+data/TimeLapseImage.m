classdef TimeLapseImage < handle
% A sequence of image together with meta-data.
%
%   The TimeLapseImage class gather several data:
%   * ImageList: the sequence of images, as an instance of
%       ImageListProvider. 
%   * ImageSize: the size of frame images (number of pixels in Y and Y
%       directions)
%   * FrameCount: the number of frames
%   * Calibration: meta-data about pixel size and time between two frames.
%
%   Example
%   TimeLapseImage
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-05-14,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.


%% Properties
properties
    % The sequence of images, as an instance of ImageSeries.
    ImageList;
    
    % The size of frame images, in [X Y] order.
    ImageSize = [0 0];
    
    % Space and time calibration of the time-lapse.
    Calibration = kymorod.data.Calibration();
    
end % end properties


%% Constructor
methods
    function obj = TimeLapseImage(varargin)
        % Constructor for TimeLapseImage class.
        
        % default initialisation
        obj.ImageList = kymorod.data.SelectedFilesImageSeries();
        
        if isempty(varargin)
            return;
        end
        
        % Check if Image List is provided
        var1 = varargin{1};
        if isa(var1, 'kymorod.data.ImageSeries')
            obj.ImageList = var1;
            
            if imageCount(obj.ImageList) > 0
                % get first image to initialize image size
                img = getImage(obj.ImageList, 1);
                obj.ImageSize = [size(img, 2) size(img, 1)];
            end
        else
            error('First input must be a kymorod.data.ImageSeries');
        end
    end

end % end constructors


%% Methods
methods
    function n = frameCount(obj)
        % Counts the frames within this time-lapse image.
        n = imageCount(obj.ImageList);
    end
    
    function b = canReadImages(obj)
        % Checks if the input images are accessible.
        b = false;
        if isempty(obj.ImageList)
            return;
        end
        
        if obj.ImageList.LazyLoading
            if isempty(obj.ImageList.FileNameList)
                % if file names have not been initialized, can not read.
                return;
            end
            
            % list the first file
            filePath = fullfile(obj.ImageList.Directory, obj.ImageList.FileNameList{1});
            fileList = dir(filePath);
            if isempty(fileList)
                return;
            end
        else
            % in case of no lazy-loading, requires the images to be stored
            % in the ImageListProvider.
            if isempty(obj.ImageList.ImageList)
                return;
            end
        end
        
        % if nothing failed, then we can read images.
        b = true;
    end
    
    function extent = physicalExtent(obj)
        % Returns the physical extent [xmin xmax ymin ymax] in user unit.
        calib = obj.Calibration;
        extX = [0 obj.ImageSize(1) * calib.PixelSize] + calib.Origin(1);
        extY = [0 obj.ImageSize(2) * calib.PixelSize] + calib.Origin(2);
        extent = [extX extY];
    end
    
    function img = getFrameImage(obj, frameIndex)
        % Get the image at a given frame index.
        %
        % IMG = getFrameImage(OBJ, INDEX)
        % Returns the image at the given index, or a default image if no
        % image series is loaded.

        if ~isempty(obj.ImageList)
            img = getImage(obj.ImageList, frameIndex);
        else
            img = ones(obj.ImageSize([2 1]));
        end
    end    

end % end methods


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
        
        str = struct('Type', 'kymorod.data.TimeLapseImage');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            
            if strcmpi(name, 'ImageList')
                str.ImageList = toStruct(obj.ImageList);
            elseif strcmpi(name, 'Calibration')
                str.Calibration = toStruct(obj.Calibration);
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
        res = kymorod.data.TimeLapseImage.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kymorod.data.TimeLapseImage();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmpi(name, 'Type')
                continue;
            elseif strcmpi(name, 'ImageList')
                obj.ImageList = kymorod.data.SelectedFilesImageSeries.fromStruct(str.ImageList);
            elseif strcmpi(name, 'Calibration')
                obj.Calibration = kymorod.data.Calibration.fromStruct(str.Calibration);
            elseif strcmpi(name, 'FrameNumber')
                % for compatibility with old version (< 2020-12-07)
                obj.FrameCount = str.FrameNumber;
            else
                obj.(name) = str.(name);
            end
        end
    end
end

end % end classdef

