function [index_vals] = search_kdtree(tree, point, Sl, B, node_number)

% SEARCH_KDTREE 
%   recursive algorithm to search in a kdtree with a FIFO queue.
%   
%   Inputs: 
%     tree:             cell array with the tree.
%     point:            sample of interest
%     Sl:               size of leaf nodes in the kdtree
%     B:                maximum number of backtracking steps
%     node_number:      internal variable
%
%   Outputs: 
%     index_vals:       list of indices found


% Initialize the global variable
global tree_cell;
global safety_check;
global PQ;
global indexPQ;

if(nargin==4) % initial pass
    safety_check=0;
    tree_cell=tree;
    clear tree;
    
    % dimension of data
    d = size(point,2); 
       
    % intialize the queue
    PQ = zeros(B,1);
    PQ(1) = 1;
    indexPQ = 1;
    backcount = 0;
    List = zeros((B+1)*Sl,1);
    
    % While backcount <= maximum backtracking steps
    % AND there are nodes in PQ
    % Do the algorithm
    while backcount <= B && ~isempty(find(PQ))
                   
        % Extract node from FIFO queue and descend till leaf
        nodeindex = PQ(1);
        index_vals = search_kdtree(0, point, Sl, B, nodeindex);

        % updates
        backcount = backcount + 1;
        inx = find(List==0,1,'first');
        if ~isempty(inx)
            %List(inx:inx+size(index_vals,1)-1) = index_vals;
            List(inx:inx+size(index_vals,2)-1) = index_vals';
        else
            %List(end:end+size(index_vals,1)-1) = index_vals;
            List(end:end+size(index_vals,2)-1) = index_vals';
        end        
        PQ(1) = [];
        indexPQ = indexPQ - 1;        
    end
    
    % clean up 
    List(List==0) = [];
    index_vals = List;
    clear List;
    clear global tree_cell
    clear global safety_check;
    return;
end

if (isempty(safety_check))
    error ('Insufficient number of input variables ... please check ');
end

% if the current node is a leaf then add points to list
if(strcmp(tree_cell(node_number).type,'leaf'))
    index_vals=tree_cell(node_number).index;
    return;
end

% if the current node is not a leaf
% check to see if the point is to the left of the split dimension
if (point(tree_cell(node_number).splitdim) == 1)
    
    % Add Right node to queue if not full 
    nodeRight = tree_cell(node_number).right;
    if(~isempty(nodeRight) && strcmp(tree_cell(nodeRight).type,'node') && ~isempty(find(PQ==0,1,'first')))
        PQ(indexPQ+1) =  nodeRight;
        indexPQ = indexPQ + 1;
    end

    % Recurse to the left
    if (isempty(tree_cell(node_number).left))
        % incase the left node is empty, then output current results
        index_vals=tree_cell(node_number).index;
    else
        [index_vals]=search_kdtree(0, point, Sl, B, tree_cell(node_number).left);
    end
    
else    
    % Add Left node to queue if not full
    nodeLeft = tree_cell(node_number).left;
    if(~isempty(nodeLeft) && strcmp(tree_cell(nodeLeft).type,'node') && ~isempty(find(PQ==0,1,'first')))
        PQ(indexPQ+1) =  nodeLeft;
        indexPQ = indexPQ + 1;
    end

    % Recurse to the right
    if (isempty(tree_cell(node_number).left))
        % incase the left node is empty, then output current results
        index_vals=tree_cell(node_number).index;
    else
        [index_vals]=search_kdtree(0, point, Sl, B, tree_cell(node_number).right);
    end

end