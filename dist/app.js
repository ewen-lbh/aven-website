
/*
 * 
 * UI RELATED
 *
 */

/*
Navbar
 */
var TOKEN, discordChannelMessages, discordGetGuild, discordGetRolesMap, discordGetUser, discordMessageAsHTML, formatTimestamp, hideNav, linkifyMentions, loadNews, parallax, removeUnicodeFonts, switchNav, treatDiscordMsg;

switchNav = function() {
  var btn, icon, nav, opened, state;
  nav = document.querySelector("nav");
  btn = document.querySelector("#open-menu");
  icon = btn.querySelector("i");
  state = nav.dataset.state;
  opened = state === "opened";
  opened = !opened;
  icon.innerText = opened ? "close" : "menu";
  if (opened) {
    return nav.dataset.state = "opened";
  } else {
    return nav.dataset.state = "closed";
  }
};

hideNav = function() {
  var nav;
  nav = document.querySelector('nav');
  if (window.pageYOffset <= window.innerHeight / 3) {
    return nav.classList.add('hidden');
  } else {
    return nav.classList.remove('hidden');
  }
};

document.addEventListener('scroll', hideNav);


/*
Parallax
 */

parallax = function() {
  var coords, element, yPos;
  element = document.querySelector("section.landing");
  yPos = window.pageYOffset / element.dataset.parallaxSpeed;
  yPos = -yPos;
  coords = 'center ' + yPos + 'px';
  return element.style.backgroundPosition = coords;
};

window.addEventListener("scroll", parallax);


/*
 * Cards grid
 * Credits goes to https://medium.com/@andybarefoot/a-masonry-style-layout-using-css-grid-8c663d355ebb
 *
 */


/*
 *
 * Discord API
 *
 */


/* TODO
- remove weird punctuation artifacts cuz these ppl can't write:
	- " , " ~> ", "
	- weirdly titlecased common nouns in the middle of a sentence
	- " . " ~> ". "
	- .trim()
	- "^\[\w*@everyone\w*\]" ~×
	- "#AvenGame" ~×
- 
-
 */


/*
I don't care, you can't do anything with this token, the bot can only read messages from public channels of this discord.
 */

TOKEN = "NjMyMjE2MDY5NDkwMDgxNzky.XbCI5g.35ioHgEMnuW3AU4F-PG61yIJnt8";

discordGetGuild = function(guildID) {
  return new Promise(function(resolve, reject) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.onload = function() {
      if (xhr.status >= 200 && xhr.status <= 300) {
        return resolve(JSON.parse(xhr.response));
      } else {
        return reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
    };
    xhr.open("GET", "https://discordapp.com/api/v6/guilds/" + guildID);
    xhr.setRequestHeader('Authorization', "Bot " + TOKEN);
    return xhr.send();
  });
};

discordGetRolesMap = function() {
  return discordGetGuild('588279707636596766').then(function(data) {
    var i, len, r, roles, rolesMap;
    roles = data.roles;
    rolesMap = {};
    for (i = 0, len = roles.length; i < len; i++) {
      r = roles[i];
      rolesMap[r.id] = r;
    }
    return rolesMap;
  });
};

discordGetRolesMap().then(function(rolesMap) {
  window.rolesMap = rolesMap;
  console.log(rolesMap);
  return loadNews();
});

discordChannelMessages = function(channelID) {
  return new Promise(function(resolve, reject) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.onload = function() {
      if (xhr.status >= 200 && xhr.status <= 300) {
        return resolve(JSON.parse(xhr.response));
      } else {
        return reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
    };
    xhr.open("GET", "https://discordapp.com/api/v6/channels/" + channelID + "/messages");
    xhr.setRequestHeader('Authorization', "Bot " + TOKEN);
    return xhr.send();
  });
};

discordGetUser = function(userID) {
  return new Promise(function(resolve, reject) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.onload = function() {
      if (xhr.status >= 200 && xhr.status <= 300) {
        return resolve(JSON.parse(xhr.response));
      } else {
        return reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
    };
    xhr.open('GET', "https://discordapp.com/api/v6/users/" + userID);
    xhr.setRequestHeader('Authorization', "Bot " + TOKEN);
    return xhr.send();
  });
};

formatTimestamp = function(timestamp) {
  var date, now;
  date = new Date(timestamp);
  now = Date.now();
  if (now.getDate === date.getDate) {
    return {
      isToday: true,
      string: "Aujourd'hui, " + (date.getHours()) + ":" + (date.getMinutes())
    };
  } else {
    return {
      isToday: false,
      string: (date.getDate()) + "/" + (date.getMonth()) + "/" + (date.getFullYear())
    };
  }
};

linkifyMentions = function(msg, msgContent) {
  var CUSTOM_LINKS, aTagUser, i, j, k, len, len1, len2, ref, ref1, ref2, role, spanTagRole, usr;
  CUSTOM_LINKS = {
    'Mx3#4002': 'https://mx3creations.com'
  };
  aTagUser = function(usr) {
    var dispText, link, text;
    text = usr.username + "#" + usr.discriminator;
    dispText = text.replace(/Aven [I|] /, '').replace(/<br>/g, '').replace(/\n/g, '');
    if (CUSTOM_LINKS[text]) {
      link = CUSTOM_LINKS[text];
      return ("<a href=\"" + link + "\">" + dispText + "</a>") + "<wbr />";
    } else {
      return ("<span class=\"discord-username\">" + dispText + "</span>") + "<wbr />";
    }
  };
  spanTagRole = function(roleID) {
    var role;
    role = window.rolesMap[roleID];
    return "<span class=\"discord-role\" style=\"color:#" + (role.color.toString(16)) + ";\">" + role.name + "</span>";
  };
  ref = msg.mention_roles;
  for (i = 0, len = ref.length; i < len; i++) {
    role = ref[i];
    msgContent = msgContent.replace("@&" + role + ">", spanTagRole(role));
  }
  ref1 = msg.mentions;
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    usr = ref1[j];
    msgContent = msgContent.replace("@!" + usr.id + ">", aTagUser(usr));
  }
  ref2 = msg.mentions;
  for (k = 0, len2 = ref2.length; k < len2; k++) {
    usr = ref2[k];
    msgContent = msgContent.replace("@" + usr.id + ">", aTagUser(usr));
  }
  msgContent = msgContent.replace(/@!?\d+>/, '');
  return msgContent;
};

removeUnicodeFonts = function(string) {
  var replacethis, transformMap, withthat;
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
  };
  for (replacethis in transformMap) {
    withthat = transformMap[replacethis];
    string = string.replace(RegExp(replacethis, 'g'), withthat);
  }
  string = string.replace(/à/g, 'à');
  return string;
};

treatDiscordMsg = function(message) {
  return {
    author: {
      username: message.author.username.replace('Aven I ', ''.trim())
    },
    content: removeUnicodeFonts(linkifyMentions(message, message.content.normalize().replace(/<[^@>]*>?/gm, '').replace(/\*/g, '').replace('[ @everyone ]', '').replace(/^\s+|\s+$/g, '').replace(/ \. /g, '. ').replace(/ , /g, ', ').replace(/\n/g, '<br>').replace(/__(.+)__/g, (function(_this) {
      return function($0, $1) {
        return "<strong>" + $1 + "</strong>";
      };
    })(this)).replace(/#AvenGame$/, '').trim())),
    date: formatTimestamp(message.timestamp)
  };
};

discordMessageAsHTML = function(msg) {
  msg = {...msg, ...treatDiscordMsg(msg)};
  if (msg.content) {
    return "<li class=\"card\"> <div class=\"card-content\"> <div class=\"card-content-inner\"> <ul class=\"top-infos\"> <li class=\"author\">" + msg.author.username + "</li> <li class=\"date" + (msg.date.isToday ? ' today' : '') + "\">" + msg.date.string + "</li> </ul> <p class=\"text\"> " + msg.content + " </p> </div> </div> </li>";
  } else {
    return "";
  }
};

loadNews = function() {
  return discordChannelMessages("598959346189205523").then(function(data) {
    var i, len, message, results;
    document.querySelector('.loading-discord-messages').style.display = "none";
    results = [];
    for (i = 0, len = data.length; i < len; i++) {
      message = data[i];
      results.push(document.querySelector('ul.cards').innerHTML += discordMessageAsHTML(message));
    }
    return results;
  });
};
