// lazyload.js — 24/08/2025
(function(){
  const isNative = 'loading' in HTMLImageElement.prototype;
  function enhance(img){
    if(!img.dataset.src) return;
    if(isNative){ img.loading='lazy'; img.src=img.dataset.src; return; }
    const io = new IntersectionObserver((entries)=>{
      entries.forEach(e=>{
        if(e.isIntersecting){ img.src = img.dataset.src; io.unobserve(img); }
      });
    },{rootMargin:'200px'});
    io.observe(img);
  }
  document.addEventListener('DOMContentLoaded', ()=>{
    document.querySelectorAll('img[data-src]').forEach(enhance);
  });
})();