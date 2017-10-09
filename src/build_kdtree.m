function tree_output = build_kdtree(X, Sl, idx, parent_number)

% BUILD_KDTREE 
%   recursive algorithm to build a kdtree
%   
%   Inputs: 
%     X:                NxD data matrix. N number of samples, D dimensionality.
%     Sl:               Size of leaf nodes in the kdtree
%     idx:              Internal variable
%     parent_number:    Internal variable
%
%   Outputs: 
%     tree_output:      array containing each node info as:
%     - left:           left tree node location
%     - right:          right tree node location
%     - numpoints:      number of points in this node
%     - type:           leaf/node
%     - parent:         location of the parent
%     - index:          index of the feature vector
%     - splitdim:       dimension along which the split is made


global tree_cell;
global node_number;
global safety_check;

if nargin == 2  % initial pass
    safety_check=0;
        
    [n, numdigits] = size(X); % Convert to binary vectors
    idx = 1:n;
    node_number=1;
    parent_number=0;
    
    % intialize node 
    Node.type='node'; 
    Node.left=0;
    Node.right=0;
    Node.numpoints=0;
    Node.index=0;
    Node.parent=0;
   
else % recursive passes
    [n, numdigits] = size(X);
    node_number=node_number+1;
end

if n==0 
    fprintf('Error: 0 points in node, causing endless loop, press ctrl-C.\n'); 
end
assigned_nn=node_number;
tree_cell(assigned_nn).type='node'; 
tree_cell(assigned_nn).parent=parent_number; 

% leaf node if less than sl samples
if n<=Sl
    tree_cell(assigned_nn).left=[];
    tree_cell(assigned_nn).right=[];
    tree_cell(assigned_nn).type='leaf';
    tree_cell(assigned_nn).numpoints=n;
    tree_cell(assigned_nn).index=idx;    
    tree_output=assigned_nn;
    return;
end

tree_cell(assigned_nn).numpoints = n;

% if the feature vectors happen to be the same then leaf again
a = min(X); b = max(X); 
if a==b tree_cell(assigned_nn).type='leaf'; end
 
% recursively build tree
if (strcmp(tree_cell(assigned_nn).type,'leaf'))
    tree_cell(assigned_nn).index=idx;
else
    % choose dimension to split
    auxsum = zeros(1,numdigits*8);
    for ibit = 8:-1:1
        indices = ([1:numdigits]-1)*8 + (9-ibit);
        auxsum(indices) = sum(bitget(X,ibit));
    end
    aux = auxsum/n;
    aux = abs(0.5 - aux);
    [~, i] = sort(aux);    
    split_dimension=i(1);
    tree_cell(assigned_nn).splitdim = split_dimension;
        
    % Samples '1'
    positioninbyte = mod(split_dimension-1,8)+1;
    valuesDimension = bitget(X,9-positioninbyte);
    valuesDimension = valuesDimension(:,ceil(split_dimension/8));
    if(size(find(valuesDimension==1),1) > 0)
        idxLeft = find(valuesDimension==1);
        tree_cell(assigned_nn).left = build_kdtree(X(idxLeft,:), Sl, idx(idxLeft), assigned_nn);
    else
        tree_cell(assigned_nn).left =[];
    end
    
    % Samples '0'
    if(size(find(valuesDimension==0),1) > 0)
        idxRight = find(valuesDimension==0);
        tree_cell(assigned_nn).right = build_kdtree(X(idxRight,:), Sl, idx(idxRight), assigned_nn);
    else
        tree_cell(assigned_nn).right =[];
    end
end

% clean up 
if nargin == 2
    tree_output=tree_cell;
    clear global tree_cell;
else
    tree_output=assigned_nn;
end