function [SK CT2 SKVerif CTVerif shift] = displacementSkeleton(SK,CT)

% coordinates at bottom left
shift=SK(1,:);
%For verification to save the contour
CTVerif(:,1)=CT(:,1);
CTVerif(:,2)=CT(:,2);
% For new contour, align at bottom left
CT2(:,1)=CT(:,1)-SK(1,1);
CT2(:,2)=-(CT(:,2)-SK(1,2));
%For verification
SKVerif(:,1)=SK(:,1);
SKVerif(:,2)=SK(:,2);
% for new Skeleton, align at bottom left
SK(:,1)=SK(:,1)-SK(1,1);
SK(:,2)=-(SK(:,2)-SK(1,2));

