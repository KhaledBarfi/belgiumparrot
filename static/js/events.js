// events.js — 24/08/2025
window.BP = window.BP || {};
BP.events = (function(){
  const bus = {};
  return {
    on: (evt, fn) => { (bus[evt] = bus[evt] || []).push(fn); },
    off: (evt, fn) => { bus[evt] = (bus[evt]||[]).filter(f=>f!==fn); },
    emit: (evt, data) => { (bus[evt]||[]).forEach(fn=>{ try{ fn(data); }catch(e){ console.error(e); } }); }
  };
})();