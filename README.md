# mdtorich-lua
Small Lua module for converting Markdown-formatted text to text with basic rich tags.
Originally made for a Luau-based project, but this should be backwards-compatible with Lua 5.1 and beyond.

# NOTES
Supports the following:
- **bold**
- *italics*
- ***italics & bold***
- __underline__
  - (this isn't in standard Markdown, but is found on Discord)
- ~~strikethrough~~
- escape characters (\\)

Does **NOT** pass the CommonMark test. Don't use it in any serious applications.

Quality not guaranteed.

# LICENSE
MIT license. See [LICENSE](https://github.com/michaelahaynesjr/mdtorich-lua/blob/main/LICENSE) for more info.
