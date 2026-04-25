local MDToRich = {}

-- Converts a Markdown-formatted message to rich text
-- @param text
-- @return the text, with Markdown symbols converted to rich text
function MDToRich:Convert(text)
	-- Return nil/empty messages
	if not text or text == "" then
		return ""
	end
	-- Return things that aren't strings
	if type(text) ~= "string" then
		warn("MDToRich: Passed value .."..tostring(text).." isn't a string")
		return ""
	end
	
	-- Escape characters that need to be escaped
	text = escape(text)

	-- bold+italics (triple asterisks)
	text = text:gsub("%*%*%*([^\n]-)%*%*%*", function(content)
		return "<b><i>" .. content .. "</i></b>"
	end)

	-- bold (double asterisks, not part of triple)
	text = text:gsub("()%*%*([^\n]-)%*%*()", function(startIdx, content, endIdx)
		if content == "" or content:match("^%s+$") then
			return "**" .. content .. "**"
		end
		return "<b>" .. content .. "</b>"
	end)

	-- underline (after all asterisk-based formatting so it can wrap formatted text)
	text = text:gsub("__(.-)__", function(content)
		if content:find("\n") or content:find("__") or content == "" then
			return "__" .. content .. "__"
		end
		return "<u>" .. content .. "</u>"
	end)

	-- strikethrough (~~text~~ becomes <s>text</s>)
	text = text:gsub("~~(.-)~~", function(content)
		if content:find("\n") or content:find("~~") or content == "" then
			return "~~" .. content .. "~~"
		end
		return "<s>" .. content .. "</s>"
	end)

	-- italics (single asterisks, not part of double/triple)
	-- To allow italics to wrap tags, we need to match *...* where ... can include tags
	-- We'll repeat the italics replacement until no more matches are found
	local function italics_replacer(pre, content, post)
		if pre == "*" or post == "*" or content == "" then
			return pre .. "*" .. content .. "*" .. post
		end
		return pre .. "<i>" .. content .. "</i>" .. post
	end

	local prev
	repeat
		prev = text
		-- Match *text* surrounded by non-asterisk characters (including tags)
		text = text:gsub("([^%*])%*([^\n%*]+)%*([^%*])", italics_replacer)
		-- Match *text* at start of string
		text = text:gsub("^%*([^\n%*]+)%*([^%*])", function(content, post)
			if post == "*" or content == "" then
				return "*" .. content .. "*" .. post
			end
			return "<i>" .. content .. "</i>" .. post
		end)
		-- Match *text* at end of string
		text = text:gsub("([^%*])%*([^\n%*]+)%*$", function(pre, content)
			if pre == "*" or content == "" then
				return pre .. "*" .. content .. "*"
			end
			return pre .. "<i>" .. content .. "</i>"
		end)
		-- Match *text* as the whole string
		text = text:gsub("^%*([^\n%*]+)%*$", function(content)
			if content == "" then
				return "*" .. content .. "*"
			end
			return "<i>" .. content .. "</i>"
		end)
	until text == prev

	-- Unescape characters
	text = unescape(text)
	
	return text
end

-- Escapes characters that need to be escaped
-- @param text
-- @return text with escaped characters.
function escape(text)
	-- Escape any character preceded by a backslash
	-- We'll encode it as \0ESCAPED<ascii>\0
	-- Example: \* -> \0ESCAPED42\0
	return text:gsub("\\(.)", function(c)
		return "\0ESCAPED" .. string.byte(c) .. "\0"
	end)
end

-- Takes text put through escape() and unescapes it
-- @param escaped text
-- @return text with unescaped characters.
function unescape(text)
	-- Replace our placeholders with the original character
	return text:gsub("\0ESCAPED(%d+)\0", function(num)
		return string.char(tonumber(num))
	end)
end

print(MDToRich:Convert(1))

return MDToRich
