switchNav  = () ->
    # Get elements
    nav = document.querySelector "nav"
    btn = document.querySelector "#open-menu"
    icon = btn.querySelector "i"
    console.log nav

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

parallax = () ->
	element = document.querySelector "section.landing"

	yPos = window.pageYOffset / element.dataset.parallaxSpeed
	yPos = -yPos;
	coords = 'center '+ yPos + 'px'
	
	element.style.backgroundPosition = coords

window.addEventListener "scroll", parallax
