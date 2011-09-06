local utils = {}

function utils.mergeTables(...)
    local merged = {}
    for i, tab in ipairs(arg) do
        for k, v in pairs(tab) do
            merged[k] = v
        end
    end
    return merged
end

function utils.copyTable(tab)
    local out = {}
    for k, v in pairs(tab) do
        if type(v) == 'table' then
            out[k] = utils.copyTable(v)
        else
            out[k] = v
        end
    end
    return out
end

return utils
