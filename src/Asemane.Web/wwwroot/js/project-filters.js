// فیلتر روی کل مجموعه منتشرشده اعمال می‌شود، نه فقط دوازده کارت صفحه فعلی.
document.querySelectorAll('.prague-dropdown').forEach(function (dropdown) {
    var button = dropdown.querySelector('a[data-toggle="dropdown"]');
    var menu = dropdown.querySelector('.prague-dropdown-menu');
    if (!button || !menu) return;
    // HTML اصلی آیکون فلش ندارد؛ handler قالب به آن دسترسی null می‌زند.
    button.onclick = function (event) {
        event.preventDefault();
        var open = !menu.classList.contains('showee');
        menu.classList.toggle('showee', open);
        menu.classList.toggle('hidee', !open);
        button.classList.toggle('active', open);
    };
});
document.querySelectorAll('.prague-dropdown-menu [data-url]').forEach(function (item) {
    function navigate(event) {
        if (event.type === 'keydown' && event.key !== 'Enter' && event.key !== ' ') return;
        event.preventDefault();
        window.location.assign(item.dataset.url);
    }
    item.addEventListener('click', navigate);
    item.addEventListener('keydown', navigate);
});
