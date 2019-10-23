var parallax, switchNav;

switchNav = function() {
  var btn, icon, nav, opened, state;
  nav = document.querySelector("nav");
  btn = document.querySelector("#open-menu");
  icon = btn.querySelector("i");
  console.log(nav);
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

parallax = function() {
  var coords, element, yPos;
  element = document.querySelector("section.landing");
  yPos = window.pageYOffset / element.dataset.parallaxSpeed;
  yPos = -yPos;
  coords = 'center ' + yPos + 'px';
  return element.style.backgroundPosition = coords;
};

window.addEventListener("scroll", parallax);
