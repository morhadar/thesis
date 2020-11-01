function db = minus128_to_nan(db)
%convert '-128' to 'nan':
    fn = fieldnames(db);
    for k = 1:numel(fn)
        hop = char(fn(k));
        disp(hop)
        if( isfield(db.(hop) , 'up') )
            db.(hop).up.raw ( db.(hop).up.raw(:,2) == -128) = nan;
        end
        if( isfield(db.(hop) , 'down') )
            db.(hop).down.raw ( db.(hop).down.raw(:,2) == -128) = nan;
        end
    end
end