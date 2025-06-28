// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
	anchor.addEventListener('click', function (e) {
		e.preventDefault()
		const target = document.querySelector(this.getAttribute('href'))
		if (target) {
			target.scrollIntoView({
				behavior: 'smooth',
				block: 'start',
			})
		}
	})
})

// Change logo on scroll
window.addEventListener('scroll', function () {
	const logo = document.querySelector('.logo img')
	if (window.scrollY > 50) {
		logo.src = './assests/media/logo_white.png'
	} else {
		logo.src = './assests/media/logo.png'
	}
})

// Navbar scroll effect
window.addEventListener('scroll', function () {
	const navbar = document.querySelector('header')
	if (window.scrollY > 50) {
		navbar.classList.add('scrolled')
	} else {
		navbar.classList.remove('scrolled')
	}
})

// Carousel functionality
const carousel = document.getElementById('carousel')
const prevBtn = document.getElementById('prevBtn')
const nextBtn = document.getElementById('nextBtn')
const dotsContainer = document.getElementById('dots')

let currentSlide = 0
const totalSlides = 4

// Create dots
for (let i = 0; i < totalSlides; i++) {
	const dot = document.createElement('div')
	dot.className = 'dot'
	if (i === 0) dot.classList.add('active')
	dot.addEventListener('click', () => goToSlide(i))
	dotsContainer.appendChild(dot)
}

const dots = document.querySelectorAll('.dot')

function updateCarousel() {
	carousel.style.transform = `translateX(-${currentSlide * 100}%)`
	dots.forEach((dot, index) => {
		dot.classList.toggle('active', index === currentSlide)
	})
}

function goToSlide(slideIndex) {
	currentSlide = slideIndex
	updateCarousel()
}

function nextSlide() {
	currentSlide = (currentSlide + 1) % totalSlides
	updateCarousel()
}

function prevSlide() {
	currentSlide = (currentSlide - 1 + totalSlides) % totalSlides
	updateCarousel()
}

nextBtn.addEventListener('click', nextSlide)
prevBtn.addEventListener('click', prevSlide)

// Auto-slide every 5 seconds
setInterval(nextSlide, 5000)

// Animation on scroll
const observerOptions = {
	threshold: 0.1,
	rootMargin: '0px 0px -50px 0px',
}

const observer = new IntersectionObserver(entries => {
	entries.forEach(entry => {
		if (entry.isIntersecting) {
			entry.target.style.opacity = '1'
			entry.target.style.transform = 'translateY(0)'
		}
	})
}, observerOptions)

// Observe all sections
document.querySelectorAll('.section').forEach(section => {
	section.style.opacity = '0'
	section.style.transform = 'translateY(30px)'
	section.style.transition = 'opacity 0.6s ease, transform 0.6s ease'
	observer.observe(section)
})

// Observe feature cards
document.querySelectorAll('.feature-card').forEach((card, index) => {
	card.style.opacity = '0'
	card.style.transform = 'translateY(30px)'
	card.style.transition = `opacity 0.6s ease ${
		index * 0.1
	}s, transform 0.6s ease ${index * 0.1}s`
	observer.observe(card)
})

// Mobile menu toggle (for future implementation)
const mobileMenuBtn = document.createElement('button')
mobileMenuBtn.innerHTML = '☰'
mobileMenuBtn.className = 'mobile-menu-btn'
mobileMenuBtn.style.cssText =
	'display: none; background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer;'

document.querySelector('.nav-container').appendChild(mobileMenuBtn)

// Show mobile menu button on small screens
function checkScreenSize() {
	if (window.innerWidth <= 768) {
		mobileMenuBtn.style.display = 'block'
	} else {
		mobileMenuBtn.style.display = 'none'
	}
}

window.addEventListener('resize', checkScreenSize)
checkScreenSize()
