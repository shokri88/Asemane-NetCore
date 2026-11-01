'use strict';
document.querySelectorAll('form[data-confirm]').forEach(form => {
    form.addEventListener('submit', event => { if (!window.confirm(form.dataset.confirm)) event.preventDefault(); });
});
document.querySelectorAll('[data-counter]').forEach(input => {
    const counter = document.getElementById(input.dataset.counter);
    const update = () => { if (counter) counter.textContent = `${input.value.length.toLocaleString('fa-IR')} / ${input.maxLength.toLocaleString('fa-IR')} کاراکتر`; };
    input.addEventListener('input',update); update();
});
const currentPath = location.pathname.toLowerCase();
document.querySelectorAll('.admin-sidebar .nav-link').forEach(link => {
    const target = new URL(link.href);
    const match = currentPath === target.pathname.toLowerCase() || (target.pathname.toLowerCase() !== '/admin' && currentPath.startsWith(target.pathname.toLowerCase().replace(/\/index$/,'')));
    if (match && (!target.searchParams.has('kind') || target.searchParams.get('kind') === new URLSearchParams(location.search).get('kind'))) { link.classList.add('active'); link.setAttribute('aria-current','page'); }
});
