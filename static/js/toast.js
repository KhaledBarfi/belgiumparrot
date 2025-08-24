// toast.js — 24/08/2025
window.BP = window.BP || {};
BP.toast = (function(){
  function show(msg, timeout=2500){
    let el = document.createElement('div');
    el.className = 'bp-toast';
    el.textContent = msg;
    Object.assign(el.style,{
      position:'fixed', bottom:'20px', right:'20px', background:'#333', color:'#fff',
      padding:'10px 14px', borderRadius:'8px', boxShadow:'0 2px 10px rgba(0,0,0,.25)', zIndex:9999,
      opacity:'0', transition:'opacity .12s ease'
    });
    document.body.appendChild(el);
    requestAnimationFrame(()=>{ el.style.opacity='1'; });
    setTimeout(()=>{ el.style.opacity='0'; setTimeout(()=> el.remove(), 200); }, timeout);
  }
  return { show };
})();