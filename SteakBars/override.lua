SetActionBarToggles(0, 0, 0, 0, 0)

SHOW_MULTI_ACTIONBAR_1 = 0
SHOW_MULTI_ACTIONBAR_2 = 0
SHOW_MULTI_ACTIONBAR_3 = 0
SHOW_MULTI_ACTIONBAR_4 = 0

if MultiActionBar_Update then
	MultiActionBar_Update()
end

for _, frame in ipairs({MainMenuBar, VehicleMenuBar, MultiBarLeft, MultiBarRight, MultiBarBottomLeft, MultiBarBottomRight}) do
	frame:HookScript("OnShow", function(self) self:Hide() end)
	frame:Hide()
	frame.ignoreFramePositionManager = true
	frame:UnregisterAllEvents()
end
