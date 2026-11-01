'use strict';
const toggle = document.querySelector('.menu-toggle');
const nav = document.getElementById('main-nav');
if (toggle && nav) {
    toggle.addEventListener('click', () => { const open = nav.classList.toggle('open'); toggle.setAttribute('aria-expanded',String(open)); });
    document.addEventListener('keydown',event => { if (event.key === 'Escape') { nav.classList.remove('open'); toggle.setAttribute('aria-expanded','false'); toggle.focus(); } });
}
const track = document.getElementById('showcase-track');
document.querySelectorAll('[data-scroll]').forEach(button => button.addEventListener('click', () => {
    if (track) track.scrollBy({ left: Number(button.dataset.scroll)*track.clientWidth*.75, behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth' });
}));
const preview = document.getElementById('gallery-preview');
const caption = document.getElementById('gallery-caption');
let imageRequest = 0;
document.querySelectorAll('[data-image]').forEach(button => button.addEventListener('click', () => {
    if (!preview) return;
    const request = ++imageRequest;
    const image = new Image();
    image.onload = () => {
        if (request !== imageRequest) return;
        preview.src = button.dataset.image;
        preview.alt = button.dataset.alt || '';
        if (caption) caption.textContent = button.dataset.caption || '';
        document.querySelectorAll('[data-image]').forEach(other => other.setAttribute('aria-pressed',String(other === button)));
    };
    image.onerror = () => { if (request === imageRequest && caption) caption.textContent = 'This image could not be loaded. Please try again.'; };
    image.src = button.dataset.image;
}));
