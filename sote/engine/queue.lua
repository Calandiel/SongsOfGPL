---@class Queue
---@field data table
---@field first integer
---@field last integer
---@field new fun():Queue
---@field enqueue fun(self: Queue, element: any)
---@field enqueue_front fun(self: Queue, element: any)
---@field dequeue fun():any
---@field length fun():integer
---@field peek fun():any
---@field clear fun()

local Queue = {}
Queue.__index = Queue
---Returns a new queue
---@return Queue
function Queue:new()
	local q = {}

	q.first = 0
	q.last = 0
	q.data = {}

	setmetatable(q, Queue)
	return q
end

---Enqueues an element
---@param element any
function Queue:enqueue(element)
	self.last = self.last + 1
	self.data[self.last] = element
end

---Enqueues an element IN FRONT of the queue
function Queue:enqueue_front(element)
	if self:length() > 0 then
		self.first = self.first - 1
		self.data[self.first] = element
	else
		self:enqueue(element)
	end
end

---Dequeues an element and returns it
---@return any
function Queue:dequeue()
	self.first = self.first + 1
	return self.data[self.first]
end

---Returns an element without dequeuing it
---@return any
function Queue:peek()
	return self.data[self.first + 1]
end

---Returns the length of the queue
---@return integer
function Queue:length()
	return self.last - self.first
end

---Clears the queue
function Queue:clear()
	self.first = 0
	self.last = 0
	for k, _ in pairs(self.data) do
		self.data[k] = nil
	end
end

return Queue
