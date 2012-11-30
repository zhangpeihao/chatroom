
describe("房间单元测试", function()
  describe("测试平台检查", function()
    it("平台应该提供基础检查功能", function()
      assert.truthy("Yup.")
      assert.is_true(true)
      assert.is_false(false)
      local obj1 = { name = "zph" }
      local obj2 = { name = "zph" }
      local obj3 = { name = "peihao" }
      local obj4 = obj1
      assert.are.same(obj1, obj2)
      assert.are_not.same(obj1, obj3)
      assert.are_not.equal(obj1, obj2)
      assert.are.equal(obj1, obj4)
    end)
    it("平台应该提供错误检查功能", function()
      assert.has_error(function() error("Yup,  it errored") end)
      assert.has_no.errors(function() end)
      local errfn = function()
        error("ERROR SAMPLE")
      end
      assert.has_error(errfn, "ERROR SAMPLE")
    end)
    it("平台应该提供函数监测功能", function()
      local s = spy.new()
      s(1, 2, 3)
      s(4, 5, 6)
      assert.spy(s).was.called()
      assert.spy(s).was.called(2) -- twice!
      assert.spy(s).was.called_with(1, 2, 3) -- checks the history
    end)
    it("平台应该提供函数模拟替换功能", function()
      local t = {
        greet = function(msg) print(msg) end
      }
      spy.on(t, "greet")
      t.greet("Hey!") -- prints 'Hey!'
      assert.spy(t.greet).was_called_with("Hey!")
    end)
    it("平台应该提供桩函数功能", function()
      local t = {
        greet = function(msg) print(msg) end
      }
      stub(t, "greet")
      t.greet("Hey!") -- DOES NOT print 'Hey!'
      assert.spy(t.greet).was.called_with("Hey!")
    end)
    it("平台应该提供监测Mocks功能", function()
      local t = {
        thing = function(msg) print(msg) end
      }

      local m = mock(t)

      m.thing("Coffee")
      assert.spy(m.thing).was.called_with("Coffee")
    end)
    it("平台应该提供模拟Mocks功能", function()
      local t = {
        thing = function(msg) print(msg) end
      }

      local m = mock(t, true)

      m.thing("Coffee")
      assert.spy(m.thing).was.called_with("Coffee")
    end)
  end)

  describe("房间基本功能", function()
    -- common Mock
    local common = {
      dumplog = function(msg) end,
      warnlog = function(msg) end
    }

    -- 网络Mock
    local networking = {
      disconnect = function(connId) end,
      request = function(uid, msgId, msg) end
    }
    local room
    it("应该可以加载聊天模块", function()
      room = require("chatroom")
    end)
    it("初始房间人数为0", function()
      assert.are.equal(0, room.number())
    end)
    it("应该可以设置和读取房间ID", function()
      assert.are.equal(0, room.rid)
      room.rid = 1
      assert.are.equal(1, room.rid)
    end)
    it("应该可以添加用户", function()
      local user = {
        Uid = 1,
        Nickname = "zph",
        Exp1 = 12345,
        Exp2 = 54321,
        OtherInfo = "Other info"
      }
      assert.has_no.errors(function() room.add(user) end)
      assert.are.equal(1, room.number())
    end)
    it("应该可以修改用户信息", function()
      local user = {
        Uid = 1,
        Exp1 = 1234,
        Exp2 = 4321,
      }
      assert.is_true(room.update(user))
      users = room.get(0)
      assert.are.equal(1, #users)
      assert.are.equal(1, users[1].Uid)
      assert.are.equal(1234, users[1].Exp1)
      assert.are.equal(4321, users[1].Exp2)
      assert.are.equal("zph", users[1].Nickname)
      assert.are.equal("Other info", users[1].OtherInfo)
    end)
    it("修改不存在的用户信息应该失败", function()
      local user = {
        Uid = 2,
        Nickname = "peihao",
        Exp1 = 1234,
        Exp2 = 4321,
        OtherInfo = "Other info"
      }
      assert.is_false(room.update(user))
    end)
    it("删除不存在的用户应该失败", function()
      assert.is_false(room.delete(2))
    end)
    it("应该可以删除用户", function()
      assert.is_true(room.delete(1))
      assert.are.equal(0, room.number())
    end)
    it("可以得到排好序的指定前N个用户数据", function()
      require("math")
      math.randomseed(os.time())
      for i = 1, 200, 1 do
        local user = {
          Uid = i,
          Nickname = "peihao",
          Exp1 = math.random(1, 100),
          Exp2 = math.random(1, 100),
          OtherInfo = "Othe info"
        }
        room.add(user)
      end
      local users = room.get(0)
      assert.are.equal(200, #users)
      assert.are.equal(200, table.getn(users))
      local userIds = {}
      local lastExp1 = 100
      local lastExp2 = 100
      for i = 1, 200, 1 do
        userIds[users[i].Uid] = i
        assert.is_false(lastExp1 < users[i].Exp1 or (lastExp1 == users[i].Exp1 and lastExp2 < users[i].Exp2))
        lastExp1 = users[i].Exp1
        lastExp2 = users[i].Exp2
      end
      assert.are.equal(200, #userIds)
      assert.are.equal(200, table.getn(userIds))

      users = room.get(1)
      assert.are.equal(1, #users)
      assert.are.equal(1, table.getn(users))
      users = room.get(100)
      assert.are.equal(100, #users)
      assert.are.equal(100, table.getn(users))
      users = room.get(200)
      assert.are.equal(200, #users)
      assert.are.equal(200, table.getn(users))
      users = room.get(1000)
      assert.are.equal(200, #users)
      assert.are.equal(200, table.getn(users))
    end)
    it("修改用户排序数据应该修改排序", function()
      users = room.get(3)
      assert.are.equal(3, #users)
      -- Change users[2] to position 1
      user1 = {
        Uid = users[1].Uid,
        Exp1 = users[1].Exp1
      }
      user2 = {
        Uid = users[2].Uid,
        Exp1 = users[1].Exp1 + 1
      }
      assert.is_true(room.update(user2))
      users = room.get(3)
      assert.are.equal(3, #users)
      assert.are.equal(user2.Uid, users[1].Uid)
      assert.are.equal(user2.Exp1, users[1].Exp1)
      assert.are.equal(user1.Uid, users[2].Uid)
      assert.are.equal(user1.Exp1, users[2].Exp1)
    end)
    it("修改用户非排序数据不应该修改排序", function()
      users = room.get(3)
      assert.are.equal(3, #users)
      userIds = {users[1].Uid, users[2].Uid, users[3].Uid} 
      user2 = {
        Uid = users[2].Uid,
        Nickname = "Zhang",
        Foo = "Bar"
      }
      assert.is_true(room.update(user2))
      users = room.get(3)
      for i = 1, 3, 1 do
        assert.are.equal(userIds[i], users[i].Uid)
      end
    end)
    it("删除用户应该修改排序", function()
      users = room.get(3)
      assert.are.equal(3, #users)
      userIds = {users[1].Uid, users[2].Uid, users[3].Uid} 
      assert.is_true(room.delete(users[2].Uid))
      users = room.get(2)
      assert.are.equal(2, #users)
      assert.are.equal(userIds[1], users[1].Uid)
      assert.are.equal(userIds[3], users[2].Uid)
    end)
  end)
end)
