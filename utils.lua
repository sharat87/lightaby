local utils = {}

function utils.mergeTables(...)
    merged = {}
    for i, tab in ipairs(arg) do
        for k, v in pairs(tab) do
            merged[k] = v
        end
    end
    return merged
end

return utils
