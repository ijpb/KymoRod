function nc = vertexCount(obj)
% Return the number of vertices.
%
%   NC = vertexCount(ML)
%
%   Example
%   vertexCount
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-01-02,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

nc = size(obj.Coords, 1);
