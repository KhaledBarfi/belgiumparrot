// cart.js — 24/08/2025
// Petit cache local pour le panier (clé/val) — démo UI locale, sans backend.
window.BP = window.BP || {};
BP.cart = (function(){
  const KEY='bp_cart';
  function read(){ try{ return JSON.parse(localStorage.getItem(KEY)||'{}'); }catch(_){ return {}; } }
  function write(v){ localStorage.setItem(KEY, JSON.stringify(v)); }
  function add(sku, qty=1){ const c=read(); c[sku]=(c[sku]||0)+qty; write(c); BP.events.emit('cart:changed', c); }
  function remove(sku){ const c=read(); delete c[sku]; write(c); BP.events.emit('cart:changed', c); }
  function count(){ const c=read(); return Object.values(c).reduce((a,b)=>a+(+b||0),0); }
  return { read, write, add, remove, count };
})();
document.addEventListener('click', (e)=>{
  const t=e.target.closest('[data-add-sku]');
  if(!t) return;
  e.preventDefault();
  BP.cart.add(t.getAttribute('data-add-sku'), +(t.getAttribute('data-qty')||1));
  BP.toast.show('Article ajouté au panier');
});