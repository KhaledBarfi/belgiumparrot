// i18n.js — 24/08/2025
window.BP = window.BP || {};
BP.i18n = (function(){
  const t = {
    fr: { added:'Article ajouté au panier', remove:'Supprimé du panier' },
    nl: { added:'Artikel aan winkelwagen toegevoegd', remove:'Verwijderd uit winkelwagen' }
  };
  function lang(){ return document.documentElement.lang?.slice(0,2) || 'fr'; }
  function __(key){ const L=lang(); return (t[L]&&t[L][key]) || (t.fr[key]||key); }
  return { __, lang };
})();