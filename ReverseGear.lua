-- ReverseGear by Alessio Franceschelli
-- GitHub: https://github.com/alefranz/ReverseGear_FS25
-- License: GPLv3

if not g_dedicatedServerInfo then

  ReverseGear = {}
  ReverseGear.vehicles = {}

  local function getVehicleData(self)
    local id = self.uniqueId or nil
    if id == nil then
      return nil, nil
    end
    if ReverseGear.vehicles[id] == nil then
      ReverseGear.vehicles[id] = {
        reverseGear = nil,
        currentDirection = 1.0
      }
    end
    return ReverseGear.vehicles[id], id
  end

  Motorized.onGearDirectionChanged = Utils.appendedFunction(Motorized.onGearDirectionChanged, function(self, direction)
      printDebug("=== ReverseGear DEBUG: onGearDirectionChanged called ===")
      printDebug("Vehicle name:", self:getName() or "Unknown")
      printDebug("Vehicle ID:", self.uniqueId or "Unknown ID")
      printDebug("Is client:", self.isClient)
      printDebug("Direction parameter:", direction)

      if self.isClient then
        local data = getVehicleData(self)
        if data == nil then
          printDebug("No vehicle data (missing ID), aborting direction handling")
        else
          data.currentDirection = direction
          if self:getDirectionChangeMode() == VehicleMotor.DIRECTION_CHANGE_MODE_MANUAL then
            printDebug("Vehicle is in MANUAL direction change mode")
            if self:getGearShiftMode() == VehicleMotor.SHIFT_MODE_MANUAL then
              printDebug("Vehicle is in MANUAL gear shift mode")
              if direction == -1.0 then
                printDebug("Switched to REVERSE")
                if data.reverseGear ~= nil then
                  printDebug("Restoring saved reverse gear:", data.reverseGear)
                  if (self.spec_motorized ~= nil and self.spec_motorized.motor ~= nil) then
                    printDebug("Motor exists, setting gear")
                    -- self.spec_motorized.motor:selectGear(data.reverseGear, true)
                    if (not self.spec_motorized.motor:getUseAutomaticGearShifting()) then
                      printDebug("Target gear was:", self.spec_motorized.motor.targetGear)
                      previousTargetGear = self.spec_motorized.motor.targetGear
                      self.spec_motorized.motor.targetGear = data.reverseGear * -1.0
                      printDebug("Setting target gear to:", self.spec_motorized.motor.targetGear)
                      printDebug("Raising onGearChanged event with time:", self.spec_motorized.motor.directionChangeTime)
                      SpecializationUtil.raiseEvent(self.spec_motorized.motor.vehicle, "onGearChanged", data.reverseGear, data.reverseGear, self.spec_motorized.motor.directionChangeTime, previousTargetGear)
                    end
                  else
                    printDebug("Motor does not exist, cannot set gear")
                  end
                else
                  printDebug("No saved reverse gear yet")
                end
              elseif direction == 1.0 then
                printDebug("Switched to FORWARD")
              else
                printDebug("Direction is neither REVERSE nor FORWARD:", direction)
              end
            else
              printDebug("Vehicle is NOT in manual gear shift mode")
            end
          else
            printDebug("Vehicle is NOT in manual direction change mode")
          end
        end
      else
        printDebug("Not on client side, skipping gear logic")
      end
      printDebug("=== ReverseGear DEBUG: onGearDirectionChanged end ===")
  end)

  Motorized.onGearChanged = Utils.appendedFunction(Motorized.onGearChanged, function(self, gear, targetGear, changeTime)
    printDebug("=== ReverseGear DEBUG: onGearChanged called ===")
    printDebug("Vehicle name:", self:getName() or "Unknown")
    printDebug("Vehicle ID:", self.uniqueId or "Unknown ID")
    printDebug("Is client:", self.isClient)
    printDebug("Gear parameter:", gear)
    printDebug("Target gear parameter:", targetGear)
    printDebug("Change time parameter:", changeTime)
    printDebug("Gear shift mode:", self:getGearShiftMode() or "Unknown")

    if self.isClient then
      local data = getVehicleData(self)
      if data == nil then
        printDebug("No vehicle data (missing ID), aborting gear change handling")
      else
        if self:getDirectionChangeMode() == VehicleMotor.DIRECTION_CHANGE_MODE_MANUAL then
          if self:getGearShiftMode() == VehicleMotor.SHIFT_MODE_MANUAL then
            printDebug("Vehicle is in MANUAL gear shift mode")
            if data.currentDirection == -1.0 then
              printDebug("Storing gear for REVERSE direction")
              if gear < 0 then
                if data.reverseGear ~= gear then
                  printDebug("Storing reverse gear:", gear)
                  data.reverseGear = gear
                else
                  printDebug("Reverse gear unchanged:", gear)
                end
              else
                printDebug("Reverse gear invalid:", gear)
              end
            else
              printDebug("Current direction is not REVERSE, not storing gear")
            end
          else
            printDebug("Vehicle is NOT in manual gear shift mode - not storing gears")
          end
        else
          printDebug("Vehicle not in manual direction change mode - not storing gears")
        end
      end
    else
      printDebug("Not on client side, skipping gear change logic")
    end

    printDebug("=== ReverseGear DEBUG: onGearChanged end ===")
  end)

  function printDebug(...)
    -- print(...)
  end

end
