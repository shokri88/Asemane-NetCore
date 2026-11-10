(function () {
    'use strict';
    // همان شمارنده‌های قالب با شروع هنگام دیده‌شدن؛ صفر و مقادیر بزرگ هم پایان قطعی دارند.
    function animate(element) {
        if (element.dataset.counted === 'true') return;
        element.dataset.counted = 'true';
        var target = Number(element.textContent.trim());
        if (!Number.isSafeInteger(target) || target < 0) return;
        if (target === 0 || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
        var start;
        function tick(time) {
            if (start === undefined) start = time;
            var progress = Math.min((time - start) / 1500, 1);
            element.textContent = String(Math.floor(target * progress));
            if (progress < 1) window.requestAnimationFrame(tick);
        }
        window.requestAnimationFrame(tick);
    }
    function init() {
        var counters = document.querySelectorAll('.about-page .counter-num');
        if (!('IntersectionObserver' in window)) return;
        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                animate(entry.target);
                observer.unobserve(entry.target);
            });
        }, { threshold: 0.5 });
        counters.forEach(function (counter) { observer.observe(counter); });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
})();
