function shadedSurfaceDisplay(data, numClusters, varargin)

sz = size(data);

if numel(varargin)
    mesh = varargin{1};
    xm = mesh.X;
    ym = mesh.Y;
    zm = mesh.Z;
else
    [xm, ym, zm] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3)); 
end
    
    dataVector = data(:);

    [idx, C] = kmeans(double(dataVector), numClusters);

    clusteredData = reshape(idx, size(data));

    uniqueElements = unique(clusteredData);

    figure

    for i = 1:length(uniqueElements)
        v = clusteredData;
        v(v~=uniqueElements(i)) = 0;
        s = isosurface(xm, ym, zm, v, 0.1);
        p = patch(s);
        set(p,'FaceColor',[rand rand rand]);  
        set(p,'EdgeColor','none');
    end

    axis([0 sz(1) 0 sz(2) 0 sz(3)]);
    view(3); 
    camlight right; 
    camlight left; 
    lighting gouraud
    axis image
end
