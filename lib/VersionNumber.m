classdef VersionNumber < handle
%VERSIONNUMBER Simple utility to manage version number as string.
%
%   Class VersionNumber
%
%   Example
%   VersionNumber
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-07-24,    using Matlab 8.5.0.197613 (R2015a)
% Copyright 2015 INRA - BIA-BIBS.


%% Properties
properties
    % the major release number, as int
    major;
    
    % the minor release number, as int
    minor;
    
    % the patch number, as int
    patch;
    
    % an optional identifier
    label = '';
    
end % end properties


%% Constructor
methods
    function this = VersionNumber(varargin)
        % Constructor for VersionNumber class
    
        if nargin == 1
            var1 = varargin{1};
            if ischar(var1)
                ver = VersionNumber.parse(var1);
                this.major = ver.major;
                this.minor = ver.minor;
                this.patch = ver.patch;
                this.label = ver.label;
                
            elseif isa(var1, 'VersionNumber')
                % copy constructeur
                this.major = var1.major;
                this.minor = var1.minor;
                this.patch = var1.patch;
                this.label = var1.label;
                
            else
                error('Unable to process input of class % s', classname(var1));
            end
            
        elseif nargin >= 3
            this.major = varargin{1};
            this.minor = varargin{2};
            this.patch = varargin{3};
            if nargin == 4
                this.label = varargin{4};
            end
        end
    end

end % end constructors

%% Static Methods
methods (Static)
    function ver = parse(string)
        
        % first extract ending label
        tokens = strsplit(string, {'-', '+'});
        if length(tokens) > 1
            lbl = tokens{2};
        else
            lbl = '';
        end
        
        % split the different version numbers
        tokens = strsplit(tokens{1}, '.');
        if length(tokens) > 3
            error('too many tokens in version string: %s', string);
        end
        
        % convert to numerical values
        maj = str2double(tokens{1});
        min = str2double(tokens{2});
        if length(tokens) > 2
            pat = str2double(tokens{3});
        else
            pat = 0;
        end
        
        % create version number object
        ver = VersionNumber(maj, min, pat, lbl);
    end
    
    function c = compareStrings(str1, str2)
        
        % case of one empty string
        len = min(length(str1), length(str2));
        if len == 0
            if ~isempty(str1)
                c = 1;
            else
                c = -1;
            end
            return;
        end
        
        % find indices of non equal characters
        inds = find(str1(1:len) ~= str2(1:len));
        
        % in case of no difference, compare lengths
        if isempty(inds)
            if length(str1) < length(str2)
                c = -1;
            elseif length(str1) == length(str2)
                c = 0;
            else
                c = 1;
            end
            return;
        end
        
        % compare first different character
        ind = inds(1);
        if str1(ind) < str2(ind)
            c = -1;
        else
            c = 1;
        end

    end
    
end % end methods


%% Methods
methods
    
    function b = eq(this, that)
        if ~(isa(this, 'VersionNumber') && isa(that, 'VersionNumber'))
            error('Both inputs must be instances of VersionNumber');
        end
         
        b1 = this.major == that.major;
        b2 = this.minor == that.minor;
        b3 = this.patch == that.patch;
        b4 = strcmp(this.label, that.label);
        b = b1 && b2 && b3 && b4;
    end
    
    function b = gt(this, that)
        if ~(isa(this, 'VersionNumber') && isa(that, 'VersionNumber'))
            error('Both inputs must be instances of VersionNumber');
        end
        
        if this.major > that.major
            b = true;
            return;
        elseif this.major < that.major
            b = false;
            return;
        end
        
        if this.minor > that.minor
            b = true;
            return;
        elseif this.minor < that.minor
            b = false;
            return;
        end
        
        if this.patch > that.patch
            b = true;
            return;
        elseif this.patch < that.patch
            b = false;
            return;
        end
        
        c = VersionNumber.compareStrings(this.label, that.label);
        b = c == 1;
    end
    
    function b = ge(this, that)
        b = gt(this, that) || eq(this, that);
    end
    
    function b = lt(this, that)
        if ~(isa(this, 'VersionNumber') && isa(that, 'VersionNumber'))
            error('Both inputs must be instances of VersionNumber');
        end
        
        if this.major < that.major
            b = true;
            return;
        elseif this.major > that.major
            b = false;
            return;
        end
        
        if this.minor < that.minor
            b = true;
            return;
        elseif this.minor > that.minor
            b = false;
            return;
        end
        
        if this.patch < that.patch
            b = true;
            return;
        elseif this.patch > that.patch
            b = false;
            return;
        end
        
        c = VersionNumber.compareStrings(this.label, that.label);
        b = c == -1;
    end
    
    function b = le(this, that)
        b = lt(this, that) || eq(this, that);
    end
    
    
    function str = char(this)
        str = sprintf('%d.%d.%d', this.major, this.minor, this.patch);
        if ~isempty(this.label)
            str = [str '-' this.label];
        end
    end
    
end % end methods

end % end classdef

