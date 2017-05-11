function error=loss(x,md)
md.options.opts.shrinkageFactor=x.shrinkageFactor;
md.options.opts.maxTreeDepth=uint32(x.maxTreeDepth);
md.options.opts.subsamplingFactor=x.subsamplingFactor;
md.options.NumIter=uint32(x.NumIter);
    md.train;
    error=md.Validate;
    error=error.RMSE;
end
