###
# 
# UI RELATED
# 
###

###
Navbar
###

switchNav = () ->
	# Get elements
	nav = document.querySelector "nav"
	btn = document.querySelector "#open-menu"
	icon = btn.querySelector "i"

	# Get current nav state
	state = nav.dataset.state
	opened = state == "opened"

	# Switch the state
	opened = !opened

	# Apply the correct icon
	icon.innerText = if opened then "close" else "menu"

	# Update the <nav> state
	if opened
		nav.dataset.state = "opened"
	else
		nav.dataset.state = "closed"

hideNav = () ->
	nav = document.querySelector 'nav'
	if window.pageYOffset <= window.innerHeight/3
		nav.classList.add 'hidden' 
	else 
		nav.classList.remove 'hidden'

document.addEventListener('scroll', hideNav)

###
Parallax
###

parallax = () ->
	element = document.querySelector "section.landing"

	yPos = window.pageYOffset / element.dataset.parallaxSpeed
	yPos = -yPos;
	coords = 'center '+ yPos + 'px'

	element.style.backgroundPosition = coords

window.addEventListener "scroll", parallax

###
# Cards grid
# Credits goes to https://medium.com/@andybarefoot/a-masonry-style-layout-using-css-grid-8c663d355ebb
# ###

# resizeGridItem = (item) ->
# 	grid = document.querySelector('.cards')[0]
# 	rowHeight = parseInt(window.getComputedStyle(grid).getPropertyValue('grid-auto-rows'))
# 	rowGap = parseInt(window.getComputedStyle(grid).getPropertyValue('grid-row-gap'))
# 	rowSpan = Math.ceil((item.querySelector('.content').getBoundingClientRect().height + rowGap) / (rowHeight + rowGap))
# 	item.style.gridRowEnd = 'span ' + rowSpan

# resizeAllGridItems = ->
# 	allItems = document.querySelector('.card')
# 	x = 0
# 	while x < allItems.length
# 		resizeGridItem allItems[x]
# 		x++

# resizeInstance = (instance) ->
# 	item = instance.elements[0]
# 	resizeGridItem item

# window.onload = resizeAllGridItems()
# window.addEventListener 'resize', resizeAllGridItems
# allItems = document.querySelector '.card'
# x = 0
# while x < allItems.length
# 	imagesLoaded allItems[x], resizeInstance
# 	x++

###
#
# Discord API
#
###

### TODO
- remove weird punctuation artifacts cuz these ppl can't write:
	- " , " ~> ", "
	- weirdly titlecased common nouns in the middle of a sentence
	- " . " ~> ". "
	- .trim()
	- "^\[\w*@everyone\w*\]" ~×
	- "#AvenGame" ~×
- 
- 
###

###
I don't care, you can't do anything with this token, the bot can only read messages from public channels of this discord.
###
TOKEN = "NjMyMjE2MDY5NDkwMDgxNzky.XbCI5g.35ioHgEMnuW3AU4F-PG61yIJnt8"

discordGetGuild = (guildID) ->
	new Promise (resolve, reject) ->
		xhr = new XMLHttpRequest
		xhr.onload = () -> 
			# Process returned data
			if xhr.status >= 200 && xhr.status <= 300
				resolve(JSON.parse(xhr.response))
			else
				reject({
					status: this.status,
					statusText: xhr.statusText
				})
		xhr.open "GET", "https://discordapp.com/api/v6/guilds/#{guildID}"
		xhr.setRequestHeader 'Authorization', "Bot #{TOKEN}"
		xhr.send()

discordGetRolesMap = () ->
	discordGetGuild('588279707636596766').then (data) ->
		roles = data.roles
		rolesMap = {}
		rolesMap[r.id] = r for r in roles
		return rolesMap

discordGetRolesMap().then (rolesMap) -> 
	window.rolesMap = rolesMap
	console.log rolesMap
	loadNews()

discordChannelMessages = (channelID) ->
	new Promise (resolve, reject) ->
		xhr = new XMLHttpRequest
		xhr.onload = () -> 
			# Process returned data
			if xhr.status >= 200 && xhr.status <= 300
				resolve(JSON.parse(xhr.response))
			else
				reject({
					status: this.status,
					statusText: xhr.statusText
				})
		xhr.open "GET", "https://discordapp.com/api/v6/channels/#{channelID}/messages"
		xhr.setRequestHeader 'Authorization', "Bot #{TOKEN}"
		xhr.send()

discordGetUser = (userID) ->
	new Promise (resolve, reject) ->
		xhr = new XMLHttpRequest
		xhr.onload = () ->
			if xhr.status >= 200 && xhr.status <= 300
				resolve(JSON.parse(xhr.response))
			else
				reject({
					status: this.status,
					statusText: xhr.statusText
				})
		xhr.open 'GET', "https://discordapp.com/api/v6/users/#{userID}"
		xhr.setRequestHeader 'Authorization', "Bot #{TOKEN}"
		xhr.send()

formatTimestamp = (timestamp) ->
	date = new Date timestamp
	now = Date.now()
	if now.getDate == date.getDate
		{isToday: true, string: "Aujourd'hui, #{date.getHours()}:#{date.getMinutes()}"}
	else
		{isToday: false, string: "#{date.getDate()}/#{date.getMonth()}/#{date.getFullYear()}"}

linkifyMentions = (msg, msgContent) ->
	CUSTOM_LINKS = {
		'Mx3#4002': 'https://mx3creations.com'
	}
	aTagUser = (usr) ->
		text = "#{usr.username}##{usr.discriminator}"
		dispText = text
			.replace /Aven [I|] /, '' # Remove the "Aven |" username header
			.replace /<br>/g, ''  # Remove linebreaks *inside* usernames
			.replace /\n/g, ''
		
		if CUSTOM_LINKS[text]
			link = CUSTOM_LINKS[text]
			"<a href=\"#{link}\">#{dispText}</a>" + "<wbr />" # Prevents the browser from breaking the line inside usernames by indicating that they can break the line after it.
		else
			"<span class=\"discord-username\">#{dispText}</span>" + "<wbr />" # Prevents the browser from breaking the line inside usernames by indicating that they can break the line after it.

	spanTagRole = (roleID) ->
		role = window.rolesMap[roleID]
		"<span class=\"discord-role\" style=\"color:##{role.color.toString 16};\">#{role.name}</span>"

	msgContent = msgContent.replace "@&#{role}>", spanTagRole(role) for role in msg.mention_roles
	msgContent = msgContent.replace "@!#{usr.id}>", aTagUser(usr) for usr in msg.mentions
	msgContent = msgContent.replace "@#{usr.id}>", aTagUser(usr) for usr in msg.mentions
	msgContent = msgContent.replace /@!?\d+>/, ''  # Remove mentions that were not found
	return msgContent


removeUnicodeFonts = (string) ->
	transformMap = {
		"𝐚": "a",
		"𝐛": "b",
		"𝐜": "c",
		"𝐝": "d",
		"𝐞": "e",
		"𝐟": "f",
		"𝐠": "g",
		"𝐡": "h",
		"𝐢": "i",
		"𝐣": "j",
		"𝐤": "k",
		"𝐥": "l",
		"𝐦": "m",
		"𝐧": "n",
		"𝐨": "o",
		"𝐩": "p",
		"𝐪": "q",
		"𝐫": "r",
		"𝐬": "s",
		"𝐭": "t",
		"𝐮": "u",
		"𝐯": "v",
		"𝐰": "w",
		"𝐱": "x",
		"𝐲": "y",
		"𝐳": "z",
		"𝐀": "A",
		"𝐁": "B",
		"𝐂": "C",
		"𝐃": "D",
		"𝐄": "E",
		"𝐅": "F",
		"𝐆": "G",
		"𝐇": "H",
		"𝐈": "I",
		"𝐉": "J",
		"𝐊": "K",
		"𝐋": "L",
		"𝐌": "M",
		"𝐍": "N",
		"𝐎": "O",
		"𝐏": "P",
		"𝐐": "Q",
		"𝐑": "R",
		"𝐒": "S",
		"𝐓": "T",
		"𝐔": "U",
		"𝐕": "V",
		"𝐖": "W",
		"𝐗": "X",
		"𝐘": "Y",
		"𝐙": "Z",
		"𝟎": "0",
		"𝟏": "1",
		"𝟐": "2",
		"𝟑": "3",
		"𝟒": "4",
		"𝟓": "5",
		"𝟔": "6",
		"𝟕": "7",
		"𝟗": "8"
	}

	for replacethis, withthat of transformMap
		string = string.replace RegExp(replacethis, 'g'), withthat
	# Replaces weirdly rendered à's. Don't touch this, the /à/ is not the same as the à.
	string = string.replace /à/g, 'à'
	return string

treatDiscordMsg = (message) ->
	{
		author: {
			username: message.author.username.replace 'Aven I ', ''.trim()
		},
		content: removeUnicodeFonts(linkifyMentions(message, message.content
			# Remove HTML, cuz we use v-html to enable <a> tags for mentions, 
			# but we don't want XSS attacks to happen
			# ↓
			.normalize()
			.replace(/<[^@>]*>?/gm, '')
			.replace(/\*/g, '')  # Remove discord formatting (very coarse, WIP)
			.replace('[ @everyone ]', '')  # Remove the mention
			.replace(/^\s+|\s+$/g, '')  # Remove leading/trailing newlines
			.replace(/ \. /g, '. ') # " . " ~> ". "
			.replace(/ , /g, ', ') # " , " ~> ", "
			.replace(/\n/g, '<br>')  # HTML Linebreaks
			.replace(/__(.+)__/g, ($0, $1) => "<strong>#{$1}</strong>")  # Markdown emphasis
			.replace(/#AvenGame$/, '')
			.trim()
		)),
		date: formatTimestamp message.timestamp,
	}

discordMessageAsHTML = (msg) ->
	`msg = {...msg, ...treatDiscordMsg(msg)}`
	if msg.content
		"<li class=\"card\">
			<div class=\"card-content\">
				<div class=\"card-content-inner\">
					<ul class=\"top-infos\">
						<li class=\"author\">#{msg.author.username}</li>
						<li class=\"date#{if msg.date.isToday then ' today' else ''}\">#{msg.date.string}</li>
					</ul>
					<p class=\"text\">
						#{msg.content}
					</p>
				</div>
			</div>
		</li>"
	else
		""

loadNews = () ->
	discordChannelMessages("598959346189205523").then (data) ->
		document.querySelector('.loading-discord-messages').style.display = "none"
		document.querySelector('ul.cards').innerHTML += discordMessageAsHTML(message) for message in data
