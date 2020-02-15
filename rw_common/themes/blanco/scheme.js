function activateDarkMode() {
	const rootElement = document.querySelector(':root');
	const darkTheme = {
		'--background-color: #000000',
		'--heading-color: #6699cc',
		'--text-color: #999999',
		'--link-color: #ffffff',
		'--link-hover-color: #6699cc',
		'--border-color: #cccccc',
		'--other-color: #080808',
		'--other-hover-color: #2b2b2b',
	}
	for(i in darkTheme) {
		rootElement.style.setProperty(i, darkTheme[i]);
	}
}

function activateLightMode() {
	const rootElement = document.querySelector(':root');
	const lightTheme = {
		'--background-color: #ffffff',
		'--heading-color: #6699cc',
		'--text-color: #666666',
		'--link-color: #000000',
		'--link-hover-color: #6699cc',
		'--border-color: #333333',
		'--other-color: #f7f7f7',
		'--other-hover-color: #d4d4d4',
	}
	for(i in lightTheme) {
		rootElement.style.setProperty(i, lightTheme[i]);
	}
}

/**
 * Sets a color scheme for the website.
 * If browser supports "prefers-color-scheme" it will respect the setting for light or dark mode
 * otherwise it will set a dark theme during night time
 **/
function setColorScheme() {
	const isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
	const isLightMode = window.matchMedia('(prefers-color-scheme: light)').matches;
	const isNotSpecified = window.matchMedia('(prefers-color-scheme: no-preference)').matches;
	const hasNoSupport = !isDarkMode && !isLightMode && !isNotSpecified;

	window.matchMedia('(prefers-color-scheme: dark)').addListener(e => e.matches && activateDarkMode());
	window.matchMedia('(prefers-color-scheme: light)').addListener(e => e.matches && activateLightMode());

	if(isDarkMode) activateDarkMode();
	if(isLightMode) activateLightMode();
	if(isNotSpecified || hasNoSupport) {
		console.log('No preference for color scheme was specified or browser does not support it.');
		console.log('Dark mode during night time is scheduled.');
		now = new Date();
		hour = now.getHours();
		if (hour < 6 || hour >= 18) {
			activateDarkMode();
		}
	}
}