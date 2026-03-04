local commonDataReporting = require("CommonDataReporting")
local Log = require("Local.Log")
local tableUtils = require("ALE.TableUtils")

function getSubTestName(subtest)

    if subtest:find("_&") then
        return subtest:match("(.*)_&")
    else
        return subtest
    end
end

function getSubSubTestName(subsubtest)
    if subsubtest:find("_&") then
        return subsubtest:match("_&(.*)")
    else
        return subsubtest
    end
end

function splitString(input, delimiter)
    if not input or not delimiter then return nil end
    input = tostring(input)
    delimiter = tostring(delimiter)
    if delimiter=='' then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function main(result, paramter)
    -- No need to create record when returned 'OFF' by CheckUOP
    if paramter == "UOP_OFF" then
        return
    end

    Log.LogInfo("======================>>>>>> runTest: " .. Device.test .. "_" .. Device.subtest)
    Log.LogInfo("======================>>>>>> createrecord: ", result)

    local testName = Device.test
    if tableUtils.hasKey(paramter, "test") then
        testName = paramter["test"]
    end

    local subTestName = Device.subtest

    if tableUtils.hasKey(paramter, "subtest") then
        subTestName = paramter["subtest"]
    else
        subTestName = getSubTestName(subTestName)
    end

    local subsubTestName = ""
    if tableUtils.hasKey(paramter, "subsubtest") then
        subsubTestName = paramter["subsubtest"]
    else
        subsubTestName = getSubSubTestName(Device.subtest)
    end

    Log.LogInfo("======================>>>>>> subsubTestName: ", subsubTestName)

    local failMessage = nil
    if tableUtils.hasKey(paramter, "failmessage") then
        failMessage = paramter["failmessage"]
    end

    local value

    local shouldUpLoadRecord = true

    if type(result) == "string" then
        local lower_result = result:lower()
        if lower_result == "true" or lower_result == "yes" or lower_result == "y" or lower_result == "pass" or lower_result == "1" then
            -- 当放回的为TRUE，yes。。。时，不需要记录
            -- shouldUpLoadRecord = false
            value = true
        elseif lower_result == "false" or lower_result == "no" or lower_result == "n" or lower_result == "fail" or lower_result == "0" then
            value = false
        else
            value = false
        end
    elseif type(result) =="boolean" then
        value = result
    else
        value = false
    end

    if shouldUpLoadRecord == true then
        if failMessage ~= nil then
            DataReporting.submitRecord(value, testName, subTestName, subsubTestName, failMessage)
        else
            DataReporting.submitRecord(value, testName, subTestName, subsubTestName)
        end
    end
end
