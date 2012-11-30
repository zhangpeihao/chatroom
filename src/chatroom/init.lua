-- init.lua
--
-- Initialize room
local _G = _G

module(...)

local chatroom = {}
local _number = 0
chatroom.rid = 0
local _tail = nil
local _head = {next = _tail}

local function compareUser(user1, user2)
	if user1.Exp1 < user2.Exp1 then
		return 1
	elseif user1.Exp1 == user2.Exp1 then
		if user1.Exp2 < user2.Exp2 then
			return 1
		elseif user1.Exp2 == user2.Exp2 then
			if user1.Uid < user2.Uid then
				return 1
			elseif user1.Uid == user2.Uid then
				return 0
			else
				return -1
			end
		else
			return -1
		end
	else
		return -1
	end
end

local function mergeUser(user1, user2)
  user = {}
  for k, v in _G.pairs(user1) do
    user[k] = v
  end
  for k, v in _G.pairs(user2) do
    user[k] = v
  end
  return user
end

-----------------------------------------------
-- Get user number
-- @return user number
-----------------------------------------------
function chatroom.number()
  return _number
end

-----------------------------------------------
-- Add new user
-- @param user user data.
-----------------------------------------------
function chatroom.add(user)
	local pre = _head
	local scan = _head.next
	while scan ~= nil do
		if compareUser(user, scan.user) == 1 then
			pre = scan
			scan = scan.next
		else
			pre.next = {next=scan, user=user, ldata={watchpos=0}}
      _number = _number + 1
			return
		end
	end
	pre.next = {next=nil, user=user}
  _number = _number + 1
	return
end

-----------------------------------------------
-- Update user
-- @param user user data.
-- @return success or not
-----------------------------------------------
function chatroom.update(user)
	local userId = user.Uid
	local pre = _head
	local scan = _head.next
	-- find user
	while scan ~= nil do
		if scan.user.Uid ~= userId then
			pre = scan
			scan = scan.next
		else
      local user = mergeUser(scan.user, user)
			local changed = compareUser(user, scan.user)
			if changed == 0 then
				-- no order change, update
				scan.user = user
			else
				-- order changed, remove first
				pre.next = scan.next
        _number = _number - 1
				-- add again
				chatroom.add(user)
			end
			return true
		end
	end
  return false
end

-----------------------------------------------
-- Delete user
-- @param userId user's id.
-- @return true:  found user and deleted
--         false: not found user
-----------------------------------------------
function chatroom.delete(userId)
	local pre = _head
	local scan = _head.next
	while scan ~= nil do
		if scan.user.Uid ~= userId then
			pre = scan
			scan = scan.next
		else
			pre.next = scan.next
      _number = _number - 1
			return true
		end
	end
  return false
end	

-----------------------------------------------
-- Get user list
-- @param number - the number of users want to get. 0 means all users
-- @return user list
-----------------------------------------------
function chatroom.get(number)
  if number == 0 then
    number = _number
  end

	local pre = _head
	local scan = _head.next
  local users = {}
  local index = 1
	while scan ~= nil do
    users[index] = scan.user
    pre = scan
    scan = scan.next
    index = index + 1
    if index > number then
      break
    end
	end
  return users
end	

return chatroom