function db = nan_2_minus128(db)
%convert 'nan' to -128;
    fn = fieldnames(db);
    for k = 1:numel(fn)
        hop = char(fn(k));
        disp(hop)
        if( isfield(db.(hop) , 'up') )
            db.(hop).up.raw ( isnan(db.(hop).up.raw(:,2)) ) = -128;
        end
        if( isfield(db.(hop) , 'down') )
            db.(hop).down.raw ( isnan(db.(hop).down.raw(:,2) )) = -128;
        end
    end
end