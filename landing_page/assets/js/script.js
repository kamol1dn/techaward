// Header scroll effect
window.addEventListener('scroll', function () {
	const header = document.getElementById('header')
	if (window.scrollY > 50) {
		header.classList.add('scrolled')
	} else {
		header.classList.remove('scrolled')
	}
})

// Number increment animation for statistics
function animateValue(el, start, end, duration) {
	let startTimestamp = null
	const step = timestamp => {
		if (!startTimestamp) startTimestamp = timestamp
		const progress = Math.min((timestamp - startTimestamp) / duration, 1)
		el.textContent = Math.floor(progress * (end - start) + start)
		if (progress < 1) {
			window.requestAnimationFrame(step)
		}
	}
	window.requestAnimationFrame(step)
}

// Intersection Observer for scroll animations
const observer = new IntersectionObserver(
	entries => {
		entries.forEach(entry => {
			if (entry.isIntersecting) {
				entry.target.classList.add('animated')

				// If it's a stat item, animate the numbers
				if (entry.target.classList.contains('stat-item')) {
					const numberEl = entry.target.querySelector('.stat-number')
					const target = parseInt(numberEl.getAttribute('data-target'))
					animateValue(numberEl, 0, target, 2000)
				}
			}
		})
	},
	{ threshold: 0.1 }
)

document.querySelectorAll('.animate-on-scroll').forEach(el => {
	observer.observe(el)
})

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
	anchor.addEventListener('click', function (e) {
		e.preventDefault()
		document.querySelector(this.getAttribute('href')).scrollIntoView({
			behavior: 'smooth',
		})
	})
})

// Language switching functionality
const languageBtns = document.querySelectorAll('.language-dropdown a')
languageBtns.forEach(btn => {
	btn.addEventListener('click', function (e) {
		e.preventDefault()
		const lang = this.getAttribute('data-lang')
		switchLanguage(lang)

		// Update language button text
		const languageBtn = document.querySelector('.language-btn')
		if (lang === 'en') languageBtn.innerHTML = '🌐 English'
		if (lang === 'uz') languageBtn.innerHTML = "🌐 O'zbekcha"
		if (lang === 'ru') languageBtn.innerHTML = '🌐 Русский'
	})
})

function switchLanguage(lang) {
	// Hide all language elements
	document.querySelectorAll('.lang-en, .lang-uz, .lang-ru').forEach(el => {
		el.style.display = 'none'
	})

	// Show elements for selected language
	document.querySelectorAll(`.lang-${lang}`).forEach(el => {
		el.style.display = ''
	})

	// Store language preference
	localStorage.setItem('preferredLanguage', lang)
}

// Check for saved language preference
const savedLanguage = localStorage.getItem('preferredLanguage') || 'en'
switchLanguage(savedLanguage)

// Theme switching functionality
const themeToggle = document.getElementById('theme-toggle')
const themeIcon = document.getElementById('theme-icon')

// Check for saved theme preference or use system preference
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
let currentTheme =
	localStorage.getItem('theme') || (prefersDark ? 'dark' : 'light')

// Apply theme
function applyTheme(theme) {
	document.documentElement.setAttribute('data-theme', theme)
	if (theme === 'dark') {
		themeIcon.textContent = '☀️'
	} else {
		themeIcon.textContent = '🌙'
	}
	localStorage.setItem('theme', theme)
}

// Initialize theme
applyTheme(currentTheme)

// Toggle theme on button click
themeToggle.addEventListener('click', () => {
	currentTheme = currentTheme === 'dark' ? 'light' : 'dark'
	applyTheme(currentTheme)
})

// Contact form submission
const contactForm = document.getElementById('contact-form')
contactForm.addEventListener('submit', function (e) {
	e.preventDefault()

	// Get form values
	const name = document.getElementById('name').value
	const email = document.getElementById('email').value
	const message = document.getElementById('message').value

	// Here you would typically send the data to a server
	// For this example, we'll just log it and show an alert
	console.log({ name, email, message })

	// Show success message in selected language
	const currentLang = localStorage.getItem('preferredLanguage') || 'en'
	if (currentLang === 'en') {
		alert('Thank you for your message! We will contact you soon.')
	} else if (currentLang === 'uz') {
		alert("Xabaringiz uchun rahmat! Tez orada siz bilan bog'lanamiz.")
	} else if (currentLang === 'ru') {
		alert('Спасибо за ваше сообщение! Мы свяжемся с вами в ближайшее время.')
	}

	// Reset form
	contactForm.reset()
})
