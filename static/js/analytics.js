// analytics.js — 24/08/2025
// Mock d'événements console (remplaçable par Matomo/GA)
window.BP = window.BP || {};
BP.analytics = {
  track: (ev, payload={}) => {
    const ts = new Date().toISOString();
    console.log('[BP][', ts, ']', ev, payload);
  }
};
document.addEventListener('click', (e)=>{
  const btn = e.target.closest('a.btn,button.btn');
  if(btn){ BP.analytics.track('ui.click', { text: btn.textContent?.trim() }); }
});