function computeAbscissas(obj)
% Compute curvilinear abscissa of midline vertices from their coordinates.
%
%   Syntax:
%   computeAbscissas(MIDLINE)
%   Computes the curvilinear abscissa of each vertex, and populate the
%   "Abscissas" property.
%
%   Example
%   computeAbscissas
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-12-31,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

obj.Abscissas = [0 ; cumsum(hypot(diff(obj.Coords(:,1)), diff(obj.Coords(:,2))))];