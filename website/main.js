// Starfield Animation
const starField = document.getElementById('star-field');
const starCount = 200;

function createStars() {
  for (let i = 0; i < starCount; i++) {
    const star = document.createElement('div');
    star.className = 'star';
    
    // Random position
    const x = Math.random() * 100;
    const y = Math.random() * 100;
    
    // Random size
    const size = Math.random() * 2 + 1;
    
    // Random delay
    const delay = Math.random() * 5;
    
    star.style.cssText = `
      position: absolute;
      left: ${x}%;
      top: ${y}%;
      width: ${size}px;
      height: ${size}px;
      background: #fff;
      border-radius: 50%;
      opacity: ${Math.random()};
      animation: pulse ${Math.random() * 3 + 2}s infinite ${delay}s;
      pointer-events: none;
    `;
    
    starField.appendChild(star);
  }
}

// Add keyframes for pulsing stars
const style = document.createElement('style');
style.textContent = `
  @keyframes pulse {
    0%, 100% { opacity: 0.3; transform: scale(1); }
    50% { opacity: 1; transform: scale(1.2); }
  }
`;
document.head.appendChild(style);

createStars();

// Simple Scroll Animation Reveal
const observerOptions = {
  threshold: 0.1
};

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('reveal');
    }
  });
}, observerOptions);

// Select elements to animate
const animElements = document.querySelectorAll('.feature-card, .cefr-item, .gallery-item, .section-header');

// Add initial hidden style and transition
animElements.forEach(el => {
  el.style.opacity = '0';
  el.style.transform = 'translateY(30px)';
  el.style.transition = 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)';
  observer.observe(el);
});

// Keyframes for reveal (added to style element)
style.textContent += `
  .reveal {
    opacity: 1 !important;
    transform: translateY(0) !important;
  }
`;

// Parallax Effect for Ship
window.addEventListener('mousemove', (e) => {
  const ship = document.querySelector('.floating-ship');
  if (ship) {
    const moveX = (e.clientX - window.innerWidth / 2) * 0.01;
    const moveY = (e.clientY - window.innerHeight / 2) * 0.01;
    ship.style.transform = `translate(${moveX}px, ${moveY}px)`;
  }
});
