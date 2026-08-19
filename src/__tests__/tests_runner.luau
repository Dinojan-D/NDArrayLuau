local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevPackages = ReplicatedStorage.DevPackages

local runCLI = require(DevPackages.Jest).runCLI

type TestOptions = {
	testPathPattern: string?,
	testNamePattern: string?,
	expand: boolean?,
	debug: boolean?,
}

return function (directoryName:string, config: TestOptions)
    local directory = ReplicatedStorage:FindFirstChild("tests")
    if (directoryName ~= "*") then
        -- '*' means run all tests, so we don't need to find a specific directory
        directory = directory:FindFirstChild(directoryName) 
    end

    local processServiceExists, ProcessService = pcall(function()
        return game:GetService("ProcessService")
    end)

    local status, result = runCLI(ReplicatedStorage, config, {directory}):awaitStatus()

    if status == "Rejected" then
        print(result)
    end

    if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
        if processServiceExists then
            ProcessService:ExitAsync(0)
        end
    end

    if processServiceExists then
        ProcessService:ExitAsync(1)
    end
end
